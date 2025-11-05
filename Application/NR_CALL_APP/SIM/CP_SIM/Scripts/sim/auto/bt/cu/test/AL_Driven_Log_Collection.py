"""Automated log validation for VCCB message counter updates.

This utility verifies that the `/var/log/vccb_count.csv` log file is present
and that the `FnVCCB_UpdateMsgIncreaseCount` function is triggered at the
expected cadence for a given deployment shape.

Usage example::

    python AL_Driven_Log_Collection.py --shape VNF

The script monitors the log file for new entries containing the target
function name and measures the interval between successive rows. It exits with
code 0 when the observed cadence satisfies the configured thresholds and
raises `SystemExit` with a non-zero code otherwise.
"""

from __future__ import annotations

import argparse
import os
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List


FUNCTION_NAME = "FnVCCB_UpdateMsgIncreaseCount"
DEFAULT_LOG_PATH = Path("/var/log/vccb_count.csv")


class MonitoringError(RuntimeError):
    """Base error raised when monitoring expectations are not met."""


@dataclass
class MonitoringConfig:
    shape: str
    log_path: Path
    wait_timeout: float
    monitor_duration: float
    min_samples: int
    poll_interval: float
    tolerance: float


@dataclass
class MonitoringOutcome:
    passed: bool
    message: str
    intervals: List[float]


def parse_args(argv: Iterable[str]) -> MonitoringConfig:
    parser = argparse.ArgumentParser(
        description=(
            "Verify VCCB FnVCCB_UpdateMsgIncreaseCount cadence from vccb_count.csv logs"
        )
    )

    parser.add_argument(
        "--shape",
        required=True,
        choices=["VNF", "NVGNB", "CNF"],
        help="Deployment shape to validate. Determines the expected interval.",
    )
    parser.add_argument(
        "--log-path",
        type=Path,
        default=DEFAULT_LOG_PATH,
        help=f"Path to log file (default: {DEFAULT_LOG_PATH})",
    )
    parser.add_argument(
        "--wait-timeout",
        type=float,
        default=60.0,
        help="Maximum seconds to wait for the log file to appear (default: 60s)",
    )
    parser.add_argument(
        "--monitor-duration",
        type=float,
        default=60.0,
        help="Overall monitoring window in seconds (default: 60s)",
    )
    parser.add_argument(
        "--min-samples",
        type=int,
        default=3,
        help="Minimum number of function hits to observe (default: 3)",
    )
    parser.add_argument(
        "--poll-interval",
        type=float,
        default=0.5,
        help="Polling interval while tailing the log file in seconds (default: 0.5s)",
    )
    parser.add_argument(
        "--abs-tolerance",
        type=float,
        default=None,
        help="Absolute tolerance for interval deviation in seconds (overrides relative)",
    )
    parser.add_argument(
        "--relative-tolerance",
        type=float,
        default=0.25,
        help="Relative tolerance (percentage of expected interval, default: 0.25)",
    )

    args = parser.parse_args(list(argv))

    expected_interval = expected_interval_for_shape(args.shape)
    if args.abs_tolerance is not None and args.abs_tolerance < 0:
        parser.error("--abs-tolerance must be non-negative when provided")
    if args.relative_tolerance < 0:
        parser.error("--relative-tolerance must be non-negative")
    if args.min_samples < 2:
        parser.error("--min-samples must be at least 2 to compute intervals")

    tolerance = (
        args.abs_tolerance
        if args.abs_tolerance is not None
        else expected_interval * args.relative_tolerance
    )

    return MonitoringConfig(
        shape=args.shape,
        log_path=args.log_path,
        wait_timeout=args.wait_timeout,
        monitor_duration=args.monitor_duration,
        min_samples=args.min_samples,
        poll_interval=args.poll_interval,
        tolerance=tolerance,
    )


def expected_interval_for_shape(shape: str) -> float:
    normalized = shape.upper()
    if normalized in {"VNF", "NVGNB"}:
        return 3.0
    if normalized == "CNF":
        return 10.0
    raise MonitoringError(f"Unsupported deployment shape: {shape}")


def wait_for_log_file(path: Path, timeout: float) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.exists():
            return
        time.sleep(0.5)
    raise MonitoringError(f"Log file not found within {timeout:.1f}s: {path}")


def compute_intervals(timestamps: List[float]) -> List[float]:
    return [second - first for first, second in zip(timestamps, timestamps[1:])]


def monitor_function_calls(cfg: MonitoringConfig) -> MonitoringOutcome:
    expected_interval = expected_interval_for_shape(cfg.shape)

    try:
        wait_for_log_file(cfg.log_path, cfg.wait_timeout)
    except MonitoringError as exc:
        return MonitoringOutcome(False, str(exc), [])

    start_time = time.monotonic()
    timestamps: List[float] = []

    try:
        with cfg.log_path.open("r", encoding="utf-8", errors="ignore") as handle:
            handle.seek(0, os.SEEK_END)
            while time.monotonic() - start_time <= cfg.monitor_duration:
                position = handle.tell()
                line = handle.readline()
                if not line:
                    time.sleep(cfg.poll_interval)
                    handle.seek(position)
                    continue
                if FUNCTION_NAME in line:
                    timestamps.append(time.monotonic())
                    if len(timestamps) >= cfg.min_samples:
                        break
    except OSError as exc:
        return MonitoringOutcome(False, f"Failed to read log file: {exc}", [])

    if len(timestamps) < cfg.min_samples:
        return MonitoringOutcome(
            False,
            (
                f"Observed only {len(timestamps)} occurrences of {FUNCTION_NAME} in "
                f"{cfg.monitor_duration:.1f}s (required: {cfg.min_samples})."
            ),
            [],
        )

    intervals = compute_intervals(timestamps)
    deviations = [abs(delta - expected_interval) for delta in intervals]

    if any(dev > cfg.tolerance for dev in deviations):
        details = (
            f"Intervals {intervals} deviate from expected {expected_interval:.2f}s "
            f"beyond tolerance ±{cfg.tolerance:.2f}s"
        )
        return MonitoringOutcome(False, details, intervals)

    return MonitoringOutcome(
        True,
        (
            f"Observed {len(intervals)} intervals averaging {sum(intervals)/len(intervals):.2f}s, "
            f"matching expected {expected_interval:.2f}s within ±{cfg.tolerance:.2f}s"
        ),
        intervals,
    )


def main(argv: Iterable[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else list(argv)
    cfg = parse_args(argv)

    outcome = monitor_function_calls(cfg)
    print(outcome.message)
    return 0 if outcome.passed else 1


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    raise SystemExit(main())
