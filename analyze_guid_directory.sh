#!/bin/bash
# GUID 디렉토리 상세 분석

MYSTERY_DIR="$HOME/\$DB06A22189314A1494B057B1D18D2DEB"

echo "=== GUID 디렉토리 상세 분석 ==="
echo ""

# 첫 번째 하위 디렉토리 확인
FIRST_SUBDIR=$(ls "$MYSTERY_DIR" | head -1)

if [ -z "$FIRST_SUBDIR" ]; then
    echo "하위 디렉토리가 없습니다."
    exit 1
fi

echo "1. 첫 번째 하위 디렉토리 분석: $FIRST_SUBDIR"
echo "   내용:"
ls -lah "$MYSTERY_DIR/$FIRST_SUBDIR" | head -15
echo ""

echo "2. 파일 유형 확인:"
find "$MYSTERY_DIR/$FIRST_SUBDIR" -type f 2>/dev/null | head -5 | while read file; do
    echo "   파일: $(basename "$file")"
    file "$file" 2>/dev/null | head -1
done
echo ""

echo "3. 파일 확장자 분포:"
find "$MYSTERY_DIR" -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10
echo ""

echo "4. 파일 이름 패턴:"
find "$MYSTERY_DIR" -type f 2>/dev/null | head -10 | xargs -I {} basename {}
echo ""

echo "5. 디렉토리 생성 시간:"
stat "$MYSTERY_DIR" 2>/dev/null | grep -E "(Modify|Birth)"
echo ""

echo "=== 분석 완료 ==="
