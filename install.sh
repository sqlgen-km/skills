#!/usr/bin/env bash
#
# install.sh — 将 sqlgen-dev 技能安装到不同的 agent 系统
#
# 源技能：本脚本同目录下的 sqlgen-dev/（SKILL.md + references/ + templates/）
# 用法：
#   ./install.sh [hermes|claude|all]    安装（默认 all）
#   ./install.sh --uninstall [target]   卸载
#   ./install.sh --list                 列出各 agent 安装状态
#   ./install.sh --dry-run [target]     只预览不执行
#
set -euo pipefail

# ── 定位脚本与源技能目录 ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/sqlgen-dev"

# ── agent 注册表（追加新 agent 系统：在此加一行 + 在 ALL_TARGETS 加名字）─
# 目标目录可用环境变量覆盖，例如 HERMES_DIR=/path/to/skill
declare -A INSTALL_DIR=(
  [hermes]="${HERMES_DIR:-$HOME/.hermes/skills/software-development/sqlgen-dev}"
  [claude]="${CLAUDE_DIR:-$HOME/.claude/skills/sqlgen-dev}"
)
ALL_TARGETS=(hermes claude)

# ── 工具函数 ────────────────────────────────────────────────────────────
die() { echo "❌ $*" >&2; exit 1; }
info() { echo "$*"; }

usage() {
  cat <<'EOF'
用法: install.sh [target] [选项]

将 sqlgen-dev 技能安装到指定 agent 系统。

target（可选，默认 all）:
  hermes   安装到 Hermes Agent（~/.hermes/skills/software-development/sqlgen-dev/）
  claude   安装到 Claude Code（~/.claude/skills/sqlgen-dev/）
  all      安装到全部（默认）

选项:
  -u, --uninstall  卸载（移除目标目录）
  -l, --list       列出各 agent 的安装状态
  -n, --dry-run    只预览，不实际执行
  -h, --help       显示本帮助
EOF
}

# 解析 target 参数，返回以空格分隔的目标列表
resolve_targets() {
  local t="$1"
  case "$t" in
    all)  printf '%s\n' "${ALL_TARGETS[@]}" ;;
    hermes|claude) printf '%s\n' "$t" ;;
    *) die "未知 target '$t'，可用: hermes | claude | all" ;;
  esac
}

installed_marker() {  # 输出目标目录是否已安装
  [ -f "$1/SKILL.md" ] && echo "已安装" || echo "未安装"
}

# ── 动作实现 ────────────────────────────────────────────────────────────
do_install() {
  local target="$1" dest="${INSTALL_DIR[$target]}"
  [ -f "$SKILL_SRC/SKILL.md" ] || die "源技能缺失: $SKILL_SRC/SKILL.md"
  if [ "$DRY_RUN" = true ]; then
    info "[dry-run] 安装 $target → $dest"
    return 0
  fi
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -r "$SKILL_SRC" "$dest"
  info "✅ 已安装 $target → $dest"
}

do_uninstall() {
  local target="$1" dest="${INSTALL_DIR[$target]}"
  if [ "$DRY_RUN" = true ]; then
    info "[dry-run] 卸载 $target（移除 $dest）"
    return 0
  fi
  if [ -e "$dest" ]; then
    rm -rf "$dest"
    info "🗑  已卸载 $target（$dest）"
  else
    info "·  $target 未安装，跳过（$dest）"
  fi
}

do_list() {
  info "sqlgen-dev 安装状态："
  for target in "${ALL_TARGETS[@]}"; do
    local dest="${INSTALL_DIR[$target]}"
    printf "  %-7s %-10s %s\n" "$target" "$(installed_marker "$dest")" "$dest"
  done
}

# ── 参数解析 ────────────────────────────────────────────────────────────
ACTION=install
DRY_RUN=false
TARGET_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--uninstall) ACTION=uninstall ;;
    -l|--list)      ACTION=list ;;
    -n|--dry-run)   DRY_RUN=true ;;
    -h|--help)      usage; exit 0 ;;
    -*)             die "未知选项 $1（见 --help）" ;;
    *)              [ -z "$TARGET_ARG" ] || die "多余参数: $1"; TARGET_ARG="$1" ;;
  esac
  shift
done

TARGET_ARG="${TARGET_ARG:-all}"

# ── 执行 ────────────────────────────────────────────────────────────────
case "$ACTION" in
  list)
    do_list
    ;;
  install|uninstall)
    mapfile -t targets < <(resolve_targets "$TARGET_ARG")
    for target in "${targets[@]}"; do
      if [ "$ACTION" = install ]; then do_install "$target"; else do_uninstall "$target"; fi
    done
    ;;
esac
