CREATE TABLE "users" (
  "id" bigserial PRIMARY KEY,
  "full_name" varchar(150),
  "email" varchar(150) UNIQUE,
  "phone_number" varchar(50),
  "password_hash" varchar(255),
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp
);

CREATE TABLE "accounts" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint,
  "account_number" varchar(30) UNIQUE,
  "account_type" varchar(50),
  "currency" varchar(10),
  "balance" decimal(18,2) DEFAULT 0,
  "status" varchar(20),
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "transactions" (
  "id" bigserial PRIMARY KEY,
  "account_id" bigint,
  "txn_type" varchar(50),
  "amount" decimal(18,2),
  "reference" varchar(100),
  "description" text,
  "related_account" bigint,
  "status" varchar(50),
  "created_at" timestamp DEFAULT (now())
);

CREATE UNIQUE INDEX ON "users" ("email");

CREATE INDEX ON "users" ("phone_number");

CREATE INDEX ON "users" ("created_at");

CREATE INDEX ON "accounts" ("user_id");

CREATE UNIQUE INDEX ON "accounts" ("account_number");

CREATE INDEX ON "accounts" ("account_type");

CREATE INDEX ON "accounts" ("status");

CREATE INDEX ON "accounts" ("created_at");

CREATE INDEX ON "transactions" ("account_id");

CREATE INDEX ON "transactions" ("txn_type");

CREATE INDEX ON "transactions" ("status");

CREATE INDEX ON "transactions" ("created_at");

ALTER TABLE "accounts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("account_id") REFERENCES "accounts" ("id");
