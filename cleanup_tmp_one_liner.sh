#!/bin/bash
# /tmp 파일 정리 - 한 줄 실행 버전

cd /tmp && \
echo "=== /tmp 파일 정리 시작 ===" && \
echo "" && \
echo "1. cursor-distro-env.* 파일들 삭제..." && \
rm -f cursor-distro-env.* && echo "   ✅ 완료" && \
echo "" && \
echo "2. devcontainer-cli-* 디렉토리들 삭제..." && \
for dir in devcontainer-cli-*; do [ -d "$dir" ] && ! lsof +D "$dir" 2>/dev/null | grep -q . && rm -rf "$dir" && echo "   ✅ $dir 삭제됨"; done && \
echo "" && \
echo "3. cursor-server-*.tar.gz 파일들 삭제..." && \
rm -f cursor-server-*.tar.gz && echo "   ✅ 완료" && \
echo "" && \
echo "4. remote-wsl-loc.txt 삭제..." && \
rm -f remote-wsl-loc.txt && echo "   ✅ 완료" && \
echo "" && \
echo "=== 정리 완료 ===" && \
echo "" && \
echo "현재 /tmp 디스크 사용량:" && \
df -h /tmp | tail -1
