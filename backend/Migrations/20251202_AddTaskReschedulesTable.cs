using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MarketingTaskAPI.Migrations
{
    public partial class AddTaskReschedulesTable : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TaskReschedules",
                columns: table => new
                {
                    RescheduleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TaskId = table.Column<int>(type: "int", nullable: false),
                    OriginalTaskDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    OriginalDeadline = table.Column<DateTime>(type: "datetime2", nullable: false),
                    NewTaskDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    NewDeadline = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RescheduleReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    RescheduledByUserId = table.Column<int>(type: "int", nullable: false),
                    RescheduledAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaskReschedules", x => x.RescheduleId);
                    table.ForeignKey(
                        name: "FK_TaskReschedules_Tasks_TaskId",
                        column: x => x.TaskId,
                        principalTable: "Tasks",
                        principalColumn: "TaskId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TaskReschedules_Users_RescheduledByUserId",
                        column: x => x.RescheduledByUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_TaskReschedules_TaskId",
                table: "TaskReschedules",
                column: "TaskId");

            migrationBuilder.CreateIndex(
                name: "IX_TaskReschedules_RescheduledByUserId",
                table: "TaskReschedules",
                column: "RescheduledByUserId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaskReschedules");
        }
    }
}
