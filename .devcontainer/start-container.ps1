# RHEL 8.10 Dev Container 시작 스크립트 (Windows PowerShell)

$ErrorActionPreference = "Stop"

$CONTAINER_NAME = "rhel8-dev-container"
$IMAGE_NAME = "access_rhel8.10:latest"
$WORKSPACE_DIR = Split-Path -Parent $PSScriptRoot

Write-Host "🚀 RHEL 8.10 Dev Container 시작 중..." -ForegroundColor Green

# Docker 확인
try {
    docker --version | Out-Null
} catch {
    Write-Host "❌ Docker가 설치되지 않았거나 실행 중이지 않습니다." -ForegroundColor Red
    Write-Host "Docker Desktop을 설치하고 실행해주세요: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# 기존 컨테이너 확인 및 제거
$existing = docker ps -a -q -f name=$CONTAINER_NAME
if ($existing) {
    Write-Host "⚠️  기존 컨테이너 발견. 제거 중..." -ForegroundColor Yellow
    docker rm -f $CONTAINER_NAME
}

# 이미지 확인
try {
    docker image inspect $IMAGE_NAME | Out-Null
} catch {
    Write-Host "❌ 이미지 '$IMAGE_NAME'를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "다음 명령으로 이미지를 빌드하거나 pull 하세요:" -ForegroundColor Yellow
    Write-Host "  docker pull $IMAGE_NAME" -ForegroundColor Cyan
    exit 1
}

# 컨테이너 시작
Write-Host "📦 컨테이너 생성 및 시작..." -ForegroundColor Green
docker run -d `
    --name $CONTAINER_NAME `
    --cap-add=SYS_PTRACE `
    --security-opt seccomp=unconfined `
    -v "${WORKSPACE_DIR}:/workspace" `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -w /workspace `
    -e HOME=/root `
    $IMAGE_NAME `
    tail -f /dev/null

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 컨테이너가 성공적으로 시작되었습니다!" -ForegroundColor Green
    Write-Host ""
    Write-Host "다음 단계:" -ForegroundColor Cyan
    Write-Host "1. Cursor에서 F1 키를 누르세요"
    Write-Host "2. 'Dev Containers: Attach to Running Container' 검색"
    Write-Host "3. '$CONTAINER_NAME' 선택"
    Write-Host ""
    Write-Host "또는 터미널에서 직접 접속:" -ForegroundColor Cyan
    Write-Host "  docker exec -it $CONTAINER_NAME /bin/bash" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "컨테이너 중지:" -ForegroundColor Cyan
    Write-Host "  docker stop $CONTAINER_NAME" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "컨테이너 제거:" -ForegroundColor Cyan
    Write-Host "  docker rm -f $CONTAINER_NAME" -ForegroundColor Yellow
} else {
    Write-Host "❌ 컨테이너 시작 실패" -ForegroundColor Red
    exit 1
}
