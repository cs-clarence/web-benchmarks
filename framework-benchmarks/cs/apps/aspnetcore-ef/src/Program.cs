using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("Default");

// Configure the database context with EF Core and a connection string
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

app.MapGet("/users",
    async (AppDbContext dbContext, CancellationToken cancellationToken) =>
    {
        var users = await dbContext.Users
            .Select(user => new
            {
                user.UserName,
                user.EmailAddress,
                user.FirstName,
                user.LastName
            })
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        return Results.Ok(users);
    });

app.Run();

public class AppDbContext(DbContextOptions<AppDbContext> options)
    : DbContext(options)
{
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var userBuilder = modelBuilder.Entity<User>();

        userBuilder.ToTable("users");
        userBuilder.Property(user => user.UserName).HasColumnName("user_name");
        userBuilder.Property(user => user.EmailAddress)
            .HasColumnName("email_address");
        userBuilder.Property(user => user.FirstName)
            .HasColumnName("first_name");
        userBuilder.Property(user => user.LastName).HasColumnName("last_name");

        base.OnModelCreating(modelBuilder);
    }
}

public class User
{
    public int Id { get; set; }
    public string UserName { get; set; }
    public string EmailAddress { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}