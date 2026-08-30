# Runbook: Database Backup & Disaster Recovery

## Backup Architecture

Automated daily backups run via a Kubernetes `CronJob` targeting PostgreSQL.

## Manual Trigger Backup

```bash
kubectl create job --from=cronjob/postgres-backup manual-db-backup-$(date +%s) -n sk-fabricator-prod
```

## Restore Procedure

1. Identify latest backup file: `skfabricatordb_backup_YYYY-MM-DD.sql.gz`.
2. Port-forward or execute shell into postgres pod:
   ```bash
   kubectl exec -it postgres-db-0 -n sk-fabricator-prod -- bash
   ```
3. Decompress and restore database:
   ```bash
   gunzip -c /backup/skfabricatordb_backup.sql.gz | psql -U postgres -d skfabricatordb
   ```
