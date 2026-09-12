import Link from "next/link";
import { ProductCard } from "@/components/ProductCard";
import { Punkt } from "@/components/Punkt";
import { donation, donationIsDecided, home } from "@/content/site";
import { getAllProducts } from "@/lib/products";

/*
 * Startsida.
 *
 * PLATSHÅLLARTEXT: all copy ligger i src/content/site.ts och är utkast.
 * Rubriker och brödtext hålls medvetet fria från hälsopåståenden — vad
 * produkterna gör får bara beskrivas med EU-godkända formuleringar, och de
 * hör hemma på produktsidorna.
 */

export default async function HomePage() {
  const products = await getAllProducts();
  const [documentation, vegan, donationPoint] = home.openPoints;

  const donationBody =
    donationIsDecided() && donation.recipient
      ? donationPoint.bodyDecided.replace("{recipient}", donation.recipient.name)
      : donationPoint.body;

  return (
    <>
      <section className="mx-auto max-w-5xl px-6 pt-8 pb-16">
        <div className="on-dark rounded-2xl bg-brand px-7 py-14 text-brand-ink sm:px-12 sm:py-20">
          <p className="font-mono text-[11px] tracking-[0.14em] uppercase opacity-70">
            {home.eyebrow}
          </p>
          <h1 className="mt-6 max-w-2xl text-5xl leading-[1.02] sm:text-6xl">
            {home.heroHeading}
            <Punkt />
          </h1>
          <p className="mt-6 max-w-xl text-lg leading-relaxed opacity-85">
            {home.heroBody}
          </p>
          <div className="mt-10 flex flex-wrap items-center gap-x-8 gap-y-4">
            <Link
              href="/produkter"
              className="rounded-full bg-dot px-6 py-3 text-sm font-semibold text-brand transition-opacity hover:opacity-90"
            >
              {home.heroCta}
            </Link>
            <span className="text-sm font-medium underline decoration-dot decoration-2 underline-offset-4">
              {home.heroSecondary}
            </span>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-8">
        <h2 className="text-3xl">{home.rangeHeading}</h2>
        <p className="mt-2 max-w-xl text-muted">{home.rangeBody}</p>
        <div className="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {products.map((product) => (
            <ProductCard key={product.slug} product={product} />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-16">
        <h2 className="text-3xl">
          {home.openHeading}
          <Punkt />
        </h2>
        <div className="mt-8 grid gap-8 sm:grid-cols-3">
          {[documentation, vegan, { ...donationPoint, body: donationBody }].map(
            (point) => (
              <div key={point.title} className="border-t border-line pt-4">
                <h3 className="text-lg">{point.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {point.body}
                </p>
              </div>
            ),
          )}
        </div>
      </section>
    </>
  );
}
