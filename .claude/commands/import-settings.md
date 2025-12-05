# 导入项目设置到用户配置

导入当前项目的agents、skills和settings到用户的Claude配置目录。

## 使用方法

```bash
/import-settings
```

## 功能

- 复制项目中的agents到 `~/.config/claude-code/agents/`
- 复制项目中的skills到 `~/.config/claude-code/skills/`
- 复制项目中的settings.local.json到 `~/.config/claude-code/settings.local.json`
- 保留用户原有的设置，会备份现有文件

## 实现步骤

1. 检查用户Claude配置目录是否存在
2. 备份用户现有设置（如果存在）
3. 创建必要的目录结构
4. 复制agents、skills和settings文件
5. 验证导入是否成功