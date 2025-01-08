Bun.build({
    entrypoints: ["./src/index.ts"],
    format: "esm",
    splitting: true,
    packages: "bundle",
    outdir: "./dist",
    target: "bun",
    minify: true,
    define: {
        "process.env.NODE_ENV": '"production"',
    },
});