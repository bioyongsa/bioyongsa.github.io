# Cursor IDE에서 Container 연결 가이드

## 현재 상황

Remote Explorer에서 보이는 항목들:
- **DEV CONTAINERS > access_rhel8.10** ← 이것이 Docker Container입니다!
- SSH TARGETS
- WSL TARGETS > Ubuntu 24.04 와 docker-desktop

## 연결 방법

### 방법 1: Remote Explorer에서 연결 (권장)

1. **왼쪽 사이드바에서 "Remote Explorer" 아이콘 클릭**
   - 또는 `Ctrl+Shift+E` 후 Remote Explorer 탭 선택

2. **"DEV CONTAINERS" 섹션 확장**
   - "access_rhel8.10" 항목이 보임

3. **"access_rhel8.10" 항목에 마우스 오버**
   - 오른쪽에 "..." (더보기) 버튼이 나타남

4. **"..." 버튼 클릭 → "Open Folder in Container" 선택**
   - 또는 "access_rhel8.10" 항목을 우클릭 → "Connect to Container" 선택

5. **새 창이 열리거나 현재 창에서 Container에 연결됨**

### 방법 2: Command Palette 사용

1. **Command Palette 열기**: `Ctrl+Shift+P`

2. **다음 중 하나 입력:**
   - `Remote-Containers: Reopen in Container`
   - `Remote-Containers: Attach to Running Container`
   - `Remote-Containers: Reopen Container`

3. **"access_rhel8.10" 선택**

### 방법 3: 직접 연결

1. **Command Palette**: `Ctrl+Shift+P`

2. **`Remote-Containers: Attach to Running Container` 입력**

3. **목록에서 "access_rhel8.10" 선택**

## 확인 방법

Container에 연결되면:

1. **왼쪽 하단에 "Dev Container: access_rhel8.10" 표시됨**
   - 또는 "Container: access_rhel8.10" 표시

2. **터미널에서 확인:**
   - `hostname` 명령어 실행 → "BuildServer" 또는 Container 이름 표시
   - `pwd` 명령어 실행 → Container 내부 경로 표시

3. **확장 프로그램 탭에서:**
   - "Installed" 섹션에 Container 확장 프로그램 표시

## 문제 해결

### Container가 목록에 나타나지 않는 경우:

1. **Docker가 실행 중인지 확인:**
   ```powershell
   # Windows PowerShell에서
   docker ps
   ```

2. **Container가 실행 중인지 확인:**
   ```powershell
   docker ps -a | findstr access_rhel8.10
   ```

3. **Cursor IDE 재시작**

### 연결이 안 되는 경우:

1. **Command Palette에서:**
   - `Remote-Containers: Show Container Log` 실행
   - 오류 메시지 확인

2. **Docker Container 재시작:**
   ```powershell
   # Windows PowerShell에서
   docker restart access_rhel8.10
   ```

3. **Cursor IDE 완전 재시작**

## 요약

**연결할 항목:**
- ✅ **DEV CONTAINERS > access_rhel8.10** ← 이것을 선택하세요!

**연결하지 않을 항목:**
- ❌ SSH TARGETS (SSH 연결용)
- ❌ WSL TARGETS (WSL용, Docker Container 아님)
