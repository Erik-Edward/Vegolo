import Link from "next/link";
import { navigation, site } from "@/content/site";

export function SiteHeader() {
  return (
    <header className="border-b border-line bg-canvas/80 backdrop-blur">
      <div className="mx-auto flex max-w-5xl items-center justify-between gap-6 px-6 py-5">
        <Link
          href="/"
          className="font-display text-2xl tracking-tight text-brand"
          aria-label={`${site.name} startsida`}
        >
          {site.name}
        </Link>

        <nav aria-label="Huvudmeny">
          <ul className="flex items-center gap-6 text-sm">
            {navigation.map((item) => (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className="text-muted transition-colors hover:text-ink"
                >
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </header>
  );
}
