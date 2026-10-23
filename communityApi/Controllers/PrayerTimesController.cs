using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/prayer-times")]
public sealed class PrayerTimesController(ApplicationDbContext context) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<List<PrayerTimeDto>>> GetPrayerTimes(
        CancellationToken ct)
    {
        var prayers = await context.PrayerTimes
            .AsNoTracking()
            .OrderBy(x => x.SortOrder)
            .ToListAsync(ct);

        return Ok(prayers.Select(PrayerTimeDto.From).ToList());
    }
}
