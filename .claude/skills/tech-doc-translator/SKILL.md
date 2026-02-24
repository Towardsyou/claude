---
name: tech-doc-translator
description: 计算机技术文档翻译工具，将英文技术文档翻译为中文。翻译原则：专有名词保持英文（如 Python、Docker、API、REST、Kubernetes 等），描述和解释性内容使用中文。当用户需要翻译 README、API 文档、技术博客、教程或任何技术文档时使用此 skill。
---

# 技术文档翻译

## 翻译原则

### 核心规则

1. **专有名词保持英文** - 技术术语、产品名称、框架、工具等保持原文
2. **描述性内容使用中文** - 解释、说明、叙述性文字翻译为中文
3. **代码块保持不变** - 代码、命令、配置示例完全不翻译
4. **保持原文结构** - 段落、列表、标题层级保持一致

### 专有名词判断标准

保持以下类型词汇为英文：

| 类型 | 示例 |
|------|------|
| 编程语言 | Python, Go, TypeScript, Rust |
| 框架库 | React, Vue, Django, Spring Boot |
| 云平台 | AWS, Azure, GCP, Docker, Kubernetes |
| 数据库 | MySQL, PostgreSQL, MongoDB, Redis |
| 技术概念 | API, REST, GraphQL, Promise, Async/Await |
| 工具 | Git, kubectl, Docker, Jenkins |
| 协议 | HTTP, WebSocket, TCP/IP, TLS |
| 格式 | JSON, YAML, XML, CSV |

完整术语列表见 [technical_terms.md](references/technical_terms.md)

## 翻译示例

### 示例 1：框架介绍

**原文:**
> React is a JavaScript library for building user interfaces. It lets you compose complex UIs from small and isolated pieces of code called "components".

**译文:**
> React 是一个用于构建用户界面的 JavaScript 库。它让你可以使用名为 "component" 的小而独立的代码片段组合复杂的 UI。

### 示例 2：API 文档

**原文:**
> The `GET /api/users/{id}` endpoint returns a user object. The `id` parameter is required.

**译文:**
> `GET /api/users/{id}` 端点返回一个 user 对象。`id` 参数是必需的。

### 示例 3：操作指南

**原文:**
> To deploy your application, use `kubectl apply -f deployment.yaml`. This creates a Deployment in the Kubernetes cluster.

**译文:**
> 要部署你的应用，使用 `kubectl apply -f deployment.yaml`。这会在 Kubernetes 集群中创建一个 Deployment。

## 特殊场景处理

### 代码块

代码块内容完全不翻译，包括代码中的注释（除非用户明确要求翻译注释）：

```
## 保持原样

```python
# Fetch user data from API
response = requests.get('/api/users')
```
```

### 命令行指令

命令和参数保持原样：

```bash
npm install react
kubectl get pods -n default
docker build -t myapp:latest .
```

### API 路径和参数

```
保持原样：
- POST /api/v1/users
- Query parameter: `?page=1&limit=10`
- Path parameter: `/users/{userId}`
```

### 混合场景

当专有名词作为主语或宾语时，直接使用：

- "使用 Docker 可以快速部署应用"
- "调用 API 获取用户数据"
- "在 Kubernetes 中创建 Deployment"

## 输出格式

翻译结果保持：

1. 原文段落结构
2. 代码块格式和语法高亮标记
3. 列表层级（无序/有序列表）
4. 链接和引用格式
5. Markdown 语法结构

## 注意事项

- 技术准确性优先于流畅性
- 不确定的专有名词保持英文
- 首次出现的术语可选择性添加简短中文说明
- 保持一致的翻译风格
- 代码示例绝不翻译
