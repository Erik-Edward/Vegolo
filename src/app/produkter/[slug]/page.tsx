import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { DraftNotice } from "@/components/DraftNotice";
import { Panel } from "@/components/Panel";
import { PriceTag } from "@/components/PriceTag";
import { getProduct, getProductSlugs } from "@/lib/products";
import { availabilityLabels, formLabels, ingredientRoleLabels } from "@/lib/products/labels";
import {
  daysPerPackage,
  getAllWarnings,
  getPublishableHealthClaims,
} from "@/lib/products/regulatory";

/*
 * Produktsidesmall.
 *
 * En och samma mall renderar hela sortimentet. Allt sidan visar kommer från
 * produktdatan i src/content/products/ — lägg till en produkt där och den får
 * en fungerande sida, utan ändringar här.
 *
 * De regulatoriskt obligatoriska avsnitten (rekommenderat dagligt intag,
 * varningstext, ingredientsförteckning och nettokvantitet) renderas alltid.
 * De är inte villkorade av att produktdatan råkar innehålla dem, eftersom
 * typerna i src/lib/products/types.ts redan kräver dem.
 */

export async function generateStaticParams() {
  const slugs = await getProductSlugs();
  return slugs.map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: PageProps<"/produkter/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const product = await getProduct(slug);

  if (!product) return {};

  return {
    title: product.name,
    description: `${product.tagline}. ${product.netQuantity.unitCount} ${product.netQuantity.unitLabel}.`,
  };
}

export default async function ProductPage({
  params,
}: PageProps<"/produkter/[slug]">) {
  const { slug } = await params;
  const product = await getProduct(slug);

  if (!product) notFound();

  const warnings = getAllWarnings(product);
  const claims = getPublishableHealthClaims(product);
  const days = daysPerPackage(product);

  return (
    <article className="mx-auto max-w-5xl px-6 py-16">
      <div className="grid gap-12 lg:grid-cols-2">
        {/* Produktfoto saknas ännu (CLAUDE.md avsnitt 8). */}
        <div
          className="flex aspect-square items-center justify-center rounded-lg bg-brand-soft text-sm text-muted"
          aria-hidden="true"
        >
          Produktbild kommer
        </div>

        <div>
          <p className="text-xs tracking-wide text-muted uppercase">
            {formLabels[product.form]} · {availabilityLabels[product.availability]}
          </p>
          <h1 className="mt-3 text-4xl">{product.name}</h1>
          <p className="mt-2 text-lg text-muted">{product.tagline}</p>

          <div className="mt-8">
            <PriceTag price={product.price} showBreakdown size="lg" />
          </div>

          <p className="mt-2 text-sm text-muted">
            {product.netQuantity.unitCount} {product.netQuantity.unitLabel} ·{" "}
            {product.netQuantity.netWeightGram} g
            {days ? ` · räcker ca ${days} dagar` : ""}
          </p>

          {/* Kassan är inte byggd ännu — knappen är avsiktligt inaktiv. */}
          <button
            type="button"
            disabled
            className="mt-8 w-full cursor-not-allowed rounded-md bg-brand px-6 py-3 text-sm text-brand-ink opacity-40 sm:w-auto"
          >
            Lägg i varukorg
          </button>
          <p className="mt-2 text-xs text-muted">
            Butiken är inte öppen ännu. Kassan byggs med Stripe.
          </p>

          <div className="mt-8 space-y-3 text-base leading-relaxed">
            {product.description.map((paragraph) => (
              <p key={paragraph}>{paragraph}</p>
            ))}
          </div>
        </div>
      </div>

      <div className="mt-16 grid gap-6 lg:grid-cols-2">
        <Panel title="Rekommenderat dagligt intag">
          <p>{product.recommendedDailyIntake.text}</p>
        </Panel>

        <Panel title="Förvaring">
          <p>{product.storage}</p>
        </Panel>

        <Panel
          title="Innehåll per dagsdos"
          description="RI = referensintag för vuxna enligt förordning (EU) 1169/2011."
        >
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-line text-left text-muted">
                <th scope="col" className="pb-2 font-normal">
                  Ämne
                </th>
                <th scope="col" className="pb-2 font-normal">
                  Mängd
                </th>
                <th scope="col" className="pb-2 font-normal">
                  % av RI
                </th>
              </tr>
            </thead>
            <tbody>
              {product.nutrients.map((nutrient) => (
                <tr key={nutrient.name} className="border-b border-line last:border-0">
                  <td className="py-2">{nutrient.name}</td>
                  <td className="py-2">{nutrient.amountPerDailyDose}</td>
                  <td className="py-2">
                    {nutrient.nrvPercent === null ? "–" : `${nutrient.nrvPercent} %`}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Panel>

        <Panel title="Ingredienser">
          <ul className="space-y-2 text-sm">
            {product.ingredients.map((ingredient) => (
              <li key={ingredient.name} className="border-b border-line pb-2 last:border-0">
                <span>{ingredient.name}</span>
                <span className="block text-xs text-muted">
                  {ingredientRoleLabels[ingredient.role]}
                  {ingredient.note ? ` · ${ingredient.note}` : ""}
                </span>
              </li>
            ))}
          </ul>
        </Panel>

        <Panel title="Varningstext">
          <ul className="list-disc space-y-2 pl-5 text-sm leading-relaxed">
            {warnings.map((warning) => (
              <li key={warning}>{warning}</li>
            ))}
          </ul>
        </Panel>

        <Panel
          title="Hälsopåståenden"
          description="Endast formuleringar som är godkända inom EU får användas."
        >
          {claims.length === 0 ? (
            <p className="text-sm text-muted">
              Inga godkända hälsopåståenden är publicerade för den här produkten
              ännu.
            </p>
          ) : (
            <ul className="space-y-3 text-sm">
              {claims.map((claim) => (
                <li key={claim.text}>
                  {claim.status === "approved" ? (
                    <p>{claim.text}</p>
                  ) : (
                    <DraftNotice>
                      {claim.text} Formuleringen måste stämmas av ord för ord mot{" "}
                      {claim.source} innan den får publiceras. Villkor:{" "}
                      {claim.condition}
                    </DraftNotice>
                  )}
                </li>
              ))}
            </ul>
          )}
        </Panel>

        <Panel
          title="Dokumentation"
          description="Underlag som styrker ursprung och innehåll."
        >
          <ul className="space-y-3 text-sm">
            {product.documentation.map((document) => (
              <li key={document.title}>
                {document.href ? (
                  <a
                    href={document.href}
                    className="text-brand underline underline-offset-4"
                  >
                    {document.title}
                  </a>
                ) : (
                  <span>{document.title}</span>
                )}
                <span className="block text-xs text-muted">
                  {document.description}
                  {document.verifiedAt
                    ? ` Senast verifierat ${document.verifiedAt}.`
                    : " Dokumentet är inte inlagt ännu."}
                </span>
              </li>
            ))}
          </ul>
        </Panel>
      </div>
    </article>
  );
}
