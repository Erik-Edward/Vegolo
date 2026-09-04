import type { Metadata } from "next";
import { ProductCard } from "@/components/ProductCard";
import { getAllProducts } from "@/lib/products";

export const metadata: Metadata = {
  title: "Produkter",
  description:
    "Vegolos sortiment av kosttillskott för dig som lever växtbaserat.",
};

export default async function ProductsPage() {
  const products = await getAllProducts();

  return (
    <div className="mx-auto max-w-5xl px-6 py-16">
      <h1 className="text-4xl">Produkter</h1>
      <p className="mt-3 max-w-xl text-muted">
        Priser visas inklusive moms. Fullständig ingrediensförteckning,
        rekommenderat dagligt intag och dokumentation finns på varje
        produktsida.
      </p>

      <div className="mt-10 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {products.map((product) => (
          <ProductCard key={product.slug} product={product} />
        ))}
      </div>
    </div>
  );
}
