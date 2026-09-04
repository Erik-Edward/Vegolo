/**
 * Belopp lagras alltid som heltal i öre. Flyttal (t.ex. 249.90) ger
 * avrundningsfel så fort man räknar moms eller summerar en varukorg.
 */

const SEK = new Intl.NumberFormat("sv-SE", {
  style: "currency",
  currency: "SEK",
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

const SEK_WHOLE = new Intl.NumberFormat("sv-SE", {
  style: "currency",
  currency: "SEK",
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
});

/** Formaterar öre som svenskt pris, t.ex. 24900 -> "249,00 kr". */
export function formatOre(ore: number): string {
  return SEK.format(ore / 100);
}

/** Som formatOre men utan ören när beloppet är jämnt, t.ex. "249 kr". */
export function formatOreCompact(ore: number): string {
  return ore % 100 === 0 ? SEK_WHOLE.format(ore / 100) : formatOre(ore);
}

/** Formaterar en momssats som procent, t.ex. 0.06 -> "6 %". */
export function formatVatRate(rate: number): string {
  return new Intl.NumberFormat("sv-SE", {
    style: "percent",
    maximumFractionDigits: 1,
  }).format(rate);
}
