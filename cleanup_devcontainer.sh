#!/bin/bash
# devcontainer-cli 디렉토리 안전 삭제 스크립트

cd /tmp

echo "=== devcontainer-cli 디렉토리 정리 ==="
echo ""

# 각 디렉토리 확인 및 삭제
for dir in devcontainer-cli-*; do
    if [ -d "$dir" ]; then
        echo "확인 중: $dir"
        
        # 사용 중인지 확인 (여러 방법 시도)
        IN_USE=false
        
        # 방법 1: lsof로 확인
        if command -v lsof >/dev/null 2>&1; then
            if lsof +D "$dir" 2>/dev/null | grep -q .; then
                IN_USE=true
                echo "  ⚠️  lsof: 사용 중으로 감지됨"
            fi
        fi
        
        # 방법 2: fuser로 확인
        if command -v fuser >/dev/null 2>&1; then
            if fuser "$dir" 2>/dev/null | grep -q .; then
                IN_USE=true
                echo "  ⚠️  fuser: 사용 중으로 감지됨"
            fi
        fi
        
        # 방법 3: 프로세스가 해당 경로를 사용하는지 확인
        if ps aux 2>/dev/null | grep -q "$dir"; then
            IN_USE=true
            echo "  ⚠️  프로세스: 사용 중으로 감지됨"
        fi
        
        if [ "$IN_USE" = false ]; then
            echo "  ✅ 사용 중이 아님 - 삭제 시도..."
            if rm -rf "$dir" 2>/dev/null; then
                echo "  ✅ 삭제 완료"
            else
                echo "  ❌ 삭제 실패 (권한 문제일 수 있음)"
            fi
        else
            echo "  ⏭️  사용 중 - 건너뜀"
        fi
        echo ""
    fi
done

echo "=== 정리 완료 ==="
echo ""
echo "남은 devcontainer-cli 디렉토리:"
ls -d devcontainer-cli-* 2>/dev/null || echo "없음"
