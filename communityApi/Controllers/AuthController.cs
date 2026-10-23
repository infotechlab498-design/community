
using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Community.Api.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminAccount = Community.Api.Models.Admin;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(
    ApplicationDbContext context,
    IPasswordHasher<AdminAccount> passwordHasher,
    TokenService tokenService) : ControllerBase
{
    [HttpPost("admin-login")]
    public async Task<ActionResult<AdminLoginResponse>> AdminLogin(
        [FromBody] AdminLoginRequest request)
    {
        var email = AdminAccount.NormalizeEmail(request.Email);

        var admin = await context.Admins
            .SingleOrDefaultAsync(a => a.Email == email);

        if (admin is null || !admin.IsActive)
        {
            return Unauthorized(new
            {
                message = "Invalid email or password."
            });
        }

        var verification = passwordHasher.VerifyHashedPassword(
            admin,
            admin.PasswordHash,
            request.Password);

        if (verification == PasswordVerificationResult.Failed)
        {
            return Unauthorized(new
            {
                message = "Invalid email or password."
            });
        }

        var (token, expiresAt) = tokenService.CreateToken(admin);

        return Ok(new AdminLoginResponse
        {
            Token = token,
            ExpiresAtUtc = expiresAt,
            AdminId = admin.Id,
            Email = admin.Email
        });
    }
}
