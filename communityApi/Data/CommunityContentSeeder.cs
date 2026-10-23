using Community.Api.Models;
using Community.Api.Models.WaterSupply;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Data;

// Seeds each table from the values the app previously hard-coded,
// but only while that table is still empty so admin edits are never overwritten.
public static class CommunityContentSeeder
{
    public static async Task SeedAsync(ApplicationDbContext db, ILogger logger)
    {
        await SeedPrayerTimesAsync(db, logger);
        await SeedShuttleAsync(db, logger);
        await SeedGymSessionsAsync(db, logger);
        await SeedContactsAsync(db, logger);
        await SeedHospitalsAsync(db, logger);
        await SeedWaterSupplyScheduleAsync(db, logger);
    }

    private static async Task SeedPrayerTimesAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.PrayerTimes.AnyAsync())
            return;

        db.PrayerTimes.AddRange(
            new PrayerTime { Id = 1, Name = "Fajr", Time = "04:17", SortOrder = 1 },
            new PrayerTime { Id = 2, Name = "Dhuhr", Time = "12:30", SortOrder = 2 },
            new PrayerTime { Id = 3, Name = "Asr", Time = "15:45", SortOrder = 3 },
            new PrayerTime { Id = 4, Name = "Maghrib", Time = "18:15", SortOrder = 4 },
            new PrayerTime { Id = 5, Name = "Isha", Time = "20:00", SortOrder = 5 },
            new PrayerTime { Id = 6, Name = "Jummah", Time = "13:30", SortOrder = 6 });

        await db.SaveChangesAsync();
        logger.LogInformation("Seeded prayer times.");
    }

    private static async Task SeedShuttleAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.ShuttleRoutes.AnyAsync())
            return;

        string[] fromLillyA =
        [
            "07:30", "08:00", "09:00", "10:00", "11:00", "12:00", "14:15",
            "15:00", "16:00", "17:15", "18:15", "19:15", "20:00"
        ];
        string[] fromMainGate =
        [
            "07:45", "08:30", "09:30", "10:30", "11:30", "12:30", "14:45",
            "15:30", "16:30", "17:45", "18:45", "19:30", "20:30"
        ];

        db.ShuttleRoutes.AddRange(
            BuildRoute("lillyA", "Lilly A", "Main Gate", 1, fromLillyA),
            BuildRoute("mainGate", "Main Gate", "Lilly A", 2, fromMainGate));

        await db.SaveChangesAsync();
        logger.LogInformation("Seeded shuttle routes.");
    }

    private static ShuttleRoute BuildRoute(
        string id,
        string origin,
        string destination,
        int sortOrder,
        string[] times) =>
        new()
        {
            Id = id,
            Origin = origin,
            Destination = destination,
            SortOrder = sortOrder,
            Departures = times
                .Select((time, index) => new ShuttleDeparture
                {
                    RouteId = id,
                    Time = time,
                    SortOrder = index,
                })
                .ToList(),
        };

    private static async Task SeedGymSessionsAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.GymSessions.AnyAsync())
            return;

        db.GymSessions.AddRange(
            new GymSession { Title = "Male Morning", Audience = "Male", StartTime = "10:00", EndTime = "12:00", SortOrder = 1 },
            new GymSession { Title = "Female Evening", Audience = "Female", StartTime = "17:00", EndTime = "19:00", SortOrder = 2 },
            new GymSession { Title = "Male Night", Audience = "Male", StartTime = "19:00", EndTime = "21:00", SortOrder = 3 });

        await db.SaveChangesAsync();
        logger.LogInformation("Seeded gym sessions.");
    }

    private static async Task SeedContactsAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.Contacts.AnyAsync())
            return;

        db.Contacts.AddRange(
            new Contact { Category = "Emergency", Name = "Fire Department", PhoneNumber = "1122", SortOrder = 1 },
            new Contact { Category = "Emergency", Name = "Medical Emergency", PhoneNumber = "0312-5899363", SecondaryNumber = "051-111555400", SortOrder = 2 },
            new Contact { Category = "Emergency", Name = "Police Dispatch", PhoneNumber = "0311-7773997", SortOrder = 3 },
            new Contact { Category = "Emergency", Name = "QRF", PhoneNumber = "0333-5679476", SortOrder = 4 },
            new Contact { Category = "Emergency", Name = "Fire Fighting Supervisor", PhoneNumber = "0301-2332885", SortOrder = 5 },
            new Contact { Category = "Emergency", Name = "Fire Brigade", PhoneNumber = "051-3570053", SortOrder = 6 },
            new Contact { Category = "Security", Name = "Community Main Gate", Description = "Updating Soon", SortOrder = 1 },
            new Contact { Category = "Security", Name = "Neighborhood Patrol", Description = "Mobile Security Unit", SortOrder = 2 },
            new Contact { Category = "Maintenance", Name = "Building Maintenance", PhoneNumber = "0311-7773997", SortOrder = 1 },
            new Contact { Category = "Maintenance", Name = "Emergency Plumbing", PhoneNumber = "0311-7773997", SortOrder = 2 },
            new Contact { Category = "Maintenance", Name = "Electrical Services", Description = "Power outages & fault repairs", SortOrder = 3 },
            new Contact { Category = "Water", Name = "Water Maintenance Team", PhoneNumber = "+92311-7773997", SortOrder = 1 },
            new Contact { Category = "Shuttle", Name = "Community Support", PhoneNumber = "0311-7773997", SortOrder = 1 });

        await db.SaveChangesAsync();
        logger.LogInformation("Seeded contacts.");
    }

    private static async Task SeedHospitalsAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.Hospitals.AnyAsync())
            return;

        db.Hospitals.AddRange(
            new Hospital { Name = "City Hospital", Address = "Islamabad", Latitude = 33.6844, Longitude = 73.0479, SortOrder = 1 },
            new Hospital { Name = "Care Medical Center", Address = "Islamabad", Latitude = 33.7000, Longitude = 73.0600, SortOrder = 2 },
            new Hospital { Name = "St. Jude Medical Center", Address = "Islamabad", Latitude = 33.6900, Longitude = 73.0550, SortOrder = 3 });

        await db.SaveChangesAsync();
        logger.LogInformation("Seeded hospitals.");
    }

    // The app shipped with a published September 2026 schedule; keep it available.
    private static async Task SeedWaterSupplyScheduleAsync(ApplicationDbContext db, ILogger logger)
    {
        if (await db.WaterSupplySchedules.AnyAsync())
            return;

        const int year = 2026;
        const int month = 9;
        var now = DateTime.UtcNow;
        var schedule = new WaterSupplySchedule
        {
            Year = year,
            Month = month,
            IsPublished = true,
            CreatedAtUtc = now,
            UpdatedAtUtc = now,
            PublishedAtUtc = now,
        };

        for (var day = 1; day <= DateTime.DaysInMonth(year, month); day++)
        {
            // The published rotation repeats every 4 days: none, C+E, B, A.
            string[] blocks = (day % 4) switch
            {
                1 => [],
                2 => ["C", "E"],
                3 => ["B"],
                _ => ["A"],
            };

            schedule.Days.Add(new WaterSupplyDay
            {
                Date = new DateTime(year, month, day, 0, 0, 0, DateTimeKind.Utc),
                BlockAssignments = blocks
                    .Select(id => new WaterSupplyDayBlock { BlockId = id })
                    .ToList(),
            });
        }

        db.WaterSupplySchedules.Add(schedule);
        await db.SaveChangesAsync();
        logger.LogInformation("Seeded published water supply schedule for {Year}-{Month}.", year, month);
    }
}
