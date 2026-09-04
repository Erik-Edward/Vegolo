/**
 * Momshantering.
 *
 * Momssatsen på kosttillskott (livsmedel) ändras över tid och får därför
 * INTE hårdkodas i komponenter. Satserna ligger i tabellen nedan med
 * giltighetsperiod, och all prisberäkning går via `getVatRate()`.
 *
 * Bakgrund: livsmedelsmomsen är tillfälligt sänkt från 12 % till 6 %
 * under perioden 2026-04-01 – 2027-12-31, och återgår till 12 % från
 * 2028-01-01. Ändringen 2028 kräver alltså ingen kodändring — den är
 * redan inlagd i tabellen.
 */

export type VatCategory = "food_supplement" | "standard";

export type VatRate = {
  /** Momssats som decimaltal, t.ex. 0.06 för 6 %. */
  rate: number;
  /** ISO-datum (inklusive). */
  validFrom: string;
  /** ISO-datum (inklusive). null = gäller tills vidare. */
  validTo: string | null;
  note: string;
};

export const VAT_RATES: Record<VatCategory, VatRate[]> = {
  food_supplement: [
    {
      rate: 0.12,
      validFrom: "2000-01-01",
      validTo: "2026-03-31",
      note: "Ordinarie livsmedelsmoms.",
    },
    {
      rate: 0.06,
      validFrom: "2026-04-01",
      validTo: "2027-12-31",
      note: "Tillfälligt sänkt livsmedelsmoms.",
    },
    {
      rate: 0.12,
      validFrom: "2028-01-01",
      validTo: null,
      note: "Återgång till ordinarie livsmedelsmoms.",
    },
  ],
  standard: [
    {
      rate: 0.25,
      validFrom: "2000-01-01",
      validTo: null,
      note: "Normalskattesats. Används för t.ex. presentkort på tjänster.",
    },
  ],
};

/**
 * Övergripande override för test och felsökning, t.ex. VAT_RATE_OVERRIDE=0.12
 * för att förhandsgranska hur sajten ser ut efter momshöjningen 2028.
 */
function readOverride(): number | null {
  const raw = process.env.NEXT_PUBLIC_VAT_RATE_OVERRIDE;
  if (!raw) return null;
  const parsed = Number.parseFloat(raw);
  if (!Number.isFinite(parsed) || parsed < 0 || parsed > 1) return null;
  return parsed;
}

/** Hämtar gällande momssats för en kategori vid en given tidpunkt. */
export function getVatRate(category: VatCategory, at: Date = new Date()): number {
  const override = readOverride();
  if (override !== null) return override;

  const day = at.toISOString().slice(0, 10);
  const match = VAT_RATES[category].find(
    (entry) => entry.validFrom <= day && (entry.validTo === null || day <= entry.validTo),
  );

  if (!match) {
    throw new Error(
      `Ingen momssats definierad för kategorin "${category}" den ${day}. ` +
        "Lägg till en period i VAT_RATES i src/lib/tax.ts.",
    );
  }

  return match.rate;
}

export type PriceBreakdown = {
  /** Pris inkl. moms i öre — det pris kunden ser. */
  grossOre: number;
  /** Pris exkl. moms i öre. */
  netOre: number;
  /** Momsbelopp i öre. */
  vatOre: number;
  /** Tillämpad momssats som decimaltal. */
  rate: number;
};

/**
 * Delar upp ett konsumentpris (inkl. moms) i netto och moms.
 *
 * Priserna lagras inklusive moms eftersom det är priset kunden ser och det
 * pris vi sätter kommersiellt. Nettot räknas fram — annars skulle det
 * annonserade priset ändras av sig självt vid momsändringen 2028.
 */
export function splitPrice(
  grossOre: number,
  category: VatCategory,
  at: Date = new Date(),
): PriceBreakdown {
  const rate = getVatRate(category, at);
  const netOre = Math.round(grossOre / (1 + rate));
  return { grossOre, netOre, vatOre: grossOre - netOre, rate };
}
