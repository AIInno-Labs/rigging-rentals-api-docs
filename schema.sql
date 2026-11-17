CREATE TABLE "organization" (
  "id" uuid PRIMARY KEY,
  "company_name" varchar(200) NOT NULL,
  "company_code" varchar(30) UNIQUE NOT NULL,
  "currency" char(3) NOT NULL DEFAULT 'AUD',
  "gst_no" varchar(20),
  "address_line1" varchar(200),
  "address_line2" varchar(200),
  "city" varchar(100),
  "state" varchar(50),
  "postcode" varchar(10),
  "country" varchar(60),
  "contact_name" varchar(120),
  "contact_email" varchar(200),
  "contact_phone" varchar(40),
  "logo" bytea,
  "logo_mime" varchar(50),
  "active" boolean NOT NULL DEFAULT true
);

CREATE TABLE "users" (
  "user_id" uuid PRIMARY KEY,
  "organization_id" uuid,
  "email" varchar(200) NOT NULL,
  "full_name" varchar(120),
  "phone" varchar(40),
  "password" varchar(100),
  "auth_provider" varchar(20),
  "enabled" boolean NOT NULL DEFAULT true,
  "locked" boolean NOT NULL DEFAULT false,
  "failed_attempt" int NOT NULL DEFAULT 0,
  "lock_time" timestamptz,
  "last_login_at" timestamptz,
  "password_changed_at" timestamptz
);

CREATE TABLE "roles" (
  "role_id" uuid PRIMARY KEY,
  "organization_id" uuid,
  "role" varchar(80) NOT NULL,
  "role_code" varchar(40) NOT NULL,
  "description" text,
  "system_managed" boolean NOT NULL DEFAULT false
);

CREATE TABLE "privileges" (
  "privilege_id" uuid PRIMARY KEY,
  "privilege_code" varchar(60) UNIQUE NOT NULL,
  "privilege_type" varchar(10) NOT NULL,
  "domain" varchar(40),
  "field_key" varchar(80),
  "access_mode" varchar(10),
  "description" varchar(200),
  "system_managed" boolean NOT NULL DEFAULT true,
  "active" boolean NOT NULL DEFAULT true,
  "sort_order" int
);

CREATE TABLE "users_roles" (
  "user_id" uuid,
  "role_id" uuid,
  PRIMARY KEY ("user_id", "role_id")
);

CREATE TABLE "roles_privileges" (
  "role_id" uuid,
  "privilege_id" uuid,
  PRIMARY KEY ("role_id", "privilege_id")
);

CREATE TABLE "application_parameter" (
  "id" uuid PRIMARY KEY,
  "param_name" varchar(100) NOT NULL,
  "param_value" text,
  "param_type" varchar(10) NOT NULL,
  "organization_id" uuid,
  "org_editable" boolean NOT NULL DEFAULT false,
  "description" varchar(200)
);

CREATE TABLE "stages" (
  "stage_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "entity_type" varchar(20) NOT NULL,
  "code" varchar(40) NOT NULL,
  "name" varchar(80) NOT NULL,
  "owner_role_id" uuid,
  "sequence" int,
  "is_initial" boolean,
  "is_terminal" boolean,
  "is_editable" boolean,
  "color" varchar(7)
);

CREATE TABLE "stage_transitions" (
  "transition_id" uuid PRIMARY KEY,
  "from_stage_id" uuid NOT NULL,
  "to_stage_id" uuid NOT NULL,
  "allowed_role_id" uuid,
  "action_code" varchar(40) NOT NULL,
  "requires_reason" boolean DEFAULT false
);

CREATE TABLE "stage_history" (
  "history_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "entity_type" varchar(20) NOT NULL,
  "entity_id" uuid NOT NULL,
  "from_stage_id" uuid,
  "to_stage_id" uuid,
  "action_code" varchar(40),
  "reason" text,
  "changed_by" uuid,
  "changed_at" timestamptz NOT NULL
);

CREATE TABLE "document_type_stage_rules" (
  "rule_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "doc_type_code" varchar(40) NOT NULL,
  "stage_id" uuid NOT NULL,
  "requirement" varchar(20) NOT NULL
);

CREATE TABLE "customers" (
  "customer_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "company_name" varchar(200) NOT NULL,
  "abn" varchar(20),
  "payment_type" varchar(10) NOT NULL,
  "credit_limit" numeric(12,2),
  "payment_terms_days" int,
  "on_stop" boolean NOT NULL DEFAULT false,
  "on_stop_reason" text,
  "billing_address" text,
  "notes" text,
  "xero_contact_id" varchar(64),
  "deleted_at" timestamptz
);

CREATE TABLE "customer_contacts" (
  "contact_id" uuid PRIMARY KEY,
  "customer_id" uuid NOT NULL,
  "name" varchar(120) NOT NULL,
  "email" varchar(200),
  "phone" varchar(40),
  "position" varchar(80),
  "is_primary" boolean DEFAULT false,
  "is_billing_contact" boolean DEFAULT false
);

CREATE TABLE "customer_sites" (
  "site_id" uuid PRIMARY KEY,
  "customer_id" uuid NOT NULL,
  "name" varchar(200),
  "address" text,
  "access_notes" text
);

CREATE TABLE "inquiry_sources" (
  "source_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "name" varchar(40) NOT NULL,
  "is_active" boolean DEFAULT true
);

CREATE TABLE "inquiries" (
  "inquiry_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "inquiry_no" varchar(20) NOT NULL,
  "source_id" uuid,
  "customer_id" uuid,
  "company" varchar(200),
  "contact_name" varchar(120),
  "email" varchar(200),
  "phone" varchar(40),
  "description" text,
  "raw_message" text,
  "jobsite" varchar(200),
  "hire_start" date,
  "hire_end" date,
  "duration_text" varchar(60),
  "est_value" numeric(12,2),
  "estimation_notes" text,
  "notes" text,
  "stage_id" uuid NOT NULL,
  "lost_reason" text,
  "assigned_to" uuid,
  "quote_id" uuid
);

CREATE TABLE "inquiry_items" (
  "item_id" uuid PRIMARY KEY,
  "inquiry_id" uuid NOT NULL,
  "category_id" uuid,
  "model_id" uuid,
  "qty" int,
  "capacity_text" varchar(40),
  "notes" text
);

CREATE TABLE "quotes" (
  "quote_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "quote_no" varchar(20) NOT NULL,
  "inquiry_id" uuid,
  "customer_id" uuid NOT NULL,
  "contact_id" uuid,
  "version" int NOT NULL DEFAULT 1,
  "hire_start" timestamptz,
  "hire_end" timestamptz,
  "jobsite" varchar(200),
  "customer_po" varchar(60),
  "delivery_address" text,
  "delivery_required" boolean,
  "pickup_required" boolean,
  "fuel_amount" numeric(12,2),
  "deposit_amount" numeric(12,2),
  "deposit_received_at" timestamptz,
  "damage_waiver" boolean,
  "quote_notes" text,
  "job_notes" text,
  "est_total" numeric(12,2),
  "valid_until" date,
  "stage_id" uuid NOT NULL,
  "tnc_accepted_by" varchar(120),
  "tnc_accepted_via" varchar(20),
  "tnc_accepted_at" timestamptz,
  "tnc_proof_document_id" uuid,
  "order_id" uuid
);

CREATE TABLE "quote_lines" (
  "line_id" uuid PRIMARY KEY,
  "quote_id" uuid NOT NULL,
  "category_id" uuid NOT NULL,
  "model_id" uuid,
  "qty" int NOT NULL,
  "daily_rate" numeric(12,2),
  "weekly_rate" numeric(12,2),
  "monthly_rate" numeric(12,2),
  "rate_overridden" boolean DEFAULT false,
  "line_notes" text,
  "sort_order" int
);

CREATE TABLE "orders" (
  "order_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "order_no" varchar(20) NOT NULL,
  "quote_id" uuid,
  "customer_id" uuid NOT NULL,
  "contact_id" uuid,
  "hire_start" timestamptz,
  "hire_end" timestamptz,
  "off_rent_at" timestamptz,
  "jobsite" varchar(200),
  "customer_po" varchar(60),
  "delivery_address" text,
  "delivery_required" boolean,
  "pickup_required" boolean,
  "fuel_amount" numeric(12,2),
  "deposit_amount" numeric(12,2),
  "damage_waiver" boolean,
  "quote_notes" text,
  "job_notes" text,
  "stage_id" uuid NOT NULL,
  "confirmed_by" uuid,
  "confirmed_at" timestamptz,
  "cancelled_reason" text
);

CREATE TABLE "order_lines" (
  "line_id" uuid PRIMARY KEY,
  "order_id" uuid NOT NULL,
  "quote_line_id" uuid,
  "model_id" uuid NOT NULL,
  "qty" int NOT NULL,
  "daily_rate" numeric(12,2),
  "weekly_rate" numeric(12,2),
  "monthly_rate" numeric(12,2),
  "line_notes" text
);

CREATE TABLE "order_line_assets" (
  "assignment_id" uuid PRIMARY KEY,
  "order_line_id" uuid NOT NULL,
  "instrument_id" uuid NOT NULL,
  "assigned_by" uuid,
  "assigned_at" timestamptz,
  "dispatched_at" timestamptz,
  "dispatch_meter" numeric(10,2),
  "returned_at" timestamptz,
  "return_meter" numeric(10,2),
  "overage_amount" numeric(12,2),
  "damage_flag" boolean,
  "missing_flag" boolean,
  "qc_notes" text,
  "qc_outcome" varchar(20)
);

CREATE TABLE "order_audits" (
  "audit_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "order_id" uuid NOT NULL,
  "quote_id" uuid,
  "stage_id" uuid,
  "event_type" varchar(30) NOT NULL,
  "entity_type" varchar(30),
  "entity_id" uuid,
  "field_name" varchar(60),
  "old_value" jsonb,
  "new_value" jsonb,
  "reason" text,
  "document_id" uuid,
  "performed_by" uuid,
  "performed_role" varchar(20),
  "performed_at" timestamptz NOT NULL,
  "source" varchar(10)
);

CREATE TABLE "equipment_categories" (
  "category_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "name" varchar(80) NOT NULL,
  "sort_order" int
);

CREATE TABLE "inventory_models" (
  "model_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "category_id" uuid NOT NULL,
  "sku" varchar(40) NOT NULL,
  "name" varchar(200) NOT NULL,
  "capacity" varchar(40),
  "length_spec" varchar(40),
  "daily_rate" numeric(12,2),
  "weekly_rate" numeric(12,2),
  "monthly_rate" numeric(12,2),
  "requires_certificate" boolean,
  "cert_validity_months" int,
  "is_active" boolean DEFAULT true,
  "description" text
);

CREATE TABLE "instruments" (
  "instrument_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "model_id" uuid NOT NULL,
  "serial_no" varchar(60) NOT NULL,
  "manufacturer_serial" varchar(80),
  "status" varchar(20) NOT NULL,
  "yard_location" varchar(80),
  "meter_reading" numeric(10,2),
  "purchase_date" date,
  "purchase_cost" numeric(12,2),
  "last_order_id" uuid,
  "notes" text
);

CREATE TABLE "instrument_certificates" (
  "cert_id" uuid PRIMARY KEY,
  "instrument_id" uuid NOT NULL,
  "cert_no" varchar(60) NOT NULL,
  "cert_type" varchar(20),
  "issued_on" date,
  "expires_on" date,
  "issued_by" varchar(120),
  "document_id" uuid,
  "is_current" boolean
);

CREATE TABLE "instrument_hidden_charges" (
  "charge_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "model_id" uuid,
  "instrument_id" uuid,
  "charge_type" varchar(20) NOT NULL,
  "description" varchar(200),
  "amount" numeric(12,2) NOT NULL,
  "unit" varchar(10),
  "is_taxable" boolean DEFAULT true,
  "trigger" varchar(20),
  "is_active" boolean DEFAULT true
);

CREATE TABLE "work_orders" (
  "work_order_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "wo_no" varchar(20),
  "instrument_id" uuid NOT NULL,
  "order_id" uuid,
  "type" varchar(20),
  "title" varchar(200),
  "description" text,
  "stage_id" uuid NOT NULL,
  "due_date" date,
  "est_hours" numeric(6,2),
  "parts_cost" numeric(12,2),
  "labour_cost" numeric(12,2),
  "chargeable_to_customer" boolean,
  "fee_estimate" numeric(12,2),
  "assigned_to" uuid,
  "started_at" timestamptz,
  "completed_at" timestamptz
);

CREATE TABLE "logistics_tasks" (
  "task_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "order_id" uuid NOT NULL,
  "type" varchar(10) NOT NULL,
  "stage_id" uuid NOT NULL,
  "scheduled_at" timestamptz,
  "address" text,
  "vehicle_notes" varchar(200),
  "auto_created" boolean,
  "driver_id" uuid,
  "signed_by_name" varchar(120),
  "signature_document_id" uuid,
  "completed_at" timestamptz
);

CREATE TABLE "invoices" (
  "invoice_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "invoice_no" varchar(30),
  "order_id" uuid,
  "customer_id" uuid NOT NULL,
  "invoice_type" varchar(15),
  "period_from" date,
  "period_to" date,
  "issue_date" date,
  "due_date" date,
  "stage_id" uuid NOT NULL,
  "subtotal" numeric(12,2),
  "discount_amount" numeric(12,2),
  "tax_rate" numeric(5,2),
  "tax_amount" numeric(12,2),
  "tax_overridden" boolean DEFAULT false,
  "tax_override_reason" text,
  "is_zeroed" boolean DEFAULT false,
  "zero_reason" text,
  "total" numeric(12,2),
  "amount_paid" numeric(12,2),
  "balance" numeric(12,2),
  "returned_to_role_id" uuid,
  "return_reason" text,
  "approved_by" uuid,
  "approved_at" timestamptz,
  "sent_at" timestamptz,
  "sent_to_email" varchar(200),
  "xero_invoice_id" varchar(64),
  "xero_synced_at" timestamptz,
  "credit_of_invoice_id" uuid
);

CREATE TABLE "invoice_lines" (
  "line_id" uuid PRIMARY KEY,
  "invoice_id" uuid NOT NULL,
  "line_type" varchar(15),
  "description" text,
  "order_line_id" uuid,
  "instrument_id" uuid,
  "charge_id" uuid,
  "months" int,
  "weeks" int,
  "days" int,
  "qty" numeric(10,2),
  "unit_price" numeric(12,2),
  "amount" numeric(12,2),
  "tax_code" varchar(10),
  "tax_rate" numeric(5,2),
  "tax_amount" numeric(12,2),
  "original_amount" numeric(12,2),
  "is_manual" boolean DEFAULT false,
  "sort_order" int
);

CREATE TABLE "invoice_adjustments" (
  "adjustment_id" uuid PRIMARY KEY,
  "invoice_id" uuid NOT NULL,
  "line_id" uuid,
  "action" varchar(20),
  "field" varchar(60),
  "old_value" text,
  "new_value" text,
  "reason" text,
  "adjusted_by" uuid,
  "adjusted_at" timestamptz
);

CREATE TABLE "payments" (
  "payment_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "customer_id" uuid NOT NULL,
  "amount" numeric(12,2) NOT NULL,
  "method" varchar(20),
  "reference" varchar(100),
  "received_at" date,
  "notes" text,
  "xero_payment_id" varchar(64)
);

CREATE TABLE "payment_allocations" (
  "allocation_id" uuid PRIMARY KEY,
  "payment_id" uuid NOT NULL,
  "invoice_id" uuid NOT NULL,
  "amount" numeric(12,2) NOT NULL
);

CREATE TABLE "document_types" (
  "code" varchar(40) PRIMARY KEY,
  "name" varchar(80),
  "entity_type" varchar(20),
  "allowed_mime" varchar(200),
  "max_mb" int
);

CREATE TABLE "documents" (
  "document_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "doc_type_code" varchar(40) NOT NULL,
  "entity_type" varchar(20) NOT NULL,
  "entity_id" uuid NOT NULL,
  "stage_id" uuid,
  "file_name" varchar(255),
  "mime_type" varchar(100),
  "size_bytes" bigint,
  "sp_site_id" varchar(200),
  "sp_drive_id" varchar(200),
  "sp_item_id" varchar(100),
  "sp_path" varchar(500),
  "sp_web_url" varchar(1000),
  "sp_etag" varchar(100),
  "sp_version" varchar(20),
  "storage_status" varchar(10),
  "checksum" varchar(64),
  "generated" boolean,
  "uploaded_by" uuid,
  "deleted_at" timestamptz
);

CREATE TABLE "number_sequences" (
  "org_id" uuid,
  "seq_type" varchar(20),
  "next_value" bigint NOT NULL,
  PRIMARY KEY ("org_id", "seq_type")
);

CREATE TABLE "email_log" (
  "email_id" uuid PRIMARY KEY,
  "org_id" uuid NOT NULL,
  "entity_type" varchar(20),
  "entity_id" uuid,
  "template" varchar(30),
  "to_address" varchar(500),
  "cc" varchar(500),
  "subject" varchar(300),
  "status" varchar(20),
  "sent_at" timestamptz,
  "provider_message_id" varchar(200)
);

CREATE TABLE "audit_log" (
  "audit_id" uuid PRIMARY KEY,
  "org_id" uuid,
  "user_id" uuid,
  "entity_type" varchar(30),
  "entity_id" uuid,
  "action" varchar(40),
  "diff" jsonb,
  "at" timestamptz
);

CREATE UNIQUE INDEX ON "users" ("organization_id", "email");

CREATE UNIQUE INDEX ON "roles" ("organization_id", "role_code");

CREATE UNIQUE INDEX ON "application_parameter" ("param_name", "organization_id");

CREATE UNIQUE INDEX ON "stages" ("org_id", "entity_type", "code");

CREATE INDEX ON "stage_history" ("entity_type", "entity_id");

CREATE UNIQUE INDEX ON "inventory_models" ("org_id", "sku");

CREATE UNIQUE INDEX ON "instruments" ("org_id", "serial_no");

CREATE INDEX ON "documents" ("entity_type", "entity_id", "stage_id");

COMMENT ON COLUMN "users"."organization_id" IS 'NULL = platform user (Super Admin)';

COMMENT ON COLUMN "users"."auth_provider" IS 'LOCAL | GOOGLE | MICROSOFT';

COMMENT ON COLUMN "roles"."organization_id" IS 'NULL = system role (SUPER_ADMIN, ORG_ADMIN)';

COMMENT ON COLUMN "privileges"."privilege_code" IS 'e.g. INVOICE_APPROVE, MENU_FINANCE_DESK, FIELD_JOB_RATE';

COMMENT ON COLUMN "privileges"."privilege_type" IS 'ACTION | MENU | FIELD';

COMMENT ON COLUMN "privileges"."access_mode" IS 'READ | WRITE | HIDDEN';

COMMENT ON COLUMN "application_parameter"."param_type" IS 'STRING | INT | DECIMAL | BOOLEAN | JSON | UUID';

COMMENT ON COLUMN "application_parameter"."organization_id" IS 'NULL = platform default';

COMMENT ON COLUMN "stages"."entity_type" IS 'INQUIRY | QUOTE | ORDER | INVOICE | WORK_ORDER | LOGISTICS';

COMMENT ON COLUMN "stages"."name" IS 'e.g. Sales (Draft), Finance Desk';

COMMENT ON COLUMN "stage_transitions"."action_code" IS 'APPROVE, RETURN, ACCEPT…';

COMMENT ON COLUMN "document_type_stage_rules"."requirement" IS 'REQUIRED_TO_EXIT | OPTIONAL | AUTO_GENERATED';

COMMENT ON COLUMN "customers"."payment_type" IS 'CASH | CREDIT';

COMMENT ON COLUMN "inquiry_sources"."name" IS 'EMAIL | PHONE | WALK_IN | WEB_FORM | REFERRAL';

COMMENT ON COLUMN "quotes"."quote_no" IS 'shares the RO- number with its order';

COMMENT ON COLUMN "quotes"."stage_id" IS 'DRAFT | SENT | ACCEPTED | CONVERTED | EXPIRED | CANCELLED';

COMMENT ON COLUMN "quotes"."tnc_accepted_via" IS 'EMAIL_REPLY | PHONE | SIGNED_PDF | IN_PERSON';

COMMENT ON COLUMN "quotes"."order_id" IS 'set when accepted → converted';

COMMENT ON COLUMN "quote_lines"."model_id" IS 'optional in DRAFT, required to accept';

COMMENT ON COLUMN "orders"."stage_id" IS 'CONFIRMED → PRE_PICK → DISPATCHED → OFF_RENT_PENDING → RETURNED → INVOICED → CLOSED';

COMMENT ON COLUMN "order_line_assets"."qc_outcome" IS 'OK_WASH_PREP | REPAIR | MISSING';

COMMENT ON TABLE "order_audits" IS 'Append-only';

COMMENT ON COLUMN "order_audits"."source" IS 'UI | API | SYSTEM';

COMMENT ON COLUMN "inventory_models"."sku" IS 'e.g. HOIST-CHAIN-E';

COMMENT ON COLUMN "instruments"."serial_no" IS 'RRP number, e.g. HOIST-CHAIN-E-A1';

COMMENT ON COLUMN "instruments"."status" IS 'AVAILABLE | RESERVED | ON_HIRE | IN_INSPECTION | MAINTENANCE | RETIRED';

COMMENT ON COLUMN "instrument_certificates"."cert_type" IS 'LOAD_TEST | INSPECTION | CALIBRATION';

COMMENT ON COLUMN "instrument_hidden_charges"."charge_type" IS 'CLEANING | DAMAGE_RECERT | OVERAGE | MISSING_PART | RECERTIFICATION | DELIVERY | FUEL | OTHER';

COMMENT ON COLUMN "instrument_hidden_charges"."unit" IS 'FLAT | PER_METRE | PER_HOUR | PER_DAY';

COMMENT ON COLUMN "instrument_hidden_charges"."trigger" IS 'ON_RETURN_DAMAGE | ON_RETURN_MISSING | ON_RETURN_DIRTY | ON_OVERAGE | ALWAYS | MANUAL';

COMMENT ON COLUMN "work_orders"."type" IS 'REPAIR | PREVENTIVE | INSPECTION | TURNAROUND | MISSING_GEAR';

COMMENT ON COLUMN "logistics_tasks"."type" IS 'DELIVERY | PICKUP';

COMMENT ON COLUMN "invoices"."invoice_type" IS 'FINAL | INTERIM | CREDIT_NOTE | DEPOSIT';

COMMENT ON COLUMN "invoices"."stage_id" IS 'DRAFT | RETURNED | APPROVED | SENT | PARTIALLY_PAID | PAID | VOID';

COMMENT ON COLUMN "invoices"."balance" IS 'generated: total - amount_paid';

COMMENT ON COLUMN "invoice_lines"."line_type" IS 'RENTAL | DAMAGE | CLEANING | OVERAGE | MISSING | FUEL | DELIVERY | DEPOSIT | DISCOUNT | OTHER';

COMMENT ON COLUMN "invoice_lines"."tax_code" IS 'GST | GST_FREE | EXEMPT | CUSTOM';

COMMENT ON COLUMN "invoice_adjustments"."action" IS 'EDIT_LINE | ADD_LINE | REMOVE_LINE | ZERO | TAX_OVERRIDE | DISCOUNT | RETURN | APPROVE | REVERT';

COMMENT ON COLUMN "payments"."method" IS 'BANK_TRANSFER | CARD | CASH | CHEQUE | DEPOSIT_APPLIED';

COMMENT ON COLUMN "document_types"."code" IS 'QUOTE_PDF, SIGNED_ACCEPTANCE, PICKING_SLIP, DISPATCH_PHOTO, RETURN_PHOTO, POD_SIGNATURE, TAX_INVOICE_PDF, CERTIFICATE…';

COMMENT ON COLUMN "documents"."stage_id" IS 'stage of the parent record at upload; set by server';

COMMENT ON COLUMN "documents"."storage_status" IS 'PENDING | STORED | FAILED | DELETED';

COMMENT ON COLUMN "number_sequences"."seq_type" IS 'ORDER | INVOICE | INQUIRY | WORK_ORDER';

COMMENT ON COLUMN "email_log"."template" IS 'QUOTE_TNC | INVOICE | REMINDER';

ALTER TABLE "users" ADD FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "roles" ADD FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "users_roles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "users_roles" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "roles_privileges" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "roles_privileges" ADD FOREIGN KEY ("privilege_id") REFERENCES "privileges" ("privilege_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "application_parameter" ADD FOREIGN KEY ("organization_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stages" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stages" ADD FOREIGN KEY ("owner_role_id") REFERENCES "roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_transitions" ADD FOREIGN KEY ("from_stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_transitions" ADD FOREIGN KEY ("to_stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_transitions" ADD FOREIGN KEY ("allowed_role_id") REFERENCES "roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_history" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_history" ADD FOREIGN KEY ("from_stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_history" ADD FOREIGN KEY ("to_stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stage_history" ADD FOREIGN KEY ("changed_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "document_type_stage_rules" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "document_type_stage_rules" ADD FOREIGN KEY ("doc_type_code") REFERENCES "document_types" ("code") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "document_type_stage_rules" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "customers" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "customer_contacts" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "customer_sites" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiry_sources" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("source_id") REFERENCES "inquiry_sources" ("source_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("assigned_to") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiries" ADD FOREIGN KEY ("quote_id") REFERENCES "quotes" ("quote_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiry_items" ADD FOREIGN KEY ("inquiry_id") REFERENCES "inquiries" ("inquiry_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiry_items" ADD FOREIGN KEY ("category_id") REFERENCES "equipment_categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inquiry_items" ADD FOREIGN KEY ("model_id") REFERENCES "inventory_models" ("model_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("inquiry_id") REFERENCES "inquiries" ("inquiry_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("contact_id") REFERENCES "customer_contacts" ("contact_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("tnc_proof_document_id") REFERENCES "documents" ("document_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quotes" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quote_lines" ADD FOREIGN KEY ("quote_id") REFERENCES "quotes" ("quote_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quote_lines" ADD FOREIGN KEY ("category_id") REFERENCES "equipment_categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "quote_lines" ADD FOREIGN KEY ("model_id") REFERENCES "inventory_models" ("model_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("quote_id") REFERENCES "quotes" ("quote_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("contact_id") REFERENCES "customer_contacts" ("contact_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("confirmed_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_lines" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_lines" ADD FOREIGN KEY ("quote_line_id") REFERENCES "quote_lines" ("line_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_lines" ADD FOREIGN KEY ("model_id") REFERENCES "inventory_models" ("model_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_line_assets" ADD FOREIGN KEY ("order_line_id") REFERENCES "order_lines" ("line_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_line_assets" ADD FOREIGN KEY ("instrument_id") REFERENCES "instruments" ("instrument_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_line_assets" ADD FOREIGN KEY ("assigned_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("quote_id") REFERENCES "quotes" ("quote_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("document_id") REFERENCES "documents" ("document_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_audits" ADD FOREIGN KEY ("performed_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "equipment_categories" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inventory_models" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inventory_models" ADD FOREIGN KEY ("category_id") REFERENCES "equipment_categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instruments" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instruments" ADD FOREIGN KEY ("model_id") REFERENCES "inventory_models" ("model_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instruments" ADD FOREIGN KEY ("last_order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instrument_certificates" ADD FOREIGN KEY ("instrument_id") REFERENCES "instruments" ("instrument_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instrument_certificates" ADD FOREIGN KEY ("document_id") REFERENCES "documents" ("document_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instrument_hidden_charges" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instrument_hidden_charges" ADD FOREIGN KEY ("model_id") REFERENCES "inventory_models" ("model_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "instrument_hidden_charges" ADD FOREIGN KEY ("instrument_id") REFERENCES "instruments" ("instrument_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "work_orders" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "work_orders" ADD FOREIGN KEY ("instrument_id") REFERENCES "instruments" ("instrument_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "work_orders" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "work_orders" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "work_orders" ADD FOREIGN KEY ("assigned_to") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "logistics_tasks" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "logistics_tasks" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "logistics_tasks" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "logistics_tasks" ADD FOREIGN KEY ("driver_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "logistics_tasks" ADD FOREIGN KEY ("signature_document_id") REFERENCES "documents" ("document_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("returned_to_role_id") REFERENCES "roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("approved_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("credit_of_invoice_id") REFERENCES "invoices" ("invoice_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_lines" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("invoice_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_lines" ADD FOREIGN KEY ("order_line_id") REFERENCES "order_lines" ("line_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_lines" ADD FOREIGN KEY ("instrument_id") REFERENCES "instruments" ("instrument_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_lines" ADD FOREIGN KEY ("charge_id") REFERENCES "instrument_hidden_charges" ("charge_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_adjustments" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("invoice_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_adjustments" ADD FOREIGN KEY ("line_id") REFERENCES "invoice_lines" ("line_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoice_adjustments" ADD FOREIGN KEY ("adjusted_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payment_allocations" ADD FOREIGN KEY ("payment_id") REFERENCES "payments" ("payment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payment_allocations" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("invoice_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "documents" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "documents" ADD FOREIGN KEY ("doc_type_code") REFERENCES "document_types" ("code") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "documents" ADD FOREIGN KEY ("stage_id") REFERENCES "stages" ("stage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "documents" ADD FOREIGN KEY ("uploaded_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "number_sequences" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "email_log" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "audit_log" ADD FOREIGN KEY ("org_id") REFERENCES "organization" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "audit_log" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;
