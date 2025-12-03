#!/bin/bash
# Docker Container 상태 확인 스크립트

echo "=========================================="
echo "  Docker Container 상태 확인"
echo "=========================================="
echo ""

# 1. Docker 명령어 확인
echo "1. Docker 명령어 확인:"
if command -v docker >/dev/null 2>&1; then
    echo "   ✅ Docker 명령어 사용 가능"
    DOCKER_CMD="docker"
elif command -v podman >/dev/null 2>&1; then
    echo "   ✅ Podman 명령어 사용 가능"
    DOCKER_CMD="podman"
else
    echo "   ❌ Docker/Podman 명령어 없음"
    echo "   ⚠️  Windows에서 Docker Desktop이 실행 중인지 확인하세요"
    exit 1
fi
echo ""

# 2. 실행 중인 Container 확인
echo "2. 실행 중인 Container 확인:"
if [ "$DOCKER_CMD" = "docker" ]; then
    RUNNING_CONTAINERS=$($DOCKER_CMD ps --format "{{.Names}}" 2>/dev/null)
    ALL_CONTAINERS=$($DOCKER_CMD ps -a --format "{{.Names}}" 2>/dev/null)
else
    RUNNING_CONTAINERS=$($DOCKER_CMD ps --format "{{.Names}}" 2>/dev/null)
    ALL_CONTAINERS=$($DOCKER_CMD ps -a --format "{{.Names}}" 2>/dev/null)
fi

if [ -n "$RUNNING_CONTAINERS" ]; then
    echo "   실행 중인 Container:"
    echo "$RUNNING_CONTAINERS" | while read name; do
        echo "     - $name"
    done
else
    echo "   ❌ 실행 중인 Container 없음"
fi
echo ""

if [ -n "$ALL_CONTAINERS" ]; then
    echo "   모든 Container (실행 중이 아닌 것 포함):"
    echo "$ALL_CONTAINERS" | while read name; do
        STATUS=$($DOCKER_CMD ps -a --filter "name=$name" --format "{{.Status}}" 2>/dev/null)
        echo "     - $name ($STATUS)"
    done
else
    echo "   ❌ Container 없음"
fi
echo ""

# 3. access_rhel8.10 Container 확인
echo "3. access_rhel8.10 Container 확인:"
if echo "$ALL_CONTAINERS" | grep -q "access_rhel8.10"; then
    echo "   ✅ access_rhel8.10 Container 존재"
    CONTAINER_STATUS=$($DOCKER_CMD ps -a --filter "name=access_rhel8.10" --format "{{.Status}}" 2>/dev/null)
    echo "   상태: $CONTAINER_STATUS"
    
    if echo "$RUNNING_CONTAINERS" | grep -q "access_rhel8.10"; then
        echo "   ✅ 실행 중"
    else
        echo "   ❌ 실행 중이 아님"
        echo "   시작 명령어: $DOCKER_CMD start access_rhel8.10"
    fi
else
    echo "   ❌ access_rhel8.10 Container 없음"
    echo "   ⚠️  Container 이름이 다를 수 있습니다"
fi
echo ""

# 4. Container 상세 정보
if echo "$ALL_CONTAINERS" | grep -q "access_rhel8.10"; then
    echo "4. Container 상세 정보:"
    $DOCKER_CMD inspect access_rhel8.10 2>/dev/null | grep -E "(State|Status|Image)" | head -5
fi
echo ""

echo "=========================================="
echo "  해결 방법"
echo "=========================================="
echo ""
echo "Container가 실행 중이 아닌 경우:"
echo "  Windows PowerShell에서:"
echo "    docker ps -a"
echo "    docker start access_rhel8.10"
echo ""
echo "Container가 없는 경우:"
echo "  - Container가 삭제되었을 수 있습니다"
echo "  - Docker Compose 파일이나 실행 스크립트 확인 필요"
echo ""
