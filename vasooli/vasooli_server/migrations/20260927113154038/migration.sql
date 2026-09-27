BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "invoice" (
    "id" bigserial PRIMARY KEY,
    "invoiceNumber" text NOT NULL,
    "financialYear" text NOT NULL,
    "issueDate" timestamp without time zone NOT NULL,
    "clientName" text NOT NULL,
    "clientGstin" text,
    "supplierStateCode" bigint NOT NULL,
    "placeOfSupplyStateCode" bigint NOT NULL,
    "status" text NOT NULL,
    "lines" json NOT NULL,
    "totalTaxable" double precision NOT NULL,
    "cgst" double precision NOT NULL,
    "sgst" double precision NOT NULL,
    "igst" double precision NOT NULL,
    "grandTotal" double precision NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "invoice_number_per_fy_unique" ON "invoice" USING btree ("financialYear", "invoiceNumber");


--
-- MIGRATION VERSION FOR vasooli
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vasooli', '20260927113154038', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927113154038', "timestamp" = now();

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
