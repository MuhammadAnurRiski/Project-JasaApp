-- Create new tables
CREATE TABLE "admin_bank_accounts" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "provider_name" VARCHAR(100) NOT NULL,
    "account_number" VARCHAR(100) NOT NULL,
    "account_name" VARCHAR(150) NOT NULL,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now(),

    CONSTRAINT "admin_bank_accounts_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "admin_ewallet_accounts" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "provider_name" VARCHAR(100) NOT NULL,
    "account_number" VARCHAR(100) NOT NULL,
    "account_name" VARCHAR(150) NOT NULL,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now(),

    CONSTRAINT "admin_ewallet_accounts_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "admin_qris_accounts" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "provider_name" VARCHAR(100) NOT NULL,
    "qris_image_url" TEXT NOT NULL,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMPTZ(6) DEFAULT now(),
    "updated_at" TIMESTAMPTZ(6) DEFAULT now(),

    CONSTRAINT "admin_qris_accounts_pkey" PRIMARY KEY ("id")
);

-- Migrate existing data
INSERT INTO admin_bank_accounts (id, provider_name, account_number, account_name, is_active, created_at, updated_at)
SELECT id, provider_name, account_number, account_name, is_active, created_at, updated_at
FROM admin_payment_accounts
WHERE type = 'bank';

INSERT INTO admin_ewallet_accounts (id, provider_name, account_number, account_name, is_active, created_at, updated_at)
SELECT id, provider_name, account_number, account_name, is_active, created_at, updated_at
FROM admin_payment_accounts
WHERE type = 'ewallet';

INSERT INTO admin_qris_accounts (id, provider_name, qris_image_url, is_active, created_at, updated_at)
SELECT id, provider_name, qris_image_url, is_active, created_at, updated_at
FROM admin_payment_accounts
WHERE type = 'qris';

-- Drop old table
DROP TABLE "admin_payment_accounts";
