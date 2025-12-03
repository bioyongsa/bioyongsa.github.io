#!/bin/bash
# $DB06A22189314A1494B057B1D18D2DEB 디렉토리 분석 스크립트

MYSTERY_DIR="$HOME/\$DB06A22189314A1494B057B1D18D2DEB"

echo "=== 디렉토리 분석: \$DB06A22189314A1494B057B1D18D2DEB ==="
echo ""

if [ ! -d "$MYSTERY_DIR" ]; then
    echo "❌ 디렉토리가 존재하지 않습니다."
    exit 1
fi

echo "1. 기본 정보:"
echo "   경로: $MYSTERY_DIR"
echo "   크기: $(du -sh "$MYSTERY_DIR" 2>/dev/null | cut -f1)"
echo "   권한: $(stat -c '%a %U:%G' "$MYSTERY_DIR" 2>/dev/null || ls -ld "$MYSTERY_DIR" | awk '{print $1, $3":"$4}')"
echo ""

echo "2. 디렉토리 내용 (최상위 레벨):"
ls -lah "$MYSTERY_DIR" | head -20
echo ""

echo "3. 파일 개수:"
echo "   총 파일: $(find "$MYSTERY_DIR" -type f 2>/dev/null | wc -l)"
echo "   총 디렉토리: $(find "$MYSTERY_DIR" -type d 2>/dev/null | wc -l)"
echo ""

echo "4. 주요 파일/디렉토리 (최대 10개):"
find "$MYSTERY_DIR" -maxdepth 2 -type f -o -type d 2>/dev/null | head -10
echo ""

echo "5. Docker 관련 파일 확인:"
if find "$MYSTERY_DIR" -name "*docker*" -o -name "*container*" 2>/dev/null | grep -q .; then
    echo "   ✅ Docker 관련 파일 발견:"
    find "$MYSTERY_DIR" -iname "*docker*" -o -iname "*container*" 2>/dev/null | head -5
else
    echo "   ❌ Docker 관련 파일 없음"
fi
echo ""

echo "6. Windows 관련 파일 확인:"
if find "$MYSTERY_DIR" -name "*Windows*" -o -name "*WSL*" 2>/dev/null | grep -q .; then
    echo "   ✅ Windows 관련 파일 발견:"
    find "$MYSTERY_DIR" -iname "*windows*" -o -iname "*wsl*" 2>/dev/null | head -5
else
    echo "   ❌ Windows 관련 파일 없음"
fi
echo ""

echo "7. 숨김 파일 확인:"
find "$MYSTERY_DIR" -maxdepth 1 -name ".*" 2>/dev/null | head -5
echo ""

echo "=== 분석 완료 ==="
echo ""
echo "💡 참고:"
echo "   - 이 디렉토리 이름은 Windows GUID 형식입니다"
echo "   - Docker container는 아닙니다 (Docker container ID는 다른 형식)"
echo "   - Windows 임시 디렉토리나 특수 시스템 디렉토리일 가능성이 높습니다"
