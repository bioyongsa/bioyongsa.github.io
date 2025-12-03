#!/bin/bash
# /tmp 디렉토리 안전 정리 스크립트
# 사용자가 요청한 파일들만 안전하게 삭제합니다.

set -e  # 에러 발생 시 중단

TMP_DIR="/tmp"
TOTAL_FREED=0

echo "=========================================="
echo "  /tmp 디렉토리 안전 정리 스크립트"
echo "=========================================="
echo ""

# 함수: 파일 크기 확인
get_size() {
    if [ -e "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# 함수: 안전하게 삭제
safe_remove() {
    local target="$1"
    local description="$2"
    
    if [ ! -e "$target" ]; then
        echo "  ⏭️  $description: 존재하지 않음"
        return 0
    fi
    
    # 디렉토리인 경우 사용 중인지 확인
    if [ -d "$target" ]; then
        if lsof +D "$target" 2>/dev/null | grep -q .; then
            echo "  ⚠️  $description: 사용 중 - 건너뜀"
            return 1
        fi
    fi
    
    local size=$(get_size "$target")
    echo "  🗑️  $description 삭제 중... (크기: $size)"
    
    if rm -rf "$target" 2>/dev/null; then
        echo "  ✅ 삭제 완료"
        return 0
    else
        echo "  ❌ 삭제 실패 (권한 문제일 수 있음)"
        return 1
    fi
}

echo "1. cursor-distro-env.* 파일들 삭제"
for file in "$TMP_DIR"/cursor-distro-env.*; do
    if [ -f "$file" ]; then
        safe_remove "$file" "cursor-distro-env 파일"
    fi
done
echo ""

echo "2. devcontainer-cli-* 디렉토리들 삭제"
for dir in "$TMP_DIR"/devcontainer-cli-*; do
    if [ -d "$dir" ]; then
        safe_remove "$dir" "devcontainer-cli 디렉토리: $(basename "$dir")"
    fi
done
echo ""

echo "3. cursor-server-*.tar.gz 파일들 삭제"
for file in "$TMP_DIR"/cursor-server-*.tar.gz; do
    if [ -f "$file" ]; then
        safe_remove "$file" "cursor-server tar.gz: $(basename "$file")"
    fi
done
echo ""

echo "4. remote-wsl-loc.txt 파일 삭제"
safe_remove "$TMP_DIR/remote-wsl-loc.txt" "remote-wsl-loc.txt"
echo ""

echo "=========================================="
echo "  정리 완료"
echo "=========================================="
echo ""
echo "⚠️  주의: 다음 파일들은 시스템이 사용 중일 수 있어 건너뛰었습니다:"
echo "   - systemd-private-* 디렉토리들"
echo "   - snap-private-tmp 디렉토리"
echo ""
echo "현재 /tmp 디스크 사용량:"
df -h "$TMP_DIR" | tail -1
