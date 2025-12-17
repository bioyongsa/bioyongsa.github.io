# 🔧 Timeout 문제 해결 가이드

## 증상
```
Failed to install remote server in container: Error: Failed to install server within the timeout
```

하지만 실제로는 서버가 설치 완료됨:
```
exitCode==0==
listeningOn==38307==
```

**원인**: Cursor의 타임아웃 설정이 서버 설치 시간보다 짧음 (약 90초 vs 실제 필요 시간 2분)

---

## ✅ 해결 방법 (우선순위 순)

### 방법 1: Cursor 설정 변경 (가장 확실함) ⭐

#### Windows에서 설정 파일 열기:

**경로:** `C:\Users\sangku\AppData\Roaming\Cursor\User\settings.json`

**또는 Cursor에서:**
1. `F1` → `Preferences: Open User Settings (JSON)`

#### 다음 내용 추가:

```json
{
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 300000,
  "remote.containers.installTimeoutSeconds": 300
}
```

**전체 예시:**
```json
{
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 13,
  "remote.containers.timeoutSeconds": 600,
  "remote.containers.connectionTimeout": 300000,
  "remote.containers.installTimeoutSeconds": 300
}
```

#### 저장 후:
1. Cursor **완전히 종료**
2. Cursor **재시작**
3. `F1` → `Attach to Running Container` → `access_rhel8.10`

---

### 방법 2: 즉시 재시도 (캐시 활용)

첫 연결 시도에서 서버가 실제로 설치되었으므로, **바로 다시 연결**하면 성공할 수 있습니다.

#### 즉시 재시도:
1. `F1`
2. `Attach to Running Container`
3. `access_rhel8.10` 선택

**2번째부터는 캐시를 사용하므로 훨씬 빠름!**

---

### 방법 3: 컨테이너 정리 후 재연결

#### PowerShell에서:

```powershell
# 컨테이너 내부 접속
docker exec -it access_rhel8.10 /bin/bash
```

#### 컨테이너 내부에서:

```bash
# 임시 파일 정리
rm -rf /tmp/cursor-server-*.tar.gz
rm -rf /tmp/vscode-*

# 압축 도구 확인/설치 (더 빠른 압축 해제)
which tar gzip || yum install -y tar gzip

# 디스크 공간 확인
df -h /tmp
df -h /root

# 빠져나오기
exit
```

#### 그 다음 Cursor에서 다시 연결

---

### 방법 4: Docker 리소스 증가

Docker Station 설정에서:

1. **Settings/Preferences**
2. **Resources**
3. 다음 증가:
   - **CPU**: 최소 4 코어
   - **Memory**: 최소 8GB
   - **Disk**: 충분한 공간

4. **Apply & Restart**

---

### 방법 5: 컨테이너 재시작

#### PowerShell에서:

```powershell
# 컨테이너 재시작
docker restart access_rhel8.10

# 재시작 확인
docker ps | Select-String "access_rhel8.10"

# Cursor에서 다시 연결
```

---

## 🎯 권장 순서

```
1단계: 방법 2 시도 (즉시 재시도)
   ↓ 실패
2단계: 방법 1 적용 (타임아웃 증가)
   ↓ 여전히 느림
3단계: 방법 3 (컨테이너 정리)
   ↓ 여전히 문제
4단계: 방법 4 (리소스 증가)
```

---

## 📊 타임아웃 설정 설명

| 설정 | 기본값 | 권장값 | 설명 |
|------|--------|--------|------|
| `timeoutSeconds` | 120 | 600 | 전체 연결 타임아웃 (초) |
| `connectionTimeout` | 60000 | 300000 | 연결 타임아웃 (밀리초) |
| `installTimeoutSeconds` | 120 | 300 | 서버 설치 타임아웃 (초) |

---

## 🔍 로그 분석 방법

### Cursor 로그 보기:
1. `F1` → `Developer: Show Logs`
2. `Window` 선택
3. 에러 메시지 확인

### 설치 진행 상황:
```
[info] Installing server script          → 시작
[info] Cursor server path: /tmp/...      → 다운로드 중
[info] exitCode==0==                     → 설치 성공!
[info] listeningOn==38307==              → 서버 실행 중!
```

---

## ✅ 성공 확인

연결 성공 시:

### 1. 좌측 하단
```
Container: access_rhel8.10
```

### 2. 터미널
```bash
[root@3d78c923c661 /]#
```

### 3. 파일 탐색기
컨테이너 내부의 `/workspace` 또는 `/` 경로 표시

---

## 🚨 여전히 실패하는 경우

### 컨테이너 로그 확인:
```powershell
docker logs access_rhel8.10 --tail 100
```

### Cursor 서버 로그 확인:
```powershell
docker exec -it access_rhel8.10 cat /root/.cursor-server/.*.log
```

### 네트워크 확인:
```powershell
docker exec -it access_rhel8.10 ping -c 3 google.com
```

### 방화벽 확인:
- 회사 네트워크 방화벽
- Windows Defender 방화벽
- Docker Station 네트워크 설정

---

## 💡 추가 팁

### Cursor 서버 수동 설치 (고급)

컨테이너 내부에서:
```bash
# Cursor 서버 디렉토리로 이동
cd /root/.cursor-server/

# 기존 서버 확인
ls -lh

# 만약 서버가 이미 있다면, 다음 연결 시 빠르게 시작됨
```

### 디스크 공간 확보:
```bash
# 컨테이너 내부에서
du -sh /root/.cursor-server/
du -sh /tmp/

# 불필요한 파일 삭제
rm -rf /tmp/cursor-server-*.tar.gz
```

---

## 📞 요약

**가장 빠른 해결책:**
1. **즉시 재시도** (방법 2)
2. 실패하면 **Cursor 설정 변경** (방법 1)
3. Cursor 재시작
4. 다시 연결

**95% 이상 방법 1+2로 해결됩니다!** 🎉
