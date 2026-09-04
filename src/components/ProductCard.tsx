import Link from "next/link";
import { PriceTag } from "@/components/PriceTag";
import { availabilityLabels, formLabels } from "@/lib/products/labels";
import { daysPerPackage } from "@/lib/products/regulatory";
import type { Product } from "@/lib/products/types";

export function ProductCard({ product }: { product: Product }) {
  const days = daysPerPackage(product);

  return (
    <article className="flex flex-col rounded-lg border border-line bg-surface p-6">
      {/* Produktfoto saknas ännu — platshållaren håller layouten stabil. */}
      <div
        className="mb-6 flex aspect-4/3 items-center justify-center rounded-md bg-brand-soft text-xs text-muted"
        aria-hidden="true"
      >
        Produktbild kommer
      </div>

      <p className="text-xs tracking-wide text-muted uppercase">
        {formLabels[product.form]} · {availabilityLabels[product.availability]}
      </p>

      <h2 className="mt-2 text-2xl">
        <Link
          href={`/produkter/${product.slug}`}
          className="transition-colors hover:text-brand"
        >
          {product.name}
        </Link>
      </h2>

      <p className="mt-1 text-sm text-muted">{product.tagline}</p>

      <p className="mt-4 text-sm text-muted">
        {product.netQuantity.unitCount} {product.netQuantity.unitLabel}
        {days ? ` · räcker ca ${days} dagar` : ""}
      </p>

      <div className="mt-auto pt-6">
        <PriceTag price={product.price} />
      </div>
    </article>
  );
}
