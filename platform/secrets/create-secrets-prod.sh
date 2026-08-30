#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sk-fabricator-prod"

echo "Provisioning secrets for namespace: ${NAMESPACE}..."

if [ -z "${PROD_POSTGRES_PASSWORD:-}" ] || [ -z "${PROD_JWT_SECRET:-}" ]; then
  echo "ERROR: Environment variables PROD_POSTGRES_PASSWORD and PROD_JWT_SECRET must be set before running."
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# PostgreSQL Secret
kubectl create secret generic postgres-secret \
  --namespace="${NAMESPACE}" \
  --from-literal=POSTGRES_DB="skfabricatordb" \
  --from-literal=POSTGRES_USER="postgres" \
  --from-literal=POSTGRES_PASSWORD="${PROD_POSTGRES_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Backend Application Secrets
kubectl create secret generic backend-api-secrets \
  --namespace="${NAMESPACE}" \
  --from-literal=ConnectionStrings__DefaultConnection="Host=postgres;Port=5432;Database=skfabricatordb;Username=postgres;Password=${PROD_POSTGRES_PASSWORD}" \
  --from-literal=JwtSettings__Secret="${PROD_JWT_SECRET}" \
  --from-literal=CloudinarySettings__CloudName="${PROD_CLOUDINARY_CLOUD:-}" \
  --from-literal=CloudinarySettings__ApiKey="${PROD_CLOUDINARY_KEY:-}" \
  --from-literal=CloudinarySettings__ApiSecret="${PROD_CLOUDINARY_SECRET:-}" \
  --from-literal=SmtpSettings__Password="${PROD_SMTP_PASS:-}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Production secrets successfully applied to ${NAMESPACE}!"
