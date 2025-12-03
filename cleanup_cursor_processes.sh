#!/bin/bash
# Cursor 서버 중복 프로세스 정리 스크립트

echo "=========================================="
echo "  Cursor 서버 프로세스 정리"
echo "=========================================="
echo ""

# 현재 실행 중인 프로세스 확인
CURSOR_PIDS=$(ps aux | grep -iE "cursor-server" | grep -v grep | awk '{print $2}' | sort -u)

if [ -z "$CURSOR_PIDS" ]; then
    echo "실행 중인 Cursor 서버 프로세스 없음"
    exit 0
fi

echo "발견된 Cursor 서버 프로세스:"
ps aux | grep -iE "cursor-server" | grep -v grep | head -5
echo ""

echo "총 프로세스 개수: $(echo "$CURSOR_PIDS" | wc -l)"
echo ""

echo "⚠️  주의: 이 프로세스들을 종료하면 Cursor IDE에서 Container 연결이 끊어질 수 있습니다."
echo ""
echo "다음 단계:"
echo "1. Cursor IDE에서 Container 연결을 먼저 끊으세요"
echo "2. 그 다음 이 스크립트를 실행하여 프로세스를 정리하세요"
echo "3. Cursor IDE에서 Container에 다시 연결하세요"
echo ""
echo "프로세스 종료 명령어 (수동 실행):"
echo "kill $CURSOR_PIDS"
echo ""
echo "또는 모든 Cursor 관련 프로세스 종료:"
echo "pkill -f cursor-server"
