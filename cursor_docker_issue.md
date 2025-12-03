# Docker Container에서 Cursor 실행 오류 해결

## 문제 분석

### 오류 원인
```
(node:14634) Warning: To load an ES module, set "type": "module" in the package.json or use the .mjs extension.
```

**원인:**
- Cursor 서버가 ES Module 형식으로 작성됨
- Node.js가 ES Module을 제대로 인식하지 못함
- Docker container 내에서 실행 시 경로/환경 문제 발생 가능

### 근본적인 문제

**Docker container 내에서 Cursor를 실행하는 것은 권장되지 않습니다:**

1. **Cursor는 IDE/에디터**
   - GUI 애플리케이션
   - 호스트 시스템에서 실행되어야 함

2. **Docker container는 격리된 환경**
   - GUI 접근 제한
   - 파일 시스템 마운트 필요

3. **Cursor 서버는 원격 개발용**
   - SSH나 원격 연결을 통해 사용
   - 직접 실행보다는 Cursor IDE에서 자동 연결

## 해결 방법

### 방법 1: 호스트에서 Cursor 실행 (권장)

**Windows 호스트에서:**
1. Cursor IDE를 Windows에서 실행
2. Cursor가 자동으로 WSL/Docker container를 감지
3. "Remote - Containers" 또는 "Remote - WSL" 확장 사용

### 방법 2: Docker Container 내에서 수정 (임시 해결)

만약 정말 Docker container 내에서 실행해야 한다면:

```bash
# 1. Cursor 서버 경로 확인
ls -la /mnt/d/.cursor-server/bin/

# 2. Node.js 버전 확인 (ES Module 지원 필요)
node --version  # v14.0.0 이상 필요

# 3. package.json에 "type": "module" 추가 (가능한 경우)
# 또는 .mjs 확장자로 변경

# 4. 환경 변수 설정
export NODE_OPTIONS="--experimental-modules"
```

하지만 이것도 완전한 해결책이 아닐 수 있습니다.

### 방법 3: Cursor Remote Development 사용

**권장 방법:**
1. Windows에서 Cursor IDE 실행
2. Cursor에서 "Remote - Containers" 확장 설치
3. Docker container에 연결
4. Container 내에서 파일 편집 가능

## 올바른 사용 방법

### Cursor + Docker Container 워크플로우

```
Windows Host
    ↓
Cursor IDE (GUI)
    ↓
Remote - Containers Extension
    ↓
Docker Container (코드 실행 환경)
```

**장점:**
- GUI는 호스트에서 실행 (성능 좋음)
- 코드는 Container에서 실행 (격리된 환경)
- 파일 동기화 자동 처리

## 현재 상황에서의 권장사항

1. **Docker container 내에서 `cursor` 명령어 실행 중단**
   - Cursor는 IDE이므로 호스트에서 실행해야 함

2. **Windows에서 Cursor IDE 실행**
   - Cursor가 자동으로 WSL/Docker 감지

3. **필요시 Remote Development 확장 사용**
   - "Remote - Containers" 확장 설치
   - Container에 연결하여 개발

## 결론

- ❌ Docker container 내에서 `cursor` 명령어 직접 실행
- ✅ Windows 호스트에서 Cursor IDE 실행
- ✅ Remote Development 확장으로 Container 연결
