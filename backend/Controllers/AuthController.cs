using Microsoft.AspNetCore.Mvc;
using MarketingTaskAPI.Services;
using MarketingTaskAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;

namespace MarketingTaskAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] AuthLoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }



            try
            {
                var user = await _authService.AuthenticateAsync(request.Username, request.Password);
                if (user == null)
                {
                    return Unauthorized(new { error = "Invalid username or password." });
                }

                var token = _authService.GenerateJwtToken(user);

                return Ok(new
                {
                    token,
                    user = new
                    {
                        user.UserId,
                        user.Username,
                        user.Role,
                        user.EmployeeId
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for {Username}", request.Username);
                throw; // Let middleware handle detailed response in development
            }
        }

        [HttpPost("validate")]
        public async Task<ActionResult> ValidateToken([FromBody] string token)
        {
            var isValid = await _authService.ValidateTokenAsync(token);
            if (!isValid)
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            return Ok(new { message = "Token is valid" });
        }
    }
}
