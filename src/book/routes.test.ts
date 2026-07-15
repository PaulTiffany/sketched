import { bookHref, parseBookRoute } from "./routes";

describe("book browser routes", () => {
  it("recognizes the projection home and normalized trailing slash", () => {
    expect(parseBookRoute("/book")).toEqual({ kind: "home" });
    expect(parseBookRoute("/book/")).toEqual({ kind: "home" });
  });

  it("recognizes path, chapter, metadata, and Content B routes", () => {
    expect(parseBookRoute("/book/path/forcing-spine")).toEqual({
      kind: "path",
      id: "forcing-spine",
    });
    expect(parseBookRoute("/book/chapter/ch07")).toEqual({ kind: "chapter", id: "ch07" });
    expect(parseBookRoute("/book/meta")).toEqual({ kind: "meta" });
    expect(parseBookRoute("/book/content-b")).toEqual({ kind: "content-b" });
  });

  it("recognizes the ledger route and round-trips its href", () => {
    expect(parseBookRoute("/book/ledger")).toEqual({ kind: "ledger" });
    expect(parseBookRoute("/book/ledger/")).toEqual({ kind: "ledger" });
    expect(parseBookRoute(bookHref({ kind: "ledger" }))).toEqual({ kind: "ledger" });
  });



  it("recognizes the Book Five Lean route and round-trips its href", () => {
    expect(parseBookRoute("/book/lean")).toEqual({ kind: "lean" });
    expect(parseBookRoute("/book/lean/")).toEqual({ kind: "lean" });
    expect(parseBookRoute(bookHref({ kind: "lean" }))).toEqual({ kind: "lean" });
  });
  it("recognizes the hypothesis-surface route and round-trips its href", () => {
    expect(parseBookRoute("/book/surface")).toEqual({ kind: "surface" });
    expect(parseBookRoute("/book/surface/")).toEqual({ kind: "surface" });
    expect(parseBookRoute(bookHref({ kind: "surface" }))).toEqual({
      kind: "surface",
    });
  });

  it("recognizes the glossary route and round-trips its href", () => {
    expect(parseBookRoute("/book/glossary")).toEqual({ kind: "glossary" });
    expect(parseBookRoute("/book/glossary/")).toEqual({ kind: "glossary" });
    expect(parseBookRoute(bookHref({ kind: "glossary" }))).toEqual({
      kind: "glossary",
    });
  });

  it("recognizes the deterministic-media route and round-trips its href", () => {
    expect(parseBookRoute("/book/media")).toEqual({ kind: "media" });
    expect(parseBookRoute("/book/media/")).toEqual({ kind: "media" });
    expect(parseBookRoute(bookHref({ kind: "media" }))).toEqual({ kind: "media" });
  });

  it("round-trips encoded route ids", () => {
    const route = { kind: "path", id: "reader's route" } as const;
    expect(parseBookRoute(bookHref(route))).toEqual(route);
  });

  it("rejects malformed or slash-decoded route ids without throwing", () => {
    expect(parseBookRoute("/book/path/%E0%A4%A")).toEqual({
      kind: "not-found",
      path: "/book/path/%E0%A4%A",
    });
    expect(parseBookRoute("/book/chapter/ch01%2Fescape")).toEqual({
      kind: "not-found",
      path: "/book/chapter/ch01%2Fescape",
    });
  });
  it("keeps unknown book locations explicit", () => {
    expect(parseBookRoute("/book/nope")).toEqual({
      kind: "not-found",
      path: "/book/nope",
    });
  });
});
