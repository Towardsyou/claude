---
name: playwright-scraper
description: 使用 Playwright + browser-use 抓取网页内容的技能。支持配置浏览器插件路径、自定义选择器、等待元素、截图等高级功能。适用于动态网页、需要登录的页面、SPA 应用等复杂场景。当用户需要：(1) 抓取网页内容 (2) 自动化浏览器操作 (3) 提取结构化数据 (4) 网页截图 (5) 处理需要登录的页面时触发此技能。
examples:
  - "抓取 https://example.com 页面的所有文章标题"
  - "获取电商网站的产品信息并导出为 JSON"
  - "登录后抓取用户数据"
  - "截取网页完整截图"
  - "等待加载完成后提取数据"
---

# Playwright 网页抓取技能

## 概述

本技能提供基于 Playwright 的强大网页抓取能力，支持动态内容、JavaScript 渲染页面、需要登录的复杂场景。配合 browser-use 可实现更智能的页面理解和操作。

## 核心功能

### 1. 基础抓取
- 页面内容提取（文本、HTML、属性）
- 元素定位（CSS 选择器、XPath、文本匹配）
- 列表数据抓取
- 表格数据提取

### 2. 高级交互
- 点击、输入、滚动
- 等待元素出现/消失
- 处理弹窗、对话框
- 文件上传/下载
- 拖拽操作

### 3. 身份验证
- Cookie 登录
- 表单登录
- OAuth 处理
- Session 保持

### 4. 浏览器插件支持
- 支持加载自定义浏览器插件（.crx 或解压后的插件目录）
- 配置插件权限
- 插件状态管理

### 5. 数据导出
- JSON 格式
- CSV 格式
- Markdown 表格
- 自定义格式

## 配置说明

### 浏览器插件配置

使用自定义浏览器插件时，需要指定插件路径：

```yaml
# 配置方式一：解压后的插件目录
plugin_path: /path/to/unpacked-extension

# 配置方式二：CRX 文件路径（会自动解压）
plugin_path: /path/to/extension.crx

# 配置方式三：多个插件
plugins:
  - /path/to/extension1
  - /path/to/extension2
```

### 浏览器启动选项

```yaml
# 无头模式（默认 true）
headless: false

# 浏览器类型
browser: chromium  # chromium / firefox / webkit

# 视口大小
viewport:
  width: 1920
  height: 1080

# 用户代理
user_agent: "Custom User Agent"

# 代理设置
proxy:
  server: "http://proxy.example.com:8080"
  username: "user"
  password: "pass"
```

## 使用方法

### 方式一：快速抓取

提供 URL 和要提取的内容：

```bash
# 用户输入示例
"抓取 https://news.example.com 的所有新闻标题和链接"
```

输出：
```json
[
  {"title": "新闻标题1", "url": "https://..."},
  {"title": "新闻标题2", "url": "https://..."}
]
```

### 方式二：指定配置

提供详细的抓取配置：

```bash
# 用户输入示例
"使用以下配置抓取数据：
- URL: https://example.com/products
- 选择器: .product-item
- 提取字段: title, price, image
- 等待: .product-list 加载完成
- 插件: /path/to/adblock.crx"
```

### 方式三：复杂流程

多步骤抓取流程：

```bash
# 用户输入示例
"执行以下抓取任务：
1. 访问登录页面
2. 输入用户名和密码
3. 点击登录按钮
4. 等待跳转到首页
5. 抓取用户信息
6. 导出为 JSON"
```

## 输出格式

### JSON 格式（默认）

```json
{
  "url": "https://example.com",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": [
    {"field1": "value1", "field2": "value2"}
  ]
}
```

### CSV 格式

```csv
field1,field2
value1,value2
```

### Markdown 格式

```markdown
# 抓取结果

## 来源
URL: https://example.com
时间: 2024-01-01 00:00:00

## 数据
| field1 | field2 |
|--------|--------|
| value1 | value2 |
```

## 工作流程

### 1. 分析需求
- 理解用户要抓取的内容
- 确定目标 URL
- 分析页面结构

### 2. 制定策略
- 选择合适的定位方式
- 确定等待策略
- 规划交互步骤

### 3. 执行抓取
- 启动浏览器（加载插件）
- 执行页面操作
- 提取目标数据

### 4. 数据处理
- 数据清洗
- 格式转换
- 文件输出

## 常见选择器模式

```python
# CSS 选择器
css_selector = ".class-name"
css_selector = "#id-name"
css_selector = "[data-attr='value']"

# XPath
xpath = "//div[@class='item']"
xpath = "//a[contains(text(), '更多')]"

# 文本匹配
text = "按钮文字"

# 组合选择器
combined = ".item >> text='标题'"
```

## 注意事项

1. **反爬虫处理**：
   - 设置合理的请求间隔
   - 使用随机 User-Agent
   - 处理验证码（需要人工介入）

2. **性能优化**：
   - 无头模式性能更好
   - 关闭不必要的图片加载
   - 并发控制

3. **错误处理**：
   - 超时重试
   - 元素找不到的降级方案
   - 网络错误处理

4. **合规性**：
   - 遵守 robots.txt
   - 控制请求频率
   - 尊重网站服务条款

## 配置参考

详细配置模板请参考 `references/config-template.md`

## 代码示例

详细代码示例请参考 `references/code-examples.md`
