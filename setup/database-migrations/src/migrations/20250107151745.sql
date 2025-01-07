-- Create "users" table
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "user_name" character varying(255) NOT NULL,
  "email_address" character varying(255) NOT NULL,
  "first_name" character varying(255) NOT NULL,
  "last_name" character varying(255) NOT NULL,
  PRIMARY KEY ("id")
);
