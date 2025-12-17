# Dev Container 타임아웃 문제 해결 가이드

## 증상
```
Failed to install remote server in container: Error: Failed to install server within the timeout
```

## 원인
Cursor가 컨테이너에 서버를 설치하는 데 시간이 너무 오래 걸림

## 해결 방법 (우선순위 순)

### ✅ 방법 1: 스크립트로 수동 시작 (가장 빠름)

```bash
# 프로젝트 루트에서
./.devcontainer/start-container.sh
```

그 다음 Cursor에서:
1. `F1` 키
2. "**Attach to Running Container**" 검색
3. `rhel8-dev-container` 선택

### ✅ 방법 2: Docker Compose 사용

```bash
cd .devcontainer
docker-compose up -d
```

그 다음 Cursor에서 위와 동일하게 실행 중인 컨테이너에 연결

### ✅ 방법 3: 간단한 설정 사용

현재 `devcontainer.json`을 백업하고 간단한 버전 사용:

```bash
cd .devcontainer
mv devcontainer.json devcontainer.json.backup
cp devcontainer.simple.json devcontainer.json
```

그 다음 Cursor 재시작

### ✅ 방법 4: Cursor 타임아웃 설정 증가

**Cursor 설정 파일 위치:**
- Mac: `~/Library/Application Support/Cursor/User/settings.json`
- Linux: `~/.config/Cursor/User/settings.json`
- Windows: `%APPDATA%\Cursor\User\settings.json`

**추가할 설정:**
```json
{
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 120000,
  "remote.autoForwardPorts": false,
  "remote.containers.executeInWSL": false
}
```

저장 후 Cursor 재시작

### ✅ 방법 5: Docker 리소스 증가

**Docker Desktop → Settings → Resources:**
- **CPUs**: 최소 4개
- **Memory**: 최소 8GB
- **Swap**: 최소 2GB
- **Disk**: 충분한 여유 공간

설정 후 Docker 재시작

### ✅ 방법 6: 캐시 및 불필요한 데이터 정리

```bash
# Docker 시스템 정리
docker system prune -a -f

# 사용하지 않는 볼륨 제거
docker volume prune -f

# Cursor 캐시 정리 (Cursor 종료 후)
# Mac/Linux
rm -rf ~/.cursor/cache
rm -rf ~/Library/Application\ Support/Cursor/Cache

# Windows
# %APPDATA%\Cursor\Cache 폴더 삭제
```

### ✅ 방법 7: Dev Container 확장 확인

Cursor에서:
1. 확장 탭 열기
2. "**Dev Containers**" 또는 "**Remote - Containers**" 검색
3. 설치되어 있지 않다면 설치
4. 비활성화되어 있다면 활성화

### ✅ 방법 8: 네트워크 문제 확인

```bash
# 이미지 다운로드 테스트
docker pull hello-world

# DNS 확인
docker run --rm alpine ping -c 3 8.8.8.8
```

프록시 사용 중이라면 `~/.docker/config.json`:
```json
{
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:8080",
      "httpsProxy": "http://proxy.example.com:8080"
    }
  }
}
```

## 최종 수단: 순수 Docker 사용

Cursor dev container 대신 순수 Docker로 작업:

```bash
# 컨테이너 시작
docker run -it --rm \
  --name rhel8-workspace \
  -v "$(pwd):/workspace" \
  -w /workspace \
  access_rhel8.10:latest \
  /bin/bash

# 별도 터미널에서 파일 편집은 Cursor로
```

## 로그 확인

더 자세한 디버깅을 위해:

**Cursor 로그:**
1. `F1` → "Developer: Show Logs"
2. "Window" 또는 "Remote Server" 선택
3. 에러 메시지 확인

**Docker 로그:**
```bash
# 컨테이너 로그
docker logs rhel8-dev-container

# Docker 데몬 로그
# Mac: ~/Library/Containers/com.docker.docker/Data/log/
# Linux: journalctl -u docker
```

## 여전히 안 되는 경우

1. **Cursor 버전 확인 및 업데이트**
2. **Docker 버전 확인 및 업데이트**
3. **시스템 재부팅**
4. **방법 1 (수동 시작)** 사용 권장

## 빠른 체크리스트

- [ ] Docker Desktop 실행 중인가?
- [ ] `access_rhel8.10:latest` 이미지 존재하는가?
- [ ] Docker에 최소 8GB 메모리 할당되었는가?
- [ ] 디스크 공간이 충분한가?
- [ ] Cursor가 최신 버전인가?
- [ ] Dev Containers 확장이 설치되어 있는가?
- [ ] 방화벽이나 VPN이 문제를 일으키지 않는가?
- [ ] 다른 컨테이너는 정상 작동하는가?

## 도움이 되는 명령어

```bash
# Docker 상태 확인
docker info
docker ps -a
docker images

# 리소스 사용량 확인
docker stats

# 특정 컨테이너 상세 정보
docker inspect rhel8-dev-container

# 네트워크 확인
docker network ls
```
