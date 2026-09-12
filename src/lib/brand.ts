/**
 * Produktkoder i den grafiska profilen.
 *
 * Varje produkt har en egen färg som används som detalj — en linje, en prick,
 * ett ord — aldrig som yta. Färgen finns i två nyanser: den ljusa används mot
 * aubergine, den mörka mot ljus botten där den ljusa är för svag (se
 * globals.css). Klassnamnen skrivs ut i sin helhet eftersom Tailwind läser
 * källkoden bokstavligt.
 *
 * En produkt utan egen färg faller tillbaka på aubergine, så nya produkter
 * fungerar direkt utan att den här filen måste uppdateras först.
 */
export type ProductAccent = {
  /** Yta i produktens ljusa nyans, för mörk botten. */
  mark: string;
  /** Text i produktens mörka nyans, för ljus botten. */
  text: string;
};

const accents: Record<string, ProductAccent> = {
  "b12-metylkobalamin": { mark: "bg-b12", text: "text-b12-deep" },
  "d3-lavbaserad": { mark: "bg-d3", text: "text-d3-deep" },
  "omega-3-algolja": { mark: "bg-omega", text: "text-omega-deep" },
};

const fallback: ProductAccent = { mark: "bg-brand-ink", text: "text-muted" };

export function accentFor(slug: string): ProductAccent {
  return accents[slug] ?? fallback;
}
