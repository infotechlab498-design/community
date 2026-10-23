using System.ComponentModel.DataAnnotations;

namespace Community.Api.DTOs.WaterSupply;

public sealed class PublishWaterSupplyMonthRequest
{
    [Range(2020, 2100)]
    public int Year { get; init; }

    [Range(1, 12)]
    public int Month { get; init; }
}