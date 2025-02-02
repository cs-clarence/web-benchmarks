import "$/bigint-polyfill";

import app from "$/app";

console.log("Starting server...");
Bun.serve({ ...app, hostname: "0.0.0.0" });
