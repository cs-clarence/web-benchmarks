import { Hono } from "hono";
import { database } from "$/database";

const app = new Hono();

function factorial(n: bigint): bigint {
    if (n === 0n) {
        return 1n;
    }
    return n * factorial(n - 1n);
}

app.get("/users", async (c) => {
    const users = await database
        .selectFrom("users")
        .select([
            "user_name as userName",
            "email_address as emailAddress",
            "first_name as firstName",
            "last_name as lastName",
        ])
        .execute();

    return c.json(users);
});

app.get("/factorial/:n", async (c) => {
    const n = Number(c.req.param("n"));
    return c.json(factorial(BigInt(n)));
});

export default {
    port: Number(process.env.PORT ?? 80),
    fetch: app.fetch,
};
