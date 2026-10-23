
namespace Community.Api.Models;

public class Admin
{
    public int Id { get; set; }

    public required string Email { get; set; }

    // Store a password hash, NEVER the original password.
    public required string PasswordHash { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAtUtc { get; set; } =
        DateTime.UtcNow;

    public static string NormalizeEmail(string email) =>
        email.Trim().ToLowerInvariant();
}
