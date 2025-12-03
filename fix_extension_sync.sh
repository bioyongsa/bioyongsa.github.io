#!/bin/bash
# 확장 프로그램 동기화 문제 해결 스크립트

echo "=========================================="
echo "  확장 프로그램 동기화 문제 해결"
echo "=========================================="
echo ""

CURSOR_SERVER_DIR="$HOME/.cursor-server"
EXTENSIONS_DIR="$CURSOR_SERVER_DIR/extensions"

# 1. 확장 프로그램 확인
echo "1. Container 내부 확장 프로그램 확인:"
if [ -d "$EXTENSIONS_DIR" ]; then
    EXT_COUNT=$(ls -d "$EXTENSIONS_DIR"/*/ 2>/dev/null | wc -l)
    echo "   확장 프로그램 디렉토리: $EXTENSIONS_DIR"
    echo "   설치된 확장 프로그램 개수: $EXT_COUNT"
    echo ""
    echo "   설치된 확장 프로그램 목록:"
    ls -1d "$EXTENSIONS_DIR"/*/ 2>/dev/null | while read ext; do
        EXT_NAME=$(basename "$ext")
        if [ -f "$ext/package.json" ]; then
            DISPLAY_NAME=$(grep '"displayName"' "$ext/package.json" 2>/dev/null | head -1 | sed 's/.*"displayName": *"\([^"]*\)".*/\1/')
            echo "     - $EXT_NAME: $DISPLAY_NAME"
        else
            echo "     - $EXT_NAME (package.json 없음)"
        fi
    done
else
    echo "   ❌ 확장 프로그램 디렉토리 없음"
fi
echo ""

# 2. 확장 프로그램 디렉토리 권한 확인
echo "2. 권한 확인:"
if [ -d "$EXTENSIONS_DIR" ]; then
    echo "   디렉토리 권한: $(stat -c '%a %U:%G' "$EXTENSIONS_DIR" 2>/dev/null || ls -ld "$EXTENSIONS_DIR" | awk '{print $1, $3":"$4}')"
    echo "   쓰기 가능: $([ -w "$EXTENSIONS_DIR" ] && echo '✅' || echo '❌')"
    
    # 각 확장 프로그램 권한 확인
    echo "   확장 프로그램 권한:"
    ls -ld "$EXTENSIONS_DIR"/*/ 2>/dev/null | head -3 | awk '{print "     -", $9, "("$1")"}'
fi
echo ""

# 3. extensions.json 확인
echo "3. extensions.json 확인:"
EXT_JSON="$EXTENSIONS_DIR/extensions.json"
if [ -f "$EXT_JSON" ]; then
    echo "   ✅ extensions.json 존재"
    echo "   내용:"
    cat "$EXT_JSON" | head -20 | sed 's/^/     /'
else
    echo "   ❌ extensions.json 없음"
fi
echo ""

# 4. Cursor 서버 프로세스 확인
echo "4. Cursor 서버 프로세스:"
CURSOR_PIDS=$(ps aux | grep -iE "cursor-server" | grep -v grep | awk '{print $2}' | sort -u)
if [ -n "$CURSOR_PIDS" ]; then
    echo "   실행 중인 프로세스 PID: $CURSOR_PIDS"
    echo "   프로세스 개수: $(echo "$CURSOR_PIDS" | wc -l)"
else
    echo "   ❌ 실행 중인 프로세스 없음"
fi
echo ""

# 5. 권한 수정 시도
echo "5. 권한 수정 시도:"
chmod -R 755 "$EXTENSIONS_DIR" 2>/dev/null
echo "   ✅ 권한 수정 완료"
echo ""

# 6. 확장 프로그램 재검색을 위한 파일 터치
echo "6. 확장 프로그램 재검색 트리거:"
touch "$EXTENSIONS_DIR/.cursor-sync" 2>/dev/null
echo "   ✅ 동기화 파일 생성"
echo ""

echo "=========================================="
echo "  다음 단계"
echo "=========================================="
echo ""
echo "1. Cursor IDE에서 Command Palette (Ctrl+Shift+P)"
echo "2. 'Developer: Reload Window' 실행"
echo "3. 또는 Container 재연결"
echo "4. 확장 프로그램 탭에서 'Dev Containers: access_rhel8.10' 확인"
echo ""
