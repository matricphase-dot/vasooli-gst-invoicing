BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "invoice" ADD COLUMN "dueDate" timestamp without time zone;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "payment" (
    "id" bigserial PRIMARY KEY,
    "invoiceId" bigint NOT NULL,
    "amount" double precision NOT NULL,
    "method" text NOT NULL,
    "upiReference" text,
    "paidAt" timestamp without time zone NOT NULL,
    "note" text
);

-- Indexes
CREATE INDEX "payment_invoice_idx" ON "payment" USING btree ("invoiceId");


--
-- MIGRATION VERSION FOR vasooli
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vasooli', '20260927172443793', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927172443793', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
