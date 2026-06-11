using HrkDemo.Data;
using HrkDemo.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString = DatabaseConnection.Resolve(builder.Configuration);
builder.Services.AddDbContext<HrkDbContext>(options => options.UseSqlServer(connectionString));
builder.Services.AddScoped<InvoiceService>();
builder.Services.AddControllersWithViews();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<HrkDbContext>();
    await db.Database.MigrateAsync();
    await SeedData.InitializeAsync(db);
}

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/invoices");
    app.UseHsts();
}

app.UseRouting();
app.MapControllers();

app.MapGet("/api/invoices/unpaid", async (InvoiceService service, CancellationToken cancellationToken) =>
    Results.Ok(await service.GetUnpaidInvoicesAsync(cancellationToken)));

app.MapPost("/api/invoices/{id:int}/payments", async (
    int id,
    PaymentRequest request,
    InvoiceService service,
    CancellationToken cancellationToken) =>
{
    try
    {
        var result = await service.CreatePaymentAsync(
            id,
            request.Amount,
            request.Method ?? "transfer",
            cancellationToken);

        return Results.Ok(result);
    }
    catch (InvalidOperationException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
});

app.MapGet("/", () => Results.Redirect("/invoices"));

app.Run();

public record PaymentRequest(decimal Amount, string? Method);
