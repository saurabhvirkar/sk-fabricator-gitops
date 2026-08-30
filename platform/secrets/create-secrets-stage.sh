#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sk-fabricator-stage"

echo "Provisioning secrets for namespace: ${NAMESPACE}..."

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# PostgreSQL Secret
kubectl create secret generic postgres-secret \
  --namespace="${NAMESPACE}" \
  --from-literal=POSTGRES_DB="skfabricatordb" \
  --from-literal=POSTGRES_USER="postgres" \
  --from-literal=POSTGRES_PASSWORD="${STAGE_POSTGRES_PASSWORD:-stagepassword123}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Backend Application Secrets
kubectl create secret generic backend-api-secrets \
  --namespace="${NAMESPACE}" \
  --from-literal=ConnectionStrings__DefaultConnection="Host=postgres;Port=5432;Database=skfabricatordb;Username=postgres;Password=${STAGE_POSTGRES_PASSWORD:-stagepassword123}" \
  --from-literal=JwtSettings__Secret="${STAGE_JWT_SECRET:-StageSecretKeyForJWTAuth1234567890}" \
  --from-literal=CloudinarySettings__CloudName="${STAGE_CLOUDINARY_CLOUD:-stage-cloud}" \
  --from-literal=CloudinarySettings__ApiKey="${STAGE_CLOUDINARY_KEY:-stage-key}" \
  --from-literal=CloudinarySettings__ApiSecret="${STAGE_CLOUDINARY_SECRET:-stage-secret}" \
  --from-literal=SmtpSettings__Password="${STAGE_SMTP_PASS:-stage-smtp-pass}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets successfully applied to ${NAMESPACE}!"
