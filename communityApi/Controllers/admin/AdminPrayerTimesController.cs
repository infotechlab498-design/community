using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/prayer-times")]
[Authorize(Roles = "Admin")]
public sealed class AdminPrayerTimesController(ApplicationDbContext context) : ControllerBase
{
    [HttpPut]
    public async Task<ActionResult<List<PrayerTimeDto>>> UpdatePrayerTimes(
        [FromBody] UpdatePrayerTimesRequest request,
        CancellationToken ct)
    {
        var prayers = await context.PrayerTimes.ToListAsync(ct);
        var byId = prayers.ToDictionary(x => x.Id);

        var unknown = request.Prayers.FirstOrDefault(p => !byId.ContainsKey(p.Id));
        if (unknown is not null)
            return NotFound(new { message = $"Prayer {unknown.Id} was not found." });

        foreach (var input in request.Prayers)
            byId[input.Id].Time = input.Time;

        await context.SaveChangesAsync(ct);

        return Ok(prayers
            .OrderBy(x => x.SortOrder)
            .Select(PrayerTimeDto.From)
            .ToList());
    }
}
