namespace Community.Api.Models;

public class Contact
{
    public int Id { get; set; }

    // Allowed values: Emergency, Security, Maintenance, Water, Shuttle.
    public required string Category { get; set; }

    public required string Name { get; set; }

    public string? Description { get; set; }

    // Null while a number is still being arranged.
    public string? PhoneNumber { get; set; }

    public string? SecondaryNumber { get; set; }

    public int SortOrder { get; set; }
}
