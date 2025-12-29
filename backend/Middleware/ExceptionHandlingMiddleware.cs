using System.Net;
using System.Text.Json;

namespace MarketingTaskAPI.Middleware
{
    public class ExceptionHandlingMiddleware : IMiddleware
    {
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;
        private readonly IWebHostEnvironment _env;

        public ExceptionHandlingMiddleware(ILogger<ExceptionHandlingMiddleware> logger, IWebHostEnvironment env)
        {
            _logger = logger;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context, RequestDelegate next)
        {
            try
            {
                await next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unhandled exception occurred.");
                
                var response = context.Response;
                response.ContentType = "application/json";
                response.StatusCode = (int)HttpStatusCode.InternalServerError;

                var errorResponse = new
                {
                    Message = _env.IsDevelopment() 
                        ? ex.Message 
                        : "An internal server error occurred.",
                    DetailedError = _env.IsDevelopment()
                        ? new
                        {
                            StackTrace = ex.StackTrace,
                            Source = ex.Source,
                            InnerException = ex.InnerException?.Message
                        }
                        : null
                };

                var json = JsonSerializer.Serialize(errorResponse);
                await response.WriteAsync(json);
            }
        }
    }
}