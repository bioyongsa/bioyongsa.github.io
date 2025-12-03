#!/bin/bash
# Container 내부에서 실행할 진단 스크립트 생성 명령어

cat > ~/deep_diagnose.sh << 'EOFSCRIPT'
#!/bin/bash
# Cursor Remote Container 심화 진단 스크립트

echo "=========================================="
echo "  Cursor Remote Container 심화 진단"
echo "=========================================="
echo ""

# 1. 기본 환경 확인
echo "1. 기본 환경:"
echo "   사용자: $(whoami)"
echo "   UID: $(id -u)"
echo "   GID: $(id -g)"
echo "   홈 디렉토리: $HOME"
echo "   Shell: $SHELL"
echo ""

# 2. Cursor 서버 디렉토리 상세 확인
echo "2. Cursor 서버 디렉토리 상세:"
CURSOR_SERVER_DIR="$HOME/.cursor-server"
if [ -d "$CURSOR_SERVER_DIR" ]; then
    echo "   경로: $CURSOR_SERVER_DIR"
    echo "   존재: ✅"
    echo "   크기: $(du -sh "$CURSOR_SERVER_DIR" 2>/dev/null | cut -f1)"
    echo "   권한: $(stat -c '%a %U:%G' "$CURSOR_SERVER_DIR" 2>/dev/null || ls -ld "$CURSOR_SERVER_DIR" | awk '{print $1, $3":"$4}')"
    echo "   쓰기 가능: $([ -w "$CURSOR_SERVER_DIR" ] && echo '✅' || echo '❌')"
    
    # 하위 디렉토리 확인
    echo "   하위 디렉토리:"
    ls -ld "$CURSOR_SERVER_DIR"/* 2>/dev/null | awk '{print "     -", $9, "("$1")"}' || echo "     없음"
else
    echo "   존재: ❌"
    echo "   생성 시도 중..."
    mkdir -p "$CURSOR_SERVER_DIR"
    chmod 755 "$CURSOR_SERVER_DIR"
fi
echo ""

# 3. 확장 프로그램 디렉토리
echo "3. 확장 프로그램 디렉토리:"
EXTENSIONS_DIR="$CURSOR_SERVER_DIR/extensions"
if [ -d "$EXTENSIONS_DIR" ]; then
    EXT_COUNT=$(find "$EXTENSIONS_DIR" -maxdepth 1 -type d 2>/dev/null | wc -l)
    echo "   경로: $EXTENSIONS_DIR"
    echo "   존재: ✅"
    echo "   확장 프로그램 개수: $((EXT_COUNT - 1))"
    echo "   권한: $(stat -c '%a %U:%G' "$EXTENSIONS_DIR" 2>/dev/null || ls -ld "$EXTENSIONS_DIR" | awk '{print $1, $3":"$4}')"
    echo "   쓰기 가능: $([ -w "$EXTENSIONS_DIR" ] && echo '✅' || echo '❌')"
    
    if [ $EXT_COUNT -gt 1 ]; then
        echo "   설치된 확장 프로그램:"
        ls -1d "$EXTENSIONS_DIR"/* 2>/dev/null | head -5 | xargs -I {} basename {} | sed 's/^/     - /'
    fi
else
    echo "   존재: ❌"
    echo "   생성 중..."
    mkdir -p "$EXTENSIONS_DIR"
    chmod 755 "$EXTENSIONS_DIR"
fi
echo ""

# 4. Cursor 서버 프로세스
echo "4. Cursor 서버 프로세스:"
CURSOR_PROCS=$(ps aux | grep -iE "cursor|code-server" | grep -v grep)
if [ -n "$CURSOR_PROCS" ]; then
    echo "   발견된 프로세스:"
    echo "$CURSOR_PROCS" | while read line; do
        PID=$(echo "$line" | awk '{print $2}')
        CMD=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        echo "     PID $PID: $CMD"
    done
else
    echo "   ❌ 실행 중인 Cursor 서버 프로세스 없음"
    echo "   ⚠️  Cursor IDE에서 Container에 연결되어 있는지 확인하세요"
fi
echo ""

# 5. 네트워크 포트
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
    echo "   ⚠️  ss 명령어 없음"
fi
echo ""

# 6. 로그 파일 확인
echo "6. 로그 파일:"
LOG_DIR="$CURSOR_SERVER_DIR/logs"
if [ -d "$LOG_DIR" ]; then
    LOG_FILES=$(find "$LOG_DIR" -name "*.log" -type f 2>/dev/null)
    if [ -n "$LOG_FILES" ]; then
        echo "   로그 파일 발견:"
        echo "$LOG_FILES" | while read log; do
            SIZE=$(du -h "$log" 2>/dev/null | cut -f1)
            MTIME=$(stat -c '%y' "$log" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            echo "     - $(basename "$log") ($SIZE, 수정: $MTIME)"
        done
        
        # 최신 로그의 마지막 오류 확인
        LATEST_LOG=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
        if [ -n "$LATEST_LOG" ] && [ -f "$LATEST_LOG" ]; then
            echo ""
            echo "   최신 로그의 마지막 오류 (마지막 30줄):"
            tail -30 "$LATEST_LOG" 2>/dev/null | grep -iE "error|fail|warn|exception" | tail -10 | sed 's/^/     /' || echo "     오류 없음"
        fi
    else
        echo "   로그 파일 없음"
    fi
else
    echo "   로그 디렉토리 없음"
fi
echo ""

# 7. 디스크 공간
echo "7. 디스크 공간:"
df -h "$HOME" | tail -1 | awk '{
    print "   총 용량: " $2
    print "   사용 중: " $3 " (" $5 ")"
    print "   사용 가능: " $4
}'
echo ""

# 8. 마운트 포인트 확인
echo "8. 마운트 포인트:"
mount | grep -E "(cursor|/mnt)" | head -5 | while read line; do
    echo "   $line"
done || echo "   관련 마운트 없음"
echo ""

# 9. 환경 변수 확인
echo "9. 관련 환경 변수:"
env | grep -iE "cursor|remote|container" | sed 's/^/   /' || echo "   관련 환경 변수 없음"
echo ""

# 10. 파일 시스템 권한 테스트
echo "10. 파일 시스템 권한 테스트:"
TEST_FILE="$EXTENSIONS_DIR/.test_write"
if touch "$TEST_FILE" 2>/dev/null; then
    echo "   ✅ 쓰기 가능"
    rm -f "$TEST_FILE"
else
    echo "   ❌ 쓰기 불가"
    echo "   권한 수정 시도 중..."
    chmod 755 "$EXTENSIONS_DIR" 2>/dev/null
    chown -R $(whoami):$(whoami) "$EXTENSIONS_DIR" 2>/dev/null || echo "   chown 실패 (권한 부족)"
fi
echo ""

echo "=========================================="
echo "  진단 완료"
echo "=========================================="
EOFSCRIPT

chmod +x ~/deep_diagnose.sh
echo "스크립트 생성 완료: ~/deep_diagnose.sh"
echo "실행: ~/deep_diagnose.sh"
