# 🚀 빠른 시작 가이드 - RHEL 8.10 Dev Container

## 📍 실행 위치가 중요합니다!

모든 명령어는 **프로젝트 루트 디렉토리(`/workspace`)**에서 실행해야 합니다.

---

## 방법 1: 자동 스크립트 사용 (⭐ 가장 쉬움)

### 1단계: Cursor에서 터미널 열기

**방법 A: 단축키**
- Windows/Linux: `Ctrl + ` ` (백틱, 숫자 1 왼쪽)
- Mac: `Cmd + ` `

**방법 B: 메뉴**
- 상단 메뉴 → `Terminal` → `New Terminal`

### 2단계: 위치 확인

터미널에 다음 입력:
```bash
pwd
```

**출력 결과가 `/workspace`인지 확인하세요!**

만약 다른 위치라면:
```bash
cd /workspace
```

### 3단계: 스크립트 실행

```bash
./.devcontainer/start-container.sh
```

**예상 출력:**
```
🚀 RHEL 8.10 Dev Container 시작 중...
📦 컨테이너 생성 및 시작...
✅ 컨테이너가 성공적으로 시작되었습니다!

다음 단계:
1. Cursor에서 F1 키를 누르세요
2. 'Dev Containers: Attach to Running Container' 검색
3. 'rhel8-dev-container' 선택
```

### 4단계: Cursor에서 컨테이너 연결

1. **`F1`** 키 누르기
2. 검색창에 **"attach"** 입력
3. **"Dev Containers: Attach to Running Container"** 선택
4. **"rhel8-dev-container"** 선택

---

## 방법 2: Docker Compose 사용

### 1단계: 터미널에서 .devcontainer 디렉토리로 이동

```bash
cd /workspace/.devcontainer
```

### 2단계: Docker Compose 실행

```bash
docker-compose up -d
```

### 3단계: 원래 디렉토리로 돌아오기

```bash
cd /workspace
```

### 4단계: Cursor에서 컨테이너 연결 (방법 1의 4단계와 동일)

---

## 방법 3: Cursor의 자동 연결 사용

### 전제 조건
- Dev Containers 확장 설치 필요
- Cursor 설정에서 타임아웃 증가 필요 (아래 참조)

### 1단계: Cursor 설정 파일 열기

**설정 파일 위치:**
- **Mac**: `~/Library/Application Support/Cursor/User/settings.json`
- **Linux**: `~/.config/Cursor/User/settings.json`  
- **Windows**: `%APPDATA%\Cursor\User\settings.json`

**또는 Cursor 내에서:**
1. `F1` → "Preferences: Open User Settings (JSON)"

### 2단계: 다음 설정 추가

```json
{
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 120000
}
```

### 3단계: Cursor 완전히 재시작

### 4단계: 컨테이너에 연결

**방법 A: 좌측 하단 아이콘**
- 좌측 하단 **`><`** 모양 아이콘 클릭
- **"Reopen in Container"** 선택

**방법 B: 명령 팔레트**
- `F1` 키
- **"Dev Containers: Open Folder in Container"** 검색 및 선택

---

## ❌ 문제 해결

### "permission denied" 에러

```bash
chmod +x /workspace/.devcontainer/start-container.sh
```

### "docker: command not found" 에러

Docker가 설치되지 않았거나 실행 중이지 않습니다.

**확인:**
```bash
docker --version
docker ps
```

**Docker Desktop 실행 확인:**
- Mac: Spotlight → "Docker" 검색 → 실행
- Windows: 시작 메뉴 → "Docker Desktop" 실행
- Linux: `sudo systemctl start docker`

### "access_rhel8.10:latest" 이미지를 찾을 수 없음

이미지가 로컬에 없습니다.

**확인:**
```bash
docker images | grep access_rhel8.10
```

**해결:**
- 이미지를 빌드하거나 pull 해야 합니다
- Dockerfile이 있다면: `docker build -t access_rhel8.10:latest .`
- 레지스트리에서: `docker pull access_rhel8.10:latest`

### 여전히 타임아웃 에러

**즉시 시도:**
```bash
# 기존 컨테이너 정리
docker ps -a | grep rhel8
docker rm -f rhel8-dev-container

# 캐시 정리
docker system prune -f

# 다시 시도
./.devcontainer/start-container.sh
```

---

## 🎓 명령어 설명

### `./` 의미
- **현재 디렉토리**를 의미
- `/workspace`에 있을 때 `./.devcontainer`는 `/workspace/.devcontainer`

### 절대 경로 사용도 가능
```bash
/workspace/.devcontainer/start-container.sh
```

---

## ✅ 성공 확인

컨테이너 연결에 성공하면:

**1. 터미널 프롬프트 변경**
```bash
root@container-id:/workspace#
```

**2. 좌측 하단 아이콘 변경**
- **`><`** 아이콘이 **"Dev Container: RHEL 8.10 Dev Container"**로 표시

**3. OS 버전 확인**
```bash
cat /etc/redhat-release
# 출력: Red Hat Enterprise Linux release 8.10
```

---

## 📞 추가 도움

더 자세한 문제 해결은 다음 파일 참조:
- `.devcontainer/README.md`
- `.devcontainer/TROUBLESHOOTING.md`

---

## 🎯 요약

```bash
# 1. 터미널 열기 (Ctrl + `)
# 2. 위치 확인
pwd  # /workspace 여야 함

# 3. 스크립트 실행
./.devcontainer/start-container.sh

# 4. Cursor에서 F1 → "Attach to Running Container" → "rhel8-dev-container" 선택
```

**그게 전부입니다!** 🎉
