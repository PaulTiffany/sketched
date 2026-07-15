export type BookRoute =
  | { kind: "home" }
  | { kind: "path"; id: string }
  | { kind: "chapter"; id: string }
  | { kind: "content-b" }
  | { kind: "ledger" }
  | { kind: "lean" }
  | { kind: "surface" }
  | { kind: "glossary" }
  | { kind: "media" }
  | { kind: "meta" }
  | { kind: "not-found"; path: string };

function safeDecode(value: string): string | null {
  try {
    const decoded = decodeURIComponent(value);
    return decoded && !decoded.includes("/") ? decoded : null;
  } catch {
    return null;
  }
}
export function parseBookRoute(pathname: string): BookRoute {
  const path = pathname.replace(/\/+$/, "") || "/";
  if (path === "/book") return { kind: "home" };
  if (path === "/book/content-b") return { kind: "content-b" };
  if (path === "/book/ledger") return { kind: "ledger" };
  if (path === "/book/lean") return { kind: "lean" };
  if (path === "/book/surface") return { kind: "surface" };
  if (path === "/book/glossary") return { kind: "glossary" };
  if (path === "/book/media") return { kind: "media" };
  if (path === "/book/meta") return { kind: "meta" };

  const pathMatch = path.match(/^\/book\/path\/([^/]+)$/);
  if (pathMatch?.[1]) {
    const id = safeDecode(pathMatch[1]);
    if (id) return { kind: "path", id };
  }

  const chapterMatch = path.match(/^\/book\/chapter\/([^/]+)$/);
  if (chapterMatch?.[1]) {
    const id = safeDecode(chapterMatch[1]);
    if (id) return { kind: "chapter", id };
  }
  return { kind: "not-found", path: pathname };
}

export function bookHref(route: BookRoute): string {
  switch (route.kind) {
    case "home":
      return "/book";
    case "path":
      return "/book/path/" + encodeURIComponent(route.id);
    case "chapter":
      return "/book/chapter/" + encodeURIComponent(route.id);
    case "content-b":
      return "/book/content-b";
    case "ledger":
      return "/book/ledger";
    case "lean":
      return "/book/lean";
    case "surface":
      return "/book/surface";
    case "glossary":
      return "/book/glossary";
    case "media":
      return "/book/media";
    case "meta":
      return "/book/meta";
    case "not-found":
      return route.path;
  }
}
