import Link from "next/link";
import { Logo } from "@/components/Logo";
import { navigation, site } from "@/content/site";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-10 border-b border-line bg-canvas/85 backdrop-blur">
      <div className="mx-auto flex max-w-5xl items-center justify-between gap-6 px-6 py-4">
        <Link
          href="/"
          className="text-ink transition-opacity hover:opacity-80"
          aria-label={`${site.name} startsida`}
        >
          <Logo className="h-6 w-auto" title={null} />
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
