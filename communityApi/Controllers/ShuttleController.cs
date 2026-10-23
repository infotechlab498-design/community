using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/shuttle")]
public sealed class ShuttleController(ApplicationDbContext context) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<List<ShuttleRouteDto>>> GetRoutes(
        CancellationToken ct)
    {
        var routes = await context.ShuttleRoutes
            .AsNoTracking()
            .Include(x => x.Departures)
            .OrderBy(x => x.SortOrder)
            .ToListAsync(ct);

        return Ok(routes.Select(ShuttleRouteDto.From).ToList());
    }
}
