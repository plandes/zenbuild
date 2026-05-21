#!/usr/bin/env bash
set -euo pipefail

die() {
    echo "arxiv-fix error: $*" >&2
    exit 1
}

warn() {
    echo "arxiv-fix warning: $*" >&2
}

log() {
    echo "arxiv-fix: $*" >&2
}

export_dir=""
tex=""
tex_latex_file=""
bib_file=""
bbl_file=""
biber=""
export_zip=""
export_zip_dir=""
export_inst_zip=""

while (($#)); do
    case "$1" in
        --export-dir)
            export_dir="$2"; shift 2 ;;
        --tex)
            tex="$2"; shift 2 ;;
        --tex-latex-file)
            tex_latex_file="$2"; shift 2 ;;
        --bib-file)
            bib_file="$2"; shift 2 ;;
        --bbl-file)
            bbl_file="$2"; shift 2 ;;
        --biber)
            biber="$2"; shift 2 ;;
        --export-zip)
            export_zip="$2"; shift 2 ;;
        --export-zip-dir)
            export_zip_dir="$2"; shift 2 ;;
        --export-inst-zip)
            export_inst_zip="$2"; shift 2 ;;
        -h|--help)
            cat >&2 <<EOF
usage: $0 --export-dir DIR --tex ROOT_BASENAME [options]

Required:
  --export-dir DIR
  --tex ROOT_BASENAME

Optional:
  --tex-latex-file FILE
  --bib-file FILE
  --bbl-file FILE
  --biber CMD
  --export-zip FILE
  --export-zip-dir DIR
  --export-inst-zip FILE
EOF
            exit 0 ;;
        *)
            die "unknown argument: $1" ;;
    esac
done

[[ -n "$export_dir" ]] || die "--export-dir is required"
[[ -n "$tex" ]] || die "--tex is required"
[[ -d "$export_dir" ]] || die "export directory not found: $export_dir"

cd "$export_dir"

root_tex="${tex}.tex"

[[ -f "$root_tex" ]] || die "root tex not found: $root_tex"

log "export dir: $(pwd)"
log "root tex:   $root_tex"
log "bib file:   ${bib_file:-<unset>}"
log "bbl file:   ${bbl_file:-<unset>}"

# ----------------------------------------------------------------------
# Keep original bibliography names.
#
# Do not rename .bib or .bbl. The exported root file remains $(TEX).tex, so
# the aux file and bibdata command stay consistent with the original project.
# ----------------------------------------------------------------------

if [[ -n "$bib_file" ]]; then
    bib_name="$(basename "$bib_file")"
    if [[ ! -f "$bib_name" ]]; then
        warn "expected bib file not found in export dir: $bib_name"
    fi
fi

if [[ -n "$bbl_file" ]]; then
    bbl_name="$(basename "$bbl_file")"
    if [[ ! -f "$bbl_name" ]]; then
        warn "expected bbl file not found in export dir: $bbl_name"
    fi
fi

# ----------------------------------------------------------------------
# Patch zledu.sty only: remove dormant biblatex support that arXiv detects.

# Replace the whole biblatex helper macro with a no-op so braces stay balanced.
# ----------------------------------------------------------------------
if [[ -f "zledu.sty" ]]; then
    python3 - <<'PY'
from pathlib import Path

path = Path("zledu.sty")
text = path.read_text()

start = text.find(r"\newcommand{\zenatlibinit}")
if start != -1:
    # The next macro after zenatlibinit in this file.
    end = text.find(r"\newcommand{\zenatlibsetup}", start)
    if end == -1:
        raise SystemExit("Could not find end marker \\newcommand{\\zenatlibsetup} in zledu.sty")

    replacement = (
        "% arxiv-fix: disabled dormant biblatex support\n"
        "\\newcommand{\\zenatlibinit}[2][]{%\n"
        "  % no-op for arXiv export\n"
        "}\n\n"
    )
    text = text[:start] + replacement + text[end:]

path.write_text(text)
PY
    echo "arxiv-fix: replaced dormant zenatlibinit macro in zledu.sty" >&2
fi

# ----------------------------------------------------------------------
# Remove temp/editor files.
# ----------------------------------------------------------------------

find . -type f \( \
    -name '*.bak' -o \
    -name '*.bak-arxiv' -o \
    -name '*~' -o \
    -name '.DS_Store' \
\) -delete

log "complete"
