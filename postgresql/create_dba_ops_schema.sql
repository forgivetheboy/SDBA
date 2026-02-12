-- Create the dba_ops schema
CREATE SCHEMA IF NOT EXISTS dba_ops;

-- Create operator_groups table
CREATE TABLE IF NOT EXISTS dba_ops.operator_groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- Create operators table
CREATE TABLE IF NOT EXISTS dba_ops.operators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    group_id INT REFERENCES dba_ops.operator_groups(id) ON DELETE CASCADE
);

-- Insert operator groups
INSERT INTO dba_ops.operator_groups (name) VALUES ('CLAIMANTS-SUPPORT'), ('SDBA')
ON CONFLICT (name) DO NOTHING;

-- Insert operators for CLAIMANTS-SUPPORT group
INSERT INTO dba_ops.operators (name, email, group_id) VALUES
('Jerry-Opolot', 'jerry.opolot@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT')),
('Chicco', 'moses.chicco@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT')),
('Saul', 'saul.akankwasa@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT')),
('Bob', 'bob.wabusa@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT')),
('Emanuel', 'emanuel.okello@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT')),
('Norman', 'norman.wolimbwa@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'CLAIMANTS-SUPPORT'))
ON CONFLICT (email) DO NOTHING;

-- Insert operators for SDBA group
INSERT INTO dba_ops.operators (name, email, group_id) VALUES
('Chicco', 'moses.chicco@ursb.go.ug', (SELECT id FROM dba_ops.operator_groups WHERE name = 'SDBA'))
ON CONFLICT (email) DO NOTHING;