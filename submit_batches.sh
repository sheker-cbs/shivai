#!/bin/bash
#
# Submit one SLURM job per batch_* under
#   shivai_symlinks/<PREDICTION>_<BRAIN_SEG>/
# All jobs of this invocation share one run folder:
#   shiva_runs/<PREDICTION>_<BRAIN_SEG>_<DATE>/
#
#   ./submit_batches.sh                       # CMB + shiva + today
#   ./submit_batches.sh CMB shiva
#   ./submit_batches.sh CMB fs_precomp        # FreeSurfer aparc+aseg
#   ./submit_batches.sh WMH shiva 2026-09-01
#
# After jobs finish:
#   ./collect_reports.sh CMB_shiva_2026-08-18
#   ./collect_reports.sh CMB_fs_precomp_2026-08-18

set -euo pipefail

PREDICTION="${1:-WMH}"
BRAIN_SEG="${2:-fs_precomp}"
DATE="${3:-$(date +%Y-%m-%d)}"
RUN_ID="${PREDICTION}_${BRAIN_SEG}_${DATE}"
SYMLINKS_DIR="shivai_symlinks/${PREDICTION}_${BRAIN_SEG}"

if [[ ! -d "$SYMLINKS_DIR" ]]; then
    echo "No input tree at $SYMLINKS_DIR" >&2
    echo "Set PREDICTIONS/BRAIN_SEG in shiva_symlinks.py to match, then: python shiva_symlinks.py" >&2
    exit 1
fi

shopt -s nullglob
batch_dirs=("$SYMLINKS_DIR"/batch_*)
if [[ ${#batch_dirs[@]} -eq 0 ]]; then
    echo "No batch_* folders under $SYMLINKS_DIR" >&2
    exit 1
fi

mkdir -p "shiva_runs/${RUN_ID}"
cat > "shiva_runs/${RUN_ID}/run.json" <<EOF
# {
#   "run_id": "${RUN_ID}",
#   "prediction": "${PREDICTION}",
#   "brain_seg": "${BRAIN_SEG}",
#   "date": "${DATE}",
#   "in": "${SYMLINKS_DIR}",
#   "out": "shiva_runs/${RUN_ID}"
# }
EOF
echo "Run folder: shiva_runs/${RUN_ID}"

for batch_dir in "${batch_dirs[@]}"; do
    if [[ -d "$batch_dir" ]]; then
        batch_name=$(basename "$batch_dir")
        echo "Submitting $batch_dir -> shiva_runs/${RUN_ID}/${batch_name}"
        sbatch --job-name="shivai_${RUN_ID}_${batch_name}" \
               run_shiva.sh "$batch_dir" "$PREDICTION" "$BRAIN_SEG" "$RUN_ID"
    fi
done
