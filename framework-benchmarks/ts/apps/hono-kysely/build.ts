Bun.build({
    entrypoints: [process.env.BUILD_ENTRYPOINT ?? "./src/index.ts"],
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
