using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace communityApi.Migrations
{
    /// <inheritdoc />
    public partial class AddCommunityContent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Contacts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Category = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    SecondaryNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Contacts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "GymSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Audience = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    StartTime = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: false),
                    EndTime = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GymSessions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Hospitals",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Address = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Latitude = table.Column<double>(type: "float", nullable: false),
                    Longitude = table.Column<double>(type: "float", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Hospitals", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PrayerTimes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Time = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PrayerTimes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ShuttleRoutes",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Origin = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Destination = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ShuttleRoutes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WaterSupplyBlocks",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WaterSupplyBlocks", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WaterSupplySchedules",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Year = table.Column<int>(type: "int", nullable: false),
                    Month = table.Column<int>(type: "int", nullable: false),
                    IsPublished = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PublishedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WaterSupplySchedules", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ShuttleDepartures",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RouteId = table.Column<string>(type: "nvarchar(30)", nullable: false),
                    Time = table.Column<string>(type: "nvarchar(5)", maxLength: 5, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ShuttleDepartures", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ShuttleDepartures_ShuttleRoutes_RouteId",
                        column: x => x.RouteId,
                        principalTable: "ShuttleRoutes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WaterSupplyDays",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ScheduleId = table.Column<int>(type: "int", nullable: false),
                    Date = table.Column<DateTime>(type: "date", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WaterSupplyDays", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WaterSupplyDays_WaterSupplySchedules_ScheduleId",
                        column: x => x.ScheduleId,
                        principalTable: "WaterSupplySchedules",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WaterSupplyDayBlocks",
                columns: table => new
                {
                    WaterSupplyDayId = table.Column<int>(type: "int", nullable: false),
                    BlockId = table.Column<string>(type: "nvarchar(10)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WaterSupplyDayBlocks", x => new { x.WaterSupplyDayId, x.BlockId });
                    table.ForeignKey(
                        name: "FK_WaterSupplyDayBlocks_WaterSupplyBlocks_BlockId",
                        column: x => x.BlockId,
                        principalTable: "WaterSupplyBlocks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_WaterSupplyDayBlocks_WaterSupplyDays_WaterSupplyDayId",
                        column: x => x.WaterSupplyDayId,
                        principalTable: "WaterSupplyDays",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PrayerTimes_Name",
                table: "PrayerTimes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ShuttleDepartures_RouteId",
                table: "ShuttleDepartures",
                column: "RouteId");

            migrationBuilder.CreateIndex(
                name: "IX_WaterSupplyDayBlocks_BlockId",
                table: "WaterSupplyDayBlocks",
                column: "BlockId");

            migrationBuilder.CreateIndex(
                name: "IX_WaterSupplyDays_ScheduleId_Date",
                table: "WaterSupplyDays",
                columns: new[] { "ScheduleId", "Date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WaterSupplySchedules_Year_Month",
                table: "WaterSupplySchedules",
                columns: new[] { "Year", "Month" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Contacts");

            migrationBuilder.DropTable(
                name: "GymSessions");

            migrationBuilder.DropTable(
                name: "Hospitals");

            migrationBuilder.DropTable(
                name: "PrayerTimes");

            migrationBuilder.DropTable(
                name: "ShuttleDepartures");

            migrationBuilder.DropTable(
                name: "WaterSupplyDayBlocks");

            migrationBuilder.DropTable(
                name: "ShuttleRoutes");

            migrationBuilder.DropTable(
                name: "WaterSupplyBlocks");

            migrationBuilder.DropTable(
                name: "WaterSupplyDays");

            migrationBuilder.DropTable(
                name: "WaterSupplySchedules");
        }
    }
}
