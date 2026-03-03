###  1. Registration Token 발급
```
# 로그인
az login

# 구독 설정
az account set --subscription "Mysubscripion No"

# Host Pool 등록 토큰 발급 (2시간 유효)
az desktopvirtualization hostpool update \
  --name "hdob-hp" \
  --resource-group "hdob-spoke-rg" \
  --registration-info expiration-time="$(date -u -d '+2 hours' '+%Y-%m-%dT%H:%M:%SZ')" \
                      registration-token-operation="Update"

# 토큰 값만 추출
az desktopvirtualization hostpool retrieve-registration-token \
  --name "hdob-hp" \
  --resource-group "hdob-spoke-rg" \
  --query "token" -o tsv
```

### 2.Session Host에 AVD Agent 설치 (VM Extension)
```
# 등록 토큰 변수 저장
TOKEN=$(az desktopvirtualization hostpool retrieve-registration-token \
  --name "hdob-hp" \
  --resource-group "hdob-spoke-rg" \
  --query "token" -o tsv)

# image-vm에 AVD DSC Extension 설치
az vm extension set \
  --resource-group "hdob-hub-rg" \
  --vm-name "hdob-image-vm" \
  --name "DSC" \
  --publisher "Microsoft.Powershell" \
  --version "2.73" \
  --settings "{
    \"modulesUrl\": \"https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip\",
    \"configurationFunction\": \"Configuration.ps1\\\\AddSessionHost\",
    \"properties\": {
      \"HostPoolName\": \"hdob-hp\",
      \"aadJoin\": false
    }
  }" \
  --protected-settings "{
    \"properties\": {
      \"registrationInfoToken\": \"$TOKEN\"
    }
  }"

```

### 3.사용자 계정 App Group 할당
```
# Entra ID 사용자 Object ID 조회
USER_OID=$(az ad user show \
  --id "user@yourdomain.com" \
  --query "id" -o tsv)

# App Group에 Desktop Virtualization User 역할 할당
APP_GROUP_ID=$(az desktopvirtualization applicationgroup show \
  --name "hdob-dag" \
  --resource-group "hdob-spoke-rg" \
  --query "id" -o tsv)

az role assignment create \
  --assignee "$USER_OID" \
  --role "Desktop Virtualization User" \
  --scope "$APP_GROUP_ID"

```

### 4. 여러 사용자 일괄 할당 (스크립트)

```
#!/bin/bash
# avd-user-assign.sh

RESOURCE_GROUP="hdob-spoke-rg"
APP_GROUP="hdob-dag"

# 할당할 사용자 목록
USERS=(
  "user1@yourdomain.com"
  "user2@yourdomain.com"
  "user3@yourdomain.com"
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

```

### 5. 등록 확인
```
# Session Host 등록 상태 확인
az desktopvirtualization sessionhost list \
  --host-pool-name "hdob-hp" \
  --resource-group "hdob-spoke-rg" \
  --query "[].{Name:name, Status:status, OSVersion:osVersion}" \
  -o table

# App Group 사용자 할당 확인
az role assignment list \
  --scope "$APP_GROUP_ID" \
  --query "[].{User:principalName, Role:roleDefinitionName}" \
  -o table

```

## 전체 실행순서
```
# 1단계: 토큰 발급
TOKEN=$(az desktopvirtualization hostpool retrieve-registration-token ...)

# 2단계: Session Host VM Extension 설치
az vm extension set ... --protected-settings "{token: $TOKEN}"

# 3단계: 사용자 할당
bash avd-user-assign.sh

# 4단계: 상태 확인
az desktopvirtualization sessionhost list ... -o table

# 5단계: 웹 클라이언트 접속 테스트
# https://client.wvd.microsoft.com/arm/webclient

```