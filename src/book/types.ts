export interface MediumContract {
  kind: string;
  statement: string;
  calibration: string;
}

export interface ContentBoundary {
  schema?: string;
  source_digest?: string;
  id: string;
  title?: string;
  owner: string;
  status: string;
  source?: string;
  inclusion?: string;
  content?: null;
  rules?: string[];
  browser_path: string;
  json_path?: string;
  note?: string;
}

export interface PathSummary {
  id: string;
  title: string;
  description: string;
  audience: string;
  chapter_ids: string[];
  assumed_chapter_ids: string[];
  includes_content_b: boolean;
  browser_path: string;
  json_path: string;
  chapter_count: number;
  assumption_count: number;
}

export interface ChapterSummary {
  id: string;
  title: string;
  status: string;
  prerequisite_ids: string[];
  source_path: string;
  browser_path: string;
  json_path: string;
  aim: string;
  word_count: number;
}

export interface ChapterSection {
  id: string;
  title: string;
  markdown: string;
}

export interface LabBinding {
  kind: "python" | "command";
  path?: string;
  argv?: string[];
}

export interface ChapterLink {
  id: string;
  title: string;
  browser_path: string;
}
export interface ChapterPacket extends ChapterSummary {
  schema: string;
  source_digest: string;
  boundary_note: string;
  atlas_refs: string[];
  code_refs: Array<{ file: string; export: string }>;
  lab: LabBinding;
  prerequisites: ChapterLink[];
  dependents: ChapterLink[];
  sections: ChapterSection[];
  raw_markdown: string;
}

export interface LedgerRow {
  id: string;
  title: string;
  type: string;
  ledger: string | null;
  ledger_gloss: string | null;
  proof: string;
  taught_in: string[];
  witnessed_by: string[];
}

export interface LedgerFootprint {
  taught: number;
  total: number;
  untaught: number;
  untaught_by_type: Record<string, number>;
}

export interface LedgerPacket {
  schema: string;
  source_digest: string;
  title: string;
  note: string;
  status_gloss: Record<string, string>;
  rows: LedgerRow[];
  footprint: LedgerFootprint;
  browser_path: string;
  json_path: string;
}

export interface SurfaceInvariant {
  name: string;
  surface_form: string;
  book_form: string;
  enforced_by: string;
}

export interface SurfaceVoidTarget {
  math_id: string;
  calibration_item: number;
  math_operator: string;
  would_need: string;
}

export interface SurfacePacket {
  schema: string;
  source_digest: string;
  title: string;
  note: string;
  invariants: SurfaceInvariant[];
  masking: {
    tagged_mentions: number;
    masked: number;
    mu: number;
    note: string;
  };
  geography: {
    note: string;
    ground: LedgerRow[];
    frontier: LedgerRow[];
    open: LedgerRow[];
  };
  voids: {
    note: string;
    calibration_targets: SurfaceVoidTarget[];
    untaught_nodes: number;
    untaught_by_type: Record<string, number>;
  };
  browser_path: string;
  json_path: string;
}

export interface GlossarySense {
  context: string;
  meaning: string;
  anchors: string[];
  citation: string | null;
}

export interface GlossaryTerm {
  term: string;
  rule: string;
  senses: GlossarySense[];
  occurrences: Record<string, number>;
}

export interface GlossaryPacket {
  schema: string;
  source_digest: string;
  title: string;
  note: string;
  terms: GlossaryTerm[];
  browser_path: string;
  json_path: string;
}

export interface ProjectionIndex {
  schema: string;
  source_digest: string;
  title: string;
  medium: MediumContract;
  paths: PathSummary[];
  chapters: ChapterSummary[];
  dependency_graph: {
    nodes: Array<{ id: string; title: string }>;
    edges: Array<{ from: string; to: string }>;
  };
  content_b: ContentBoundary;
  ledger?: {
    browser_path: string;
    json_path: string;
    rows: number;
    footprint: LedgerFootprint;
  };
  surface?: {
    browser_path: string;
    json_path: string;
    mu: number;
    ground: number;
    frontier: number;
    open: number;
    voids: number;
  };
  glossary?: {
    browser_path: string;
    json_path: string;
    terms: number;
  };
  links: Record<string, string>;
}

export interface ProjectionPacket {
  schema: string;
  source_digest: string;
  title: string;
  medium: MediumContract;
  projection: PathSummary;
  chain: {
    assumed_chapter_ids: string[];
    sequence: string[];
    edges: Array<{ from: string; to: string }>;
  };
  content_b: ContentBoundary;
  chapters: ChapterPacket[];
}

export interface Book5LeanTheorem {
  name: string;
  file: string;
  statement: string;
  axioms: string[];
  sorry: boolean;
  status: string;
}

export interface Book5LeanEntry {
  atlas_id: string;
  coverage: string;
  note: string;
  atlas: {
    type: string | null;
    name: string | null;
    file: string | null;
    line: number | null;
    proof_status: string | null;
  };
  theorems: Book5LeanTheorem[];
}

export interface Book5LeanPacket {
  schema: string;
  source: string;
  boundary: string;
  verified_declarations: number;
  mapped_anchors: number;
  mapped_declarations: number;
  coverage_counts: Record<string, number>;
  atlas: {
    book5_nodes: number;
    claim_nodes: number;
    unmapped_claim_nodes: number;
  };
  entries: Book5LeanEntry[];
  unmapped_claims: Array<{
    id: string;
    type: string;
    name: string | null;
    line: number | null;
    proof_status: string | null;
  }>;
  browser_path: string;
  json_path: string;
}