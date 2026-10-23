namespace Community.Api.Models.WaterSupply;

public sealed class WaterSupplyBlock
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public ICollection<WaterSupplyDayBlock> DayAssignments { get; set; }
        = new List<WaterSupplyDayBlock>();
}