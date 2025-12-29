# Use .NET 8 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy backend project
COPY backend/*.csproj ./
RUN dotnet restore

# Copy all backend files
COPY backend/. ./
RUN dotnet publish -c Release -o /app/publish

# Use .NET 8 runtime for final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

# Expose port
EXPOSE 8080

# Set environment variable for port
ENV ASPNETCORE_URLS=http://+:8080

# Run the application
ENTRYPOINT ["dotnet", "MarketingTaskAPI.dll"]
