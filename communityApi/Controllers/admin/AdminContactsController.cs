using Community.Api.Data;
using Community.Api.DTOs;
using Community.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Community.Api.Controllers.Admin;

[ApiController]
[Route("api/admin/contacts")]
[Authorize(Roles = "Admin")]
public sealed class AdminContactsController(ApplicationDbContext context) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<ContactDto>> Create(
        [FromBody] SaveContactRequest request,
        CancellationToken ct)
    {
        var contact = new Contact { Category = "", Name = "" };
        request.ApplyTo(contact);

        context.Contacts.Add(contact);
        await context.SaveChangesAsync(ct);

        return Created($"/api/contacts/{contact.Id}", ContactDto.From(contact));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<ContactDto>> Update(
        int id,
        [FromBody] SaveContactRequest request,
        CancellationToken ct)
    {
        var contact = await context.Contacts.FindAsync([id], ct);
        if (contact is null)
            return NotFound(new { message = "Contact not found." });

        request.ApplyTo(contact);
        await context.SaveChangesAsync(ct);

        return Ok(ContactDto.From(contact));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        var contact = await context.Contacts.FindAsync([id], ct);
        if (contact is null)
            return NotFound(new { message = "Contact not found." });

        context.Contacts.Remove(contact);
        await context.SaveChangesAsync(ct);

        return NoContent();
    }
}
