namespace Community.Api.Models.WaterSupply;

public sealed class WaterSupplyDayBlock
{
    public int WaterSupplyDayId { get; set; }
    public string BlockId { get; set; } = "";

    public WaterSupplyDay Day { get; set; } = null!;
    public WaterSupplyBlock Block { get; set; } = null!;
}