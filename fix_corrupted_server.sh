#!/bin/bash
# 손상된 Cursor 서버 파일 정리 및 재설치

echo "=========================================="
echo "  손상된 Cursor 서버 파일 정리"
echo "=========================================="
echo ""

# 1. 현재 사용자 확인
echo "1. 현재 사용자:"
echo "   사용자: $(whoami)"
echo "   UID: $(id -u)"
echo "   홈 디렉토리: $HOME"
echo ""

# 2. 손상된 Cursor 서버 파일 확인
echo "2. 손상된 Cursor 서버 파일 확인:"

# /tmp의 cursor-server tar.gz 파일 확인
echo "   /tmp의 cursor-server tar.gz 파일:"
ls -lh /tmp/cursor-server-*.tar.gz 2>/dev/null || echo "     없음"

# /root/.cursor-server 확인
if [ -d "/root/.cursor-server" ]; then
    echo "   /root/.cursor-server 존재: ✅"
    echo "   크기: $(du -sh /root/.cursor-server 2>/dev/null | cut -f1)"
else
    echo "   /root/.cursor-server 없음"
fi

# 현재 사용자의 .cursor-server 확인
if [ -d "$HOME/.cursor-server" ]; then
    echo "   $HOME/.cursor-server 존재: ✅"
    echo "   크기: $(du -sh $HOME/.cursor-server 2>/dev/null | cut -f1)"
else
    echo "   $HOME/.cursor-server 없음"
fi
echo ""

# 3. 손상된 파일 삭제
echo "3. 손상된 파일 삭제:"

# /tmp의 cursor-server tar.gz 파일 삭제
echo "   /tmp의 cursor-server tar.gz 파일 삭제 중..."
rm -f /tmp/cursor-server-*.tar.gz 2>/dev/null
echo "   ✅ 삭제 완료"

# /root/.cursor-server 삭제 (root 사용자일 경우에만)
if [ "$(whoami)" = "root" ]; then
    echo "   /root/.cursor-server 삭제 중..."
    rm -rf /root/.cursor-server 2>/dev/null
    echo "   ✅ 삭제 완료"
else
    echo "   ⚠️  root 권한 필요 - sudo로 삭제 필요할 수 있음"
fi

# 현재 사용자의 손상된 서버 파일 삭제
if [ -d "$HOME/.cursor-server/bin" ]; then
    echo "   $HOME/.cursor-server/bin 삭제 중..."
    rm -rf "$HOME/.cursor-server/bin" 2>/dev/null
    echo "   ✅ 삭제 완료"
fi

# 설치 잠금 파일 삭제
rm -f "$HOME/.cursor-server/.installation_lock" 2>/dev/null
rm -f "/root/.cursor-server/.installation_lock" 2>/dev/null
echo "   ✅ 설치 잠금 파일 삭제 완료"
echo ""

# 4. 확장 프로그램은 보존
echo "4. 확장 프로그램 보존:"
if [ -d "$HOME/.cursor-server/extensions" ]; then
    EXT_COUNT=$(ls -d "$HOME/.cursor-server/extensions"/*/ 2>/dev/null | wc -l)
    echo "   확장 프로그램 개수: $EXT_COUNT"
    echo "   ✅ 확장 프로그램 보존됨"
else
    echo "   확장 프로그램 디렉토리 없음"
fi
echo ""

# 5. 권한 확인
echo "5. 권한 확인:"
if [ -d "$HOME/.cursor-server" ]; then
    chmod -R 755 "$HOME/.cursor-server" 2>/dev/null
    echo "   ✅ 권한 수정 완료"
fi
echo ""

echo "=========================================="
echo "  정리 완료"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "1. Cursor IDE에서 Container 재연결"
echo "2. Cursor 서버가 자동으로 재설치됨"
echo "3. 확장 프로그램 탭에서 확인"
echo ""
