/**
 * Punkten som figur: logotypens punkt med ögon.
 *
 * Formen är samma punkt som i ordbilden, men i vila — en aning ihoptryckt, som
 * något mjukt som just landat — och med blicken tillbaka mot texten den hör
 * till. Därför står figuren till höger om texten, inte till vänster.
 *
 * Regeln från profilen (CLAUDE.md avsnitt 5): figuren hör hemma där kunden
 * inte ska fatta ett beslut — orderbekräftelse, tom varukorg, en sida som inte
 * finns. Aldrig på burkens framsida, i produktinformation eller i kassan.
 *
 * Kroppen fylls med --vg-dot, samma variabel som logotypens punkt, så figuren
 * byter nyans med ytan. Ögonen följer textfärgen.
 */
export function Figur({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 100 100"
      className={className}
      role="img"
      aria-label="Vegolos figur: punkten med ögon"
    >
      <ellipse className="vg-dot" cx="50" cy="56" rx="48" ry="42" />
      <g className="vg-ogon">
        <ellipse fill="currentColor" cx="30" cy="50" rx="6.6" ry="9.4" />
        <ellipse fill="currentColor" cx="50" cy="50" rx="6.6" ry="9.4" />
      </g>
    </svg>
  );
}
