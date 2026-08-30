#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sk-fabricator-dev"

echo "Provisioning secrets for namespace: ${NAMESPACE}..."

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# PostgreSQL Secret
kubectl create secret generic postgres-secret \
  --namespace="${NAMESPACE}" \
  --from-literal=POSTGRES_DB="skfabricatordb" \
  --from-literal=POSTGRES_USER="postgres" \
  --from-literal=POSTGRES_PASSWORD="devpassword123" \
  --dry-run=client -o yaml | kubectl apply -f -

# Backend Application Secrets
kubectl create secret generic backend-api-secrets \
  --namespace="${NAMESPACE}" \
  --from-literal=ConnectionStrings__DefaultConnection="Host=postgres;Port=5432;Database=skfabricatordb;Username=postgres;Password=devpassword123" \
  --from-literal=JwtSettings__Secret="DevSuperSecretKeyForJWTAuth1234567890" \
  --from-literal=Jwt__Key="DevSuperSecretKeyForJWTAuth1234567890" \
  --from-literal=CloudinarySettings__CloudName="dev-cloud" \
  --from-literal=CloudinarySettings__ApiKey="dev-key" \
  --from-literal=CloudinarySettings__ApiSecret="dev-secret" \
  --from-literal=SmtpSettings__Password="dev-smtp-pass" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets successfully applied to ${NAMESPACE}!"
