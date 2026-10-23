
using System.ComponentModel.DataAnnotations;

namespace Community.Api.DTOs;

public class UpdateWaterScheduleRequest
{
    [Required]
    [StringLength(150)]
    public required string Time { get; set; }

    [Required]
    [RegularExpression(
        "^(Open|Closed)$",
        ErrorMessage = "Status must be Open or Closed.")]
    public required string Status { get; set; }
}
