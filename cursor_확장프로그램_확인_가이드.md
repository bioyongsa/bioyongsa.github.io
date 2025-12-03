# Cursor 확장 프로그램 확인 가이드

## 문제 상황

Container에 연결은 성공했지만 확장 프로그램이 보이지 않음

## 확인해야 할 섹션

확장 프로그램 탭 (`Ctrl+Shift+X`)에서 여러 섹션이 있습니다:

### ❌ 잘못된 섹션 (확인하지 않을 것)
- **Local - INSTALLED**: Windows 호스트에 설치된 확장 프로그램
- **WSL: UBUNTU 24.04 - INSTALLED**: WSL에 설치된 확장 프로그램

### ✅ 올바른 섹션 (확인할 것)
- **Dev Container: access_rhel8.10 - INSTALLED**: Container에 설치된 확장 프로그램
- 또는 **Container: access_rhel8.10 - INSTALLED**

## 확인 방법

### 1. 확장 프로그램 탭에서 올바른 섹션 찾기

1. **확장 프로그램 탭 열기**: `Ctrl+Shift+X`

2. **왼쪽 사이드바에서 다음 섹션들을 확인:**
   - "INSTALLED" 섹션 확장
   - "Dev Container: access_rhel8.10" 또는 "Container: access_rhel8.10" 섹션 찾기
   - 이 섹션에 설치된 확장 프로그램이 표시되어야 함

3. **만약 섹션이 보이지 않으면:**
   - Container 연결이 제대로 되지 않았을 수 있음
   - 왼쪽 하단의 연결 상태 확인

### 2. Container 내부에서 확인

Container 내부 터미널에서:

```bash
# 확장 프로그램 목록 확인
ls -la ~/.cursor-server/extensions/

# 확장 프로그램 개수 확인
ls -d ~/.cursor-server/extensions/*/ 2>/dev/null | wc -l

# 확장 프로그램 상세 정보 확인
for ext in ~/.cursor-server/extensions/*/; do
    if [ -f "$ext/package.json" ]; then
        echo "$(basename "$ext"):"
        grep '"displayName"' "$ext/package.json" 2>/dev/null | head -1
    fi
done
```

### 3. 확장 프로그램 활성화 확인

확장 프로그램 탭에서:
- 각 확장 프로그램 옆에 "Enable" 버튼이 있는지 확인
- "Disable"로 표시되어 있으면 이미 활성화된 것
- "Enable"로 표시되어 있으면 클릭하여 활성화

## 문제 해결

### 문제 1: Container 섹션이 보이지 않음

**해결 방법:**
1. Container 재연결
2. Cursor IDE 재시작
3. Command Palette에서 `Developer: Reload Window` 실행

### 문제 2: 확장 프로그램이 비활성화됨

**해결 방법:**
1. 확장 프로그램 탭에서 각 확장 프로그램 옆의 "Enable" 클릭
2. 또는 Command Palette에서 `Extensions: Enable All Installed Extensions` 실행

### 문제 3: 확장 프로그램이 설치되지 않음

**해결 방법:**
1. 확장 프로그램 탭에서 "INSTALLED" 섹션 확인
2. "Dev Container: access_rhel8.10" 섹션에서 확장 프로그램 설치
3. 또는 Local에서 설치 후 "Install in Container" 클릭

## 확인 명령어

Container 내부에서 실행:

```bash
# 확장 프로그램 확인 스크립트
cat > ~/check_extensions.sh << 'EOF'
echo "=== Container 확장 프로그램 확인 ==="
echo ""
EXT_DIR="$HOME/.cursor-server/extensions"
echo "확장 프로그램 디렉토리: $EXT_DIR"
echo "확장 프로그램 개수: $(ls -d $EXT_DIR/*/ 2>/dev/null | wc -l)"
echo ""
echo "설치된 확장 프로그램:"
ls -1d $EXT_DIR/*/ 2>/dev/null | while read ext; do
    EXT_NAME=$(basename "$ext")
    if [ -f "$ext/package.json" ]; then
        DISPLAY_NAME=$(grep '"displayName"' "$ext/package.json" 2>/dev/null | head -1 | sed 's/.*"displayName": *"\([^"]*\)".*/\1/')
        echo "  - $EXT_NAME: $DISPLAY_NAME"
    else
        echo "  - $EXT_NAME"
    fi
done
EOF
chmod +x ~/check_extensions.sh
~/check_extensions.sh
```

## 요약

1. ✅ Container 연결 확인됨 (왼쪽 하단 표시)
2. ⚠️ 확장 프로그램 탭에서 올바른 섹션 확인 필요
   - "Dev Container: access_rhel8.10 - INSTALLED" 섹션 확인
   - "WSL: UBUNTU 24.04 - INSTALLED"가 아님
3. 확장 프로그램이 비활성화되어 있을 수 있음 → "Enable" 클릭
