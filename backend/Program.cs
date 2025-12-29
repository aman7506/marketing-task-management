using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MarketingTaskAPI.Data;
using MarketingTaskAPI.Services;
using MarketingTaskAPI.Hubs;
using MarketingForm.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Net.Sockets;
using System.IO;
using System.Linq;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// IMPORTANT: Use environment variable PORT for production, 5005 for local development
// Frontend `environment.ts` is configured to use http://localhost:5005 for local dev
// Production will use the PORT environment variable (set by hosting platform like Render)
var selectedPort = Environment.GetEnvironmentVariable("PORT") != null 
    ? int.Parse(Environment.GetEnvironmentVariable("PORT")!) 
    : 5005;
builder.Configuration["Hosting:SelectedPort"] = selectedPort.ToString();

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(selectedPort);
});

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // ✅ CRITICAL: Allow camelCase from Angular to map to PascalCase in C# models
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
        Console.WriteLine("✅ JSON PropertyNameCaseInsensitive = TRUE");
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add SignalR with CORS support
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
});

var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection.GetValue<string>("Key") ?? throw new InvalidOperationException("JWT Key missing in configuration.");
var jwtIssuer = jwtSection.GetValue<string>("Issuer");
var jwtAudience = jwtSection.GetValue<string>("Audience");

builder.Services
    .AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.SaveToken = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.FromMinutes(1)
        };

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) &&
                    (path.StartsWithSegments("/trackingHub") || path.StartsWithSegments("/notificationHub")))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

// Add CORS with explicit origins
var allowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? Array.Empty<string>();

if (allowedOrigins.Length == 0)
{
    allowedOrigins = new[]
    {
        "http://localhost:4200",
        "http://172.1.3.201:1010"
    };
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendOrigins", policy =>
    {
        policy.WithOrigins(allowedOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Add Entity Framework
builder.Services.AddDbContext<MarketingTaskDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register services
builder.Services.AddScoped<MarketingCampaignService>();
builder.Services.AddScoped<ITaskService, TaskService>();
builder.Services.AddScoped<ITaskTypeService, TaskTypeService>();
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmployeeFeedbackService, EmployeeFeedbackService>();
builder.Services.AddScoped<ILocationService, LocationService>();
builder.Services.AddScoped<ILocationLogService, LocationLogService>();

// Add configuration
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable CORS FIRST - before HTTPS redirection to avoid preflight redirect issues
app.UseCors("FrontendOrigins");

// Disable HTTPS redirection in development to avoid CORS preflight issues
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();

app.Logger.LogInformation("MarketingTaskAPI listening on port {Port}", selectedPort);

app.UseDefaultFiles();
app.UseStaticFiles();

// Map controllers
app.MapControllers().RequireCors("FrontendOrigins");

// Map SignalR hubs with CORS support
app.MapHub<NotificationHub>("/notificationHub").RequireCors("FrontendOrigins");
app.MapHub<TrackingHub>("/trackingHub").RequireCors("FrontendOrigins");

// SPA fallback to index.html for Angular routing
app.MapFallbackToFile("index.html");

app.Run();
