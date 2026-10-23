using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/gym-sessions")]
[Authorize(Roles = "Admin")]
public sealed class AdminGymSessionsController(ApplicationDbContext context) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<GymSessionDto>> Create(
        [FromBody] SaveGymSessionRequest request,
        CancellationToken ct)
    {
        var session = new GymSession
        {
            Title = request.Title.Trim(),
            Audience = request.Audience,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            SortOrder = request.SortOrder,
        };

        context.GymSessions.Add(session);
        await context.SaveChangesAsync(ct);

        return Created($"/api/gym-sessions/{session.Id}", GymSessionDto.From(session));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<GymSessionDto>> Update(
        int id,
        [FromBody] SaveGymSessionRequest request,
        CancellationToken ct)
    {
        var session = await context.GymSessions.FindAsync([id], ct);
        if (session is null)
            return NotFound(new { message = "Gym session not found." });

        session.Title = request.Title.Trim();
        session.Audience = request.Audience;
        session.StartTime = request.StartTime;
        session.EndTime = request.EndTime;
        session.SortOrder = request.SortOrder;

        await context.SaveChangesAsync(ct);

        return Ok(GymSessionDto.From(session));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        var session = await context.GymSessions.FindAsync([id], ct);
        if (session is null)
            return NotFound(new { message = "Gym session not found." });

        context.GymSessions.Remove(session);
        await context.SaveChangesAsync(ct);

        return NoContent();
    }
}
