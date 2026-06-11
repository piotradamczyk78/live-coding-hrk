namespace HrkDemo.Models;

public sealed class Invoice
{
    public int Id { get; set; }

    public string Number { get; set; } = string.Empty;

    public int CustomerId { get; set; }

    public Customer Customer { get; set; } = null!;

    public decimal Amount { get; set; }

    public string Status { get; set; } = "draft";

    public DateOnly? IssuedAt { get; set; }

    public DateOnly? DueAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public ICollection<Payment> Payments { get; set; } = [];
}
