-- Rollback migration: Remove tables from wrong project
-- These tables were added by mistake and belong to another project

-- Drop the function first (depends on table)
DROP FUNCTION IF EXISTS delete_old_performance_metrics();

-- Drop tables (CASCADE will remove all policies and indexes)
DROP TABLE IF EXISTS admin_audit_log CASCADE;
DROP TABLE IF EXISTS data_export_requests CASCADE;
DROP TABLE IF EXISTS performance_metrics CASCADE;

-- Verify tables are gone
DO $$
BEGIN
  IF EXISTS (
    SELECT FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename IN ('performance_metrics', 'data_export_requests', 'admin_audit_log')
  ) THEN
    RAISE EXCEPTION 'Failed to drop one or more tables';
  END IF;
END $$;

COMMENT ON SCHEMA public IS 'Rollback completed: Removed performance_metrics, data_export_requests, and admin_audit_log tables';
