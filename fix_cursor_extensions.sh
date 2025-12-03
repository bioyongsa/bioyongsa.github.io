#!/bin/bash
# Cursor 확장 프로그램 설치 문제 해결 스크립트

echo "=== Cursor 확장 프로그램 설치 문제 해결 ==="
echo ""

CURSOR_SERVER_DIR="$HOME/.cursor-server"
EXTENSIONS_DIR="$CURSOR_SERVER_DIR/extensions"

# 1. 디렉토리 생성 및 권한 설정
echo "1. 디렉토리 생성 및 권한 설정:"
mkdir -p "$EXTENSIONS_DIR"
chmod 755 "$EXTENSIONS_DIR"
echo "   ✅ 확장 프로그램 디렉토리: $EXTENSIONS_DIR"
echo ""

# 2. 권한 확인
echo "2. 권한 확인:"
if [ -w "$EXTENSIONS_DIR" ]; then
    echo "   ✅ 쓰기 권한 있음"
else
    echo "   ❌ 쓰기 권한 없음 - 수정 필요"
    chmod 755 "$EXTENSIONS_DIR"
fi
echo ""

# 3. Cursor 서버 프로세스 재시작
echo "3. Cursor 서버 프로세스 확인:"
CURSOR_PIDS=$(ps aux | grep -i cursor-server | grep -v grep | awk '{print $2}')
if [ -n "$CURSOR_PIDS" ]; then
    echo "   발견된 Cursor 서버 프로세스: $CURSOR_PIDS"
    echo "   ⚠️  Cursor IDE에서 Container를 재연결하면 자동으로 재시작됩니다"
else
    echo "   Cursor 서버 프로세스 없음 (정상 - IDE에서 연결 시 시작됨)"
fi
echo ""

# 4. 로그 디렉토리 확인
echo "4. 로그 디렉토리 확인:"
mkdir -p "$CURSOR_SERVER_DIR/logs"
chmod 755 "$CURSOR_SERVER_DIR/logs"
echo "   ✅ 로그 디렉토리 준비됨"
echo ""

# 5. 환경 변수 확인
echo "5. 환경 변수 확인:"
echo "   HOME: $HOME"
echo "   USER: $USER"
echo ""

echo "=== 완료 ==="
echo ""
echo "다음 단계:"
echo "1. Cursor IDE에서 Command Palette (Ctrl+Shift+P) 열기"
echo "2. 'Remote-Containers: Reopen Container' 실행"
echo "3. 또는 'Developer: Reload Window' 실행"
echo "4. 확장 프로그램 설치 재시도"
