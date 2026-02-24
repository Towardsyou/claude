#!/usr/bin/env python3
"""
AI Chat 分享链接抓取脚本

支持平台：
- Claude.ai
- ChatGPT
- Gemini (需要登录)
- Qwen/通义千问 (可能有反爬限制)
- ChatGLM

使用方法:
    python fetch_chat.py <share-url>
"""

import sys
import re
import json
import argparse
from urllib.parse import urlparse
from datetime import datetime


def detect_platform(url):
    """根据 URL 检测平台"""
    host = urlparse(url).netloc.lower()

    platform_map = {
        'claude.ai': 'claude',
        'chatgpt.com': 'chatgpt',
        'gemini.google.com': 'gemini',
        'qianwen.com': 'qwen',
        'qianwen.aliyun.com': 'qwen',
        'chatglm.cn': 'chatglm',
    }

    for domain, platform in platform_map.items():
        if domain in host:
            return platform

    return 'unknown'


def print_usage_instruction(platform, url):
    """打印手动获取指南"""
    instructions = {
        'claude': f"""
Claude.ai 分享链接抓取指南:

1. 访问链接: {url}
2. 如果需要登录，请先登录 Claude.ai
3. 完整复制对话内容
4. 将内容粘贴回来供分析

或者使用 MCP web-reader 工具直接抓取。
""",

        'chatgpt': f"""
ChatGPT 分享链接抓取指南:

1. 访问链接: {url}
2. 如果需要登录，请先登录 ChatGPT
3. 完整复制对话内容
4. 将内容粘贴回来供分析

或者使用 MCP web-reader 工具直接抓取。
""",

        'gemini': f"""
Gemini 分享链接抓取指南:

Gemini 分享链接需要登录才能查看完整内容。

请按以下步骤操作：
1. 访问链接: {url}
2. 登录你的 Google 账号
3. 完整复制对话内容
4. 将内容粘贴回来供分析

或者使用 playwright-scraper skill 进行自动化抓取。
""",

        'qwen': f"""
Qwen (通义千问) 分享链接抓取指南:

Qwen 可能有反爬限制。

请按以下步骤操作：
1. 访问链接: {url}
2. 登录你的阿里云账号
3. 完整复制对话内容
4. 将内容粘贴回来供分析

或者使用 playwright-scraper skill 进行自动化抓取。
""",

        'chatglm': f"""
ChatGLM 分享链接可以直接抓取:

链接: {url}

使用 MCP web-reader 工具可直接获取内容。
""",
    }

    return instructions.get(platform, f"未知平台，请访问 {url} 并复制内容")


def main():
    parser = argparse.ArgumentParser(description='抓取 AI Chat 分享链接内容')
    parser.add_argument('url', help='分享链接 URL')
    parser.add_argument('--raw', action='store_true', help='仅输出原始 URL')
    args = parser.parse_args()

    url = args.url
    platform = detect_platform(url)

    if args.raw:
        print(url)
        return 0

    print(f"检测到平台: {platform.upper()}", file=sys.stderr)
    print(f"分享链接: {url}", file=sys.stderr)
    print(file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print(print_usage_instruction(platform, url), file=sys.stderr)

    # 输出 JSON 格式供程序解析
    output = {
        "platform": platform,
        "url": url,
        "timestamp": datetime.now().isoformat(),
        "status": "manual_fetch_required" if platform in ['gemini', 'qwen'] else "auto_fetch_possible"
    }

    print("\n" + "=" * 60, file=sys.stderr)
    print("JSON 输出 (供程序使用):", file=sys.stderr)
    print(json.dumps(output, ensure_ascii=False))

    return 0


if __name__ == '__main__':
    sys.exit(main())
