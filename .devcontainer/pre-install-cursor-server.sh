#!/bin/bash
# Cursor 서버 미리 설치 스크립트 (컨테이너 내부에서 실행)

set -e

CURSOR_SERVER_DIR="/root/.cursor-server"
CURSOR_VERSION="656af3704923280dedba3ccd49cfaf9b9d456e9a"
DOWNLOAD_URL="https://downloads.cursor.com/production/${CURSOR_VERSION}/linux/x64/cursor-reh-linux-x64.tar.gz"

echo "🚀 Cursor 서버 사전 설치 시작..."

# 디렉토리 생성
mkdir -p "$CURSOR_SERVER_DIR/bin"

# 이미 설치되어 있는지 확인
if [ -d "$CURSOR_SERVER_DIR/bin/$CURSOR_VERSION" ]; then
    echo "✅ Cursor 서버가 이미 설치되어 있습니다."
    echo "경로: $CURSOR_SERVER_DIR/bin/$CURSOR_VERSION"
    exit 0
fi

# 다운로드
echo "📥 Cursor 서버 다운로드 중..."
cd "$CURSOR_SERVER_DIR"
curl -L "$DOWNLOAD_URL" -o cursor-server.tar.gz

# 압축 해제
echo "📦 압축 해제 중..."
mkdir -p "bin/$CURSOR_VERSION"
tar -xzf cursor-server.tar.gz -C "bin/$CURSOR_VERSION" --strip-components=1

# 정리
rm cursor-server.tar.gz

# 권한 설정
chmod +x "bin/$CURSOR_VERSION/bin/cursor-server"

echo "✅ Cursor 서버 사전 설치 완료!"
echo "경로: $CURSOR_SERVER_DIR/bin/$CURSOR_VERSION"
