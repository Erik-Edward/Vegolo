import Link from "next/link";
import { Logo } from "@/components/Logo";
import { PriceTag } from "@/components/PriceTag";
import { accentFor } from "@/lib/brand";
import { availabilityLabels, formLabels } from "@/lib/products/labels";
import { daysPerPackage } from "@/lib/products/regulatory";
import type { Product } from "@/lib/products/types";

export function ProductCard({ product }: { product: Product }) {
  const days = daysPerPackage(product);
  const accent = accentFor(product.slug);

  return (
    <article className="flex flex-col overflow-hidden rounded-xl border border-line bg-surface">
      {/*
       * Produktfoto saknas ännu (CLAUDE.md avsnitt 9). Platshållaren är
       * utformad som etiketten: mörk botten, produktens färg som markering.
       */}
      <div className="on-dark flex aspect-4/3 flex-col justify-between bg-brand p-5 text-brand-ink">
        <Logo className="h-4 w-auto" title={null} />
        <div>
          <p className="text-2xl leading-none font-semibold tracking-tight">
            {product.name.replace(/^Vegolo\s+/, "")}
          </p>
          <span className={`mt-2 block h-1 w-10 rounded-full ${accent.mark}`} />
        </div>
        <p className="font-mono text-[10px] tracking-wide opacity-60">
          Produktbild kommer
        </p>
      </div>

      <div className="flex flex-1 flex-col p-5">
        <p className="font-mono text-[10px] tracking-wide text-muted uppercase">
          {formLabels[product.form]} · {availabilityLabels[product.availability]}
        </p>

        <h2 className="mt-2 text-xl">
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
      </div>
    </article>
  );
}
