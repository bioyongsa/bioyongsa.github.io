#!/bin/bash
# Cursor Remote Container 진단 스크립트

echo "=== Cursor Remote Container 진단 ==="
echo ""

# 1. 사용자 정보
echo "1. 사용자 및 환경 정보:"
echo "   사용자: $(whoami)"
echo "   홈 디렉토리: $HOME"
echo "   현재 디렉토리: $(pwd)"
echo ""

# 2. Cursor 서버 프로세스 확인
echo "2. Cursor 서버 프로세스 확인:"
CURSOR_PROCESSES=$(ps aux | grep -i cursor | grep -v grep)
if [ -n "$CURSOR_PROCESSES" ]; then
    echo "   ✅ Cursor 프로세스 발견:"
    echo "$CURSOR_PROCESSES" | while read line; do
        echo "   $line"
    done
else
    echo "   ❌ Cursor 프로세스 없음"
fi
echo ""

# 3. Cursor 서버 디렉토리 확인
echo "3. Cursor 서버 디렉토리 확인:"
CURSOR_SERVER_DIR="$HOME/.cursor-server"
if [ -d "$CURSOR_SERVER_DIR" ]; then
    echo "   ✅ Cursor 서버 디렉토리 존재: $CURSOR_SERVER_DIR"
    echo "   크기: $(du -sh "$CURSOR_SERVER_DIR" 2>/dev/null | cut -f1)"
    echo "   권한: $(stat -c '%a %U:%G' "$CURSOR_SERVER_DIR" 2>/dev/null || ls -ld "$CURSOR_SERVER_DIR" | awk '{print $1, $3":"$4}')"
    
    # 확장 프로그램 디렉토리
    if [ -d "$CURSOR_SERVER_DIR/extensions" ]; then
        EXT_COUNT=$(ls -1 "$CURSOR_SERVER_DIR/extensions" 2>/dev/null | wc -l)
        echo "   확장 프로그램 개수: $EXT_COUNT"
        echo "   확장 프로그램 목록:"
        ls -1 "$CURSOR_SERVER_DIR/extensions" 2>/dev/null | head -5 | sed 's/^/     - /'
    else
        echo "   ⚠️  확장 프로그램 디렉토리 없음"
    fi
    
    # 로그 디렉토리
    if [ -d "$CURSOR_SERVER_DIR/logs" ]; then
        echo "   로그 파일:"
        ls -lh "$CURSOR_SERVER_DIR/logs" 2>/dev/null | tail -3 | awk '{print "     -", $9, "("$5")"}'
    fi
else
    echo "   ❌ Cursor 서버 디렉토리 없음"
fi
echo ""

# 4. 네트워크 포트 확인
echo "4. 네트워크 포트 확인:"
if command -v ss >/dev/null 2>&1; then
    LISTENING_PORTS=$(ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u)
    echo "   열린 포트:"
    echo "$LISTENING_PORTS" | head -10 | sed 's/^/     - /'
elif command -v netstat >/dev/null 2>&1; then
    LISTENING_PORTS=$(netstat -tuln 2>/dev/null | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -u)
    echo "   열린 포트:"
    echo "$LISTENING_PORTS" | head -10 | sed 's/^/     - /'
else
    echo "   ⚠️  포트 확인 도구 없음"
fi
echo ""

# 5. 디스크 공간 확인
echo "5. 디스크 공간 확인:"
df -h "$HOME" | tail -1 | awk '{print "   사용 가능: " $4 " / " $2 " (사용률: " $5 ")"}'
echo ""

# 6. 권한 확인
echo "6. 권한 확인:"
if [ -w "$HOME" ]; then
    echo "   ✅ 홈 디렉토리 쓰기 가능"
else
    echo "   ❌ 홈 디렉토리 쓰기 불가"
fi

if [ -d "$CURSOR_SERVER_DIR" ] && [ -w "$CURSOR_SERVER_DIR" ]; then
    echo "   ✅ Cursor 서버 디렉토리 쓰기 가능"
else
    echo "   ⚠️  Cursor 서버 디렉토리 쓰기 불가 또는 없음"
fi
echo ""

# 7. 최근 로그 확인
echo "7. 최근 Cursor 로그 (마지막 20줄):"
if [ -d "$CURSOR_SERVER_DIR/logs" ]; then
    LATEST_LOG=$(ls -t "$CURSOR_SERVER_DIR/logs"/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ] && [ -f "$LATEST_LOG" ]; then
        echo "   로그 파일: $LATEST_LOG"
        tail -20 "$LATEST_LOG" | sed 's/^/   /'
    else
        echo "   로그 파일 없음"
    fi
else
    echo "   로그 디렉토리 없음"
fi
echo ""

echo "=== 진단 완료 ==="
echo ""
echo "💡 다음 단계:"
echo "   1. Cursor IDE에서 'Remote-Containers: Reopen Container' 실행"
echo "   2. Cursor IDE에서 'Developer: Reload Window' 실행"
echo "   3. 로그 파일 확인하여 오류 메시지 확인"
