namespace Community.Api.Models.WaterSupply;

public sealed class WaterSupplyDay
{
    public int Id { get; set; }
    public int ScheduleId { get; set; }

    // Always the date at midnight UTC; the value represents a calendar date.
    public DateTime Date { get; set; }

    public WaterSupplySchedule Schedule { get; set; } = null!;

    public ICollection<WaterSupplyDayBlock> BlockAssignments { get; set; }
        = new List<WaterSupplyDayBlock>();
}