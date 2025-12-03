# Cursor Remote Container 문제 해결 가이드

## 문제 상황
- 확장 프로그램이 Container에 설치되지 않음 ("installing..." 상태에서 멈춤)
- Chat이 반응 없음

## 가능한 원인

1. **Container 연결 문제**
   - Cursor 서버가 Container에서 제대로 실행되지 않음
   - 네트워크 연결 문제

2. **권한 문제**
   - Container 내에서 파일 쓰기 권한 없음
   - 확장 프로그램 설치 경로 접근 불가

3. **Cursor 서버 문제**
   - 서버가 제대로 시작되지 않음
   - 로그에서 오류 확인 필요

4. **Container 설정 문제**
   - devcontainer.json 설정 누락
   - 필요한 도구 미설치

## 해결 방법

### 1. Container 연결 상태 확인

접속한 환경에서 확인:

```bash
# Cursor 서버 프로세스 확인
ps aux | grep cursor

# Cursor 서버 로그 확인
ls -la ~/.cursor-server/logs/
tail -50 ~/.cursor-server/logs/*.log

# 확장 프로그램 디렉토리 확인
ls -la ~/.cursor-server/extensions/
```

### 2. 수동으로 확장 프로그램 설치

```bash
# 확장 프로그램 디렉토리 생성
mkdir -p ~/.cursor-server/extensions

# 권한 확인
ls -la ~/.cursor-server/
```

### 3. Container 재연결

Cursor IDE에서:
1. Command Palette (Ctrl+Shift+P)
2. "Remote-Containers: Reopen Container" 실행
3. 또는 "Remote-Containers: Rebuild Container"

### 4. Cursor 서버 재시작

```bash
# Cursor 서버 프로세스 종료
pkill -f cursor-server

# 또는 특정 프로세스 찾아서 종료
ps aux | grep cursor-server
kill <PID>
```

### 5. 네트워크 연결 확인

```bash
# 포트 확인
netstat -tuln | grep -E "(3000|8080|9000)"

# Cursor 서버 포트 확인
ss -tuln | grep cursor
```

### 6. devcontainer.json 확인

Container 루트에 `.devcontainer/devcontainer.json` 파일이 있는지 확인:

```json
{
  "name": "Your Container",
  "image": "your-image",
  "features": {},
  "customizations": {
    "vscode": {
      "extensions": []
    }
  }
}
```
