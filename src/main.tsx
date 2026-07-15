import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import { DrawApp } from "./draw/DrawApp";
import { BookApp } from "./book/BookApp";
import { HumanFloorApp } from "./flow/HumanFloorApp";
import "./styles.css";

const root = document.getElementById("root");
if (!root) throw new Error("Missing #root element");

const path = window.location.pathname;
const bookSurface = path.startsWith("/book");
const flowSurface = path.startsWith("/flow");
// The panel/stage workbench keeps its full interface at /stage; draw mode is
// the presented face at "/". Same Stage, Gatekeeper, and audit underneath.
const stageSurface = path.startsWith("/stage");

if (flowSurface) document.title = "Human Floor - Sketched";
if (bookSurface) document.title = "Forcing at the Surface — Sketched";
if (stageSurface) document.title = "Stage workbench — Sketched";

createRoot(root).render(
  <StrictMode>
    {bookSurface ? (
      <BookApp />
    ) : flowSurface ? (
      <HumanFloorApp />
    ) : stageSurface ? (
      <App />
    ) : (
      <DrawApp />
    )}
  </StrictMode>,
);
