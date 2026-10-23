namespace Community.Api.Models;

public class PrayerTime
{
    // Fixed IDs: Fajr = 1, Dhuhr = 2, Asr = 3, Maghrib = 4, Isha = 5, Jummah = 6.
    public int Id { get; set; }

    public required string Name { get; set; }

    // 24-hour "HH:mm".
    public required string Time { get; set; }

    public int SortOrder { get; set; }
}
