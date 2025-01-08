-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_address_key" UNIQUE ("email_address"), ADD CONSTRAINT "users_user_name_key" UNIQUE ("user_name");
