import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Sketched runs local-first. No proxying to remote services here on purpose:
// the shared center is localhost, and there are no hidden network calls.
export default defineConfig({
  plugins: [react()],
  server: {
    host: "127.0.0.1",
    port: 5173,
  },
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.test.{ts,tsx}"],
  },
});
