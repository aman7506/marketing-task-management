using Microsoft.EntityFrameworkCore;
using MarketingTaskAPI.Models;

namespace MarketingTaskAPI.Data
{
    public class MarketingTaskDbContext : DbContext
    {
        public MarketingTaskDbContext(DbContextOptions<MarketingTaskDbContext> options)
            : base(options)
        {
        }

        // DbSets
        public DbSet<UserTask> UserTasks { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Employee> Employees { get; set; }
        public DbSet<Location> Locations { get; set; }
        public DbSet<TaskStatusHistory> TaskStatusHistories { get; set; }  // plural naming
        public DbSet<TaskReschedule> TaskReschedules { get; set; }

        // Additional DbSets for hierarchical location system
        public DbSet<State> States { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Area> Areas { get; set; }
        public DbSet<Pincode> Pincodes { get; set; }

        // TaskStatus for dropdowns
        public DbSet<TaskStatusEntity> TaskStatus { get; set; }

        // Additional DbSets for other entities
        public DbSet<TaskType> TaskTypes { get; set; }
        public DbSet<TaskTaskType> TaskTaskTypes { get; set; }
        public DbSet<TaskLocation> TaskLocations { get; set; }
        public DbSet<EmployeeFeedback> EmployeeFeedback { get; set; }
        public DbSet<LocationLog> LocationLogs { get; set; }
        
        // Alias for UserTasks to support legacy code
        public DbSet<UserTask> Tasks => UserTasks;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Remove global query filter to fix EF warnings
            // Global query filters cause warnings when related entities don't have matching filters

            // Configure UserTask entity
            modelBuilder.Entity<UserTask>(entity =>
            {
                entity.ToTable("Tasks");

                entity.HasKey(e => e.TaskId);

                entity.Property(e => e.Description)
                    .IsRequired()
                    .HasMaxLength(500);


                entity.Property(e => e.EstimatedHours)
                    .HasColumnType("decimal(6,2)");

                entity.Property(e => e.ActualHours)
                    .HasColumnType("decimal(6,2)");

                entity.Property(e => e.Priority)
                    .IsRequired()
                    .HasMaxLength(10);

                entity.Property(e => e.Status)
                    .IsRequired()
                    .HasMaxLength(20)
                    .HasDefaultValue("Not Started");

                entity.Property(e => e.TaskType)
                    .HasMaxLength(50)
                    .HasDefaultValue("General");

                entity.Property(e => e.Department)
                    .HasMaxLength(100)
                    .HasDefaultValue("Marketing");

                entity.Property(e => e.TaskCategory)
                    .HasMaxLength(50)
                    .HasDefaultValue("Field Work");

                entity.Property(e => e.CreatedAt)
                    .HasDefaultValueSql("GETUTCDATE()");

                entity.Property(e => e.UpdatedAt)
                    .HasDefaultValueSql("GETUTCDATE()");

                // No explicit column mapping needed when column name matches property
                


                // Relationships
                entity.HasOne(e => e.AssignedByUser)
                    .WithMany()
                    .HasForeignKey(e => e.AssignedByUserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.Employee)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.EmployeeId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(d => d.Location)
                    .WithMany(p => p.Tasks)
                    .HasForeignKey(d => d.LocationId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(d => d.StateNavigation)
                    .WithMany()
                    .HasForeignKey(d => d.StateId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(d => d.CityNavigation)
                    .WithMany()
                    .HasForeignKey(d => d.CityId)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(d => d.AreaNavigation)
                    .WithMany()
                    .HasForeignKey(d => d.AreaId)
                    .OnDelete(DeleteBehavior.SetNull);
            });

            // Configure TaskStatusHistory entity
            modelBuilder.Entity<TaskStatusHistory>(entity =>
            {
                entity.ToTable("TaskStatusHistories", "dbo");
                entity.HasKey(e => e.HistoryId);

                entity.Property(e => e.Status)
                    .IsRequired()
                    .HasMaxLength(20);

                entity.Property(e => e.Remarks)
                    .HasMaxLength(500);

                entity.HasOne(e => e.Task)
                    .WithMany(t => t.StatusHistory)
                    .HasForeignKey(e => e.TaskId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.ChangedByUser)
                    .WithMany()
                    .HasForeignKey(e => e.ChangedByUserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Configure TaskReschedule entity
            modelBuilder.Entity<TaskReschedule>(entity =>
            {
                entity.HasKey(e => e.RescheduleId);

                entity.Property(e => e.RescheduleReason)
                    .HasMaxLength(500);

                entity.HasOne(e => e.Task)
                    .WithMany()
                    .HasForeignKey(e => e.TaskId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.RescheduledByUser)
                    .WithMany()
                    .HasForeignKey(e => e.RescheduledByUserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Configure User entity
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.UserId);

                entity.Property(e => e.Username)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.PasswordHash)
                    .IsRequired()
                    .HasMaxLength(256);
            });

            // Configure Employee entity
            modelBuilder.Entity<Employee>(entity =>
            {
                entity.HasKey(e => e.EmployeeId);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.Contact)
                    .HasMaxLength(50);

                entity.Property(e => e.Designation)
                    .HasMaxLength(100);

                entity.Property(e => e.Email)
                    .HasMaxLength(200);

                entity.Property(e => e.EmployeeCode)
                    .HasMaxLength(50);
            });

            // Configure Location entity
            modelBuilder.Entity<Location>(entity =>
            {
                entity.ToTable("Locations");

                entity.HasKey(e => e.LocationId);

                entity.Property(e => e.LocationName)
                    .IsRequired()
                    .HasMaxLength(200);

                entity.Property(e => e.State)
                    .HasMaxLength(100);
            });

            // Configure State entity
            modelBuilder.Entity<State>(entity =>
            {
                entity.HasKey(e => e.StateId);

                entity.Property(e => e.StateName)
                    .IsRequired()
                    .HasMaxLength(100);
            });

            // Configure City entity
            modelBuilder.Entity<City>(entity =>
            {
                entity.HasKey(e => e.CityId);

                entity.Property(e => e.CityName)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.HasOne(d => d.State)
                    .WithMany(p => p.Cities)
                    .HasForeignKey(d => d.StateId)
                    .OnDelete(DeleteBehavior.ClientSetNull);
            });

            // Configure Area entity
            modelBuilder.Entity<Area>(entity =>
            {
                entity.HasKey(e => e.AreaId);

                entity.Property(e => e.AreaName)
                    .IsRequired()
                    .HasMaxLength(200);

                entity.HasOne(d => d.City)
                    .WithMany(p => p.Areas)
                    .HasForeignKey(d => d.CityId)
                    .OnDelete(DeleteBehavior.ClientSetNull);
            });

            // Configure Pincode entity
            modelBuilder.Entity<Pincode>(entity =>
            {
                entity.HasKey(e => e.PincodeId);

                entity.Property(e => e.PincodeValue)
                    .IsRequired()
                    .HasMaxLength(10);

                entity.HasOne(d => d.Area)
                    .WithMany(p => p.Pincodes)
                    .HasForeignKey(d => d.AreaId)
                    .OnDelete(DeleteBehavior.ClientSetNull);
            });

            // Configure TaskType entity
            modelBuilder.Entity<TaskType>(entity =>
            {
                entity.HasKey(e => e.TaskTypeId);

                entity.Property(e => e.TypeName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.Description)
                    .HasMaxLength(200);
            });

            // Configure TaskTaskType junction entity
            modelBuilder.Entity<TaskTaskType>(entity =>
            {
                entity.HasKey(e => e.TaskTaskTypeId);

                entity.HasOne(d => d.Task)
                    .WithMany(p => p.TaskTaskTypes)
                    .HasForeignKey(d => d.TaskId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(d => d.TaskType)
                    .WithMany(p => p.TaskTaskTypes)
                    .HasForeignKey(d => d.TaskTypeId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure TaskLocation junction entity
            modelBuilder.Entity<TaskLocation>(entity =>
            {
                entity.HasKey(e => e.TaskLocationId);

                entity.HasOne(d => d.Task)
                    .WithMany(p => p.TaskLocations)
                    .HasForeignKey(d => d.TaskId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(d => d.Location)
                    .WithMany()
                    .HasForeignKey(d => d.LocationId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure EmployeeFeedback entity
            modelBuilder.Entity<EmployeeFeedback>(entity =>
            {
                entity.HasKey(e => e.FeedbackId);

                entity.Property(e => e.Remarks)
                    .HasMaxLength(1000);

                entity.HasOne(d => d.Task)
                    .WithMany(p => p.EmployeeFeedback)
                    .HasForeignKey(d => d.TaskId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(d => d.Employee)
                    .WithMany(p => p.EmployeeFeedback)
                    .HasForeignKey(d => d.EmployeeId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<LocationLog>(entity =>
            {
                entity.HasKey(e => e.LogId);

                entity.Property(e => e.Latitude)
                    .HasColumnType("decimal(9,6)");

                entity.Property(e => e.Longitude)
                    .HasColumnType("decimal(9,6)");

                entity.Property(e => e.Timestamp)
                    .HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(e => new { e.EmployeeId, e.Timestamp });
            });

            // Seed default task statuses
            modelBuilder.Entity<TaskStatusEntity>().HasData(
                new TaskStatusEntity { StatusId = 1, StatusName = "Not Started", StatusCode = "NOT_STARTED" },
                new TaskStatusEntity { StatusId = 2, StatusName = "In Progress", StatusCode = "IN_PROGRESS" },
                new TaskStatusEntity { StatusId = 3, StatusName = "Completed", StatusCode = "COMPLETED" },
                new TaskStatusEntity { StatusId = 4, StatusName = "Postponed", StatusCode = "POSTPONED" },
                new TaskStatusEntity { StatusId = 5, StatusName = "Partial Close", StatusCode = "PARTIAL_CLOSE" }
            );

            // Seed default task types
            modelBuilder.Entity<TaskType>().HasData(
                new TaskType { TaskTypeId = 1, TypeName = "Meeting Consultant", Description = "Meeting with consultant" },
                new TaskType { TaskTypeId = 2, TypeName = "Field Work", Description = "Field work activities" },
                new TaskType { TaskTypeId = 3, TypeName = "Follow Up", Description = "Follow up activities" },
                new TaskType { TaskTypeId = 4, TypeName = "Documentation", Description = "Documentation tasks" },
                new TaskType { TaskTypeId = 5, TypeName = "Client Meeting", Description = "Client meetings and presentations" },
                new TaskType { TaskTypeId = 6, TypeName = "Training", Description = "Training and development activities" }
            );
        }
    }
}
