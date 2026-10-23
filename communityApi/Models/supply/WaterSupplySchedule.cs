namespace Community.Api.Models.WaterSupply;

public sealed class WaterSupplySchedule
{
    public int Id { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }

    // Draft schedules are invisible to the resident API.
    public bool IsPublished { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateTime? PublishedAtUtc { get; set; }

    public ICollection<WaterSupplyDay> Days { get; set; }
        = new List<WaterSupplyDay>();
}