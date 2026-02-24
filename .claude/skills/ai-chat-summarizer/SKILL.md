---
name: ai-chat-summarizer
description: 从 AI 对话分享链接抓取并总结知识点，保存到项目的 /docs/daily 文件夹。支持 Claude.ai、ChatGPT、Gemini、Qwen（通义千问）、ChatGLM（智谱清言）等平台的分享链接。当用户需要：(1) 抓取 AI 对话内容 (2) 总结对话中的知识点 (3) 将知识点整理归档到文档时触发此技能。
---

# AI Chat Summarizer

## Overview

从各 AI 平台的分享链接中抓取对话内容，智能提取并总结知识点，按固定格式保存到项目文档目录。

## 支持平台

| 平台 | URL 格式 |
|------|----------|
| Claude.ai | `https://claude.ai/share/...` |
| ChatGPT | `https://chatgpt.com/share/...` |
| Gemini | `https://gemini.google.com/share/...` |
| Qwen | `https://www.qianwen.com/share/...` 或 `https://qianwen.aliyun.com/share/...` |
| ChatGLM | `https://chatglm.cn/share/...` |

## Workflow

### Step 1: 抓取内容

使用 `scripts/fetch_chat.py` 脚本抓取分享链接内容：

```bash
python scripts/fetch_chat.py <share-url>
```

脚本会自动识别平台并返回纯文本格式的对话内容。

### Step 2: 提取知识点

分析抓取的内容，提取核心知识点。遵循以下原则：

1. **概述部分**：使用 bullet point 列出主要知识点，最多三层嵌套
2. **详细部分**：对概述中需要深入解释的内容展开说明
3. **使用列表层级表示内容结构**，避免使用 ## ### 等多级标题

### Step 3: 生成文档

将知识点保存到 `/docs/daily/{YYYY-MM-DD}.md`：

```
/docs/daily/2026-01-25.md
```

如果 `/docs/daily` 目录不存在，自动创建。

## 输出格式

参考 [references/format.md](references/format.md) 中的格式规范。

## Resources

- **scripts/**: `fetch_chat.py` - 多平台对话抓取脚本
- **references/**: `format.md` - 输出格式模板
