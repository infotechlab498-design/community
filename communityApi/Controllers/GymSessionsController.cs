using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/gym-sessions")]
public sealed class GymSessionsController(ApplicationDbContext context) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<List<GymSessionDto>>> GetSessions(
        CancellationToken ct)
    {
        var sessions = await context.GymSessions
            .AsNoTracking()
            .OrderBy(x => x.SortOrder)
            .ThenBy(x => x.StartTime)
            .ToListAsync(ct);

        return Ok(sessions.Select(GymSessionDto.From).ToList());
    }
}
