#!/bin/bash

# RHEL 8.10 Dev Container 시작 스크립트

set -e

CONTAINER_NAME="rhel8-dev-container"
IMAGE_NAME="access_rhel8.10:latest"
WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 RHEL 8.10 Dev Container 시작 중..."

# 기존 컨테이너 확인
if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "⚠️  기존 컨테이너 발견. 제거 중..."
    docker rm -f $CONTAINER_NAME
fi

# 이미지 확인
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "❌ 이미지 '$IMAGE_NAME'를 찾을 수 없습니다."
    echo "다음 명령으로 이미지를 빌드하거나 pull 하세요:"
    echo "  docker pull $IMAGE_NAME"
    exit 1
fi

# 컨테이너 시작
echo "📦 컨테이너 생성 및 시작..."
docker run -d \
    --name $CONTAINER_NAME \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    -v "$WORKSPACE_DIR:/workspace:cached" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /workspace \
    -e HOME=/root \
    $IMAGE_NAME \
    tail -f /dev/null

echo "✅ 컨테이너가 성공적으로 시작되었습니다!"
echo ""
echo "다음 단계:"
echo "1. Cursor에서 F1 키를 누르세요"
echo "2. 'Dev Containers: Attach to Running Container' 검색"
echo "3. '$CONTAINER_NAME' 선택"
echo ""
echo "또는 터미널에서 직접 접속:"
echo "  docker exec -it $CONTAINER_NAME /bin/bash"
echo ""
echo "컨테이너 중지:"
echo "  docker stop $CONTAINER_NAME"
echo ""
echo "컨테이너 제거:"
echo "  docker rm -f $CONTAINER_NAME"
