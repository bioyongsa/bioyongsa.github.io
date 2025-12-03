#!/bin/bash
# Cursor 문제 해결 스크립트

echo "=========================================="
echo "  Cursor 문제 해결"
echo "=========================================="
echo ""

CURSOR_SERVER_DIR="$HOME/.cursor-server"
LOGS_DIR="$CURSOR_SERVER_DIR/logs"

# 1. 로그 디렉토리 생성
echo "1. 로그 디렉토리 생성:"
mkdir -p "$LOGS_DIR"
chmod 755 "$LOGS_DIR"
echo "   ✅ 로그 디렉토리 생성: $LOGS_DIR"
echo ""

# 2. Windows 마운트 경로 확인
echo "2. Windows 마운트 경로 확인:"
WINDOWS_CURSOR_PATH="/mnt/d/.cursor-server"
if [ -d "$WINDOWS_CURSOR_PATH" ]; then
    echo "   Windows 경로 존재: $WINDOWS_CURSOR_PATH"
    echo "   크기: $(du -sh "$WINDOWS_CURSOR_PATH" 2>/dev/null | cut -f1)"
    echo "   권한: $(ls -ld "$WINDOWS_CURSOR_PATH" 2>/dev/null | awk '{print $1, $3":"$4}')"
else
    echo "   Windows 경로 없음"
fi
echo ""

# 3. 확장 프로그램 상세 확인
echo "3. 확장 프로그램 상세:"
EXTENSIONS_DIR="$CURSOR_SERVER_DIR/extensions"
if [ -d "$EXTENSIONS_DIR" ]; then
    echo "   설치된 확장 프로그램:"
    ls -1d "$EXTENSIONS_DIR"/*/ 2>/dev/null | while read ext; do
        EXT_NAME=$(basename "$ext")
        if [ -f "$ext/package.json" ]; then
            EXT_DISPLAY=$(grep '"displayName"' "$ext/package.json" 2>/dev/null | head -1 | sed 's/.*"displayName": *"\([^"]*\)".*/\1/' || echo "$EXT_NAME")
            echo "     - $EXT_NAME ($EXT_DISPLAY)"
        else
            echo "     - $EXT_NAME (package.json 없음)"
        fi
    done
fi
echo ""

# 4. Cursor 서버 프로세스 확인
echo "4. Cursor 서버 프로세스:"
CURSOR_PIDS=$(ps aux | grep -iE "cursor-server" | grep -v grep | awk '{print $2}' | sort -u)
if [ -n "$CURSOR_PIDS" ]; then
    echo "   실행 중인 프로세스 PID: $CURSOR_PIDS"
    echo "   ⚠️  이 프로세스들을 종료하려면:"
    echo "   kill $CURSOR_PIDS"
    echo "   (Cursor IDE에서 Container 재연결 시 자동으로 재시작됨)"
else
    echo "   실행 중인 프로세스 없음"
fi
echo ""

# 5. 네트워크 포트 확인
echo "5. 네트워크 포트:"
if command -v ss >/dev/null 2>&1; then
    PORTS=$(ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u | grep -E "^[0-9]+$")
    if [ -n "$PORTS" ]; then
        echo "   열린 포트:"
        echo "$PORTS" | head -10 | while read port; do
            echo "     - $port"
        done
    else
        echo "   열린 포트 없음"
    fi
else
    echo "   ss 명령어 없음"
fi
echo ""

# 6. 권한 테스트
echo "6. 권한 테스트:"
TEST_FILE="$EXTENSIONS_DIR/.test_write"
if touch "$TEST_FILE" 2>/dev/null; then
    echo "   ✅ 확장 프로그램 디렉토리 쓰기 가능"
    rm -f "$TEST_FILE"
else
    echo "   ❌ 확장 프로그램 디렉토리 쓰기 불가"
    echo "   권한 수정 시도 중..."
    chmod 755 "$EXTENSIONS_DIR" 2>/dev/null
fi
echo ""

echo "=========================================="
echo "  해결 방법"
echo "=========================================="
echo ""
echo "1. Cursor IDE에서 Container 재연결:"
echo "   Command Palette (Ctrl+Shift+P)"
echo "   -> 'Remote-Containers: Reopen Container'"
echo ""
echo "2. 확장 프로그램이 설치되어 있지만 인식되지 않는 경우:"
echo "   - Cursor IDE 완전 재시작"
echo "   - Container 재연결"
echo ""
echo "3. Chat이 작동하지 않는 경우:"
echo "   - Cursor 서버 프로세스 확인 (위에서 확인됨)"
echo "   - 네트워크 연결 확인"
echo "   - Cursor IDE에서 'Developer: Reload Window' 실행"
echo ""
