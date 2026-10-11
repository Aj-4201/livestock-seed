-- Reference data — idempotent. Safe to re-run after migrations.
-- System roles use tenant_id = NULL (available to every tenant).

-- Permissions ---------------------------------------------------------------
INSERT INTO permissions (code, description) VALUES
  ('animals.read',    'View animals and lineage'),
  ('animals.write',   'Create/update animals'),
  ('health.read',     'View health history'),
  ('health.write',    'Record health events'),
  ('breeding.read',   'View breeding records'),
  ('breeding.write',  'Record breeding events'),
  ('inventory.read',  'View feed inventory'),
  ('inventory.write', 'Manage feed and stock'),
  ('finance.read',    'View financial data and reports'),
  ('finance.write',   'Record transactions and invoices'),
  ('workforce.read',  'View workers and attendance'),
  ('workforce.write', 'Manage workers and attendance'),
  ('reports.read',    'Generate and export reports'),
  ('audit.read',      'View audit trail (owner/manager only)'),
  ('users.manage',    'Manage users and roles'),
  ('tenants.manage',  'Manage tenant/subscription settings')
ON CONFLICT (code) DO NOTHING;

-- System roles --------------------------------------------------------------
INSERT INTO roles (id, tenant_id, name, description) VALUES
  ('00000000-0000-0000-0000-000000000100', NULL, 'owner',   'Full access incl. audit trail'),
  ('00000000-0000-0000-0000-000000000101', NULL, 'manager', 'Operational access incl. audit trail'),
  ('00000000-0000-0000-0000-000000000102', NULL, 'worker',  'Limited operational access')
ON CONFLICT (tenant_id, name) DO NOTHING;

-- Role → permission wiring --------------------------------------------------
-- owner: everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000100', id FROM permissions
ON CONFLICT DO NOTHING;

-- manager: everything except tenant/user administration
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000101', id FROM permissions
WHERE code NOT IN ('tenants.manage', 'users.manage')
ON CONFLICT DO NOTHING;

-- worker: read-only + health/attendance acknowledgement paths
INSERT INTO role_permissions (role_id, permission_id)
SELECT '00000000-0000-0000-0000-000000000102', id FROM permissions
WHERE code IN ('animals.read', 'health.read', 'inventory.read', 'workforce.read')
ON CONFLICT DO NOTHING;

-- System breeds (tenant_id = NULL) ------------------------------------------
INSERT INTO breeds (tenant_id, name, species) VALUES
  (NULL, 'Friesian',      'cattle'),
  (NULL, 'Ayrshire',      'cattle'),
  (NULL, 'Boran',         'cattle'),
  (NULL, 'Sahiwal',       'cattle'),
  (NULL, 'Zebu',          'cattle'),
  (NULL, 'Dorper',        'sheep'),
  (NULL, 'Galla',         'goat')
ON CONFLICT DO NOTHING;
