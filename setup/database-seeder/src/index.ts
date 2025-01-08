import { Pool } from "pg";
import { faker } from "@faker-js/faker";
import process from "node:process";

const pool = new Pool({
    user: process.env.DATABASE_USER || "root",
    host: process.env.DATABASE_HOSTNAME || "database",
    database: process.env.DATABASE_NAME || "web_benchmarks",
    password: process.env.DATABASE_PASSWORD || "password",
    port: Number(process.env.DATABASE_PORT || 5432),
});

type User = {
    userName: string;
    emailAddress: string;
    firstName: string;
    lastName: string;
};

function generateBatchInsertQuery(batch: User[]) {
    const placeholders = batch
        .map((_, i) => {
            const idx = i * 4;
            return `($${idx + 1}, $${idx + 2}, $${idx + 3}, $${idx + 4})`;
        })
        .join(",");

    const values = batch.flatMap((u) => [
        u.userName,
        u.emailAddress,
        u.firstName,
        u.lastName,
    ]);

    return [
        `INSERT INTO users (user_name, email_address, first_name, last_name) VALUES ${placeholders}`,
        values,
    ] as const;
}

async function seedUsers() {
    const client = await pool.connect();
    const batch = [] as User[];
    const batchSize = Number.parseInt(process.env.BATCH_SIZE || "2000");
    const totalSize = Number.parseInt(process.env.TOTAL_SIZE || "10000");
    

    const currentCount = await client.query("SELECT COUNT(*) AS count FROM users").then((res) => res.rows[0].count);
    
    if (currentCount >= totalSize) {
        console.log("Users already seeded");
        return;
    }

    try {
        console.log("Seeding users...");

        for (let i = 0; i < totalSize; i++) {
            const userName = faker.internet.username() + i;
            const emailAddress = faker.internet.email().replace("@", `_${i}@`);
            const firstName = faker.person.firstName();
            const lastName = faker.person.lastName();

            batch.push({
                emailAddress,
                firstName,
                lastName,
                userName,
            });

            if (batch.length === batchSize) {
                const [q, v] = generateBatchInsertQuery(batch);
                await client.query(q, v);
                batch.length = 0;
            }
        }

        console.log("Seeding completed.");
    } catch (err) {
        console.error("Error seeding users:", err);
    } finally {
        client.release();
    }
}

seedUsers().catch((err) => console.error("Seeding script error:", err));
