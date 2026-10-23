using System.ComponentModel.DataAnnotations;
using Community.Api.Models;

namespace Community.Api.DTOs;

public sealed record PrayerTimeDto(int Id, string Name, string Time, int SortOrder)
{
    public static PrayerTimeDto From(PrayerTime entity) =>
        new(entity.Id, entity.Name, entity.Time, entity.SortOrder);
}

public sealed class UpdatePrayerTimesRequest : IValidatableObject
{
    [Required]
    [MinLength(1)]
    public List<PrayerTimeInput> Prayers { get; init; } = [];

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (Prayers.Select(p => p.Id).Distinct().Count() != Prayers.Count)
        {
            yield return new ValidationResult(
                "Each prayer may appear only once.",
                [nameof(Prayers)]);
        }
    }
}

public sealed class PrayerTimeInput
{
    [Range(1, 6)]
    public int Id { get; init; }

    [Required]
    [RegularExpression(TimeOfDayFormat.Pattern, ErrorMessage = TimeOfDayFormat.ErrorMessage)]
    public string Time { get; init; } = "";
}
