namespace Community.Api.Models;

public class GymSession
{
    public int Id { get; set; }

    public required string Title { get; set; }

    // Allowed values: Male, Female.
    public required string Audience { get; set; }

    // 24-hour "HH:mm".
    public required string StartTime { get; set; }

    public required string EndTime { get; set; }

    public int SortOrder { get; set; }
}
