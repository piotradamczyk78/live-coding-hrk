var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<InvoiceService>();

var app = builder.Build();

app.MapGet("/api/invoices/unpaid", (InvoiceService service) =>
{
    return Results.Ok(service.GetUnpaidInvoices());
});

app.MapPost("/api/invoices/{id:int}/payments", (int id, PaymentRequest request, InvoiceService service) =>
{
    try
    {
        var result = service.CreatePayment(id, request.Amount, request.Method ?? "transfer");
        return Results.Ok(result);
    }
    catch (InvalidOperationException ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
});

app.Run();

public record PaymentRequest(decimal Amount, string? Method);

public sealed class InvoiceService
{
    private readonly List<Invoice> _invoices =
    [
        new(1, "FV/2026/001", "Acme Travel Sp. z o.o.", 12500m, 5000m, "issued"),
        new(2, "FV/2026/002", "Acme Travel Sp. z o.o.", 8400m, 8400m, "paid"),
        new(3, "FV/2026/003", "Globex Business Trips", 22000m, 800m, "overdue"),
    ];

    public IReadOnlyList<object> GetUnpaidInvoices()
    {
        return _invoices
            .Where(i => i.PaidTotal < i.Amount && i.Status is not "cancelled" and not "draft")
            .Select(i => new
            {
                invoice_number = i.Number,
                customer_name = i.CustomerName,
                amount = i.Amount,
                paid_total = i.PaidTotal,
                remaining = i.Amount - i.PaidTotal,
            })
            .ToList();
    }

    public object CreatePayment(int invoiceId, decimal amount, string method)
    {
        if (amount <= 0)
        {
            throw new InvalidOperationException("Amount must be greater than zero.");
        }

        var invoice = _invoices.FirstOrDefault(i => i.Id == invoiceId)
            ?? throw new InvalidOperationException("Invoice not found.");

        if (invoice.Status == "cancelled")
        {
            throw new InvalidOperationException("Cannot add payment to cancelled invoice.");
        }

        invoice = invoice with { PaidTotal = invoice.PaidTotal + amount };

        if (invoice.PaidTotal >= invoice.Amount)
        {
            invoice = invoice with { Status = "paid" };
        }

        var index = _invoices.FindIndex(i => i.Id == invoiceId);
        _invoices[index] = invoice;

        return new
        {
            ok = true,
            invoice_id = invoiceId,
            paid_total = invoice.PaidTotal,
            status = invoice.Status,
            method,
        };
    }
}

public record Invoice(
    int Id,
    string Number,
    string CustomerName,
    decimal Amount,
    decimal PaidTotal,
    string Status
);
