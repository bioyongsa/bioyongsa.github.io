#!/usr/bin/env python3
"""
AL_Driven_Log_Collection.py

VCCB 카운트 로그 수집 및 모니터링 스크립트
- /var/log/vccb_count.csv 파일 생성 확인
- 형상에 따른 FnVCCB_UpdateMsgIncreaseCount 함수 호출 주기 확인
  * VNF/NVGNB 형상: 3초 주기
  * CNF 형상: 10초 주기
"""

import os
import sys
import time
import csv
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple, List

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('vccb_monitor.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# 상수 정의
VCCB_COUNT_CSV_PATH = "/var/log/vccb_count.csv"
VNF_NVGNB_INTERVAL = 3  # 초
CNF_INTERVAL = 10  # 초
TOLERANCE = 0.5  # 주기 허용 오차 (초)


class VCCBMonitor:
    """VCCB 카운트 모니터링 클래스"""
    
    def __init__(self, csv_path: str = VCCB_COUNT_CSV_PATH):
        """
        초기화
        
        Args:
            csv_path: VCCB 카운트 CSV 파일 경로
        """
        self.csv_path = csv_path
        self.csv_file = Path(csv_path)
        self.last_check_time = None
        self.last_file_size = 0
        
    def check_csv_file_exists(self) -> bool:
        """
        VCCB 카운트 CSV 파일이 존재하는지 확인
        
        Returns:
            파일 존재 여부
        """
        exists = self.csv_file.exists()
        if exists:
            logger.info(f"✓ CSV 파일 존재 확인: {self.csv_path}")
            logger.info(f"  파일 크기: {self.csv_file.stat().st_size} bytes")
            logger.info(f"  수정 시간: {datetime.fromtimestamp(self.csv_file.stat().st_mtime)}")
        else:
            logger.warning(f"✗ CSV 파일이 존재하지 않습니다: {self.csv_path}")
        return exists
    
    def detect_configuration(self) -> Optional[str]:
        """
        형상(VNF/NVGNB/CNF) 감지
        환경 변수나 설정 파일을 통해 형상 확인
        
        Returns:
            형상 타입 ('VNF', 'NVGNB', 'CNF', None)
        """
        # 환경 변수로 형상 확인
        config_type = os.environ.get('VNF_CONFIG_TYPE') or os.environ.get('CONFIG_TYPE')
        
        if config_type:
            config_type = config_type.upper()
            if config_type in ['VNF', 'NVGNB', 'CNF']:
                logger.info(f"형상 감지: {config_type} (환경 변수)")
                return config_type
        
        # 설정 파일 확인 (가능한 경우)
        config_paths = [
            "/etc/vnf_config",
            "/etc/config_type",
            "/opt/vccb/config",
        ]
        
        for config_path in config_paths:
            if os.path.exists(config_path):
                try:
                    with open(config_path, 'r') as f:
                        content = f.read().strip().upper()
                        if content in ['VNF', 'NVGNB', 'CNF']:
                            logger.info(f"형상 감지: {content} (설정 파일: {config_path})")
                            return content
                except Exception as e:
                    logger.debug(f"설정 파일 읽기 실패 ({config_path}): {e}")
        
        # 기본값: VNF로 가정 (사용자에게 확인 필요)
        logger.warning("형상을 자동으로 감지할 수 없습니다. 기본값으로 VNF를 사용합니다.")
        logger.warning("환경 변수 VNF_CONFIG_TYPE 또는 CONFIG_TYPE을 설정하거나 형상을 수동으로 지정하세요.")
        return "VNF"  # 기본값
    
    def read_csv_entries(self, max_lines: Optional[int] = None) -> List[Tuple[datetime, dict]]:
        """
        CSV 파일에서 엔트리 읽기
        
        Args:
            max_lines: 최대 읽을 라인 수 (None이면 전체)
        
        Returns:
            [(타임스탬프, 데이터 딕셔너리), ...] 리스트
        """
        if not self.csv_file.exists():
            return []
        
        entries = []
        try:
            with open(self.csv_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for i, row in enumerate(reader):
                    if max_lines and i >= max_lines:
                        break
                    
                    # 타임스탬프 파싱 시도
                    timestamp = None
                    timestamp_str = row.get('timestamp') or row.get('time') or row.get('date')
                    
                    if timestamp_str:
                        try:
                            timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                        except:
                            try:
                                timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
                            except:
                                pass
                    
                    if not timestamp:
                        timestamp = datetime.fromtimestamp(self.csv_file.stat().st_mtime)
                    
                    entries.append((timestamp, row))
            
            logger.info(f"CSV 파일에서 {len(entries)}개 엔트리 읽기 완료")
        except Exception as e:
            logger.error(f"CSV 파일 읽기 오류: {e}")
        
        return entries
    
    def check_function_call_interval(
        self, 
        config_type: str, 
        sample_size: int = 10
    ) -> Tuple[bool, List[float]]:
        """
        함수 호출 주기 확인
        
        Args:
            config_type: 형상 타입 ('VNF', 'NVGNB', 'CNF')
            sample_size: 확인할 샘플 수
        
        Returns:
            (주기 준수 여부, 실제 주기 리스트)
        """
        entries = self.read_csv_entries(max_lines=sample_size * 2)
        
        if len(entries) < 2:
            logger.warning("충분한 엔트리가 없어 주기 확인을 수행할 수 없습니다.")
            return False, []
        
        # 예상 주기 설정
        expected_interval = VNF_NVGNB_INTERVAL if config_type in ['VNF', 'NVGNB'] else CNF_INTERVAL
        
        # 타임스탬프 추출 및 정렬
        timestamps = [entry[0] for entry in entries]
        timestamps.sort()
        
        # 주기 계산
        intervals = []
        for i in range(1, len(timestamps)):
            delta = (timestamps[i] - timestamps[i-1]).total_seconds()
            intervals.append(delta)
        
        # 주기 분석
        if not intervals:
            logger.warning("주기를 계산할 수 없습니다.")
            return False, []
        
        avg_interval = sum(intervals) / len(intervals)
        min_interval = min(intervals)
        max_interval = max(intervals)
        
        logger.info(f"예상 주기: {expected_interval}초")
        logger.info(f"평균 주기: {avg_interval:.2f}초")
        logger.info(f"최소 주기: {min_interval:.2f}초")
        logger.info(f"최대 주기: {max_interval:.2f}초")
        
        # 주기 확인
        within_tolerance = abs(avg_interval - expected_interval) <= TOLERANCE
        
        if within_tolerance:
            logger.info(f"✓ 주기 확인 통과: 평균 {avg_interval:.2f}초 (예상: {expected_interval}초)")
        else:
            logger.error(f"✗ 주기 확인 실패: 평균 {avg_interval:.2f}초 (예상: {expected_interval}초)")
        
        return within_tolerance, intervals
    
    def monitor_csv_file_creation(self, timeout: int = 60) -> bool:
        """
        CSV 파일 생성 대기 및 확인
        
        Args:
            timeout: 타임아웃 (초)
        
        Returns:
            파일 생성 여부
        """
        logger.info(f"CSV 파일 생성 대기 중: {self.csv_path} (타임아웃: {timeout}초)")
        
        start_time = time.time()
        check_interval = 1  # 1초마다 확인
        
        while time.time() - start_time < timeout:
            if self.csv_file.exists():
                file_size = self.csv_file.stat().st_size
                if file_size > 0:
                    logger.info(f"✓ CSV 파일 생성 확인: {self.csv_path}")
                    return True
            
            time.sleep(check_interval)
            elapsed = int(time.time() - start_time)
            if elapsed % 10 == 0:
                logger.info(f"대기 중... ({elapsed}/{timeout}초)")
        
        logger.error(f"✗ CSV 파일 생성 타임아웃: {timeout}초 내에 파일이 생성되지 않았습니다.")
        return False
    
    def run_monitoring(self, config_type: Optional[str] = None, duration: int = 60):
        """
        모니터링 실행
        
        Args:
            config_type: 형상 타입 (None이면 자동 감지)
            duration: 모니터링 지속 시간 (초)
        """
        logger.info("=" * 60)
        logger.info("VCCB 카운트 모니터링 시작")
        logger.info("=" * 60)
        
        # 1. CSV 파일 생성 확인
        logger.info("\n[1단계] CSV 파일 생성 확인")
        if not self.check_csv_file_exists():
            logger.info("CSV 파일이 없어 생성 대기 중...")
            if not self.monitor_csv_file_creation(timeout=duration):
                logger.error("CSV 파일 생성 실패")
                return False
        
        # 2. 형상 감지
        logger.info("\n[2단계] 형상 감지")
        if not config_type:
            config_type = self.detect_configuration()
        
        if not config_type:
            logger.error("형상을 확인할 수 없습니다.")
            return False
        
        # 3. 함수 호출 주기 확인
        logger.info("\n[3단계] 함수 호출 주기 확인")
        logger.info(f"형상: {config_type}")
        expected_interval = VNF_NVGNB_INTERVAL if config_type in ['VNF', 'NVGNB'] else CNF_INTERVAL
        logger.info(f"예상 호출 주기: {expected_interval}초")
        
        # 충분한 샘플 수집을 위해 대기
        sample_count = 5
        wait_time = expected_interval * sample_count + 5
        logger.info(f"샘플 수집을 위해 {wait_time}초 대기 중...")
        time.sleep(wait_time)
        
        # 주기 확인
        passed, intervals = self.check_function_call_interval(config_type, sample_size=sample_count)
        
        # 결과 요약
        logger.info("\n" + "=" * 60)
        logger.info("모니터링 결과 요약")
        logger.info("=" * 60)
        logger.info(f"CSV 파일 존재: {'✓' if self.check_csv_file_exists() else '✗'}")
        logger.info(f"형상: {config_type}")
        logger.info(f"주기 확인: {'✓ 통과' if passed else '✗ 실패'}")
        
        if intervals:
            logger.info(f"실제 주기: 평균 {sum(intervals)/len(intervals):.2f}초")
        
        return passed and self.check_csv_file_exists()


def main():
    """메인 함수"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='VCCB 카운트 로그 수집 및 모니터링',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
예제:
  # 형상 자동 감지
  python AL_Driven_Log_Collection.py
  
  # 형상 수동 지정
  python AL_Driven_Log_Collection.py --config-type VNF
  
  # CSV 파일 경로 지정
  python AL_Driven_Log_Collection.py --csv-path /custom/path/vccb_count.csv
  
  # 모니터링 지속 시간 지정
  python AL_Driven_Log_Collection.py --duration 120
        """
    )
    
    parser.add_argument(
        '--csv-path',
        default=VCCB_COUNT_CSV_PATH,
        help=f'VCCB 카운트 CSV 파일 경로 (기본값: {VCCB_COUNT_CSV_PATH})'
    )
    
    parser.add_argument(
        '--config-type',
        choices=['VNF', 'NVGNB', 'CNF'],
        help='형상 타입 (VNF, NVGNB, CNF). 지정하지 않으면 자동 감지 시도'
    )
    
    parser.add_argument(
        '--duration',
        type=int,
        default=60,
        help='모니터링 지속 시간 (초, 기본값: 60)'
    )
    
    parser.add_argument(
        '--check-only',
        action='store_true',
        help='일회성 확인만 수행 (지속 모니터링 없음)'
    )
    
    args = parser.parse_args()
    
    monitor = VCCBMonitor(csv_path=args.csv_path)
    
    if args.check_only:
        # 일회성 확인
        exists = monitor.check_csv_file_exists()
        if exists:
            config_type = args.config_type or monitor.detect_configuration()
            if config_type:
                passed, intervals = monitor.check_function_call_interval(config_type)
                sys.exit(0 if passed else 1)
        sys.exit(1)
    else:
        # 지속 모니터링
        success = monitor.run_monitoring(
            config_type=args.config_type,
            duration=args.duration
        )
        sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
