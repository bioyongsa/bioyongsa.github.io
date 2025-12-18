# RHEL 8.10 Dev Container 설정

`access_rhel8.10:latest` 이미지를 사용하는 dev container 설정입니다.

## 연결 방법

### 방법 1: Command Palette 사용
Cursor에서 `F1` 또는 `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)를 누르고 다음 중 하나를 검색:

- **"Dev Containers: Open Folder in Container"**
- **"Remote-Containers: Reopen in Container"**
- **"Dev Containers: Rebuild and Reopen in Container"**

### 방법 2: 좌측 하단 아이콘 클릭
Cursor 창 좌측 하단의 초록색/파란색 아이콘(`><`)을 클릭하고:
- "Reopen in Container" 선택

### 방법 3: Docker 이미지가 없는 경우
로컬에 `access_rhel8.10:latest` 이미지가 있는지 확인:

```bash
docker images | grep access_rhel8.10
```

이미지가 없다면 먼저 pull/build 해야 합니다.

## 타임아웃 문제 해결

### 1. Docker 이미지 확인 및 준비
```bash
# 이미지 존재 확인
docker images access_rhel8.10:latest

# 이미지가 없다면 빌드 또는 pull
# docker pull access_rhel8.10:latest
# 또는 Dockerfile이 있다면: docker build -t access_rhel8.10:latest .
```

### 2. 기존 컨테이너 정리
```bash
# 사용하지 않는 컨테이너 제거
docker ps -a | grep access_rhel8.10
docker rm -f <container_id>

# 볼륨 정리
docker volume prune -f
```

### 3. Docker Desktop 리소스 증가
- **Settings → Resources**
- **CPU: 최소 4 코어**
- **Memory: 최소 8GB**
- **Disk: 충분한 공간 확보**

### 4. Cursor 설정 확인
Cursor 설정 파일 (`settings.json`)에서 타임아웃 증가:

```json
{
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 120000
}
```

설정 파일 위치:
- **Mac**: `~/Library/Application Support/Cursor/User/settings.json`
- **Linux**: `~/.config/Cursor/User/settings.json`
- **Windows**: `%APPDATA%\Cursor\User\settings.json`

### 5. 수동으로 컨테이너 시작
```bash
# 컨테이너를 먼저 시작
docker run -d \
  --name rhel8-dev \
  -v "$(pwd)":/workspace \
  -w /workspace \
  access_rhel8.10:latest \
  tail -f /dev/null

# Cursor에서 실행 중인 컨테이너에 연결
# F1 → "Dev Containers: Attach to Running Container"
```

### 6. 로그 확인
Cursor 로그에서 자세한 에러 확인:
- `F1` → "Developer: Show Logs"
- "Window" 또는 "Remote Server" 로그 확인

### 7. 네트워크 문제
```bash
# DNS 확인
docker run --rm access_rhel8.10:latest ping -c 3 8.8.8.8

# 프록시 설정이 필요한 경우 ~/.docker/config.json 확인
```

## 일반적인 문제 해결

### "Failed to install server within the timeout" 에러
1. **Cursor 완전 재시작**
2. **Docker Desktop 재시작**
3. **postCreateCommand 비활성화** (이미 최소화됨)
4. **수동 컨테이너 연결 방식 사용** (위 방법 5 참조)

### RHEL 8.10 특정 이슈
RHEL은 구독이 필요할 수 있습니다. 컨테이너 내에서:

```bash
# 구독 확인
subscription-manager status

# 또는 CentOS Stream 8 사용 고려
```

## 연결 후 확인

컨테이너 연결 성공 후:

```bash
# OS 버전 확인
cat /etc/redhat-release

# 작업 디렉토리 확인
pwd  # /workspace 여야 함

# 사용자 확인
whoami  # root
```

## 추가 도움말

문제가 계속되면:
1. Cursor 버전 업데이트
2. Docker 버전 업데이트
3. 구체적인 에러 로그 확인
