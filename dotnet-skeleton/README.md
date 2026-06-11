# .NET Web API — szkielet referencyjny

Minimalne API odpowiadające ćwiczeniom PHP/SQL (faktury nieopłacone, dodawanie płatności).

## Uruchomienie

```bash
brew install --cask dotnet-sdk   # jeśli nie masz SDK
cd dotnet-skeleton
dotnet run
```

Test:

```bash
curl http://localhost:5000/api/invoices/unpaid
curl -X POST http://localhost:5000/api/invoices/1/payments \
  -H 'Content-Type: application/json' \
  -d '{"amount": 7500, "method": "transfer"}'
```

Port może być `5000` lub `8080` — sprawdź output `dotnet run`.
