using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/hospitals")]
[Authorize(Roles = "Admin")]
public sealed class AdminHospitalsController(ApplicationDbContext context) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<HospitalDto>> Create(
        [FromBody] SaveHospitalRequest request,
        CancellationToken ct)
    {
        var hospital = new Hospital { Name = "", Address = "" };
        request.ApplyTo(hospital);

        context.Hospitals.Add(hospital);
        await context.SaveChangesAsync(ct);

        return Created($"/api/hospitals/{hospital.Id}", HospitalDto.From(hospital));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<HospitalDto>> Update(
        int id,
        [FromBody] SaveHospitalRequest request,
        CancellationToken ct)
    {
        var hospital = await context.Hospitals.FindAsync([id], ct);
        if (hospital is null)
            return NotFound(new { message = "Hospital not found." });

        request.ApplyTo(hospital);
        await context.SaveChangesAsync(ct);

        return Ok(HospitalDto.From(hospital));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        var hospital = await context.Hospitals.FindAsync([id], ct);
        if (hospital is null)
            return NotFound(new { message = "Hospital not found." });

        context.Hospitals.Remove(hospital);
        await context.SaveChangesAsync(ct);

        return NoContent();
    }
}
