using Community.Api.Data;
using Community.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Community.Api.Controllers;

[ApiController]
[Route("api/contacts")]
public sealed class ContactsController(ApplicationDbContext context) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<List<ContactDto>>> GetContacts(
        [FromQuery] string? category,
        CancellationToken ct)
    {
        var query = context.Contacts.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(category))
            query = query.Where(x => x.Category == category);

        var contacts = await query
            .OrderBy(x => x.Category)
            .ThenBy(x => x.SortOrder)
            .ToListAsync(ct);

        return Ok(contacts.Select(ContactDto.From).ToList());
    }
}
