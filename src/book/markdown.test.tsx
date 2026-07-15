import { describe, expect, it } from "vitest";
import { isValidElement, type ReactElement } from "react";
import { MarkdownText, renderInline } from "./MarkdownText";
import { renderToStaticMarkup } from "react-dom/server";

function shape(node: unknown): unknown {
  if (typeof node === "string") return node;
  if (isValidElement(node)) {
    const element = node as ReactElement<{ children?: unknown }>;
    const children = element.props.children;
    return {
      [String(element.type)]: Array.isArray(children)
        ? children.map(shape)
        : shape(children),
    };
  }
  return node;
}

describe("renderInline", () => {
  it("renders status tags as bold, not literal asterisks", () => {
    expect(renderInline("proved (**P**), see the ledger").map(shape)).toEqual([
      "proved (",
      { strong: ["P"] },
      "), see the ledger",
    ]);
  });

  it("renders atlas anchors as code spans", () => {
    expect(renderInline("cites `lem:void` here").map(shape)).toEqual([
      "cites ",
      { code: "lem:void" },
      " here",
    ]);
  });

  it("keeps asterisks inside code spans literal", () => {
    expect(renderInline("`a ** b`").map(shape)).toEqual([{ code: "a ** b" }]);
  });

  it("nests code inside bold", () => {
    expect(renderInline("**run `lab08` now**").map(shape)).toEqual([
      { strong: ["run ", { code: "lab08" }, " now"] },
    ]);
  });

  it("renders single-asterisk emphasis", () => {
    expect(renderInline("a *medium*, not occupancy").map(shape)).toEqual([
      "a ",
      { em: ["medium"] },
      ", not occupancy",
    ]);
  });

  it("leaves unmatched markers verbatim", () => {
    expect(renderInline("2 ** 7 masks and a * bullet")).toEqual([
      "2 ** 7 masks and a * bullet",
    ]);
  });
});

describe("MarkdownText block parsing", () => {
  it("joins a numbered list item that wraps across indented continuation lines", () => {
    const markdown = [
      "1. **Predict, then run.** How many filters does the depth-3 binary tree",
      "   have? Write both numbers down; then check.",
      "2. Show by hand that the pair breaks downward directedness.",
    ].join("\n");
    const html = renderToStaticMarkup(<MarkdownText markdown={markdown} />);
    expect(html).toContain(
      "How many filters does the depth-3 binary tree have? Write both numbers down; then check.",
    );
    expect(html).toContain("Show by hand that the pair breaks downward directedness.");
    // exactly one <ol>, not one per item (numbering must not restart per item)
    expect(html.match(/<ol>/g)?.length).toBe(1);
    expect(html.match(/<li>/g)?.length).toBe(2);
  });

  it("joins a bulleted list item that wraps across indented continuation lines", () => {
    const markdown = [
      "- Channel. Paper: the channel-margin subposet, the region where the",
      "  interaction matrix keeps a positive spectral margin.",
      "- Forcing. Two senses the paper itself separates.",
    ].join("\n");
    const html = renderToStaticMarkup(<MarkdownText markdown={markdown} />);
    expect(html).toContain(
      "Channel. Paper: the channel-margin subposet, the region where the interaction matrix keeps a positive spectral margin.",
    );
    expect(html.match(/<ul>/g)?.length).toBe(1);
    expect(html.match(/<li>/g)?.length).toBe(2);
  });

  it("still separates single-line list items correctly", () => {
    const markdown = ["1. First item.", "2. Second item.", "3. Third item."].join(
      "\n",
    );
    const html = renderToStaticMarkup(<MarkdownText markdown={markdown} />);
    expect(html.match(/<li>/g)?.length).toBe(3);
    expect(html).toContain("First item.");
    expect(html).toContain("Second item.");
    expect(html).toContain("Third item.");
  });

  it("terminates a list at a blank line or a new block, not mid-paragraph", () => {
    const markdown = [
      "- one",
      "  continued",
      "",
      "A plain paragraph that follows.",
    ].join("\n");
    const html = renderToStaticMarkup(<MarkdownText markdown={markdown} />);
    expect(html.match(/<li>/g)?.length).toBe(1);
    expect(html).toContain("one continued");
    expect(html).toContain("<p>A plain paragraph that follows.</p>");
  });
});
