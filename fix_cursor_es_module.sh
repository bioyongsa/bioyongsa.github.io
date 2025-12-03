#!/bin/bash
# Cursor ES Module 오류 임시 해결 스크립트
# 주의: 이것은 임시 해결책이며, 권장 방법은 호스트에서 Cursor를 실행하는 것입니다.

echo "=== Cursor ES Module 오류 임시 해결 ==="
echo ""

# 1. Node.js 버전 확인
echo "1. Node.js 버전 확인:"
node --version
echo ""

# 2. Cursor 서버 경로 확인
CURSOR_SERVER_PATH="/mnt/d/.cursor-server/bin"
if [ -d "$CURSOR_SERVER_PATH" ]; then
    echo "2. Cursor 서버 경로 확인:"
    ls -la "$CURSOR_SERVER_PATH" | head -5
    echo ""
    
    # 최신 서버 디렉토리 찾기
    LATEST_SERVER=$(ls -td "$CURSOR_SERVER_PATH"/*/ 2>/dev/null | head -1)
    if [ -n "$LATEST_SERVER" ]; then
        echo "3. 최신 서버 디렉토리: $LATEST_SERVER"
        
        # package.json 확인
        if [ -f "$LATEST_SERVER/package.json" ]; then
            echo "4. package.json 발견 - 수정 시도..."
            # 백업
            cp "$LATEST_SERVER/package.json" "$LATEST_SERVER/package.json.bak"
            
            # "type": "module" 추가 (jq가 있는 경우)
            if command -v jq >/dev/null 2>&1; then
                jq '. + {"type": "module"}' "$LATEST_SERVER/package.json.bak" > "$LATEST_SERVER/package.json"
                echo "   ✅ package.json에 'type': 'module' 추가됨"
            else
                echo "   ⚠️  jq가 없어서 수동 수정 필요"
                echo "   package.json에 \"type\": \"module\" 추가하세요"
            fi
        else
            echo "4. package.json 없음"
        fi
    fi
else
    echo "2. Cursor 서버 경로를 찾을 수 없습니다: $CURSOR_SERVER_PATH"
fi

echo ""
echo "=== 주의사항 ==="
echo "이것은 임시 해결책입니다."
echo "권장 방법: Windows 호스트에서 Cursor IDE를 실행하세요."
echo ""
echo "환경 변수 설정 (임시):"
echo "export NODE_OPTIONS=\"--experimental-modules\""
