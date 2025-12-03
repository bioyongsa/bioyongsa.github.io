# WSL 및 임시 파일 정리 가이드

## 1. WSL 삭제 방법

WSL(Windows Subsystem for Linux)은 Windows 호스트에서 삭제해야 합니다. Docker 컨테이너 내부에서는 삭제할 수 없습니다.

### Windows PowerShell 또는 CMD에서 실행:

```powershell
# 설치된 WSL 배포판 목록 확인
wsl --list --verbose

# 특정 배포판 삭제 (예: Ubuntu-24.04)
wsl --unregister Ubuntu-24.04

# 또는 배포판 이름이 다르다면
wsl --unregister <배포판이름>
```

### 주의사항:
- WSL을 삭제하면 해당 배포판의 모든 데이터가 삭제됩니다
- `/home/sangku/wsl` 디렉토리는 Windows 파일 시스템에 있으므로, WSL 삭제 후에도 남아있을 수 있습니다
- 필요하다면 Windows에서 해당 디렉토리를 수동으로 삭제하세요

## 2. /tmp 디렉토리 파일 정리

### 안전하게 삭제 가능한 파일들:

1. **cursor-distro-env.* 파일들**
   - Cursor 에디터의 임시 환경 변수 파일
   - 삭제해도 무방

2. **devcontainer-cli-* 디렉토리들**
   - Dev Container CLI의 임시 디렉토리
   - 사용 중이 아닌 경우 삭제 가능

3. **cursor-server-*.tar.gz 파일들**
   - Cursor 서버의 압축 파일 (약 65MB)
   - 이미 설치된 경우 삭제 가능

4. **remote-wsl-loc.txt**
   - WSL 위치 정보 임시 파일
   - 삭제해도 무방

### 주의가 필요한 파일들:

1. **systemd-private-* 디렉토리들**
   - systemd 서비스의 private 임시 디렉토리
   - 실행 중인 서비스가 사용 중일 수 있음
   - 사용 중이 아닌 경우에만 삭제 가능

2. **snap-private-tmp**
   - Snap 패키지의 임시 디렉토리
   - 사용 중일 수 있으므로 주의 필요

## 3. 정리 스크립트 사용법

제공된 `cleanup_tmp.sh` 스크립트를 사용하여 안전하게 정리할 수 있습니다:

```bash
# 1. 스크립트에 실행 권한 부여
chmod +x cleanup_tmp.sh

# 2. 먼저 DRY_RUN 모드로 확인 (기본값)
./cleanup_tmp.sh

# 3. 스크립트를 편집하여 DRY_RUN=false로 변경 후 실제 삭제
# 또는 직접 명령어로 삭제:
```

### 수동 삭제 명령어:

```bash
# cursor-distro-env 파일들 삭제
rm -f /tmp/cursor-distro-env.*

# devcontainer-cli 디렉토리들 삭제 (사용 중이 아닌 경우)
rm -rf /tmp/devcontainer-cli-*

# cursor-server tar.gz 파일들 삭제
rm -f /tmp/cursor-server-*.tar.gz

# remote-wsl-loc.txt 삭제
rm -f /tmp/remote-wsl-loc.txt

# systemd-private 디렉토리들 (사용 중이 아닌지 확인 후)
# lsof +D /tmp/systemd-private-*  # 사용 중인지 확인
# rm -rf /tmp/systemd-private-*    # 사용 중이 아닌 경우에만
```

## 4. 디스크 공간 확인

```bash
# /tmp 디렉토리 사용량 확인
du -sh /tmp/*

# 전체 디스크 사용량 확인
df -h
```
