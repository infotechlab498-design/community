using System.ComponentModel.DataAnnotations;
using Community.Api.Models;

namespace Community.Api.DTOs;

public sealed record HospitalDto(
    int Id,
    string Name,
    string Address,
    double Latitude,
    double Longitude,
    int SortOrder)
{
    public static HospitalDto From(Hospital entity) =>
        new(
            entity.Id,
            entity.Name,
            entity.Address,
            entity.Latitude,
            entity.Longitude,
            entity.SortOrder);
}

public sealed class SaveHospitalRequest
{
    [Required]
    [StringLength(150, MinimumLength = 1)]
    public string Name { get; init; } = "";

    [Required]
    [StringLength(250, MinimumLength = 1)]
    public string Address { get; init; } = "";

    [Range(-90, 90)]
    public double Latitude { get; init; }

    [Range(-180, 180)]
    public double Longitude { get; init; }

    [Range(0, 1000)]
    public int SortOrder { get; init; }

    public void ApplyTo(Hospital entity)
    {
        entity.Name = Name.Trim();
        entity.Address = Address.Trim();
        entity.Latitude = Latitude;
        entity.Longitude = Longitude;
        entity.SortOrder = SortOrder;
    }
}
