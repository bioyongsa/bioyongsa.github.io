#!/bin/bash
# 확장 프로그램 상세 확인

echo "=========================================="
echo "  확장 프로그램 상세 확인"
echo "=========================================="
echo ""

EXTENSIONS_DIR="$HOME/.cursor-server/extensions"

if [ -d "$EXTENSIONS_DIR" ]; then
    echo "확장 프로그램 목록:"
    echo ""
    
    ls -1d "$EXTENSIONS_DIR"/*/ 2>/dev/null | while read ext; do
        EXT_NAME=$(basename "$ext")
        echo "확장 프로그램: $EXT_NAME"
        
        if [ -f "$ext/package.json" ]; then
            DISPLAY_NAME=$(grep '"displayName"' "$ext/package.json" 2>/dev/null | head -1 | sed 's/.*"displayName": *"\([^"]*\)".*/\1/')
            VERSION=$(grep '"version"' "$ext/package.json" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
            echo "  이름: $DISPLAY_NAME"
            echo "  버전: $VERSION"
        fi
        
        echo "  경로: $ext"
        echo "  크기: $(du -sh "$ext" 2>/dev/null | cut -f1)"
        echo ""
    done
else
    echo "확장 프로그램 디렉토리 없음"
fi

echo "=========================================="
echo "  Cursor 서버 연결 확인"
echo "=========================================="
echo ""

# Cursor 서버 토큰 파일 확인
TOKEN_FILE=$(find "$HOME/.cursor-server" -name "*.token" 2>/dev/null | head -1)
if [ -n "$TOKEN_FILE" ]; then
    echo "토큰 파일: $TOKEN_FILE"
    echo "존재: ✅"
else
    echo "토큰 파일 없음"
fi

echo ""
echo "Cursor 서버 프로세스:"
ps aux | grep -iE "cursor-server" | grep -v grep | head -3
