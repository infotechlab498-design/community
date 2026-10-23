
using System.Text;
using Community.Api.Data;
using Community.Api.Models;
using Community.Api.Models.WaterSupply;
using Community.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// 1. Register controllers and API documentation
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// 2. Register SQL Server database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString(
            "DefaultConnection")));

// 3. Register password hashing and JWT token services
builder.Services.AddScoped<
    IPasswordHasher<Admin>,
    PasswordHasher<Admin>>();

builder.Services.AddScoped<TokenService>();

// 4. Configure JWT authentication
var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException(
        "Configure Jwt:Key before starting the API.");

if (Encoding.UTF8.GetByteCount(jwtKey) < 32)
{
    throw new InvalidOperationException(
        "JWT signing key must contain at least 32 bytes.");
}

var jwtIssuer = builder.Configuration["Jwt:Issuer"]
    ?? throw new InvalidOperationException(
        "Configure Jwt:Issuer.");

var jwtAudience = builder.Configuration["Jwt:Audience"]
    ?? throw new InvalidOperationException(
        "Configure Jwt:Audience.");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = jwtIssuer,

                ValidateAudience = true,
                ValidAudience = jwtAudience,

                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(jwtKey)),

                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromSeconds(30)
            };
    });

builder.Services.AddAuthorization();
builder.Services.AddScoped<WaterSupplyService>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod());
});

var app = builder.Build();

// 5. Development API documentation
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// 6. Configure the HTTP request pipeline.
// HTTPS is terminated by the host (usama498.bsite.net). Redirecting again inside
// the app makes every request bounce between http and https.

if (app.Environment.IsDevelopment())
{
    app.UseCors("Frontend");
}

app.UseAuthentication();
app.UseAuthorization();


// 7. Register controller routes
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider
        .GetRequiredService<ApplicationDbContext>();

    var hasher = scope.ServiceProvider
        .GetRequiredService<IPasswordHasher<Admin>>();

    var logger = app.Logger;
    var connection = db.Database.GetDbConnection();

    logger.LogInformation(
        "Admin bootstrap is using database {Database} on {DataSource}.",
        connection.Database,
        connection.DataSource);

    var email = app.Configuration["BootstrapAdmin:Email"];
    var password = app.Configuration["BootstrapAdmin:Password"];

    if (string.IsNullOrWhiteSpace(email) ||
        string.IsNullOrWhiteSpace(password))
    {
        logger.LogWarning(
            "Bootstrap admin was not created because BootstrapAdmin:Email or BootstrapAdmin:Password is not configured.");
    }
    else
    {
        try
        {
            if (!await db.Database.CanConnectAsync())
            {
                throw new InvalidOperationException(
                    "Bootstrap admin seeding could not connect to the configured database.");
            }

            var normalizedEmail = Admin.NormalizeEmail(email);

            var exists = await db.Admins
                .AnyAsync(a => a.Email == normalizedEmail);

            if (!exists)
            {
                var admin = new Admin
                {
                    Email = normalizedEmail,
                    PasswordHash = string.Empty,
                    IsActive = true
                };

                admin.PasswordHash = hasher.HashPassword(
                    admin,
                    password);

                db.Admins.Add(admin);
                await db.SaveChangesAsync();

                logger.LogInformation(
                    "Bootstrap admin created for {Email}.",
                    normalizedEmail);
            }
            else
            {
                logger.LogInformation(
                    "Bootstrap admin already exists for {Email}.",
                    normalizedEmail);
            }
        }
        catch (DbUpdateException ex) when (IsDuplicateAdminEmail(ex))
        {
            logger.LogWarning(
                "Bootstrap admin was not inserted because that email is already stored.");
        }
        catch (Exception ex)
        {
            logger.LogError(
                ex,
                "Bootstrap admin seeding failed for database {Database} on {DataSource}.",
                connection.Database,
                connection.DataSource);
            throw;
        }
    }

    await SeedWaterScheduleAsync(db, logger);
    await SeedWaterSupplyBlocksAsync(db, logger);
    await CommunityContentSeeder.SeedAsync(db, logger);
}

static async Task SeedWaterScheduleAsync(
    ApplicationDbContext db,
    ILogger logger)
{
    WaterSchedule[] defaults =
    [
        new() { Id = 1, Day = "Monday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 2, Day = "Tuesday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 3, Day = "Wednesday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 4, Day = "Thursday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 5, Day = "Friday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 6, Day = "Saturday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" },
        new() { Id = 0, Day = "Sunday", Time = "9:00 AM – 11:00 AM & 4:00 PM - 8:00 PM", Status = "Open" }
    ];

    try
    {
        if (!await db.Database.CanConnectAsync())
        {
            throw new InvalidOperationException(
                "Water schedule seeding could not connect to the configured database.");
        }

        var existingIds = await db.WaterSchedules
            .Select(item => item.Id)
            .ToListAsync();

        var missing = defaults
            .Where(item => !existingIds.Contains(item.Id))
            .ToList();

        if (missing.Count == 0)
        {
            logger.LogInformation(
                "Water schedule already has {Count} stored days.",
                existingIds.Count);
            return;
        }

        db.WaterSchedules.AddRange(missing);
        await db.SaveChangesAsync();

        logger.LogInformation(
            "Stored {Count} water schedule days.",
            missing.Count);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Water schedule seeding failed.");
        throw;
    }
}

static async Task SeedWaterSupplyBlocksAsync(
    ApplicationDbContext db,
    ILogger logger)
{
    WaterSupplyBlock[] initialBlocks =
    [
        new() { Id = "A", Name = "Block A" },
        new() { Id = "B", Name = "Block B" },
        new() { Id = "C", Name = "Block C" },
        new() { Id = "E", Name = "Block E" }
    ];

    var existingIds = await db.WaterSupplyBlocks
        .Select(x => x.Id)
        .ToListAsync();

    var missing = initialBlocks
        .Where(block => !existingIds.Contains(block.Id))
        .ToList();

    if (missing.Count == 0)
        return;

    db.WaterSupplyBlocks.AddRange(missing);
    await db.SaveChangesAsync();

    logger.LogInformation(
        "Stored {Count} water supply blocks.",
        missing.Count);
}

static bool IsDuplicateAdminEmail(DbUpdateException exception) =>
    exception.InnerException is SqlException sqlException &&
    sqlException.Number is 2601 or 2627;

app.Run();
