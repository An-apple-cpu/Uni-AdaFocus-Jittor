#!/usr/bin/env bash
# Read-only inventory. Usage: bash check_server.sh [persistent_data_dir] [required_free_bytes]
set -u

data_dir="${1:-}"
required_bytes="${2:-}"
printf 'detected_at_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'os='; if [[ -r /etc/os-release ]]; then . /etc/os-release; printf '%s %s\n' "${NAME:-unknown}" "${VERSION_ID:-unknown}"; else printf 'unknown\n'; fi
printf 'kernel='; uname -r
printf 'architecture='; uname -m
printf 'cpu_logical='; if command -v nproc >/dev/null 2>&1; then nproc; else printf 'unavailable\n'; fi
printf 'ram='; if command -v free >/dev/null 2>&1; then free -h; else printf 'unavailable\n'; fi
printf 'mounts_and_space=\n'; if command -v df >/dev/null 2>&1; then df -hT; else printf 'df unavailable\n'; fi

if command -v nvidia-smi >/dev/null 2>&1; then
  printf 'gpu_name,memory_total_mib,driver_version=\n'
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader || printf 'nvidia-smi query failed\n'
  printf 'driver_reported_cuda=\n'
  nvidia-smi | head -n 4 || printf 'nvidia-smi header unavailable\n'
else printf 'nvidia-smi=missing\n'; fi
if command -v nvcc >/dev/null 2>&1; then printf 'cuda_toolkit_nvcc=\n'; nvcc --version || printf 'nvcc query failed\n'; else printf 'cuda_toolkit_nvcc=missing (driver CUDA is not Toolkit)\n'; fi
for tool in python3 python pip3 pip conda gcc g++; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%s=' "$tool"
    case "$tool" in
      pip|pip3) "$tool" --version 2>&1 || true ;;
      *) "$tool" --version 2>&1 | head -n 1 || true ;;
    esac
  else printf '%s=missing\n' "$tool"; fi
done

if [[ -z "$data_dir" ]]; then
  printf 'persistent_data_dir=not supplied; confirm actual AutoDL mount before use\n'
elif [[ -d "$data_dir" ]]; then
  printf 'persistent_data_dir=exists: %s\n' "$data_dir"
  df -h "$data_dir" 2>/dev/null || printf 'data_dir_space=unavailable\n'
  if [[ -n "$required_bytes" ]]; then
    if [[ "$required_bytes" =~ ^[0-9]+$ ]]; then
      available=$(df -B1 --output=avail "$data_dir" 2>/dev/null | tail -n 1 | tr -d '[:space:]')
      if [[ "$available" =~ ^[0-9]+$ ]]; then
        printf 'required_free_bytes=%s available_bytes=%s\n' "$required_bytes" "$available"
        if (( available >= required_bytes )); then printf 'space_check=meets supplied estimate\n'; else printf 'space_check=below supplied estimate\n'; fi
      else printf 'space_check=unable to measure\n'; fi
    else printf 'space_check=invalid required_free_bytes; supply nonnegative integer\n'; fi
  else printf 'space_check=no requirement supplied; estimate data, weights, outputs, and temporary peak first\n'; fi
else printf 'persistent_data_dir=missing or not a directory: %s\n' "$data_dir"; fi

if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'project_git_sha='; git rev-parse HEAD 2>/dev/null || printf 'no commit yet\n'
else printf 'project_git_sha=unavailable (run from project checkout)\n'; fi
