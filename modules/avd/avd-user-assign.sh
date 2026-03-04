#!/bin/bash
# avd-user-assign.sh

RESOURCE_GROUP="hdob-spoke-rg"
APP_GROUP="hdob-dag"

# 할당할 사용자 목록
USERS=(
  "user01@imyoungmogmail.onmicrosoft.com"
  "user02@imyoungmogmail.onmicrosoft.com"
  "user03@imyoungmogmail.onmicrosoft.com"
)

APP_GROUP_ID=$(az desktopvirtualization applicationgroup show \
  --name "$APP_GROUP" \
  --resource-group "$RESOURCE_GROUP" \
  --query "id" -o tsv)

for USER in "${USERS[@]}"; do
  USER_OID=$(az ad user show --id "$USER" --query "id" -o tsv)
  az role assignment create \
    --assignee "$USER_OID" \
    --role "Desktop Virtualization User" \
    --scope "$APP_GROUP_ID"
  echo "✅ $USER 할당 완료"
done
