using System.ComponentModel.DataAnnotations;
using Community.Api.Models;

namespace Community.Api.DTOs;

public sealed record ContactDto(
    int Id,
    string Category,
    string Name,
    string? Description,
    string? PhoneNumber,
    string? SecondaryNumber,
    int SortOrder)
{
    public static ContactDto From(Contact entity) =>
        new(
            entity.Id,
            entity.Category,
            entity.Name,
            entity.Description,
            entity.PhoneNumber,
            entity.SecondaryNumber,
            entity.SortOrder);
}

public sealed class SaveContactRequest
{
    public const string PhonePattern = @"^[0-9+\-\s()]{3,30}$";

    [Required]
    [RegularExpression(
        "^(Emergency|Security|Maintenance|Water|Shuttle)$",
        ErrorMessage = "Category must be Emergency, Security, Maintenance, Water, or Shuttle.")]
    public string Category { get; init; } = "";

    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Name { get; init; } = "";

    [StringLength(200)]
    public string? Description { get; init; }

    [RegularExpression(PhonePattern, ErrorMessage = "Phone number may contain only digits, spaces, +, -, and brackets.")]
    public string? PhoneNumber { get; init; }

    [RegularExpression(PhonePattern, ErrorMessage = "Phone number may contain only digits, spaces, +, -, and brackets.")]
    public string? SecondaryNumber { get; init; }

    [Range(0, 1000)]
    public int SortOrder { get; init; }

    public void ApplyTo(Contact entity)
    {
        entity.Category = Category;
        entity.Name = Name.Trim();
        entity.Description = Normalize(Description);
        entity.PhoneNumber = Normalize(PhoneNumber);
        entity.SecondaryNumber = Normalize(SecondaryNumber);
        entity.SortOrder = SortOrder;
    }

    private static string? Normalize(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
