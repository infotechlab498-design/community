using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/shuttle")]
[Authorize(Roles = "Admin")]
public sealed class AdminShuttleController(ApplicationDbContext context) : ControllerBase
{
    [HttpPut("{routeId}")]
    public async Task<ActionResult<ShuttleRouteDto>> UpdateRoute(
        string routeId,
        [FromBody] UpdateShuttleRouteRequest request,
        CancellationToken ct)
    {
        var route = await context.ShuttleRoutes
            .Include(x => x.Departures)
            .FirstOrDefaultAsync(x => x.Id == routeId, ct);

        if (route is null)
            return NotFound(new { message = "Shuttle route not found." });

        route.Origin = request.Origin.Trim();
        route.Destination = request.Destination.Trim();

        context.ShuttleDepartures.RemoveRange(route.Departures);
        route.Departures = request.Times
            .OrderBy(TimeOfDayFormat.ToMinutes)
            .Select((time, index) => new ShuttleDeparture
            {
                RouteId = route.Id,
                Time = time,
                SortOrder = index,
            })
            .ToList();

        await context.SaveChangesAsync(ct);

        return Ok(ShuttleRouteDto.From(route));
    }
}
