using System.ComponentModel.DataAnnotations;
using HrkDemo.Services;

namespace HrkDemo.ViewModels;

public sealed class InvoiceFormViewModel : IValidatableObject
{
    public int? Id { get; set; }

    [Required(ErrorMessage = "Numer faktury jest wymagany.")]
    [MaxLength(50, ErrorMessage = "Numer faktury może mieć maksymalnie 50 znaków.")]
    [Display(Name = "Numer faktury")]
    public string Number { get; set; } = string.Empty;

    [Required(ErrorMessage = "Klient jest wymagany.")]
    [Range(1, int.MaxValue, ErrorMessage = "Klient jest wymagany.")]
    [Display(Name = "Klient")]
    public int CustomerId { get; set; }

    [Required(ErrorMessage = "Kwota jest wymagana.")]
    [Range(0.01, double.MaxValue, ErrorMessage = "Kwota musi być większa od zera.")]
    [Display(Name = "Kwota (PLN)")]
    public decimal Amount { get; set; }

    [Required(ErrorMessage = "Status jest wymagany.")]
    [Display(Name = "Status")]
    public string Status { get; set; } = "draft";

    [Display(Name = "Data wystawienia")]
    public DateOnly? IssuedAt { get; set; }

    [Display(Name = "Termin płatności")]
    public DateOnly? DueAt { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!InvoiceService.Statuses.Contains(Status))
        {
            yield return new ValidationResult(
                "Nieprawidłowy status faktury.",
                [nameof(Status)]);
        }
    }
}
