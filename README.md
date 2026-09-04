# Vegolo

Webbplats och webbutik för Vegolo — kosttillskott för dig som lever växtbaserat.

Affärskontext, regulatoriska krav och fattade beslut finns i [CLAUDE.md](./CLAUDE.md).

## Komma igång

```bash
npm install
npm run dev
```

Sajten körs sedan på http://localhost:3000.

Övriga kommandon:

| Kommando | Gör |
|---|---|
| `npm run dev` | Startar utvecklingsservern med automatisk omladdning |
| `npm run build` | Bygger en produktionsversion och kontrollerar att allt håller ihop |
| `npm start` | Kör den byggda versionen lokalt |
| `npm run lint` | Letar efter kodfel |

## Så ändrar du produktinformation

All produktinformation ligger i **`src/content/products/`** — en fil per produkt. Där ändrar du texter, priser, ingredienser, doser och dokumentation utan att röra någon sidkod.

Varumärkestexter (rubriker på startsidan, beskrivningar, donationsuppgifter) ligger i **`src/content/site.ts`**.

Om en obligatorisk uppgift saknas failar `npm run build` med ett felmeddelande i stället för att publicera en ofullständig produktsida.

### Lägga till en ny produkt

1. Kopiera en befintlig fil i `src/content/products/`.
2. Ändra `slug` (den blir produktens webbadress) och övriga uppgifter.
3. Lägg till produkten i listan i `src/lib/products/index.ts`.

Produktsidan skapas automatiskt. Ordningen i listan styr visningsordningen i butiken.

## Regulatoriska skyddsnät i koden

Sajten hanterar kosttillskott, och några krav upprätthålls därför av koden själv:

- **De tre lagstadgade varningarna** läggs på automatiskt för varje produkt. De kan inte glömmas bort.
- **Hälsopåståenden** har en granskningsstatus. Ett påstående som inte är granskat och satt till `approved` visas aldrig i skarp drift — det syns bara lokalt, med en gul varningsruta.
- **Momsen** ligger i en tabell med giltighetsperioder (`src/lib/tax.ts`). 6 % gäller till och med 2027-12-31 och 12 % från 2028-01-01. Återgången kräver ingen kodändring.
- **Priser** lagras i öre inklusive moms, eftersom det är priset kunden ska se. Nettot räknas fram.

## Status

Scaffolding. Startsida, produktlista och produktsidesmall fungerar. **Allt innehåll är platshållartext.** Kassa, varukorg och betalning är inte byggda ännu — det görs med Stripe, se CLAUDE.md avsnitt 6.
