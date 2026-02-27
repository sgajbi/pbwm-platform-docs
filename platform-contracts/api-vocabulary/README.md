# Lotus API Vocabulary Inventory

This directory stores per-application API vocabulary contracts used to enforce shared naming and documentation quality across Lotus services.

## Document Once Rule

For each application inventory:

- Every semantic attribute is documented exactly once in `attributeCatalog`.
- Endpoint request/response fields must reference that attribute using `attributeRef`/`semanticId`.
- Endpoint-local field entries are usage mappings, not duplicate documentation records.

## lotus-core Inventory

- File: `lotus-core-api-vocabulary.v1.json`
- Source: `lotus-core` OpenAPI contracts (`query_service` and `ingestion_service`)
- Generator: `lotus-core/scripts/api_vocabulary_inventory.py`

## Regeneration

```powershell
python ..\lotus-core\scripts\api_vocabulary_inventory.py `
  --output .\platform-contracts\api-vocabulary\lotus-core-api-vocabulary.v1.json
```
