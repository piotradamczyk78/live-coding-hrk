using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace HrkDemo.Data;

public sealed class HrkDbContextFactory : IDesignTimeDbContextFactory<HrkDbContext>
{
    public HrkDbContext CreateDbContext(string[] args)
    {
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false)
            .AddJsonFile("appsettings.Development.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        var optionsBuilder = new DbContextOptionsBuilder<HrkDbContext>();
        optionsBuilder.UseSqlServer(DatabaseConnection.Resolve(configuration));

        return new HrkDbContext(optionsBuilder.Options);
    }
}
