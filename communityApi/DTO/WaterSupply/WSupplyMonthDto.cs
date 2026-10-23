namespace Community.Api.DTOs.WaterSupply;

public sealed record WaterSupplyMonthDto(
    int Year,
    int Month,
    bool IsPublished,
    DateTime? PublishedAtUtc,
    IReadOnlyList<WaterSupplyBlockDto> Blocks,
    IReadOnlyList<WaterSupplyDayDto> Days);

public sealed record WaterSupplyDayDto(
    DateOnly Date,
    IReadOnlyList<string> ActiveBlockIds);