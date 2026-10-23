using System.ComponentModel.DataAnnotations;

namespace Community.Api.DTOs.WaterSupply;

public sealed class SaveWaterSupplyMonthRequest : IValidatableObject
{
    [Range(2020, 2100)]
    public int Year { get; init; }

    [Range(1, 12)]
    public int Month { get; init; }

    [Required]
    public List<SaveWaterSupplyDayDto> Days { get; init; } = [];

    public IEnumerable<ValidationResult> Validate(
        ValidationContext validationContext)
    {
        if (Year is < 2020 or > 2100 || Month is < 1 or > 12)
            yield break;

        var daysInMonth = DateTime.DaysInMonth(Year, Month);

        if (Days.Count != daysInMonth)
        {
            yield return new ValidationResult(
                $"Exactly {daysInMonth} dates are required.",
                [nameof(Days)]);
            yield break;
        }

        var dates = new HashSet<DateOnly>();

        foreach (var day in Days)
        {
            if (day.Date.Year != Year || day.Date.Month != Month)
            {
                yield return new ValidationResult(
                    "Every date must belong to the selected month.",
                    [nameof(Days)]);
            }

            if (!dates.Add(day.Date))
            {
                yield return new ValidationResult(
                    "Duplicate dates are not allowed.",
                    [nameof(Days)]);
            }

            if (day.ActiveBlockIds is null ||
                day.ActiveBlockIds.Any(string.IsNullOrWhiteSpace) ||
                day.ActiveBlockIds.Distinct(
                    StringComparer.OrdinalIgnoreCase).Count()
                    != day.ActiveBlockIds.Count)
            {
                yield return new ValidationResult(
                    $"Block assignments for {day.Date} are invalid.",
                    [nameof(Days)]);
            }
        }

        if (dates.Count == daysInMonth)
        {
            for (var number = 1; number <= daysInMonth; number++)
            {
                if (!dates.Contains(new DateOnly(Year, Month, number)))
                {
                    yield return new ValidationResult(
                        "Every calendar date must be included.",
                        [nameof(Days)]);
                    break;
                }
            }
        }
    }
}

public sealed class SaveWaterSupplyDayDto
{
    public DateOnly Date { get; init; }

    public List<string> ActiveBlockIds { get; init; } = [];
}