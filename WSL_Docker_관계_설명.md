# WSL과 Docker의 관계 설명

## 현재 상황 분석

당신의 환경:
- **Windows 11 호스트**
- **WSL 2** (Windows Subsystem for Linux)
- **Docker Desktop** (WSL 2 백엔드 사용 가능)
- **Docker Container** (Ubuntu 24.04 이미지 실행 중)

## 중요한 구분

### 1. WSL 배포판 (Ubuntu-24.04)
- Windows에서 Linux 환경을 제공하는 **배포판**
- 예: Ubuntu-24.04, Ubuntu-22.04, Debian 등
- 각 배포판은 독립적입니다

### 2. Docker Desktop
- Windows에서 Docker를 실행하기 위한 도구
- **WSL 2 백엔드**를 사용할 수 있음 (설정에 따라)

### 3. Docker Container
- Docker 이미지에서 실행되는 **컨테이너**
- WSL 배포판과는 **별개**입니다

## WSL 배포판 삭제의 영향

### ✅ 안전한 경우
```
Docker Desktop이 WSL 2 백엔드를 사용하지만,
다른 WSL 배포판(예: Ubuntu-22.04)을 사용하는 경우
→ Ubuntu-24.04 배포판 삭제해도 Docker는 계속 작동
```

### ⚠️ 주의가 필요한 경우
```
Docker Desktop이 Ubuntu-24.04 배포판을 직접 사용하는 경우
→ Ubuntu-24.04 삭제 시 Docker에 영향 가능
```

## 확인 방법

### Windows PowerShell에서 확인:

```powershell
# 1. 설치된 WSL 배포판 목록 확인
wsl --list --verbose

# 2. Docker Desktop이 사용하는 WSL 배포판 확인
# Docker Desktop 설정 > Resources > WSL Integration에서 확인
# 또는 다음 명령어로 확인:
wsl --list --verbose | findstr docker
```

### Docker Desktop 설정 확인:
1. Docker Desktop 열기
2. Settings (설정) 클릭
3. Resources > WSL Integration 이동
4. "Enable integration with my default WSL distro" 체크 여부 확인
5. 어떤 배포판이 활성화되어 있는지 확인

## 권장 사항

### 시나리오 1: Docker Desktop이 Ubuntu-24.04를 사용하지 않는 경우
- ✅ **안전하게 삭제 가능**
- Ubuntu-24.04 배포판만 삭제됨
- Docker container는 계속 정상 작동

### 시나리오 2: Docker Desktop이 Ubuntu-24.04를 사용하는 경우
- ⚠️ **먼저 Docker Desktop 설정 변경 필요**
- Docker Desktop > Settings > WSL Integration에서 다른 배포판 선택
- 또는 "Enable integration with my default WSL distro" 해제
- 그 후 Ubuntu-24.04 삭제 가능

## 결론

**질문에 대한 답변:**
- ✅ **네, 맞습니다!** `wsl --unregister Ubuntu-24.04`는 **WSL 배포판만** 삭제합니다
- ✅ Docker container는 **Docker Desktop이 실행되는 한** 계속 작동합니다
- ⚠️ 단, Docker Desktop이 Ubuntu-24.04 배포판을 직접 사용 중이라면, 먼저 설정을 변경해야 합니다

**안전한 삭제 절차:**
1. Docker Desktop 설정에서 WSL Integration 확인
2. Ubuntu-24.04가 사용 중이면 다른 배포판으로 변경
3. 그 후 `wsl --unregister Ubuntu-24.04` 실행
