import Link from "next/link";
import { ProductCard } from "@/components/ProductCard";
import { donation, donationIsDecided, site } from "@/content/site";
import { getAllProducts } from "@/lib/products";

/*
 * Startsida.
 *
 * PLATSHÅLLARTEXT: all copy nedan är utkast. Rubriker och brödtext hålls
 * medvetet fria från hälsopåståenden — vad produkterna gör får bara beskrivas
 * med EU-godkända formuleringar, och de hör hemma på produktsidorna.
 */

export default async function HomePage() {
  const products = await getAllProducts();

  return (
    <>
      <section className="mx-auto max-w-5xl px-6 pt-20 pb-16">
        <p className="text-sm tracking-wide text-brand uppercase">
          Platshållartext
        </p>
        <h1 className="mt-4 max-w-2xl text-5xl leading-tight sm:text-6xl">
          {site.tagline}
        </h1>
        <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted">
          B12, D3 och omega-3 utan animaliska råvaror. Vi visar öppet vad som
          finns i burken, var råvarorna kommer ifrån och vart pengarna går.
        </p>
        <Link
          href="/produkter"
          className="mt-8 inline-block rounded-md bg-brand px-6 py-3 text-sm text-brand-ink transition-opacity hover:opacity-90"
        >
          Se produkterna
        </Link>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-8">
        <h2 className="text-3xl">Sortimentet</h2>
        <p className="mt-2 max-w-xl text-muted">
          Tre tillskott till att börja med. Fler tillkommer efterhand.
        </p>
        <div className="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {products.map((product) => (
            <ProductCard key={product.slug} product={product} />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 py-16">
        <h2 className="text-3xl">Öppet redovisat</h2>
        <div className="mt-8 grid gap-8 sm:grid-cols-3">
          <div>
            <h3 className="text-lg">Dokumentation, inte påståenden</h3>
            <p className="mt-2 text-sm leading-relaxed text-muted">
              Ursprungsintyg och analyscertifikat ligger på produktsidan, inte
              begravda i en FAQ.
            </p>
          </div>
          <div>
            <h3 className="text-lg">Veganskt hela vägen</h3>
            <p className="mt-2 text-sm leading-relaxed text-muted">
              Även kapseln och processhjälpmedlen. D3 kommer från lav, inte
              från lanolin.
            </p>
          </div>
          <div>
            <h3 className="text-lg">En del av intäkten doneras</h3>
            <p className="mt-2 text-sm leading-relaxed text-muted">
              {donationIsDecided() && donation.recipient
                ? `Varje köp bidrar till ${donation.recipient.name}. Vi redovisar det donerade beloppet publikt.`
                : "Mekanism, belopp och mottagande organisation beslutas innan lansering. Beloppet kommer att redovisas publikt och gå att stämma av — inte anges som en marknadsföringssiffra."}
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
