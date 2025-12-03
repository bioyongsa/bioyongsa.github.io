#!/bin/bash
# /tmp 디렉토리 정리 스크립트
# 안전하게 삭제 가능한 임시 파일들을 정리합니다.

TMP_DIR="/tmp"
DRY_RUN=true  # true로 설정하면 실제 삭제 없이 확인만 합니다

echo "=== /tmp 디렉토리 정리 스크립트 ==="
echo ""

# 삭제 가능한 파일 패턴들
PATTERNS=(
    "cursor-distro-env.*"
    "devcontainer-cli-*"
    "cursor-server-*.tar.gz"
    "remote-wsl-loc.txt"
)

# systemd-private 디렉토리는 주의가 필요하지만, 오래된 것은 삭제 가능
SYSTEMD_PATTERNS=(
    "systemd-private-*"
)

echo "다음 파일들이 삭제 대상입니다:"
echo ""

# cursor-distro-env 파일들
echo "1. cursor-distro-env 파일들:"
find "$TMP_DIR" -maxdepth 1 -name "cursor-distro-env.*" -type f 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        echo "   - $file ($(du -h "$file" | cut -f1))"
        if [ "$DRY_RUN" = false ]; then
            rm -f "$file" && echo "     삭제됨" || echo "     삭제 실패"
        fi
    fi
done

# devcontainer-cli 디렉토리들
echo ""
echo "2. devcontainer-cli 디렉토리들:"
find "$TMP_DIR" -maxdepth 1 -name "devcontainer-cli-*" -type d 2>/dev/null | while read dir; do
    if [ -d "$dir" ]; then
        # 디렉토리가 사용 중인지 확인
        if lsof +D "$dir" 2>/dev/null | grep -q .; then
            echo "   - $dir (사용 중 - 건너뜀)"
        else
            echo "   - $dir ($(du -sh "$dir" 2>/dev/null | cut -f1))"
            if [ "$DRY_RUN" = false ]; then
                rm -rf "$dir" && echo "     삭제됨" || echo "     삭제 실패"
            fi
        fi
    fi
done

# cursor-server tar.gz 파일들
echo ""
echo "3. cursor-server tar.gz 파일들:"
find "$TMP_DIR" -maxdepth 1 -name "cursor-server-*.tar.gz" -type f 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        echo "   - $file ($(du -h "$file" | cut -f1))"
        if [ "$DRY_RUN" = false ]; then
            rm -f "$file" && echo "     삭제됨" || echo "     삭제 실패"
        fi
    fi
done

# remote-wsl-loc.txt
echo ""
echo "4. remote-wsl-loc.txt:"
if [ -f "$TMP_DIR/remote-wsl-loc.txt" ]; then
    echo "   - $TMP_DIR/remote-wsl-loc.txt ($(du -h "$TMP_DIR/remote-wsl-loc.txt" | cut -f1))"
    if [ "$DRY_RUN" = false ]; then
        rm -f "$TMP_DIR/remote-wsl-loc.txt" && echo "     삭제됨" || echo "     삭제 실패"
    fi
fi

# systemd-private 디렉토리들 (주의 필요)
echo ""
echo "5. systemd-private 디렉토리들 (시스템 서비스 관련 - 주의 필요):"
find "$TMP_DIR" -maxdepth 1 -name "systemd-private-*" -type d 2>/dev/null | while read dir; do
    if [ -d "$dir" ]; then
        # 디렉토리가 사용 중인지 확인
        if lsof +D "$dir" 2>/dev/null | grep -q .; then
            echo "   - $dir (사용 중 - 건너뜀)"
        else
            echo "   - $dir ($(du -sh "$dir" 2>/dev/null | cut -f1))"
            echo "     ⚠️  시스템 서비스 관련 파일이므로 신중히 삭제하세요"
            if [ "$DRY_RUN" = false ]; then
                read -p "     정말 삭제하시겠습니까? (y/N): " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    rm -rf "$dir" && echo "     삭제됨" || echo "     삭제 실패"
                fi
            fi
        fi
    fi
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "⚠️  DRY_RUN 모드입니다. 실제로 삭제하려면 스크립트에서 DRY_RUN=false로 변경하세요."
else
    echo "✅ 정리 완료"
fi

echo ""
echo "=== 디스크 사용량 ==="
df -h "$TMP_DIR" | tail -1
