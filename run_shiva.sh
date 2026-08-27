#!/bin/bash


#-------------------------------------------------------------------------------
# run_shiva.sh — one SLURM job for one subject batch.
#
# Writes original SHiVAi output (main_workflow/ + results/) to:
#   shiva_runs/<PREDICTION>_<BRAIN_SEG>_<DATE>/<batch>/
# so parallel jobs do not share a Nipype workdir, but every batch of the
# same run sits under one named folder.
#
# After all batches finish, collect PDFs:
#   ./collect_reports.sh CMB_shiva_2026-08-18
#
# Usage:
#   sbatch run_shiva.sh shivai_symlinks/CMB_shiva/batch_001 CMB shiva CMB_shiva_2026-08-18
#   ./submit_batches.sh CMB shiva
#   ./submit_batches.sh CMB fs_precomp
#-------------------------------------------------------------------------------


#SBATCH --job-name=shivai
#SBATCH --partition=short
#SBATCH --cpus-per-task=10
#SBATCH --mem=70G
#SBATCH --time=3:00:00
#SBATCH --account=atayeva
#SBATCH --output=logs/output_logs/%x_%j.out
#SBATCH --error=logs/error_logs/%x_%j.err


set -euo pipefail

PROJECT_ROOT="/data/pt_life/ResearchProjects/Sheker/SHiVAi_master"

mv "$PROJECT_ROOT"/crash-*.pklz "$PROJECT_ROOT/crashes/" 2>/dev/null || true

if [[ $# -lt 1 ]]; then
    echo "Usage: sbatch run_shiva.sh <batch_dir> [PREDICTION] [BRAIN_SEG] [RUN_ID]" >&2
    echo "  e.g. sbatch run_shiva.sh shivai_symlinks/CMB_shiva/batch_001 CMB shiva CMB_shiva_2026-08-18" >&2
    exit 1
fi

BATCH_DIR="$1"
BATCH_NAME=$(basename "$BATCH_DIR")
PREDICTION="${2:-WMH}"
BRAIN_SEG="${3:-fs_precomp}"
RUN_ID="${4:-${PREDICTION}_${BRAIN_SEG}_$(date +%Y-%m-%d)}"
OUT_DIR="shiva_runs/${RUN_ID}/${BATCH_NAME}"

mkdir -p logs/output_logs logs/error_logs crashes "shiva_runs/${RUN_ID}"

source /data/u_atayeva_software/conda/etc/profile.d/conda.sh
conda activate shivai

shiva --in "$BATCH_DIR" \
      --out "$OUT_DIR" \
      --input_type BIDS \
      --brain_seg "$BRAIN_SEG" \
      --prediction "$PREDICTION" \
      --config "$PROJECT_ROOT/config_example.yml" \
      --run_plugin MultiProc \
      --containerized_nodes
