# 🪟 Windows에서 Dev Container 시작하기

Windows에서 RHEL 8.10 dev container에 연결하는 방법입니다.

---

## 전제 조건

### ✅ 1. Docker Desktop 설치 및 실행

**확인 방법:**
- 작업 표시줄(트레이)에 Docker 고래 아이콘이 있는지 확인
- PowerShell에서 `docker --version` 실행

**설치 필요시:**
https://www.docker.com/products/docker-desktop

---

## 방법 1: PowerShell 스크립트 사용 ⭐

### 1단계: 프로젝트 폴더 위치 찾기

**Cursor에서 확인:**
1. 좌측 파일 탐색기에서 아무 파일이나 **우클릭**
2. **"Reveal in File Explorer"** 클릭
3. 주소창의 경로 복사 (예: `C:\Users\sangku\workspace`)

### 2단계: PowerShell에서 해당 폴더로 이동

```powershell
cd "C:\Users\sangku\workspace"  # 실제 경로로 변경
```

### 3단계: 스크립트 실행

```powershell
.\.devcontainer\start-container.ps1
```

**에러가 나면 실행 정책 변경:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

그리고 다시:
```powershell
.\.devcontainer\start-container.ps1
```

### 4단계: Cursor에서 컨테이너 연결

1. **F1** 키
2. **"Dev Containers: Attach to Running Container"** 검색
3. **"rhel8-dev-container"** 선택

---

## 방법 2: Docker 명령어 직접 사용

### PowerShell에서 프로젝트 폴더로 이동 후:

```powershell
# 현재 폴더를 컨테이너에 마운트
docker run -d `
  --name rhel8-dev-container `
  -v "${PWD}:/workspace" `
  -w /workspace `
  access_rhel8.10:latest `
  tail -f /dev/null
```

### 컨테이너에 바로 접속:

```powershell
docker exec -it rhel8-dev-container /bin/bash
```

---

## 방법 3: WSL 사용 (권장) 🐧

Windows에서 Linux 환경을 사용하는 가장 좋은 방법입니다.

### WSL이 설치되어 있다면:

**PowerShell에서:**
```powershell
wsl
```

**또는 Cursor 터미널에서:**
- 터미널 창 우측 상단의 **`+`** 옆 **드롭다운(∨)** 클릭
- **"Ubuntu"** 또는 **"WSL"** 선택

**그러면 Linux 터미널이 열립니다:**
```bash
# 프로젝트 폴더로 이동 (WSL 경로)
cd /mnt/c/Users/sangku/workspace  # Windows C:\ = /mnt/c/

# 스크립트 실행
./.devcontainer/start-container.sh
```

### WSL 설치가 필요하다면:

**PowerShell (관리자 권한):**
```powershell
wsl --install
```

재부팅 후 Ubuntu 설정 완료

---

## 🔍 Cursor 연결 상태 확인

Cursor 화면 **좌측 하단**을 확인하세요:

| 표시 | 의미 | 터미널 위치 |
|------|------|------------|
| `><` | 로컬 Windows | Windows PowerShell |
| `WSL: Ubuntu` | WSL 연결 | Linux (WSL) |
| `SSH: hostname` | SSH 연결 | 원격 Linux |
| `Dev Container: ...` | 컨테이너 연결 | 컨테이너 내부 |

---

## 🎯 권장 워크플로우

### 옵션 A: WSL 사용 (가장 좋음)

```
Windows → WSL → Docker 컨테이너
```

**장점:**
- Linux 환경 그대로 사용
- 성능 우수
- 경로 문제 없음

### 옵션 B: Windows에서 직접

```
Windows PowerShell → Docker 컨테이너
```

**장점:**
- WSL 설치 불필요
- 간단함

---

## ❌ 문제 해결

### "docker: command not found"

**Docker Desktop이 설치되어 있나요?**
```powershell
docker --version
```

**설치 필요:**
https://www.docker.com/products/docker-desktop

**설치되어 있는데 안 되면:**
- Docker Desktop 실행 확인
- PowerShell 재시작

### "cannot start service: image not found"

`access_rhel8.10:latest` 이미지가 없습니다.

**확인:**
```powershell
docker images | Select-String "access_rhel8.10"
```

**해결:**
- 이미지를 pull: `docker pull access_rhel8.10:latest`
- 또는 Dockerfile로 빌드

### PowerShell 스크립트 실행 에러

```
... cannot be loaded because running scripts is disabled ...
```

**해결:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 경로를 찾을 수 없음

**경로에 공백이 있으면 따옴표로 감싸세요:**
```powershell
cd "C:\Users\sangku\my projects\workspace"
```

### WSL 터미널이 목록에 없음

1. WSL이 설치되어 있는지 확인:
   ```powershell
   wsl --list
   ```

2. 없으면 설치:
   ```powershell
   wsl --install
   ```

3. Cursor 재시작

---

## 📊 명령어 비교

### Bash (Linux/WSL/Mac)
```bash
cd /workspace
./start-container.sh
```

### PowerShell (Windows)
```powershell
cd C:\Users\sangku\workspace
.\start-container.ps1
```

### CMD (Windows)
```cmd
cd C:\Users\sangku\workspace
powershell -ExecutionPolicy Bypass -File .\.devcontainer\start-container.ps1
```

---

## ✅ 성공 확인

### 1. Docker 컨테이너 실행 중
```powershell
docker ps
```
**출력에 `rhel8-dev-container` 보여야 함**

### 2. Cursor 좌측 하단
**`Dev Container: RHEL 8.10 Dev Container`** 표시

### 3. 터미널
```bash
root@container-id:/workspace#
```

---

## 🎓 요약

```
┌─────────────────────────────────────────────┐
│ 1. Docker Desktop 실행 확인                   │
├─────────────────────────────────────────────┤
│ 2. PowerShell에서 프로젝트 폴더로 이동         │
│    cd "C:\Users\sangku\workspace"           │
├─────────────────────────────────────────────┤
│ 3. 스크립트 실행                              │
│    .\.devcontainer\start-container.ps1      │
├─────────────────────────────────────────────┤
│ 4. Cursor에서 F1 → Attach to Running        │
│    Container → rhel8-dev-container 선택      │
└─────────────────────────────────────────────┘
```

**또는 WSL 사용:**
```
┌─────────────────────────────────────────────┐
│ 1. PowerShell에서: wsl                       │
├─────────────────────────────────────────────┤
│ 2. Linux 터미널에서:                          │
│    cd /mnt/c/Users/sangku/workspace         │
│    ./.devcontainer/start-container.sh       │
├─────────────────────────────────────────────┤
│ 3. Cursor에서 F1 → Attach to Running        │
│    Container → rhel8-dev-container 선택      │
└─────────────────────────────────────────────┘
```

---

**이제 어떤 방법을 시도해보시겠어요?** 😊
