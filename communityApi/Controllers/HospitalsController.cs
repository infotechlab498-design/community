using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/hospitals")]
public sealed class HospitalsController(ApplicationDbContext context) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<List<HospitalDto>>> GetHospitals(
        CancellationToken ct)
    {
        var hospitals = await context.Hospitals
            .AsNoTracking()
            .OrderBy(x => x.SortOrder)
            .ThenBy(x => x.Name)
            .ToListAsync(ct);

        return Ok(hospitals.Select(HospitalDto.From).ToList());
    }
}
