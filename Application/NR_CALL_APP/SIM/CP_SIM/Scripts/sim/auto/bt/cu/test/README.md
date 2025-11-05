# AL Driven Log Collection Test

이 스크립트는 VCCB (Virtual Cell Control Block)의 로그 수집 기능을 자동으로 테스트합니다.

## 테스트 항목

1. **로그 파일 생성 확인**: `/var/log/vccb_count.csv` 파일이 생성되는지 확인
2. **형상 타입 감지**: VNF, NVGNB, 또는 CNF 형상을 자동으로 감지
3. **함수 호출 주기 검증**: 
   - VNF/NVGNB 형상: 3초 주기로 `FnVCCB_UpdateMsgIncreaseCount` 함수 호출 확인
   - CNF 형상: 10초 주기로 `FnVCCB_UpdateMsgIncreaseCount` 함수 호출 확인

## 사용 방법

### 기본 실행 (60초 모니터링)
```bash
python AL_Driven_Log_Collection.py
```

### 사용자 지정 모니터링 시간
```bash
# 120초 동안 모니터링
python AL_Driven_Log_Collection.py --duration 120
```

### 형상 타입 수동 설정
```bash
# CNF 형상으로 설정
NF_CONFIG_TYPE=CNF python AL_Driven_Log_Collection.py

# 또는 명령줄 옵션 사용
python AL_Driven_Log_Collection.py --config-type CNF
```

### 커스텀 로그 파일 경로
```bash
python AL_Driven_Log_Collection.py --log-file /custom/path/vccb_count.csv
```

## 명령줄 옵션

- `--duration SECONDS`: 모니터링 지속 시간 (기본값: 60초)
- `--config-type {VNF,NVGNB,CNF}`: 형상 타입 수동 설정
- `--log-file PATH`: VCCB count 로그 파일 경로 지정
- `-h, --help`: 도움말 표시

## 테스트 결과

스크립트는 다음과 같은 정보를 출력합니다:

```
================================================================================
TEST RESULT SUMMARY
================================================================================
Log File Check: PASS
Configuration Type: VNF
Expected Period: 3 seconds
Actual Periods (samples: 19):
  - Average: 3.02 seconds
  - Min: 2.85 seconds
  - Max: 3.15 seconds
Period Verification: PASS
================================================================================

OVERALL TEST: PASS ✓
```

## 종료 코드

- `0`: 모든 테스트 통과
- `1`: 하나 이상의 테스트 실패

## 형상 타입 감지 방법

스크립트는 다음 방법으로 형상 타입을 자동 감지합니다:

1. **환경 변수**: `NF_CONFIG_TYPE` 환경 변수 확인
2. **설정 파일**: 다음 경로에서 설정 파일 확인
   - `/etc/nr_call_app/config.ini`
   - `/opt/nr_call_app/config.ini`
   - `/workspace/Application/NR_CALL_APP/config.ini`
3. **시스템 속성**: Kubernetes 환경 확인 (CNF 판별)
4. **기본값**: 감지 실패 시 VNF로 설정

## 함수 호출 모니터링 방법

스크립트는 다음 방법으로 함수 호출을 모니터링합니다:

1. **시스템 로그 파싱**: 기존 로그 파일에서 함수 호출 기록 추출
   - `/var/log/messages`
   - `/var/log/syslog`
   - `/var/log/vccb.log`
   - `/var/log/nr_call_app.log`

2. **실시간 모니터링**: `journalctl`을 사용한 실시간 로그 추적

3. **시뮬레이션 모드**: 테스트 환경에서 데이터가 없을 경우 샘플 데이터 생성

## 검증 기준

- **주기 허용 오차**: 예상 주기의 ±10%
- **허용 가능한 이상값**: 전체 측정값의 20% 미만

## 요구사항

- Python 3.6 이상
- 시스템 로그 읽기 권한
- (선택사항) journalctl 접근 권한 (실시간 모니터링용)

## 예제

### 테스트 자동화 스크립트에서 사용
```bash
#!/bin/bash
# 테스트 실행
python AL_Driven_Log_Collection.py --duration 120

# 결과 확인
if [ $? -eq 0 ]; then
    echo "VCCB 로그 수집 테스트 성공"
else
    echo "VCCB 로그 수집 테스트 실패"
    exit 1
fi
```

### CI/CD 파이프라인에서 사용
```yaml
test-vccb-log-collection:
  script:
    - python Application/NR_CALL_APP/SIM/CP_SIM/Scripts/sim/auto/bt/cu/test/AL_Driven_Log_Collection.py --duration 90
  timeout: 2m
```

## 문제 해결

### 로그 파일을 찾을 수 없음
- `/var/log/vccb_count.csv` 파일이 생성되었는지 확인
- VCCB 애플리케이션이 실행 중인지 확인
- 로그 파일 생성 권한 확인

### 함수 호출 데이터 부족
- 모니터링 시간을 늘려보세요 (`--duration` 옵션)
- 시스템 로그가 활성화되어 있는지 확인
- VCCB 애플리케이션의 로그 레벨 확인

### 형상 타입 감지 실패
- 환경 변수 또는 명령줄 옵션으로 수동 설정
- 설정 파일이 올바른 위치에 있는지 확인
