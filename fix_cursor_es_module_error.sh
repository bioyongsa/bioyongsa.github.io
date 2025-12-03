#!/bin/bash
# Cursor ES Module 오류 해결 스크립트

CURSOR_SERVER_PATH="/mnt/d/.cursor-server/bin/ab326d0767c02fb9847b342c43ea58275c4b1680"

echo "=== Cursor ES Module 오류 해결 ==="
echo ""

# 1. Cursor 서버 경로 확인
if [ ! -d "$CURSOR_SERVER_PATH" ]; then
    echo "❌ Cursor 서버 경로를 찾을 수 없습니다: $CURSOR_SERVER_PATH"
    echo ""
    echo "사용 가능한 서버 버전:"
    ls -la /mnt/d/.cursor-server/bin/ 2>/dev/null | head -10
    exit 1
fi

echo "✅ Cursor 서버 경로 발견: $CURSOR_SERVER_PATH"
echo ""

# 2. package.json 확인 및 수정
PACKAGE_JSON="$CURSOR_SERVER_PATH/package.json"
if [ -f "$PACKAGE_JSON" ]; then
    echo "2. package.json 발견 - 수정 시도..."
    
    # 백업 생성
    cp "$PACKAGE_JSON" "$PACKAGE_JSON.bak"
    echo "   ✅ 백업 생성: $PACKAGE_JSON.bak"
    
    # jq가 있는 경우 사용
    if command -v jq >/dev/null 2>&1; then
        echo "   jq를 사용하여 수정 중..."
        jq '. + {"type": "module"}' "$PACKAGE_JSON.bak" > "$PACKAGE_JSON"
        echo "   ✅ package.json에 'type': 'module' 추가됨"
    else
        # jq가 없는 경우 sed 사용
        echo "   sed를 사용하여 수정 중..."
        if ! grep -q '"type"' "$PACKAGE_JSON"; then
            # 첫 번째 { 뒤에 "type": "module", 추가
            sed -i '1s/{/{\n  "type": "module",/' "$PACKAGE_JSON"
            echo "   ✅ package.json에 'type': 'module' 추가됨"
        else
            echo "   ⚠️  이미 'type' 필드가 있습니다"
        fi
    fi
else
    echo "⚠️  package.json을 찾을 수 없습니다"
    echo "   새로 생성 시도..."
    
    # package.json 생성
    cat > "$PACKAGE_JSON" << EOF
{
  "type": "module",
  "name": "cursor-server",
  "version": "1.0.0"
}
EOF
    echo "   ✅ package.json 생성됨"
fi

echo ""

# 3. Node.js 버전 확인
echo "3. Node.js 버전 확인:"
NODE_VERSION=$(node --version)
echo "   Node.js 버전: $NODE_VERSION"

# Node.js 14 이상인지 확인
NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v\([0-9]*\).*/\1/')
if [ "$NODE_MAJOR" -ge 14 ]; then
    echo "   ✅ ES Module 지원됨"
else
    echo "   ⚠️  Node.js 14 이상 권장"
fi
echo ""

# 4. 환경 변수 설정 스크립트 생성
ENV_SCRIPT="$HOME/.cursor_env.sh"
cat > "$ENV_SCRIPT" << 'EOF'
#!/bin/bash
# Cursor 실행을 위한 환경 변수 설정
export NODE_OPTIONS="--experimental-modules --no-warnings"
export NODE_ENV=production
EOF

chmod +x "$ENV_SCRIPT"
echo "4. 환경 변수 스크립트 생성: $ENV_SCRIPT"
echo ""

# 5. Cursor 래퍼 스크립트 생성
CURSOR_WRAPPER="$HOME/.local/bin/cursor"
mkdir -p "$(dirname "$CURSOR_WRAPPER")"

cat > "$CURSOR_WRAPPER" << 'EOF'
#!/bin/bash
# Cursor 실행 래퍼 스크립트
source ~/.cursor_env.sh 2>/dev/null
exec /mnt/d/.cursor-server/bin/ab326d0767c02fb9847b342c43ea58275c4b1680/out/server-cli.js "$@"
EOF

chmod +x "$CURSOR_WRAPPER"
echo "5. Cursor 래퍼 스크립트 생성: $CURSOR_WRAPPER"
echo ""

echo "=== 완료 ==="
echo ""
echo "사용 방법:"
echo "1. 환경 변수 로드:"
echo "   source ~/.cursor_env.sh"
echo ""
echo "2. Cursor 실행:"
echo "   ~/.local/bin/cursor"
echo ""
echo "또는:"
echo "   export NODE_OPTIONS=\"--experimental-modules --no-warnings\""
echo "   cursor"
echo ""
echo "⚠️  주의: Docker container 내에서 cursor를 직접 실행하는 것은 권장되지 않습니다."
echo "   Windows 호스트에서 Cursor IDE를 실행하고 Remote Development로 연결하세요."
