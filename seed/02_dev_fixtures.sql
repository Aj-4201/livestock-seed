-- DEV FIXTURES — fake data for local development only. Never load in production.
-- Fixed UUID prefixes make cross-references readable.

-- Tenant --------------------------------------------------------------------
INSERT INTO tenants (id, name, subscription_plan, subscription_status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Green Acres Demo', 'trial', 'active')
ON CONFLICT DO NOTHING;

-- Users (password for all: ChangeMe123) -------------------------------------
INSERT INTO users (id, tenant_id, email, password_hash, full_name, phone)
VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001',
   'owner@demo.local',   crypt('ChangeMe123', gen_salt('bf')), 'Demo Owner',   '+254700000001'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001',
   'manager@demo.local', crypt('ChangeMe123', gen_salt('bf')), 'Demo Manager', '+254700000002'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001',
   'worker@demo.local',  crypt('ChangeMe123', gen_salt('bf')), 'Demo Worker',  '+254700000003')
ON CONFLICT (tenant_id, email) DO NOTHING;

INSERT INTO user_roles (user_id, role_id) VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000100'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000101'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000102')
ON CONFLICT DO NOTHING;

-- Animals (with one dam → calf lineage) -------------------------------------
INSERT INTO animals (id, tenant_id, tag_number, name, breed_id, sex, date_of_birth, origin, dam_id, status, created_by)
SELECT '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001',
       'GA-001', 'Bella', b.id, 'female', '2022-03-01', 'purchased', NULL, 'active',
       '00000000-0000-0000-0000-000000000011'
FROM breeds b WHERE b.name = 'Friesian' AND b.tenant_id IS NULL
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

INSERT INTO animals (id, tenant_id, tag_number, name, breed_id, sex, date_of_birth, origin, status, created_by)
SELECT '00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000001',
       'GA-002', 'Rocky', b.id, 'male', '2021-06-15', 'local', 'active',
       '00000000-0000-0000-0000-000000000011'
FROM breeds b WHERE b.name = 'Boran' AND b.tenant_id IS NULL
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

INSERT INTO animals (id, tenant_id, tag_number, name, sex, date_of_birth, origin, dam_id, sire_id, status, created_by)
VALUES ('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0000-000000000001',
        'GA-003', 'Junior', 'male', '2024-01-10', 'newborn',
        '00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000102', 'active',
        '00000000-0000-0000-0000-000000000011')
ON CONFLICT (tenant_id, tag_number) DO NOTHING;

-- Health (append-only) ------------------------------------------------------
INSERT INTO health_records (tenant_id, animal_id, event_type, occurred_at, medication, dosage, vet_name, cost, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
   'vaccination', '2026-08-01 09:00+03', 'FMD Vaccine', '2ml', 'Dr. Otieno', 1500.00,
   '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000102',
   'deworming', '2026-08-10 09:00+03', 'Albendazole', '10ml', 'Dr. Otieno', 800.00,
   '00000000-0000-0000-0000-000000000011')
ON CONFLICT DO NOTHING;

-- Breeding ------------------------------------------------------------------
INSERT INTO breeding_events (tenant_id, dam_id, sire_id, event_type, occurred_at, expected_due_date, recorded_by)
VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
        '00000000-0000-0000-0000-000000000102', 'birth', '2024-01-10 06:00+03', NULL,
        '00000000-0000-0000-0000-000000000011')
ON CONFLICT DO NOTHING;

-- Feed inventory ------------------------------------------------------------
INSERT INTO feed_items (id, tenant_id, name, category, unit) VALUES
  ('00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000001', 'Dairy Meal', 'concentrate', 'kg'),
  ('00000000-0000-0000-0000-000000000402', '00000000-0000-0000-0000-000000000001', 'Hay', 'roughage', 'bale')
ON CONFLICT (tenant_id, name) DO NOTHING;

INSERT INTO feed_inventory (tenant_id, feed_item_id, quantity_on_hand, reorder_level, unit_cost) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000401', 120.000, 50.000, 55.00),
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000402', 8.000, 10.000, 300.00)  -- below reorder → triggers low stock
ON CONFLICT (tenant_id, feed_item_id) DO NOTHING;

-- Workers + attendance ------------------------------------------------------
INSERT INTO workers (id, tenant_id, user_id, full_name, phone, role_title, hired_date)
VALUES ('00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000012', 'Demo Worker', '+254700000003', 'Herdsman', '2025-01-15')
ON CONFLICT DO NOTHING;

INSERT INTO attendance (tenant_id, worker_id, work_date, status, check_in, check_out, recorded_by, acknowledged_by, acknowledged_at)
VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000301',
        CURRENT_DATE, 'present', now(), now(), '00000000-0000-0000-0000-000000000011',
        '00000000-0000-0000-0000-000000000012', now())
ON CONFLICT (tenant_id, worker_id, work_date) DO NOTHING;

-- Finance -------------------------------------------------------------------
INSERT INTO invoices (id, tenant_id, invoice_number, customer_name, issue_date, due_date, total_amount, status, created_by)
VALUES ('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000001',
        'INV-0001', 'Nairobi Dairy Co-op', CURRENT_DATE, CURRENT_DATE + 30, 45000.00, 'partial',
        '00000000-0000-0000-0000-000000000011')
ON CONFLICT (tenant_id, invoice_number) DO NOTHING;

INSERT INTO invoice_items (invoice_id, description, quantity, unit_price) VALUES
  ('00000000-0000-0000-0000-000000000501', 'Milk (litres)', 900, 50.00)
ON CONFLICT DO NOTHING;

INSERT INTO installments (tenant_id, invoice_id, amount, due_date, paid_date, status, method)
VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000501',
        20000.00, CURRENT_DATE, CURRENT_DATE, 'paid', 'mpesa')
ON CONFLICT DO NOTHING;

INSERT INTO transactions (tenant_id, txn_type, amount, category, description, occurred_at, recorded_by)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'income',  20000.00, 'milk_sales', 'Installment 1', now(), '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0000-000000000001', 'expense',  1500.00, 'veterinary', 'FMD vaccine',   now(), '00000000-0000-0000-0000-000000000011')
ON CONFLICT DO NOTHING;

-- Notifications -------------------------------------------------------------
INSERT INTO alert_rules (tenant_id, name, event_type, channel, lead_time_days) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Vaccination due', 'vaccination_due', 'sms', 3),
  ('00000000-0000-0000-0000-000000000001', 'Low feed stock',  'low_stock',       'sms', 0)
ON CONFLICT DO NOTHING;
