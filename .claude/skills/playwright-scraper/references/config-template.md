# Playwright 抓取配置模板

## 完整配置示例

```yaml
# 基础配置
url: "https://example.com"
timeout: 30000  # 毫秒

# 浏览器配置
browser:
  type: chromium  # chromium | firefox | webkit
  headless: true
  viewport:
    width: 1920
    height: 1080
  user_agent: "Custom User Agent String"

# 插件配置（支持 crx 文件或解压后的目录）
plugins:
  - /absolute/path/to/extension.crx
  - /absolute/path/to/unpacked-extension

# 或者单个插件
plugin_path: /absolute/path/to/plugin.crx

# 代理配置
proxy:
  server: "http://proxy.example.com:8080"
  username: "user"
  password: "pass"

# 认证配置
auth:
  type: cookie  # cookie | form | oauth
  cookies:
    - name: "session"
      value: "xxx"
      domain: ".example.com"
  form:
    login_url: "https://example.com/login"
    username: "user@example.com"
    password: "password"
    username_selector: "#email"
    password_selector: "#pass"
    submit_selector: "button[type='submit']"

# 抓取配置
scrape:
  # 列表抓取
  list:
    selector: ".item-container"
    fields:
      - name: title
        selector: ".title"
        type: text
      - name: url
        selector: "a"
        type: attribute
        attribute: href
      - name: price
        selector: ".price"
        type: text
        transform: "float"  # string | int | float | clean

  # 等待配置
  wait:
    selector: ".content-loaded"
    timeout: 10000

  # 分页配置
  pagination:
    next_selector: "a.next-page"
    max_pages: 5

# 输出配置
output:
  format: json  # json | csv | markdown
  file: "./output/result.json"
  pretty: true
```

## 场景配置

### 场景一：简单静态页面

```yaml
url: "https://blog.example.com"
browser:
  headless: true
scrape:
  list:
    selector: "article.post"
    fields:
      - name: title
        selector: "h2"
        type: text
      - name: summary
        selector: ".summary"
        type: text
      - name: link
        selector: "a"
        type: attribute
        attribute: href
```

### 场景二：需要登录的页面

```yaml
url: "https://app.example.com/dashboard"
auth:
  type: form
  form:
    login_url: "https://app.example.com/login"
    username_selector: "#username"
    password_selector: "#password"
    submit_selector: "#login-button"
    username: "${USERNAME}"  # 环境变量
    password: "${PASSWORD}"
scrape:
  list:
    selector: ".data-row"
    fields:
      - name: id
        selector: "[data-id]"
        type: attribute
        attribute: data-id
      - name: name
        selector: ".name"
        type: text
      - name: status
        selector: ".status"
        type: text
```

### 场景三：使用插件

```yaml
url: "https://example.com"
plugin_path: "/Users/name/extensions/adblock.crx"
browser:
  headless: false  # 某些插件可能需要非无头模式
scrape:
  list:
    selector: ".content"
    fields:
      - name: text
        selector: "p"
        type: text
```

### 场景四：多步骤流程

```yaml
steps:
  - name: "访问首页"
    action: goto
    url: "https://example.com"

  - name: "点击搜索"
    action: click
    selector: "#search-button"

  - name: "输入关键词"
    action: fill
    selector: "#search-input"
    value: "搜索内容"

  - name: "提交搜索"
    action: click
    selector: "button[type='submit']"

  - name: "等待结果"
    action: wait
    selector: ".search-results"

  - name: "抓取结果"
    action: scrape
    selector: ".result-item"
    fields:
      - name: title
        selector: ".title"
        type: text
      - name: url
        selector: "a"
        type: attribute
        attribute: href
```

### 场景五：处理动态加载

```yaml
url: "https://example.com/infinite-scroll"
scrape:
  list:
    selector: ".item"
    fields:
      - name: title
        selector: ".title"
        type: text

  # 滚动加载更多
  scroll:
    selector: ".load-more-trigger"
    max_scrolls: 5
    wait_between: 1000  # 毫秒

  # 或点击加载更多
  pagination:
    next_selector: "button.load-more"
    max_pages: 10
```

## 环境变量

```bash
# 在配置中可以使用环境变量
export USERNAME="your_username"
export PASSWORD="your_password"
export PROXY_URL="http://proxy:8080"

# 配置中使用
username: "${USERNAME}"
password: "${PASSWORD}"
proxy:
  server: "${PROXY_URL}"
```

## 选择器类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `css` | CSS 选择器（默认） | `.class` `#id` `[attr]` |
| `xpath` | XPath 表达式 | `//div[@class='item']` |
| `text` | 文本匹配 | `text='按钮'` |
| `data-*` | 数据属性 | `[data-id]` |

## 数据转换

| 转换类型 | 说明 | 示例 |
|---------|------|------|
| `text` | 纯文本 | `"Hello World"` |
| `int` | 整数 | `123` |
| `float` | 浮点数 | `123.45` |
| `clean` | 清理空白 | `"hello world"` |
| `url` | 完整 URL | `https://example.com/path` |
| `date` | 日期解析 | `2024-01-01` |
