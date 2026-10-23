
using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/water-schedule")]
public class WaterScheduleController(
    ApplicationDbContext context) : ControllerBase
{
    // Public app: anyone can read the current schedule.
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<IEnumerable<WaterSchedule>>> GetSchedule(
        CancellationToken cancellationToken)
    {
        var schedule = await context.WaterSchedules
            .AsNoTracking()
            .OrderBy(x => x.Id == 0 ? 7 : x.Id)
            .ToListAsync(cancellationToken);

        return Ok(schedule);
    }

    // Admin only: update one day's timing and status.
    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<WaterSchedule>> UpdateSchedule(
        int id,
        [FromBody] UpdateWaterScheduleRequest request,
        CancellationToken cancellationToken)
    {
        if (id < 0 || id > 6)
        {
            return BadRequest(new
            {
                message = "Day ID must be between 0 and 6."
            });
        }

        var item = await context.WaterSchedules
            .SingleOrDefaultAsync(
                x => x.Id == id,
                cancellationToken);

        if (item is null)
        {
            return NotFound(new
            {
                message = "Water schedule entry was not found."
            });
        }

        item.Time = request.Time.Trim();
        item.Status = request.Status;

        await context.SaveChangesAsync(cancellationToken);

        return Ok(item);
    }
}
