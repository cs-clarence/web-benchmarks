using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dapper;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("Default");


// Configure the database context with EF Core and a connection string
builder.Services.AddDbContextPool<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

app.MapGet("/users",
    async (AppDbContext dbContext) =>
    {
        var dbConnection = dbContext.Database.GetDbConnection();
        var users = await dbConnection.QueryAsync<UserDto>(
            """
            SELECT
                user_name AS UserName,
                email_address AS EmailAddress,
                first_name AS FirstName,
                last_name AS LastName
            FROM users
            """);

        return Results.Ok(users);
    });

app.MapGet("/factorial/{n}",
    (ulong n) =>
        Task.FromResult(Results.Ok(Factorial(n))));


app.Run();
return;

ulong Factorial(ulong n)
{
    if (n == 0)
    {
        return 1;
    }

    return n * Factorial(n - 1);
}

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

public record UserDto
{
    public string UserName { get; set; }
    public string EmailAddress { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}