#!/bin/bash
# /tmp 파일 정리 - sudo 권한 필요한 파일 포함

cd /tmp

echo "=== /tmp 파일 정리 (sudo 포함) ==="
echo ""

# 1. 일반 사용자 권한으로 삭제 가능한 파일들
echo "1. cursor-distro-env.* 파일들 삭제..."
rm -f cursor-distro-env.* 2>/dev/null && echo "   ✅ 완료" || echo "   ⏭️  없음"

echo ""
echo "2. devcontainer-cli-* 디렉토리들 삭제..."
for dir in devcontainer-cli-*; do
    if [ -d "$dir" ]; then
        if ! lsof +D "$dir" 2>/dev/null | grep -q .; then
            rm -rf "$dir" 2>/dev/null && echo "   ✅ $dir 삭제됨"
        else
            echo "   ⚠️  $dir 사용 중 - 건너뜀"
        fi
    fi
done

echo ""
echo "3. remote-wsl-loc.txt 삭제..."
rm -f remote-wsl-loc.txt 2>/dev/null && echo "   ✅ 완료" || echo "   ⏭️  없음"

echo ""
echo "4. cursor-server-*.tar.gz 파일들 삭제 (sudo 필요)..."
if ls cursor-server-*.tar.gz 1>/dev/null 2>&1; then
    sudo rm -f cursor-server-*.tar.gz && echo "   ✅ 완료 (sudo 사용)" || echo "   ❌ sudo 권한 필요"
else
    echo "   ⏭️  없음"
fi

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "현재 /tmp 디스크 사용량:"
df -h /tmp | tail -1
