type PanelProps = {
  title: string;
  /** Kort förklaring under rubriken, t.ex. varför uppgiften visas. */
  description?: string;
  children: React.ReactNode;
};

/** Innehållsblock på produktsidan. Ger alla avsnitt samma ram och rytm. */
export function Panel({ title, description, children }: PanelProps) {
  return (
    <section className="rounded-lg border border-line bg-surface p-6">
      <h2 className="text-xl">{title}</h2>
      {description ? (
        <p className="mt-1 text-sm text-muted">{description}</p>
      ) : null}
      <div className="mt-4">{children}</div>
    </section>
  );
}
