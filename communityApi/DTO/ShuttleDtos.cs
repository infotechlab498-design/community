using System.ComponentModel.DataAnnotations;
using Community.Api.Models;

namespace Community.Api.DTOs;

public sealed record ShuttleDepartureDto(int Id, string Time);

public sealed record ShuttleRouteDto(
    string Id,
    string Origin,
    string Destination,
    IReadOnlyList<ShuttleDepartureDto> Departures)
{
    public static ShuttleRouteDto From(ShuttleRoute route) =>
        new(
            route.Id,
            route.Origin,
            route.Destination,
            route.Departures
                .OrderBy(d => d.SortOrder)
                .Select(d => new ShuttleDepartureDto(d.Id, d.Time))
                .ToList());
}

public sealed class UpdateShuttleRouteRequest : IValidatableObject
{
    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Origin { get; init; } = "";

    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Destination { get; init; } = "";

    [Required]
    [MinLength(1)]
    [MaxLength(60)]
    public List<string> Times { get; init; } = [];

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (Times.Any(time => !TimeOfDayFormat.IsValid(time)))
        {
            yield return new ValidationResult(
                TimeOfDayFormat.ErrorMessage,
                [nameof(Times)]);
            yield break;
        }

        if (Times.Distinct().Count() != Times.Count)
        {
            yield return new ValidationResult(
                "Departure times must be unique.",
                [nameof(Times)]);
        }
    }
}
