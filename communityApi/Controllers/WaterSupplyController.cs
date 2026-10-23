using Community.Api.DTOs.WaterSupply;
using Community.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/water-supply")]
public sealed class WaterSupplyController(
    WaterSupplyService service) : ControllerBase
{
    [HttpGet("blocks")]
    public async Task<ActionResult<List<WaterSupplyBlockDto>>> GetBlocks(
        CancellationToken ct)
    {
        return Ok(await service.GetBlocksAsync(ct));
    }

    [HttpGet("month")]
    public async Task<ActionResult<WaterSupplyMonthDto>> GetMonth(
        [FromQuery] int year,
        [FromQuery] int month,
        [FromQuery] string? blockId,
        CancellationToken ct)
    {
        if (year is < 2020 or > 2100 || month is < 1 or > 12)
            return BadRequest(new { message = "Invalid year or month." });

        var result = await service.GetMonthAsync(
            year, month, includeDraft: false, ct);

        if (result is null)
            return NotFound(new {
                message = "No published ground water schedule exists for this month."
            });

        if (!string.IsNullOrWhiteSpace(blockId) &&
            !result.Blocks.Any(b =>
                string.Equals(b.Id, blockId,
                    StringComparison.OrdinalIgnoreCase)))
        {
            return BadRequest(new { message = "Unknown block ID." });
        }

        if (!string.IsNullOrWhiteSpace(blockId))
        {
            result = result with
            {
                Days = result.Days.Select(day => day with
                {
                    ActiveBlockIds = day.ActiveBlockIds
                        .Where(id => string.Equals(
                            id, blockId,
                            StringComparison.OrdinalIgnoreCase))
                        .ToList()
                }).ToList()
            };
        }

        return Ok(result);
    }
}