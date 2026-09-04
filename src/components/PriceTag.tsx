import { formatOre, formatOreCompact, formatVatRate } from "@/lib/money";
import type { ProductPrice } from "@/lib/products/types";
import { splitPrice } from "@/lib/tax";

type PriceTagProps = {
  price: ProductPrice;
  /** Visa uppdelningen i netto och moms under priset. */
  showBreakdown?: boolean;
  size?: "sm" | "lg";
};

/**
 * Visar konsumentpris. Priset som lagras är alltid inklusive moms, eftersom
 * det är vad B2C-kunder ska se; nettot räknas fram via splitPrice() med den
 * momssats som gäller vid visningstillfället.
 */
export function PriceTag({ price, showBreakdown = false, size = "sm" }: PriceTagProps) {
  const { grossOre, netOre, vatOre, rate } = splitPrice(
    price.grossOre,
    price.vatCategory,
  );

  return (
    <div>
      <p className={size === "lg" ? "text-3xl text-ink" : "text-lg text-ink"}>
        {formatOreCompact(grossOre)}
      </p>
      <p className="mt-1 text-xs text-muted">
        Inklusive {formatVatRate(rate)} moms
      </p>
      {showBreakdown ? (
        <p className="mt-1 text-xs text-muted">
          {formatOre(netOre)} exklusive moms + {formatOre(vatOre)} moms
        </p>
      ) : null}
    </div>
  );
}
