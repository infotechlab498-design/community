namespace Community.Api.Models;

public class Hospital
{
    public int Id { get; set; }

    public required string Name { get; set; }

    public required string Address { get; set; }

    public double Latitude { get; set; }

    public double Longitude { get; set; }

    public int SortOrder { get; set; }
}
