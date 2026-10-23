
namespace Community.Api.DTOs;

public class AdminLoginResponse
{
    public string Token { get; set; } = string.Empty;

    public DateTime ExpiresAtUtc { get; set; }

    public int AdminId { get; set; }

    public string Email { get; set; } = string.Empty;
}
