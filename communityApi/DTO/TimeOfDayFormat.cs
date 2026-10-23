namespace Community.Api.DTOs;

public static class TimeOfDayFormat
{
    public const string Pattern = "^([01][0-9]|2[0-3]):[0-5][0-9]$";

    public const string ErrorMessage = "Time must use 24-hour HH:mm format.";

    public static bool IsValid(string? value) =>
        value is not null &&
        System.Text.RegularExpressions.Regex.IsMatch(value, Pattern);

    public static int ToMinutes(string value) =>
        int.Parse(value[..2]) * 60 + int.Parse(value[3..]);
}
