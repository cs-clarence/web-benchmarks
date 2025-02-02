import {
    Kysely,
    PostgresDialect,
    type Generated,
    type Insertable,
    type Selectable,
    type Updateable,
} from "kysely";
import { Pool } from "pg";

export interface Database {
    users: UserTable;
}

export interface UserTable {
    id: Generated<number>;
    user_name: string;
    email_address: string;
    first_name: string;
    last_name: string;
}

export type User = Selectable<UserTable>;

export type NewUser = Insertable<UserTable>;
export type UserUpdate = Updateable<UserTable>;

export const database = new Kysely<Database>({
    dialect: new PostgresDialect({
        pool: new Pool({
            database: process.env.DATABASE_NAME,
            user: process.env.DATABASE_USERNAME,
            password: process.env.DATABASE_PASSWORD,
            host: process.env.DATABASE_HOSTNAME,
            port: Number(process.env.DATABASE_PORT ?? 5432),
        }),
    }),
});
