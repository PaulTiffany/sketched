import type { ReactNode } from "react";

const FENCE = String.fromCharCode(96).repeat(3);

// Inline spans, tried left to right: code (atomic — asterisks inside stay
// literal), then bold, then emphasis. Anything else renders verbatim; the
// canonical Markdown remains the authority and this renderer never guesses.
const INLINE_RE = /(`[^`]+`|\*\*[^*]+\*\*|\*[^*\s][^*]*\*)/g;

export function renderInline(text: string): ReactNode[] {
  return text
    .split(INLINE_RE)
    .filter(Boolean)
    .map((part, index) => {
      if (part.startsWith("`") && part.endsWith("`") && part.length > 2) {
        return <code key={index}>{part.slice(1, -1)}</code>;
      }
      if (part.startsWith("**") && part.endsWith("**") && part.length > 4) {
        return <strong key={index}>{renderInline(part.slice(2, -2))}</strong>;
      }
      if (part.startsWith("*") && part.endsWith("*") && part.length > 2) {
        return <em key={index}>{renderInline(part.slice(1, -1))}</em>;
      }
      return part;
    });
}

function isBlockStart(line: string): boolean {
  return (
    line.startsWith(FENCE) ||
    line.startsWith("### ") ||
    line.startsWith("- ") ||
    /^\d+\.\s/.test(line) ||
    line.startsWith("> ") ||
    line.startsWith("|")
  );
}

export function MarkdownText({ markdown }: { markdown: string }) {
  const lines = markdown.split(/\r?\n/);
  const blocks: ReactNode[] = [];
  let index = 0;

  while (index < lines.length) {
    const line = lines[index] ?? "";
    if (!line.trim()) {
      index += 1;
      continue;
    }

    if (line.startsWith(FENCE)) {
      const language = line.slice(3).trim();
      const code: string[] = [];
      index += 1;
      while (index < lines.length && !(lines[index] ?? "").startsWith(FENCE)) {
        code.push(lines[index] ?? "");
        index += 1;
      }
      index += 1;
      blocks.push(
        <pre
          className="book-code"
          data-language={language || undefined}
          key={blocks.length}
        >
          <code>{code.join("\n")}</code>
        </pre>,
      );
      continue;
    }

    if (line.startsWith("### ")) {
      blocks.push(<h3 key={blocks.length}>{renderInline(line.slice(4))}</h3>);
      index += 1;
      continue;
    }

    if (line.startsWith("- ")) {
      const items: string[] = [];
      while (index < lines.length && (lines[index] ?? "").startsWith("- ")) {
        const parts = [(lines[index] ?? "").slice(2).trim()];
        index += 1;
        while (
          index < lines.length &&
          (lines[index] ?? "").trim() &&
          !isBlockStart(lines[index] ?? "")
        ) {
          parts.push((lines[index] ?? "").trim());
          index += 1;
        }
        items.push(parts.join(" "));
      }
      blocks.push(
        <ul key={blocks.length}>
          {items.map((item, itemIndex) => (
            <li key={itemIndex}>{renderInline(item)}</li>
          ))}
        </ul>,
      );
      continue;
    }

    if (/^\d+\.\s/.test(line)) {
      const items: string[] = [];
      while (index < lines.length && /^\d+\.\s/.test(lines[index] ?? "")) {
        const parts = [(lines[index] ?? "").replace(/^\d+\.\s/, "").trim()];
        index += 1;
        while (
          index < lines.length &&
          (lines[index] ?? "").trim() &&
          !isBlockStart(lines[index] ?? "")
        ) {
          parts.push((lines[index] ?? "").trim());
          index += 1;
        }
        items.push(parts.join(" "));
      }
      blocks.push(
        <ol key={blocks.length}>
          {items.map((item, itemIndex) => (
            <li key={itemIndex}>{renderInline(item)}</li>
          ))}
        </ol>,
      );
      continue;
    }

    if (line.startsWith("> ")) {
      const quote: string[] = [];
      while (index < lines.length && (lines[index] ?? "").startsWith("> ")) {
        quote.push((lines[index] ?? "").slice(2));
        index += 1;
      }
      blocks.push(
        <blockquote key={blocks.length}>{renderInline(quote.join(" "))}</blockquote>,
      );
      continue;
    }

    if (line.startsWith("|")) {
      const table: string[] = [];
      while (index < lines.length && (lines[index] ?? "").startsWith("|")) {
        table.push(lines[index] ?? "");
        index += 1;
      }
      blocks.push(
        <pre className="book-table" key={blocks.length}>
          {table.join("\n")}
        </pre>,
      );
      continue;
    }

    const paragraph = [line.trim()];
    index += 1;
    while (
      index < lines.length &&
      (lines[index] ?? "").trim() &&
      !isBlockStart(lines[index] ?? "")
    ) {
      paragraph.push((lines[index] ?? "").trim());
      index += 1;
    }
    blocks.push(<p key={blocks.length}>{renderInline(paragraph.join(" "))}</p>);
  }

  return <div className="book-markdown">{blocks}</div>;
}
