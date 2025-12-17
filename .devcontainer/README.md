# Dev Container Setup

이 프로젝트는 Jekyll 블로그를 위한 Dev Container 설정을 포함하고 있습니다.

## 사용 방법

1. **Dev Container 열기**
   - VSCode/Cursor에서 `F1` 또는 `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
   - "Dev Containers: Reopen in Container" 선택

2. **Jekyll 서버 실행**
   ```bash
   bundle exec jekyll serve --livereload
   ```
   
   또는 호스트에서 접근하려면:
   ```bash
   bundle exec jekyll serve --host 0.0.0.0 --livereload
   ```

3. **브라우저에서 확인**
   - http://localhost:4000

## 타임아웃 문제 해결

만약 여전히 타임아웃 문제가 발생한다면:

### 방법 1: Docker 리소스 증가
- Docker Desktop 설정에서 CPU와 메모리 할당량 증가
- 최소 4GB RAM, 2 CPU 코어 권장

### 방법 2: Docker 이미지 미리 다운로드
```bash
docker pull mcr.microsoft.com/devcontainers/ruby:1-3.3-bullseye
```

### 방법 3: 기존 컨테이너 정리
```bash
# 사용하지 않는 컨테이너 제거
docker container prune -f

# 사용하지 않는 이미지 제거
docker image prune -a -f

# 사용하지 않는 볼륨 제거
docker volume prune -f
```

### 방법 4: Dev Container 재빌드
- VSCode/Cursor에서 `F1` 또는 `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
- "Dev Containers: Rebuild Container" 선택

## 문제 해결

### 연결이 느린 경우
네트워크 상태를 확인하고, 필요시 Docker Hub 미러를 설정하세요.

### 포트가 이미 사용 중인 경우
```bash
# 포트 사용 중인 프로세스 확인
lsof -i :4000

# 또는 다른 포트 사용
bundle exec jekyll serve --port 4001
```
