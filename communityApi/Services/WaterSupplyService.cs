using Community.Api.Data;
using Community.Api.DTOs.WaterSupply;
using Community.Api.Models.WaterSupply;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Services;

public sealed class WaterSupplyService(ApplicationDbContext db)
{
    public async Task<List<WaterSupplyBlockDto>> GetBlocksAsync(
        CancellationToken ct)
    {
        return await db.WaterSupplyBlocks
            .AsNoTracking()
            .OrderBy(x => x.Id)
            .Select(x => new WaterSupplyBlockDto(x.Id, x.Name))
            .ToListAsync(ct);
    }

    public async Task<WaterSupplyMonthDto?> GetMonthAsync(
        int year,
        int month,
        bool includeDraft,
        CancellationToken ct)
    {
        var query = db.WaterSupplySchedules
            .AsNoTracking()
            .Where(x => x.Year == year && x.Month == month);

        if (!includeDraft)
            query = query.Where(x => x.IsPublished);

        var schedule = await query
            .Include(x => x.Days)
                .ThenInclude(x => x.BlockAssignments)
            .FirstOrDefaultAsync(ct);

        if (schedule is null)
            return null;

        var blocks = await GetBlocksAsync(ct);

        var days = schedule.Days
            .OrderBy(x => x.Date)
            .Select(x => new WaterSupplyDayDto(
                DateOnly.FromDateTime(x.Date),
                x.BlockAssignments
                    .Select(a => a.BlockId)
                    .OrderBy(id => id)
                    .ToList()))
            .ToList();

        return new WaterSupplyMonthDto(
            schedule.Year,
            schedule.Month,
            schedule.IsPublished,
            schedule.PublishedAtUtc,
            blocks,
            days);
    }

    public async Task SaveDraftAsync(
        SaveWaterSupplyMonthRequest request,
        CancellationToken ct)
    {
        var allowedIds = await db.WaterSupplyBlocks
            .Select(x => x.Id)
            .ToListAsync(ct);

        var allowed = allowedIds.ToHashSet(
            StringComparer.OrdinalIgnoreCase);

        foreach (var day in request.Days)
        {
            if (day.ActiveBlockIds.Any(id => !allowed.Contains(id)))
            {
                throw new InvalidOperationException(
                    "One or more block IDs do not exist.");
            }
        }

        await using var transaction =
            await db.Database.BeginTransactionAsync(ct);

        var schedule = await db.WaterSupplySchedules
            .Include(x => x.Days)
                .ThenInclude(x => x.BlockAssignments)
            .FirstOrDefaultAsync(
                x => x.Year == request.Year &&
                     x.Month == request.Month, ct);

        if (schedule?.IsPublished == true)
        {
            throw new InvalidOperationException(
                "This month is published. Unpublish it before editing.");
        }

        if (schedule is null)
        {
            schedule = new WaterSupplySchedule
            {
                Year = request.Year,
                Month = request.Month
            };
            db.WaterSupplySchedules.Add(schedule);
        }
        else
        {
            db.WaterSupplyDayBlocks.RemoveRange(
                schedule.Days.SelectMany(x => x.BlockAssignments));
            db.WaterSupplyDays.RemoveRange(schedule.Days);
        }

        foreach (var input in request.Days.OrderBy(x => x.Date))
        {
            var day = new WaterSupplyDay
            {
                Date = input.Date.ToDateTime(
                    TimeOnly.MinValue, DateTimeKind.Utc),
                BlockAssignments = input.ActiveBlockIds
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .Select(id => new WaterSupplyDayBlock
                    {
                        BlockId = allowedIds.First(
                            existing => string.Equals(
                                existing, id,
                                StringComparison.OrdinalIgnoreCase))
                    })
                    .ToList()
            };

            schedule.Days.Add(day);
        }

        schedule.UpdatedAtUtc = DateTime.UtcNow;
        schedule.IsPublished = false;
        schedule.PublishedAtUtc = null;

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);
    }

    public async Task<bool> PublishAsync(
        int year, int month, CancellationToken ct)
    {
        var schedule = await db.WaterSupplySchedules
            .Include(x => x.Days)
            .FirstOrDefaultAsync(
                x => x.Year == year && x.Month == month, ct);

        if (schedule is null)
            return false;

        var expectedDays = DateTime.DaysInMonth(year, month);

        if (schedule.Days.Count != expectedDays)
        {
            throw new InvalidOperationException(
                "Save the complete monthly calendar before publishing.");
        }

        schedule.IsPublished = true;
        schedule.PublishedAtUtc = DateTime.UtcNow;
        schedule.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<bool> UnpublishAsync(
        int year, int month, CancellationToken ct)
    {
        var schedule = await db.WaterSupplySchedules
            .FirstOrDefaultAsync(
                x => x.Year == year && x.Month == month, ct);

        if (schedule is null)
            return false;

        schedule.IsPublished = false;
        schedule.PublishedAtUtc = null;
        schedule.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return true;
    }
}