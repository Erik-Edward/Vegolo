/**
 * Synlig markering för innehåll som ännu inte är regulatoriskt granskat.
 *
 * Notisen finns för att ogranskat innehåll ska vara omöjligt att missa under
 * arbetets gång. I skarp drift filtreras ogranskade hälsopåståenden bort helt
 * (se src/lib/products/regulatory.ts) — notisen är alltså ett arbetsverktyg,
 * inte ett publikt element.
 */
export function DraftNotice({ children }: { children: React.ReactNode }) {
  return (
    <p className="rounded-md border border-notice-line bg-notice px-4 py-3 text-sm leading-relaxed text-notice-ink">
      <span className="font-medium">Ej granskat innehåll. </span>
      {children}
    </p>
  );
}
