
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Community.Api.Models;
using Microsoft.IdentityModel.Tokens;

namespace Community.Api.Services;

public class TokenService(IConfiguration configuration)
{
    public (string Token, DateTime ExpiresAtUtc) CreateToken(
        Admin admin)
    {
        var key = configuration["Jwt:Key"]
            ?? throw new InvalidOperationException(
                "JWT signing key is not configured.");

        var issuer = configuration["Jwt:Issuer"]
            ?? throw new InvalidOperationException(
                "JWT issuer is not configured.");

        var audience = configuration["Jwt:Audience"]
            ?? throw new InvalidOperationException(
                "JWT audience is not configured.");

        var expiresAt = DateTime.UtcNow.AddMinutes(30);

        var claims = new[]
        {
            new Claim(
                ClaimTypes.NameIdentifier,
                admin.Id.ToString()),

            new Claim(ClaimTypes.Email, admin.Email),

            new Claim(ClaimTypes.Role, "Admin")
        };

        var signingKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(key));

        var credentials = new SigningCredentials(
            signingKey,
            SecurityAlgorithms.HmacSha256);

        var jwt = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: expiresAt,
            signingCredentials: credentials);

        return (
            new JwtSecurityTokenHandler().WriteToken(jwt),
            expiresAt
        );
    }
}
