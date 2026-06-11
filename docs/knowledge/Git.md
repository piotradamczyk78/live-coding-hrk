<link rel="stylesheet" href="../styles/main.css">

# Git

<!-- nav -->
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)

Komendy przydatne na live coding i przy omawianiu workflow. Projekt: `live-coding-hrk/`.

## Status i podgląd zmian

```bash
git status                    # co zmienione / unstaged / staged
git status -sb                # krótki format + branch
git diff                      # diff unstaged
git diff --staged             # diff staged (do commita)
git diff laravel/routes/      # diff konkretnego pliku/katalogu
git log --oneline -10         # ostatnie 10 commitów
git log --oneline --graph -15 # historia z grafem branchy
git show HEAD                 # ostatni commit (diff + meta)
git show HEAD:laravel/.env    # zawartość pliku z ostatniego commita
git blame app/Http/Controllers/InvoiceController.php
```

## Branching

```bash
git branch                    # lista branchy lokalnych
git branch -a                 # lokalne + zdalne
git switch -c feature/invoices-unpaid
git checkout -b feature/invoices-unpaid  # starsza składnia
git switch main
git merge feature/invoices-unpaid
```

## Stage, commit, cofanie

```bash
git add laravel/routes/api.php
git add laravel/app/
git add -p                              # interaktywnie (fragmenty pliku)
git add -u                              # tylko zmodyfikowane (bez nowych)
git commit -m "Add GET /api/invoices/unpaid endpoint"
git commit -am "Fix unpaid invoices query"

git restore laravel/routes/api.php
git restore --staged laravel/routes/api.php
git reset HEAD~1                        # cofnij commit (zmiany zostają)
git reset --hard HEAD~1                 # cofnij commit + usuń zmiany (ostrożnie!)
```

## Stash

```bash
git stash push -m "wip invoice controller"
git stash list
git stash show -p stash@{0}
git stash pop
git stash apply stash@{0}
git stash drop stash@{0}
```

## Remote

```bash
git remote -v
git fetch origin
git pull origin main
git push -u origin feature/invoices-unpaid
git push origin main
```

## Przydatne na live coding

```bash
git diff --staged --stat
git diff --name-only
git ls-files laravel/.env
git status --ignored
git log -1 --format='%h %s (%an, %ar)' -- sql/exercises.md
```

## Czego unikać na spotkaniu

```bash
# NIE używaj bez wyraźnej prośby rekrutera:
git push --force
git reset --hard
git clean -fdx          # usuwa nieśledzone pliki (w tym .env lokalne!)
git commit --no-verify  # omija hooki
```

## Dobre praktyki

- Commituj **małymi krokami** z sensownymi komunikatami
- Przed commitem: `git diff --staged` — nie commituj secretów
- Placeholdery `{{bw:...}}` w `.env` — **OK do commita**
- `vendor/`, `node_modules/`, `.secrets/.bw-session` — **nigdy** nie commituj

## .gitignore w tym projekcie

```
vendor/, node_modules/
.secrets/.bw-session, .secrets/defaults.env
laravel/vendor/, symfony/vendor/
*.log, *.bak
```

```bash
git check-ignore -v .secrets/defaults.env laravel/vendor/
```

---
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)
