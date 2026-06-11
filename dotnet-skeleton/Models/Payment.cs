namespace HrkDemo.Models;

public sealed class Payment
{
    public int Id { get; set; }

    public int InvoiceId { get; set; }

    public Invoice Invoice { get; set; } = null!;

    public decimal Amount { get; set; }

    public DateTime PaidAt { get; set; }

    public string Method { get; set; } = "transfer";
}
