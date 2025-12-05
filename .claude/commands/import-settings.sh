#!/bin/bash

# 导入项目设置到用户Claude配置的脚本
# 用于 /import-settings 命令

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 项目根目录（脚本所在位置的父目录的父目录）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# 用户Claude配置目录
USER_CLAUDE_CONFIG="$HOME/.config/claude-code"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查项目设置是否存在
check_project_settings() {
    log_info "检查项目设置..."

    if [[ ! -d "$CLAUDE_DIR" ]]; then
        log_error "项目.claude目录不存在: $CLAUDE_DIR"
        exit 1
    fi

    if [[ ! -f "$CLAUDE_DIR/settings.local.json" ]]; then
        log_warn "项目中未找到settings.local.json"
    fi

    if [[ ! -d "$CLAUDE_DIR/agents" ]]; then
        log_warn "项目中未找到agents目录"
    fi

    if [[ ! -d "$CLAUDE_DIR/skills" ]]; then
        log_warn "项目中未找到skills目录"
    fi

    log_info "项目设置检查完成"
}

# 备份用户现有设置
backup_user_settings() {
    if [[ -d "$USER_CLAUDE_CONFIG" ]]; then
        BACKUP_DIR="$USER_CLAUDE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "备份现有用户设置到: $BACKUP_DIR"
        cp -r "$USER_CLAUDE_CONFIG" "$BACKUP_DIR"
    fi
}

# 创建用户配置目录
create_user_config_dirs() {
    log_info "创建用户配置目录..."
    mkdir -p "$USER_CLAUDE_CONFIG/agents"
    mkdir -p "$USER_CLAUDE_CONFIG/skills"
    mkdir -p "$USER_CLAUDE_CONFIG/commands"
}

# 导入agents
import_agents() {
    if [[ -d "$CLAUDE_DIR/agents" ]]; then
        log_info "导入agents..."
        cp -r "$CLAUDE_DIR/agents/"* "$USER_CLAUDE_CONFIG/agents/"
        log_info "agents导入完成"
    else
        log_warn "跳过agents导入（目录不存在）"
    fi
}

# 导入skills
import_skills() {
    if [[ -d "$CLAUDE_DIR/skills" ]]; then
        log_info "导入skills..."
        cp -r "$CLAUDE_DIR/skills/"* "$USER_CLAUDE_CONFIG/skills/"
        log_info "skills导入完成"
    else
        log_warn "跳过skills导入（目录不存在）"
    fi
}

# 导入settings
import_settings() {
    if [[ -f "$CLAUDE_DIR/settings.local.json" ]]; then
        log_info "导入settings.local.json..."
        cp "$CLAUDE_DIR/settings.local.json" "$USER_CLAUDE_CONFIG/"
        log_info "settings导入完成"
    else
        log_warn "跳过settings导入（文件不存在）"
    fi
}

# 导入commands
import_commands() {
    if [[ -d "$CLAUDE_DIR/commands" ]]; then
        log_info "导入commands..."
        cp -r "$CLAUDE_DIR/commands/"* "$USER_CLAUDE_CONFIG/commands/"
        log_info "commands导入完成"
    else
        log_warn "跳过commands导入（目录不存在）"
    fi
}

# 验证导入
verify_import() {
    log_info "验证导入结果..."

    local success=true

    if [[ -f "$CLAUDE_DIR/settings.local.json" ]] && [[ ! -f "$USER_CLAUDE_CONFIG/settings.local.json" ]]; then
        log_error "settings.local.json导入失败"
        success=false
    fi

    if [[ -d "$CLAUDE_DIR/agents" ]] && [[ ! -d "$USER_CLAUDE_CONFIG/agents" ]] || [[ -z "$(ls -A "$USER_CLAUDE_CONFIG/agents" 2>/dev/null)" ]]; then
        log_error "agents导入失败"
        success=false
    fi

    if [[ -d "$CLAUDE_DIR/skills" ]] && [[ ! -d "$USER_CLAUDE_CONFIG/skills" ]] || [[ -z "$(ls -A "$USER_CLAUDE_CONFIG/skills" 2>/dev/null)" ]]; then
        log_error "skills导入失败"
        success=false
    fi

    if $success; then
        log_info "✅ 所有设置导入成功！"
        log_info "用户配置目录: $USER_CLAUDE_CONFIG"
    else
        log_error "❌ 导入过程中出现错误"
        exit 1
    fi
}

# 主函数
main() {
    log_info "开始导入项目设置到用户配置..."
    log_info "项目根目录: $PROJECT_ROOT"
    log_info "用户配置目录: $USER_CLAUDE_CONFIG"

    check_project_settings
    backup_user_settings
    create_user_config_dirs
    import_agents
    import_skills
    import_settings
    import_commands
    verify_import

    log_info "🎉 设置导入完成！重启Claude Code以使用新的配置。"
}

# 执行主函数
main "$@"