namespace Community.Api.Models;

public class ShuttleRoute
{
    // Stable slug used by the app, e.g. "lillyA" or "mainGate".
    public required string Id { get; set; }

    public required string Origin { get; set; }

    public required string Destination { get; set; }

    public int SortOrder { get; set; }

    public ICollection<ShuttleDeparture> Departures { get; set; }
        = new List<ShuttleDeparture>();
}

public class ShuttleDeparture
{
    public int Id { get; set; }

    public required string RouteId { get; set; }

    // 24-hour "HH:mm".
    public required string Time { get; set; }

    public int SortOrder { get; set; }

    public ShuttleRoute Route { get; set; } = null!;
}
