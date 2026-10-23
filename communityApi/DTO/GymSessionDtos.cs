using System.ComponentModel.DataAnnotations;
using Community.Api.Models;

namespace Community.Api.DTOs;

public sealed record GymSessionDto(
    int Id,
    string Title,
    string Audience,
    string StartTime,
    string EndTime,
    int SortOrder)
{
    public static GymSessionDto From(GymSession entity) =>
        new(
            entity.Id,
            entity.Title,
            entity.Audience,
            entity.StartTime,
            entity.EndTime,
            entity.SortOrder);
}

public sealed class SaveGymSessionRequest : IValidatableObject
{
    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Title { get; init; } = "";

    [Required]
    [RegularExpression("^(Male|Female)$", ErrorMessage = "Audience must be Male or Female.")]
    public string Audience { get; init; } = "";

    [Required]
    [RegularExpression(TimeOfDayFormat.Pattern, ErrorMessage = TimeOfDayFormat.ErrorMessage)]
    public string StartTime { get; init; } = "";

    [Required]
    [RegularExpression(TimeOfDayFormat.Pattern, ErrorMessage = TimeOfDayFormat.ErrorMessage)]
    public string EndTime { get; init; } = "";

    [Range(0, 1000)]
    public int SortOrder { get; init; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (TimeOfDayFormat.IsValid(StartTime) &&
            TimeOfDayFormat.IsValid(EndTime) &&
            TimeOfDayFormat.ToMinutes(EndTime) <= TimeOfDayFormat.ToMinutes(StartTime))
        {
            yield return new ValidationResult(
                "End time must be after start time.",
                [nameof(EndTime)]);
        }
    }
}
