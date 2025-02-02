import { Hono } from "hono";
import { database } from "$/database";

const app = new Hono();

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

export default {
    port: Number(process.env.PORT ?? 80),
    fetch: app.fetch,
};
