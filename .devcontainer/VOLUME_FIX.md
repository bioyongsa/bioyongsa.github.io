# 🔧 매번 다운로드 문제 해결

## 문제
매번 Cursor 연결 시 90MB+ 서버를 다시 다운로드하고 있습니다.

**원인**: 컨테이너에 `/root/.cursor-server`를 영구 저장할 볼륨이 없음

---

## 해결 방법 (선택)

### ⭐ 방법 1: 타임아웃 늘리기 (가장 안전, 기존 컨테이너 유지)

기존 컨테이너를 그대로 두고, 매번 다운로드해도 타임아웃이 발생하지 않도록 설정

#### Cursor 설정:
`C:\Users\sangku\AppData\Roaming\Cursor\User\settings.json`

```json
{
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 300000,
  "remote.containers.installTimeoutSeconds": 300
}
```

**장점**: 기존 컨테이너 그대로 사용, 안전
**단점**: 매번 2-3분 대기

---

### 🥇 방법 2: Docker 볼륨 추가 (권장, 새 컨테이너)

영구 볼륨을 사용하여 Cursor 서버 캐시 저장

#### PowerShell에서:

```powershell
# 1. 볼륨 생성
docker volume create cursor-server-cache

# 2. 새 컨테이너 시작 (기존 컨테이너는 그대로 둠)
docker run -d `
  --name rhel8-persistent `
  -v cursor-server-cache:/root/.cursor-server `
  -v C:\Users\sangku\workspace:/workspace `
  nwharbor.sec.samsung.net/build/access_rhel8.10:latest `
  tail -f /dev/null

# 3. Cursor에서 새 컨테이너에 연결
# F1 → Attach to Running Container → rhel8-persistent
```

**첫 연결**: 서버 다운로드 (2-3분)
**이후 연결**: 캐시 사용 (10초 이내) ⚡

**장점**: 두 번째부터 매우 빠름
**단점**: 새 컨테이너 필요

---

### 🥈 방법 3: 기존 컨테이너 수정 (고급)

기존 `access_rhel8.10` 컨테이너를 중지하고 볼륨 추가하여 재생성

#### ⚠️ 주의: 컨테이너 내부 데이터 백업 필요

```powershell
# 1. 현재 컨테이너 백업
docker commit access_rhel8.10 access_rhel8.10:backup

# 2. 컨테이너 중지 및 이름 변경
docker stop access_rhel8.10
docker rename access_rhel8.10 access_rhel8.10_old

# 3. 볼륨 생성
docker volume create cursor-server-cache

# 4. 같은 이름으로 새 컨테이너 시작
docker run -d `
  --name access_rhel8.10 `
  -v cursor-server-cache:/root/.cursor-server `
  nwharbor.sec.samsung.net/build/access_rhel8.10:latest `
  /bin/bash -c "while true; do sleep 30; done"

# 5. Cursor에서 연결
```

**필요시 이전 컨테이너 복구:**
```powershell
docker stop access_rhel8.10
docker rm access_rhel8.10
docker rename access_rhel8.10_old access_rhel8.10
docker start access_rhel8.10
```

---

### 🥉 방법 4: Windows 폴더 직접 마운트

```powershell
# 1. 캐시 폴더 생성
mkdir C:\cursor-cache

# 2. 새 컨테이너 시작
docker run -d `
  --name rhel8-cached `
  -v C:\cursor-cache:/root/.cursor-server `
  nwharbor.sec.samsung.net/build/access_rhel8.10:latest `
  tail -f /dev/null
```

**장점**: Windows에서 캐시 파일 직접 확인 가능
**단점**: 경로 권한 문제 발생 가능

---

## 📊 방법 비교

| 방법 | 기존 컨테이너 유지 | 첫 연결 | 이후 연결 | 난이도 |
|------|-------------------|---------|-----------|--------|
| 1. 타임아웃 늘리기 | ✅ | 3분 | 3분 | ⭐ |
| 2. 새 컨테이너 | ❌ | 3분 | 10초 | ⭐⭐ |
| 3. 기존 재생성 | ⚠️ | 3분 | 10초 | ⭐⭐⭐ |
| 4. Windows 마운트 | ❌ | 3분 | 10초 | ⭐⭐ |

---

## 🎯 권장 순서

### 당장 연결하고 싶다면:
**→ 방법 1 (타임아웃 늘리기)**

### 장기적으로 빠른 연결 원한다면:
**→ 방법 2 (새 컨테이너)**

### 기존 컨테이너가 중요하지 않다면:
**→ 방법 3 (기존 재생성)**

---

## 🔍 볼륨 확인 명령어

```powershell
# 생성된 볼륨 목록
docker volume ls

# 볼륨 상세 정보
docker volume inspect cursor-server-cache

# 볼륨 사용 중인 컨테이너 확인
docker ps --filter volume=cursor-server-cache

# 볼륨 삭제 (사용 중이 아닐 때)
docker volume rm cursor-server-cache
```

---

## ✅ 성공 확인

### 첫 연결 시:
- 서버 다운로드 진행 (2-3분)
- "Installing server script" 메시지

### 두 번째 연결 시:
- ⚡ **매우 빠름 (10초 이내)**
- 다운로드 메시지 없음
- 바로 "Server ready" 상태

---

## 💡 추가 팁

### devcontainer.json에 볼륨 추가

`.devcontainer/devcontainer.json`:
```json
{
  "name": "RHEL 8.10 Dev Container",
  "image": "nwharbor.sec.samsung.net/build/access_rhel8.10:latest",
  "mounts": [
    "source=cursor-server-cache,target=/root/.cursor-server,type=volume"
  ]
}
```

### docker-compose.yml 사용

`.devcontainer/docker-compose.yml`:
```yaml
version: '3.8'
services:
  rhel-dev:
    image: nwharbor.sec.samsung.net/build/access_rhel8.10:latest
    volumes:
      - cursor-server-cache:/root/.cursor-server
    command: tail -f /dev/null

volumes:
  cursor-server-cache:
```

---

## 📞 요약

```
┌─────────────────────────────────────────────┐
│ 빠른 해결: 방법 1 (타임아웃 늘리기)          │
│ - settings.json에 3줄 추가                  │
│ - Cursor 재시작                             │
│ - 매번 3분 소요하지만 성공함                │
├─────────────────────────────────────────────┤
│ 최적 해결: 방법 2 (새 컨테이너 + 볼륨)       │
│ - docker volume create cursor-server-cache │
│ - docker run -v cursor-server-cache:...    │
│ - 첫 연결 3분, 이후 10초                    │
└─────────────────────────────────────────────┘
```

**지금은 방법 1로 연결 성공시키고, 나중에 방법 2로 개선하는 것을 권장합니다!** 🚀
