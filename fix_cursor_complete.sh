#!/bin/bash
# Cursor Remote Container 완전 수정 스크립트

set -e

echo "=========================================="
echo "  Cursor Remote Container 완전 수정"
echo "=========================================="
echo ""

CURSOR_SERVER_DIR="$HOME/.cursor-server"
EXTENSIONS_DIR="$CURSOR_SERVER_DIR/extensions"
LOGS_DIR="$CURSOR_SERVER_DIR/logs"

# 1. 기존 Cursor 서버 프로세스 종료
echo "1. 기존 Cursor 서버 프로세스 종료:"
CURSOR_PIDS=$(ps aux | grep -iE "cursor-server|code-server" | grep -v grep | awk '{print $2}')
if [ -n "$CURSOR_PIDS" ]; then
    echo "   발견된 프로세스: $CURSOR_PIDS"
    echo "   ⚠️  Cursor IDE에서 Container 연결을 끊은 후 다시 연결하세요"
    echo "   또는 수동으로 종료: kill $CURSOR_PIDS"
else
    echo "   ✅ 실행 중인 프로세스 없음"
fi
echo ""

# 2. 디렉토리 구조 생성
echo "2. 디렉토리 구조 생성:"
mkdir -p "$EXTENSIONS_DIR"
mkdir -p "$LOGS_DIR"
echo "   ✅ 디렉토리 생성 완료"
echo ""

# 3. 권한 설정
echo "3. 권한 설정:"
chmod 755 "$CURSOR_SERVER_DIR" 2>/dev/null || true
chmod 755 "$EXTENSIONS_DIR" 2>/dev/null || true
chmod 755 "$LOGS_DIR" 2>/dev/null || true

# 소유권 변경 시도 (가능한 경우)
if command -v chown >/dev/null 2>&1; then
    chown -R $(whoami):$(whoami) "$CURSOR_SERVER_DIR" 2>/dev/null || echo "   ⚠️  chown 실패 (권한 부족 - 정상일 수 있음)"
fi

echo "   ✅ 권한 설정 완료"
echo ""

# 4. 쓰기 테스트
echo "4. 쓰기 테스트:"
TEST_FILE="$EXTENSIONS_DIR/.write_test"
if touch "$TEST_FILE" 2>/dev/null; then
    echo "   ✅ 쓰기 가능"
    rm -f "$TEST_FILE"
else
    echo "   ❌ 쓰기 불가 - 권한 문제"
    echo "   수동으로 권한 설정 필요"
fi
echo ""

# 5. 이전 로그 백업
echo "5. 이전 로그 백업:"
if [ -d "$LOGS_DIR" ] && [ "$(ls -A $LOGS_DIR 2>/dev/null)" ]; then
    BACKUP_DIR="$LOGS_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    mv "$LOGS_DIR"/*.log "$BACKUP_DIR" 2>/dev/null || true
    echo "   ✅ 로그 백업 완료: $BACKUP_DIR"
else
    echo "   백업할 로그 없음"
fi
echo ""

# 6. 환경 변수 설정
echo "6. 환경 변수 확인:"
echo "   HOME=$HOME"
echo "   USER=$USER"
echo "   CURSOR_SERVER_DIR=$CURSOR_SERVER_DIR"
echo ""

# 7. 최종 상태 확인
echo "7. 최종 상태:"
echo "   Cursor 서버 디렉토리: $CURSOR_SERVER_DIR"
echo "   존재: $([ -d "$CURSOR_SERVER_DIR" ] && echo '✅' || echo '❌')"
echo "   확장 프로그램 디렉토리: $EXTENSIONS_DIR"
echo "   존재: $([ -d "$EXTENSIONS_DIR" ] && echo '✅' || echo '❌')"
echo "   쓰기 가능: $([ -w "$EXTENSIONS_DIR" ] && echo '✅' || echo '❌')"
echo ""

echo "=========================================="
echo "  수정 완료"
echo "=========================================="
echo ""
echo "📋 다음 단계:"
echo ""
echo "1. Cursor IDE에서:"
echo "   - Command Palette (Ctrl+Shift+P)"
echo "   - 'Remote-Containers: Reopen Container' 실행"
echo "   - 또는 'Remote-Containers: Rebuild Container' 실행"
echo ""
echo "2. Container 재연결 후:"
echo "   - 확장 프로그램 설치 재시도"
echo "   - Chat 기능 테스트"
echo ""
echo "3. 여전히 문제가 있으면:"
echo "   - Cursor IDE 완전 종료 후 재시작"
echo "   - Windows에서 Docker container 재시작"
echo "   - 로그 파일 확인: ~/.cursor-server/logs/"
