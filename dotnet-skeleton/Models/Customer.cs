namespace HrkDemo.Models;

public sealed class Customer
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? TaxId { get; set; }

    public DateTime CreatedAt { get; set; }

    public ICollection<Invoice> Invoices { get; set; } = [];
}
