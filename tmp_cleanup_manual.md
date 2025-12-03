# /tmp 파일 정리 가이드

## 방법 1: 스크립트 사용 (권장)

```bash
# 스크립트를 현재 환경으로 복사
cp /workspace/cleanup_tmp_safe.sh ~/cleanup_tmp_safe.sh
chmod +x ~/cleanup_tmp_safe.sh

# 실행
~/cleanup_tmp_safe.sh
```

## 방법 2: 직접 명령어 실행

### 1. cursor-distro-env.* 파일들 삭제
```bash
cd /tmp
rm -f cursor-distro-env.*
```

### 2. devcontainer-cli-* 디렉토리들 삭제 (사용 중이 아닌 경우)
```bash
cd /tmp
# 먼저 사용 중인지 확인
for dir in devcontainer-cli-*; do
    if [ -d "$dir" ]; then
        if lsof +D "$dir" 2>/dev/null | grep -q .; then
            echo "$dir is in use - skipping"
        else
            rm -rf "$dir"
            echo "Deleted $dir"
        fi
    fi
done
```

### 3. cursor-server-*.tar.gz 파일들 삭제
```bash
cd /tmp
rm -f cursor-server-*.tar.gz
```

### 4. remote-wsl-loc.txt 삭제
```bash
cd /tmp
rm -f remote-wsl-loc.txt
```

## 한 번에 실행 (안전 버전)

```bash
cd /tmp

# cursor-distro-env 파일들
rm -f cursor-distro-env.*

# devcontainer-cli 디렉토리들 (사용 중이 아닌 경우만)
for dir in devcontainer-cli-*; do
    [ -d "$dir" ] && ! lsof +D "$dir" 2>/dev/null | grep -q . && rm -rf "$dir"
done

# cursor-server tar.gz 파일들
rm -f cursor-server-*.tar.gz

# remote-wsl-loc.txt
rm -f remote-wsl-loc.txt

# 결과 확인
echo "정리 완료. 남은 파일:"
ls -lh | grep -E "(cursor|devcontainer|remote-wsl)"
```

## 삭제 전 확인 (선택사항)

```bash
cd /tmp

# 삭제될 파일들의 크기 확인
echo "=== 삭제될 파일 크기 ==="
du -sh cursor-distro-env.* 2>/dev/null
du -sh devcontainer-cli-* 2>/dev/null
du -sh cursor-server-*.tar.gz 2>/dev/null
du -sh remote-wsl-loc.txt 2>/dev/null

# 총 크기 계산
echo ""
echo "=== 총 예상 삭제 크기 ==="
du -ch cursor-distro-env.* devcontainer-cli-* cursor-server-*.tar.gz remote-wsl-loc.txt 2>/dev/null | tail -1
```

## 주의사항

- `systemd-private-*` 디렉토리와 `snap-private-tmp`는 시스템이 사용 중일 수 있으므로 건너뜁니다
- 삭제 후 디스크 공간이 확보됩니다 (약 130MB 이상)
