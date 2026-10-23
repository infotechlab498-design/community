using Community.Api.DTOs.WaterSupply;
using Community.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/water-supply")]
[Authorize(Roles = "Admin")]
public sealed class AdminWaterSupplyController(
    WaterSupplyService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<WaterSupplyMonthDto>> GetMonth(
        [FromQuery] int year,
        [FromQuery] int month,
        CancellationToken ct)
    {
        if (year is < 2020 or > 2100 || month is < 1 or > 12)
            return BadRequest(new { message = "Invalid year or month." });

        var result = await service.GetMonthAsync(
            year, month, includeDraft: true, ct);

        if (result is null)
            return NotFound(new { message = "No schedule exists for this month." });

        return Ok(result);
    }

    [HttpPut]
    public async Task<IActionResult> SaveDraft(
        [FromQuery] int year,
        [FromQuery] int month,
        [FromBody] SaveWaterSupplyMonthRequest request,
        CancellationToken ct)
    {
        if (year != request.Year || month != request.Month)
            return BadRequest(new {
                message = "Query year/month must match the request body."
            });

        try
        {
            await service.SaveDraftAsync(request, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPost("publish")]
    public async Task<IActionResult> Publish(
        [FromBody] PublishWaterSupplyMonthRequest request,
        CancellationToken ct)
    {
        try
        {
            var published = await service.PublishAsync(
                request.Year, request.Month, ct);

            return published
                ? NoContent()
                : NotFound(new { message = "Save a draft before publishing." });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPost("unpublish")]
    public async Task<IActionResult> Unpublish(
        [FromBody] PublishWaterSupplyMonthRequest request,
        CancellationToken ct)
    {
        var changed = await service.UnpublishAsync(
            request.Year, request.Month, ct);

        return changed
            ? NoContent()
            : NotFound(new { message = "Schedule not found." });
    }
}