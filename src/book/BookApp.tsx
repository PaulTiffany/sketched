import { useEffect, useState, type MouseEvent, type ReactNode } from "react";
import { MarkdownText } from "./MarkdownText";
import { bookHref, parseBookRoute, type BookRoute } from "./routes";
import type {
  Book5LeanPacket,
  ChapterPacket,
  ChapterSummary,
  ContentBoundary,
  GlossaryPacket,
  LedgerPacket,
  LedgerRow,
  PathSummary,
  ProjectionIndex,
  ProjectionPacket,
  SurfacePacket,
} from "./types";
import "./book.css";

function navigate(href: string) {
  window.history.pushState({}, "", href);
  window.dispatchEvent(new PopStateEvent("popstate"));
  window.scrollTo({ top: 0, behavior: "instant" });
}

function BookLink({
  href,
  children,
  className,
}: {
  href: string;
  children: ReactNode;
  className?: string;
}) {
  function onClick(event: MouseEvent<HTMLAnchorElement>) {
    if (
      event.button === 0 &&
      !event.metaKey &&
      !event.ctrlKey &&
      !event.shiftKey &&
      !event.altKey
    ) {
      event.preventDefault();
      navigate(href);
    }
  }
  return (
    <a className={className} href={href} onClick={onClick}>
      {children}
    </a>
  );
}

function useBookRoute(): BookRoute {
  const [route, setRoute] = useState(() => parseBookRoute(window.location.pathname));
  useEffect(() => {
    const update = () => setRoute(parseBookRoute(window.location.pathname));
    window.addEventListener("popstate", update);
    return () => window.removeEventListener("popstate", update);
  }, []);
  return route;
}

function useJson<T>(url: string | null, expectedSchema: string) {
  const [state, setState] = useState<{
    data: T | null;
    error: string | null;
    loading: boolean;
  }>({ data: null, error: null, loading: Boolean(url) });

  useEffect(() => {
    if (!url) {
      setState({ data: null, error: null, loading: false });
      return;
    }
    const controller = new AbortController();
    setState({ data: null, error: null, loading: true });
    fetch(url, { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error("HTTP " + response.status + " for " + url);
        return response.json().then((value: unknown) => {
          if (
            typeof value !== "object" ||
            value === null ||
            !("schema" in value) ||
            value.schema !== expectedSchema
          ) {
            throw new Error("Schema mismatch for " + url);
          }
          return value as T;
        });
      })
      .then((data) => setState({ data, error: null, loading: false }))
      .catch((error: unknown) => {
        if (error instanceof DOMException && error.name === "AbortError") return;
        setState({
          data: null,
          error: error instanceof Error ? error.message : String(error),
          loading: false,
        });
      });
    return () => controller.abort();
  }, [url, expectedSchema]);

  return state;
}

function ScreenState({ loading, error }: { loading: boolean; error: string | null }) {
  if (loading) return <main className="book-state">Opening the projection…</main>;
  if (error) return <main className="book-state book-error">{error}</main>;
  return null;
}

function BookHeader({ digest }: { digest?: string }) {
  return (
    <header className="book-header">
      <BookLink href="/book" className="book-brand">
        <span className="book-brand-mark">S</span>
        <span>
          <strong>Forcing at the Surface</strong>
          <small>A witnessed introduction</small>
        </span>
      </BookLink>
      <nav aria-label="Book interface">
        <BookLink href="/book">Paths</BookLink>
        <BookLink href="/book/surface">Surface</BookLink>
        <BookLink href="/book/ledger">Ledger</BookLink>
        <BookLink href="/book/lean">Lean</BookLink>
        <BookLink href="/book/glossary">Glossary</BookLink>
        <BookLink href="/book/media">Media</BookLink>
        <BookLink href="/book/content-b">Content B</BookLink>
        <BookLink href="/book/meta">Interface</BookLink>
        <a href="/book/meta.json">JSON</a>
      </nav>
      {digest ? (
        <span className="book-digest" title={digest}>
          source {digest.slice(0, 10)}
        </span>
      ) : null}
    </header>
  );
}

function MediumNotice({ meta }: { meta: ProjectionIndex }) {
  return (
    <aside className="medium-notice">
      <span className="eyebrow">Browser interface · localhost</span>
      <p>{meta.medium.statement}</p>
      <small>{meta.medium.calibration}</small>
    </aside>
  );
}

// Derived from the id, never list position: an appendix mixed into a
// numbered list must read as an appendix, not as "chapter 09".
function chapterMarker(id: string): string {
  const numbered = id.match(/^ch(\d+)$/)?.[1];
  if (numbered) return numbered.padStart(2, "0");
  const appendix = id.match(/^app([a-z])$/i)?.[1];
  if (appendix) return appendix.toUpperCase();
  return id;
}

function ChapterCard({ chapter }: { chapter: ChapterSummary }) {
  return (
    <BookLink href={chapter.browser_path} className="chapter-card">
      <span className="chapter-number">{chapterMarker(chapter.id)}</span>
      <span className="chapter-card-copy">
        <strong>{chapter.title}</strong>
        <small>
          {chapter.word_count.toLocaleString()} words · {chapter.status}
        </small>
      </span>
      <span aria-hidden="true">→</span>
    </BookLink>
  );
}

function PathCard({ path }: { path: PathSummary }) {
  return (
    <BookLink href={path.browser_path} className="path-card">
      <span className="eyebrow">{path.audience}</span>
      <h2>{path.title}</h2>
      <p>{path.description}</p>
      <footer>
        <span>
          {path.chapter_count} chapter{path.chapter_count === 1 ? "" : "s"}
        </span>
        <span>
          {path.assumption_count ? path.assumption_count + " assumed" : "self-contained"}
        </span>
        <span>
          {path.includes_content_b ? "Content B boundary included" : "Content A only"}
        </span>
      </footer>
    </BookLink>
  );
}

function HomeView({ meta }: { meta: ProjectionIndex }) {
  return (
    <main className="book-main">
      <section className="book-hero">
        <div>
          <span className="eyebrow">Choose a bounded projection</span>
          <h1>
            One book.
            <br />
            Several honest entrances.
          </h1>
          <p>
            The chapters stay canonical. A path selects the context a reader—or a
            browser-instantiated agent—receives.
          </p>
        </div>
        <MediumNotice meta={meta} />
      </section>

      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Learning profiles</span>
          <h2>Paths through the argument</h2>
        </div>
        <div className="path-grid">
          {meta.paths.map((path) => (
            <PathCard key={path.id} path={path} />
          ))}
        </div>
      </section>

      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Canonical sources</span>
          <h2>All chapters</h2>
        </div>
        <div className="chapter-list">
          {meta.chapters.map((chapter) => (
            <ChapterCard chapter={chapter} key={chapter.id} />
          ))}
        </div>
      </section>
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Generated, drift-checked every build</span>
          <h2>Cross-references</h2>
        </div>
        <div className="generated-grid">
          <article className="generated-card">
            <span className="eyebrow">Principia Symbolica · Book Five</span>
            <h3>Verified kernels and explicit proof debt</h3>
            <p>Lean declarations mapped to their exact Principia anchors.</p>
            <BookLink href="/book/lean">Open the proof surface →</BookLink>
          </article>          {meta.ledger ? (
            <article className="generated-card">
              <span className="eyebrow">Appendix A</span>
              <h3>
                {meta.ledger.rows} nodes · {meta.ledger.footprint.untaught} left to
                the paper
              </h3>
              <p>Every atlas claim the book teaches, status and witness attached.</p>
              <BookLink href="/book/ledger">Open the ledger →</BookLink>
            </article>
          ) : null}
          {meta.surface ? (
            <article className="generated-card">
              <span className="eyebrow">Epistemic geography</span>
              <h3>
                μ = {meta.surface.mu.toFixed(2)} · {meta.surface.ground} ground ·{" "}
                {meta.surface.frontier} frontier · {meta.surface.open} open ·{" "}
                {meta.surface.voids} voids
              </h3>
              <p>The book's own hypothesis surface: what it claims, what it owes.</p>
              <BookLink href="/book/surface">Walk the surface →</BookLink>
            </article>
          ) : null}
          {meta.glossary ? (
            <article className="generated-card">
              <span className="eyebrow">Words that collide</span>
              <h3>{meta.glossary.terms} double-booked terms</h3>
              <p>The paper, Sketched, and now this book's own inspiration source.</p>
              <BookLink href="/book/glossary">Open the glossary →</BookLink>
            </article>
          ) : null}
        </div>
      </section>
    </main>
  );
}
function PathView({ id, meta }: { id: string; meta: ProjectionIndex }) {
  const { data, error, loading } = useJson<ProjectionPacket>(
    "/book/context/" + id + ".json",
    "sketched.pedagogy.projection.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== meta.source_digest) {
    return <ScreenState loading={false} error="Projection source digest mismatch" />;
  }
  const assumptions = data.projection.assumed_chapter_ids
    .map((chapterId) => meta.chapters.find((chapter) => chapter.id === chapterId))
    .filter((chapter): chapter is ChapterSummary => Boolean(chapter));
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">{data.projection.audience}</span>
        <h1>{data.projection.title}</h1>
        <p>{data.projection.description}</p>
        <div className="path-actions">
          <a className="machine-link" href={data.projection.json_path}>
            Open bounded JSON context
          </a>
          <span>
            {data.projection.chapter_count} chapters · {data.projection.assumption_count}{" "}
            assumptions
          </span>
        </div>
      </section>
      <MediumNotice meta={meta} />
      {assumptions.length ? (
        <section className="assumption-strip">
          <span className="eyebrow">Assumed before entry</span>
          <div>
            {assumptions.map((chapter) => (
              <BookLink href={chapter.browser_path} key={chapter.id}>
                {chapter.id} · {chapter.title}
              </BookLink>
            ))}
          </div>
        </section>
      ) : null}{" "}
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Selected sequence</span>
          <h2>What this projection carries</h2>
        </div>
        <div className="chapter-list">
          {data.chapters.map((chapter) => (
            <ChapterCard chapter={chapter} key={chapter.id} />
          ))}
        </div>
      </section>
      {data.projection.includes_content_b ? (
        <section className="content-boundary-inline">
          <div>
            <span className="eyebrow">Reserved authorship</span>
            <h2>Content B is OmegaClaw's to write.</h2>
            <p>
              The path carries the seat, its constraints, and its location; the
              voice that fills it belongs to its author.
            </p>
          </div>
          <BookLink href="/book/content-b">Visit the seat →</BookLink>
        </section>
      ) : null}
    </main>
  );
}

function ChapterView({ id, digest }: { id: string; digest: string }) {
  const { data, error, loading } = useJson<ChapterPacket>(
    "/book/chapters/" + id + ".json",
    "sketched.pedagogy.chapter.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== digest) {
    return <ScreenState loading={false} error="Chapter source digest mismatch" />;
  }
  const labText = data.lab.path ?? data.lab.argv?.join(" ") ?? "unbound";
  return (
    <main className="chapter-layout">
      <aside className="chapter-rail">
        <BookLink href="/book">← All paths</BookLink>
        <span className="chapter-kicker">
          {data.id} · {data.status}
        </span>
        <h1>{data.title}</h1>
        <p>{data.word_count.toLocaleString()} words</p>
        <nav aria-label="Chapter sections">
          <section className="chapter-chain" aria-label="Chapter dependency chain">
            <div>
              <span className="eyebrow">Requires</span>
              {data.prerequisites.length ? (
                data.prerequisites.map((chapter) => (
                  <BookLink href={chapter.browser_path} key={chapter.id}>
                    {chapter.id} · {chapter.title}
                  </BookLink>
                ))
              ) : (
                <span>Front door · no prior chapter</span>
              )}
            </div>
            <strong aria-hidden="true">→</strong>
            <div>
              <span className="eyebrow">Unlocks</span>
              {data.dependents.length ? (
                data.dependents.map((chapter) => (
                  <BookLink href={chapter.browser_path} key={chapter.id}>
                    {chapter.id} · {chapter.title}
                  </BookLink>
                ))
              ) : (
                <span>Terminal chapter</span>
              )}
            </div>
          </section>{" "}
          {data.sections.map((section) => (
            <a href={"#" + section.id} key={section.id}>
              {section.title}
            </a>
          ))}
        </nav>
        <a className="machine-link" href={data.json_path}>
          Chapter JSON
        </a>
      </aside>
      <article className="chapter-article">
        <header>
          <span className="eyebrow">Canonical chapter · projected into browser</span>
          <h1>{data.title}</h1>
          <div className="evidence-strip">
            <span>{data.atlas_refs.length} atlas anchors</span>
            <span>{data.code_refs.length} code anchors</span>
            <span>lab: {labText}</span>
          </div>
        </header>
        <section className="chapter-chain" aria-label="Chapter dependency chain">
          <div>
            <span className="eyebrow">Requires</span>
            {data.prerequisites.length ? (
              data.prerequisites.map((chapter) => (
                <BookLink href={chapter.browser_path} key={chapter.id}>
                  {chapter.id} · {chapter.title}
                </BookLink>
              ))
            ) : (
              <span>Front door · no prior chapter</span>
            )}
          </div>
          <strong aria-hidden="true">→</strong>
          <div>
            <span className="eyebrow">Unlocks</span>
            {data.dependents.length ? (
              data.dependents.map((chapter) => (
                <BookLink href={chapter.browser_path} key={chapter.id}>
                  {chapter.id} · {chapter.title}
                </BookLink>
              ))
            ) : (
              <span>Terminal chapter</span>
            )}
          </div>
        </section>{" "}
        {data.sections.map((section) => (
          <section id={section.id} key={section.id}>
            <h2>{section.title}</h2>
            <MarkdownText markdown={section.markdown} />
          </section>
        ))}
      </article>
    </main>
  );
}

function ContentBoundaryView({ digest }: { digest: string }) {
  const { data, error, loading } = useJson<ContentBoundary>(
    "/book/content-b.json",
    "sketched.pedagogy.content-boundary.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== digest) {
    return <ScreenState loading={false} error="Content B source digest mismatch" />;
  }
  return (
    <main className="book-main">
      <section className="boundary-hero">
        <span className="eyebrow">Reserved authorship · a real layer</span>
        <h1>{data.title}</h1>
        <p className="boundary-owner">
          Authored by {data.owner} · status: {data.status}
        </p>
        <p>{data.note}</p>
        <div
          className="empty-content"
          aria-label="Reserved Content B has no projected prose"
        >
          <strong>content: null</strong>
          <span>
            Unwritten, not withheld — a stand-in would be someone else speaking
            in the author's place.
          </span>
        </div>
      </section>
      <section className="book-section two-column">
        <div>
          <span className="eyebrow">Interface contract</span>
          <h2>How this seat is kept</h2>
          <ul className="boundary-rules">
            {data.rules?.map((rule) => (
              <li key={rule}>{rule}</li>
            ))}
          </ul>
        </div>
        <div className="boundary-source">
          <span className="eyebrow">Authoritative boundary</span>
          <p>{data.source}</p>
          <a className="machine-link" href={data.json_path}>
            Boundary JSON
          </a>
        </div>
      </section>
    </main>
  );
}

function StatusChip({
  ledger,
  gloss,
}: {
  ledger: string | null;
  gloss: string | null;
}) {
  if (!ledger) return <span className="status-chip status-none">—</span>;
  return (
    <span className={"status-chip status-" + ledger.toLowerCase()}>
      <strong>{ledger}</strong> {gloss}
    </span>
  );
}


function Book5LeanView() {
  const { data, error, loading } = useJson<Book5LeanPacket>(
    "/lean/book5.json",
    "sketched.book5-lean-coverage.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">Lean-verified Principia Symbolica</span>
        <h1>Book Five proof surface</h1>
        <p>{data.boundary}</p>
        <div className="path-actions">
          <a className="machine-link" href={data.json_path}>
            Coverage JSON
          </a>
          <span>
            {data.verified_declarations} verified declarations · {data.mapped_anchors} mapped
            anchors · {data.atlas.unmapped_claim_nodes} open claim nodes
          </span>
        </div>
      </section>
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Exact strength, declaration by declaration</span>
          <h2>Mapped claims</h2>
        </div>
        <div className="ledger-scroll">
          <table className="ledger-table">
            <thead>
              <tr>
                <th>Principia anchor</th>
                <th>Coverage</th>
                <th>Lean declarations</th>
                <th>Boundary</th>
              </tr>
            </thead>
            <tbody>
              {data.entries.map((entry) => (
                <tr key={entry.atlas_id}>
                  <td>
                    <code>{entry.atlas_id}</code>
                    <small>{entry.atlas.name}</small>
                  </td>
                  <td>
                    <span className="status-chip">{entry.coverage}</span>
                  </td>
                  <td className="ledger-witnesses">
                    {entry.theorems.map((theorem) => (
                      <code key={theorem.name} title={theorem.statement}>
                        {theorem.name}
                      </code>
                    ))}
                  </td>
                  <td>{entry.note}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Not promoted by association</span>
          <h2>Open Book Five claims</h2>
        </div>
        <div className="void-list">
          {data.unmapped_claims.map((claim) => (
            <article className="void-card" key={claim.id}>
              <span className="eyebrow">
                {claim.type} · source line {claim.line ?? "?"}
              </span>
              <p>
                <code>{claim.id}</code>
              </p>
              <p>{claim.name}</p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}

function LedgerView({ digest }: { digest: string }) {
  const { data, error, loading } = useJson<LedgerPacket>(
    "/book/ledger.json",
    "sketched.pedagogy.ledger.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== digest) {
    return <ScreenState loading={false} error="Ledger source digest mismatch" />;
  }
  const remainder = Object.entries(data.footprint.untaught_by_type)
    .map(([kind, count]) => count + " " + kind + (count === 1 ? "" : "s"))
    .join(", ");
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">Generated cross-reference</span>
        <h1>{data.title}</h1>
        <p>{data.note}</p>
        <div className="path-actions">
          <a className="machine-link" href={data.json_path}>
            Ledger JSON
          </a>
          <span>
            {data.rows.length} nodes taught · {data.footprint.untaught} left to the
            paper
          </span>
        </div>
      </section>
      <section className="book-section">
        <div className="ledger-scroll">
          <table className="ledger-table">
            <thead>
              <tr>
                <th>Atlas id</th>
                <th>Statement</th>
                <th>Ledger</th>
                <th>Proof (paper)</th>
                <th>Taught in</th>
                <th>Witnessed by</th>
              </tr>
            </thead>
            <tbody>
              {data.rows.map((row) => (
                <tr key={row.id}>
                  <td>
                    <code>{row.id}</code>
                  </td>
                  <td>{row.title}</td>
                  <td>
                    <StatusChip ledger={row.ledger} gloss={row.ledger_gloss} />
                  </td>
                  <td>{row.proof}</td>
                  <td className="ledger-chapters">
                    {row.taught_in.map((cid) => (
                      <BookLink href={"/book/chapter/" + cid} key={cid}>
                        {cid}
                      </BookLink>
                    ))}
                  </td>
                  <td className="ledger-witnesses">
                    {row.witnessed_by.map((witness) => (
                      <code key={witness}>{witness}</code>
                    ))}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
      <section className="book-section">
        <p className="ledger-footprint">
          The book teaches <strong>{data.footprint.taught}</strong> of the paper's{" "}
          <strong>{data.footprint.total}</strong> atlas nodes. The remaining{" "}
          {data.footprint.untaught} ({remainder}) are the paper's own business. A
          node absent here is not a claim the book makes silently; it is a claim
          the book does not make.
        </p>
      </section>
    </main>
  );
}

function GeographyBand({
  label,
  gloss,
  rows,
}: {
  label: string;
  gloss: string;
  rows: LedgerRow[];
}) {
  return (
    <div className={"surface-band surface-band-" + label}>
      <h3>
        {label} <small>{gloss}</small>
      </h3>
      <ul>
        {rows.map((row) => (
          <li key={row.id}>
            <code>{row.id}</code>
            <StatusChip ledger={row.ledger} gloss={row.ledger_gloss} />
            <span className="surface-taught">
              {row.taught_in.map((cid) => (
                <BookLink href={"/book/chapter/" + cid} key={cid}>
                  {cid}
                </BookLink>
              ))}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

function SurfaceView({ digest }: { digest: string }) {
  const { data, error, loading } = useJson<SurfacePacket>(
    "/book/surface.json",
    "sketched.pedagogy.surface.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== digest) {
    return <ScreenState loading={false} error="Surface source digest mismatch" />;
  }
  const untaught = Object.entries(data.voids.untaught_by_type)
    .map(([kind, count]) => count + " " + kind + (count === 1 ? "" : "s"))
    .join(", ");
  return (
    <main className="book-main">
      <section className="path-hero surface-hero">
        <div>
          <span className="eyebrow">Epistemic geography · judge-free</span>
          <h1>{data.title}</h1>
          <p>{data.note}</p>
        </div>
        <aside className="mu-tile" title={data.masking.note}>
          <span className="eyebrow">Masking rate</span>
          <strong>μ = {data.masking.mu.toFixed(2)}</strong>
          <small>
            {data.masking.masked} masked of {data.masking.tagged_mentions} tagged
            mentions · builds fail if μ &gt; 0
          </small>
        </aside>
      </section>

      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">Integrability conditions</span>
          <h2>Three invariants, already enforced</h2>
        </div>
        <div className="invariant-grid">
          {data.invariants.map((inv) => (
            <article className="invariant-card" key={inv.name}>
              <h3>{inv.name}</h3>
              <p className="invariant-surface">{inv.surface_form}</p>
              <p>{inv.book_form}</p>
              <code>{inv.enforced_by}</code>
            </article>
          ))}
        </div>
      </section>

      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">{data.geography.note}</span>
          <h2>Ground · Frontier · Open</h2>
        </div>
        <div className="surface-bands">
          <GeographyBand
            label="ground"
            gloss="established"
            rows={data.geography.ground}
          />
          <GeographyBand
            label="frontier"
            gloss="actively measured"
            rows={data.geography.frontier}
          />
          <GeographyBand label="open" gloss="owed" rows={data.geography.open} />
        </div>
      </section>

      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">{data.voids.note}</span>
          <h2>Void map</h2>
        </div>
        <div className="void-list">
          {data.voids.calibration_targets.map((v) => (
            <article className="void-card" key={v.math_id + v.calibration_item}>
              <span className="eyebrow">
                calibration item {v.calibration_item} · <code>{v.math_id}</code>
              </span>
              <p className="void-math">{v.math_operator}</p>
              <p>
                <strong>Would need:</strong> {v.would_need}
              </p>
            </article>
          ))}
        </div>
        <p className="ledger-footprint">
          Beyond the queue, {data.voids.untaught_nodes} atlas nodes ({untaught})
          stay with the paper — claims this book does not make.
        </p>
      </section>
    </main>
  );
}

function GlossaryView({ digest }: { digest: string }) {
  const { data, error, loading } = useJson<GlossaryPacket>(
    "/book/glossary.json",
    "sketched.pedagogy.glossary.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  if (data.source_digest !== digest) {
    return <ScreenState loading={false} error="Glossary source digest mismatch" />;
  }
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">Generated cross-reference</span>
        <h1>{data.title}</h1>
        <p>{data.note}</p>
        <div className="path-actions">
          <a className="machine-link" href={data.json_path}>
            Glossary JSON
          </a>
          <span>{data.terms.length} double-booked terms</span>
        </div>
      </section>
      <section className="book-section">
        {data.terms.map((entry) => {
          const counts = Object.entries(entry.occurrences)
            .map(([cid, n]) => cid + " (" + n + ")")
            .join(", ");
          return (
            <article className="glossary-term" key={entry.term}>
              <h2>{entry.term}</h2>
              <div className="glossary-senses">
                {entry.senses.map((sense) => (
                  <div className="glossary-sense" key={sense.context}>
                    <span className="eyebrow">{sense.context}</span>
                    <p>{sense.meaning}</p>
                    {sense.anchors.length ? (
                      <p className="glossary-anchor glossary-anchor-verified">
                        {sense.anchors.map((a) => (
                          <code key={a}>{a}</code>
                        ))}
                      </p>
                    ) : (
                      <p className="glossary-anchor glossary-anchor-cited">
                        cited, not verified: {sense.citation}
                      </p>
                    )}
                  </div>
                ))}
              </div>
              <p className="glossary-rule">
                <strong>Rule.</strong> {entry.rule}
              </p>
              <p className="glossary-counts">
                Where the reader meets it: {counts || "nowhere yet"}.
              </p>
            </article>
          );
        })}
      </section>
    </main>
  );
}

interface MediaCertificateExcerpt {
  [key: string]: string | number | boolean;
}

interface MediaVideo {
  slug: string;
  title: string;
  kind: string;
  mp4: string;
  poster: string;
  subtitles: string;
  certificate_path: string;
  engine: string;
  certificate: MediaCertificateExcerpt;
}

interface MediaNotebook {
  slug: string;
  title: string;
  kind: string;
  ipynb: string;
  certificate_path: string;
  audit_path: string;
  compiler: string;
  certificate: MediaCertificateExcerpt;
}

interface MediaPacket {
  schema: string;
  title: string;
  note: string;
  boundary: string;
  json_path: string;
  videos: MediaVideo[];
  notebooks: MediaNotebook[];
}

function CertificateExcerpt({
  cert,
  href,
}: {
  cert: MediaCertificateExcerpt;
  href: string;
}) {
  return (
    <div className="media-certificate">
      <span className="eyebrow">Certificate (excerpt)</span>
      <dl>
        {Object.entries(cert).map(([key, value]) => (
          <div key={key}>
            <dt>{key}</dt>
            <dd>
              <code>{String(value)}</code>
            </dd>
          </div>
        ))}
      </dl>
      <a className="machine-link" href={href}>
        Full certificate JSON
      </a>
    </div>
  );
}

function MediaView() {
  // Media assets live under /media, deliberately outside /book: the book
  // projection tool owns the /book JSON namespace and deletes foreign
  // packets on every build. The audit boundary is a filesystem boundary.
  const { data, error, loading } = useJson<MediaPacket>(
    "/media/media.json",
    "sketched.pedagogy.media.v1",
  );
  const state = <ScreenState loading={loading} error={error} />;
  if (!data) return state;
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">Deterministic media · certified artifacts</span>
        <h1>{data.title}</h1>
        <p>{data.note}</p>
        <div className="path-actions">
          <a className="machine-link" href={data.json_path}>
            Media JSON
          </a>
          <span>
            {data.videos.length} video{data.videos.length === 1 ? "" : "s"} ·{" "}
            {data.notebooks.length} notebook
            {data.notebooks.length === 1 ? "" : "s"}
          </span>
        </div>
      </section>
      <aside className="medium-notice media-boundary">
        <span className="eyebrow">Boundary · not part of the book audit chain</span>
        <p>{data.boundary}</p>
      </aside>
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">orbit_review engine · certified .mp4</span>
          <h2>Deterministic video explainers</h2>
        </div>
        <div className="media-grid">
          {data.videos.map((video) => (
            <article className="media-card" key={video.slug}>
              <span className="eyebrow">{video.kind}</span>
              <h3>{video.title}</h3>
              <video controls preload="none" poster={video.poster} className="media-player">
                <source src={video.mp4} type="video/mp4" />
                Your browser cannot play this video; the file is at {video.mp4}.
              </video>
              <p className="media-engine">
                <code>{video.engine}</code>
                {video.subtitles ? (
                  <>
                    {" "}
                    · <a href={video.subtitles}>subtitles (narration verbatim)</a>
                  </>
                ) : null}
              </p>
              <CertificateExcerpt cert={video.certificate} href={video.certificate_path} />
            </article>
          ))}
        </div>
      </section>
      <section className="book-section">
        <div className="section-heading">
          <span className="eyebrow">notebook_compiler · certified .ipynb</span>
          <h2>Deterministic notebooks</h2>
        </div>
        <div className="media-grid">
          {data.notebooks.map((notebook) => (
            <article className="media-card" key={notebook.slug}>
              <span className="eyebrow">{notebook.kind}</span>
              <h3>{notebook.title}</h3>
              <p className="media-engine">
                <code>{notebook.compiler}</code>
              </p>
              <p className="media-links">
                <a href={notebook.ipynb} download>
                  Download notebook
                </a>{" "}
                · <a href={notebook.audit_path}>audit JSON</a>
              </p>
              <CertificateExcerpt
                cert={notebook.certificate}
                href={notebook.certificate_path}
              />
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}

function MetaView({ meta }: { meta: ProjectionIndex }) {
  return (
    <main className="book-main">
      <section className="path-hero">
        <span className="eyebrow">Authoritative interface metadata</span>
        <h1>The browser knows what it carries.</h1>
        <p>{meta.medium.statement}</p>
      </section>
      <section className="book-section meta-grid">
        <div>
          <span className="eyebrow">Source digest</span>
          <code>{meta.source_digest}</code>
        </div>
        <div>
          <span className="eyebrow">Packet schema</span>
          <code>{meta.schema}</code>
        </div>
        <div>
          <span className="eyebrow">Machine entry</span>
          <a href="/book/meta.json">/book/meta.json</a>
        </div>
        <div>
          <span className="eyebrow">Reserved contribution</span>
          <BookLink href="/book/content-b">Content B contract</BookLink>
        </div>
      </section>
    </main>
  );
}
export function BookApp() {
  const route = useBookRoute();
  const {
    data: meta,
    error,
    loading,
  } = useJson<ProjectionIndex>("/book/meta.json", "sketched.pedagogy.index.v1");

  if (!meta) {
    return (
      <div className="book-app">
        <BookHeader />
        <ScreenState loading={loading} error={error} />
      </div>
    );
  }

  let view: ReactNode;
  switch (route.kind) {
    case "home":
      view = <HomeView meta={meta} />;
      break;
    case "path":
      view = <PathView id={route.id} meta={meta} />;
      break;
    case "chapter":
      view = <ChapterView id={route.id} digest={meta.source_digest} />;
      break;
    case "content-b":
      view = <ContentBoundaryView digest={meta.source_digest} />;
      break;
    case "ledger":
      view = <LedgerView digest={meta.source_digest} />;
      break;
    case "lean":
      view = <Book5LeanView />;
      break;
    case "surface":
      view = <SurfaceView digest={meta.source_digest} />;
      break;
    case "glossary":
      view = <GlossaryView digest={meta.source_digest} />;
      break;
    case "media":
      view = <MediaView />;
      break;
    case "meta":
      view = <MetaView meta={meta} />;
      break;
    case "not-found":
      view = (
        <main className="book-state">
          <h1>Projection not found</h1>
          <p>{route.path}</p>
          <BookLink href={bookHref({ kind: "home" })}>Return to the book</BookLink>
        </main>
      );
      break;
  }

  return (
    <div className="book-app">
      <BookHeader digest={meta.source_digest} />
      {view}
      <footer className="book-footer">
        <span>
          Canonical Markdown → bounded browser projection → reader reconstruction
        </span>
        <a href="/">Return to the Sketched stage</a>
      </footer>
    </div>
  );
}
