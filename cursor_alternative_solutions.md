# Cursor Remote Container 문제 - 대안 해결 방법

## 문제 요약
- 확장 프로그램이 Container에 설치되지 않음 ("installing..." 상태에서 멈춤)
- Chat이 작동하지 않음
- Container 재시작해도 해결되지 않음

## 근본 원인 가능성

1. **Cursor Remote Container 확장 프로그램 문제**
2. **Windows와 Container 간 네트워크/마운트 문제**
3. **Cursor 서버가 Container에서 제대로 시작되지 않음**
4. **권한 문제**

## 해결 방법

### 방법 1: Cursor Remote Container 확장 프로그램 재설치

**Windows Cursor IDE에서:**

1. 확장 프로그램 탭 열기 (Ctrl+Shift+X)
2. "Remote - Containers" 검색
3. 확장 프로그램 제거
4. Cursor IDE 완전 재시작
5. "Remote - Containers" 확장 프로그램 재설치
6. Container에 다시 연결

### 방법 2: Cursor IDE 설정 확인

**Settings 확인:**

1. Cursor IDE에서 Settings 열기 (Ctrl+,)
2. "Remote" 검색
3. 다음 설정 확인:
   - `remote.containers.defaultExtensions` 확인
   - `remote.containers.enableDynamicRegistration` 확인
   - `remote.containers.useLocalAfterRemote` 확인

### 방법 3: 수동으로 확장 프로그램 설치

**Container 내에서:**

```bash
# 확장 프로그램 디렉토리 확인
ls -la ~/.cursor-server/extensions/

# 확장 프로그램을 수동으로 다운로드하여 설치
# 예: Python 확장 프로그램
# 확장 프로그램 ID를 찾아서 설치
```

하지만 이 방법은 복잡하고 권장하지 않습니다.

### 방법 4: SSH Remote 사용 (대안)

**SSH를 통한 연결:**

1. Container에 SSH 서버 설치
2. Cursor IDE에서 "Remote - SSH" 확장 사용
3. SSH를 통해 Container에 연결

**장점:**
- Remote Container보다 안정적일 수 있음
- 확장 프로그램 설치가 더 잘 작동할 수 있음

**단점:**
- 추가 설정 필요
- SSH 서버 설치 필요

### 방법 5: WSL 사용 (대안)

**WSL을 통한 개발:**

1. Docker container 대신 WSL 사용
2. Cursor IDE에서 "Remote - WSL" 확장 사용
3. WSL에 직접 연결

**장점:**
- Windows와의 통합이 더 좋음
- 확장 프로그램 설치가 더 잘 작동할 수 있음

**단점:**
- Docker container 환경과 다를 수 있음

### 방법 6: 로컬 개발 + Docker 실행만 Container에서

**하이브리드 접근:**

1. 코드는 Windows/WSL에서 편집
2. 실행만 Docker container에서
3. Docker Compose나 docker run으로 실행

**장점:**
- 확장 프로그램 문제 회피
- Chat 기능 정상 작동

**단점:**
- Container 내부 환경과 다를 수 있음

## 즉시 시도할 수 있는 방법

### 단계 1: 진단 실행

Container 내에서:
```bash
cp /workspace/deep_diagnose_cursor.sh ~/diagnose.sh
chmod +x ~/diagnose.sh
~/diagnose.sh > ~/cursor_diagnosis.txt 2>&1
cat ~/cursor_diagnosis.txt
```

### 단계 2: 완전 수정 스크립트 실행

Container 내에서:
```bash
cp /workspace/fix_cursor_complete.sh ~/fix.sh
chmod +x ~/fix.sh
~/fix.sh
```

### 단계 3: Cursor IDE에서 Container 로그 확인

1. Command Palette (Ctrl+Shift+P)
2. `Remote-Containers: Show Container Log` 실행
3. 오류 메시지 확인

### 단계 4: Cursor IDE 완전 재시작

1. Cursor IDE 완전 종료
2. Windows 작업 관리자에서 모든 Cursor 프로세스 확인 및 종료
3. Windows 재시작 (선택사항)
4. Cursor IDE 재실행
5. Container에 다시 연결

### 단계 5: Docker Container 재빌드

**주의: 이 방법은 시간이 오래 걸릴 수 있습니다**

1. Cursor IDE에서 Command Palette
2. `Remote-Containers: Rebuild Container` 실행
3. 완료될 때까지 대기

## 로그 확인 방법

### Container 내에서:
```bash
# Cursor 서버 로그 확인
tail -100 ~/.cursor-server/logs/*.log

# 실시간 로그 모니터링
tail -f ~/.cursor-server/logs/*.log
```

### Windows에서:
1. Cursor IDE > Help > Toggle Developer Tools
2. Console 탭에서 오류 확인
3. Network 탭에서 연결 문제 확인

## 최후의 수단

### 방법 A: Cursor IDE 재설치

1. Cursor IDE 완전 제거
2. Windows 재시작
3. Cursor IDE 최신 버전 재설치
4. Container에 다시 연결

### 방법 B: Docker Container 재생성

1. Container 백업 (필요한 데이터)
2. Container 삭제
3. 새로 Container 생성
4. Cursor IDE에서 다시 연결

## 질문할 사항

진단을 위해 다음 정보가 필요합니다:

1. **Container 내에서 진단 스크립트 실행 결과**
2. **Cursor IDE의 Container 로그 내용**
3. **Windows 이벤트 로그의 오류 (선택사항)**
4. **Docker container 실행 방법** (docker run, docker-compose 등)
5. **Container 이미지 정보**

이 정보를 제공해주시면 더 구체적인 해결 방법을 제시할 수 있습니다.
