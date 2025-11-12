-- ============================================================================
-- Update OPC Endpoints to MockServer
-- ============================================================================
-- This script updates all OPC endpoint URLs to point to MockServer
-- Run this to switch from real Nordex servers to mock servers for testing
-- ============================================================================

-- Backup current OPC endpoint URLs (optional, for rollback)
-- CREATE TABLE IF NOT EXISTS opc_endpoints_backup AS
-- SELECT id, plant_name, opc_endpoint_url, opc_is_active, updated_at
-- FROM plants WHERE opc_endpoint_url IS NOT NULL;

-- Update all plants to use MockServer
UPDATE plants
SET
    opc_endpoint_url = 'http://mockserver:1080/nordex/services/nordex_opc',
    opc_locale_id = 'en-us',
    opc_timeout_ms = 180000,
    opc_is_active = true,
    updated_at = CURRENT_TIMESTAMP
WHERE opc_endpoint_url IS NOT NULL
  AND is_deleted = false;

-- Verify the update
SELECT
    id,
    plant_name,
    opc_endpoint_url,
    opc_is_active,
    updated_at
FROM plants
WHERE opc_endpoint_url IS NOT NULL
ORDER BY id;

-- ============================================================================
-- Rollback Script (if needed)
-- ============================================================================
-- To restore original endpoints, uncomment and run:
--
-- UPDATE plants p
-- SET
--     opc_endpoint_url = b.opc_endpoint_url,
--     opc_is_active = b.opc_is_active,
--     updated_at = CURRENT_TIMESTAMP
-- FROM opc_endpoints_backup b
-- WHERE p.id = b.id;
-- ============================================================================

-- Original Nordex Endpoint URLs (for reference):
-- Silivri:     http://78.188.16.11:8034/nordex/services/nordex_opc
-- Tokat:       http://95.9.229.118:8060/nordex/services/nordex_opc
-- Merzifon:    http://95.9.239.214:8005/nordex/services/nordex_opc
-- Hasanbeyli:  http://88.247.27.241:8180/nordex/services/nordex_opc
-- Seferihisar: http://95.6.38.155:8035/nordex/services/nordex_opc
-- Susurluk:    http://88.250.254.212:8010/nordex/services/nordex_opc
-- Ovacık:      http://85.98.95.38:8135/nordex/services/nordex_opc
-- Geyve:       http://212.156.57.230:8054/nordex/services/nordex_opc
