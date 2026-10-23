
namespace Community.Api.Models;

public class WaterSchedule
{
    // Fixed IDs: Sunday = 0, Monday = 1, ..., Saturday = 6.
    public int Id { get; set; }

    public required string Day { get; set; }

    public required string Time { get; set; }

    // Allowed values: Open, Closed.
    public required string Status { get; set; }
}
