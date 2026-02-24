# Playwright 抓取代码示例

## 基础示例

### 1. 简单页面抓取

```python
from playwright.sync_api import sync_playwright
import json

def scrape_simple():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto("https://example.com")
        page.wait_for_selector(".content")

        items = page.query_selector_all(".item")
        results = []

        for item in items:
            title = item.query_selector(".title").text_content()
            link = item.query_selector("a").get_attribute("href")
            results.append({"title": title, "url": link})

        browser.close()
        return results

# 输出
print(json.dumps(scrape_simple(), ensure_ascii=False, indent=2))
```

### 2. 加载浏览器插件

```python
from playwright.sync_api import sync_playwright
import zipfile
import tempfile
import os
import shutil

def extract_crx_if_needed(crx_path):
    """如果路径是 .crx 文件，解压到临时目录"""
    if crx_path.endswith('.crx'):
        temp_dir = tempfile.mkdtemp()
        with zipfile.ZipFile(crx_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        return temp_dir
    return crx_path

def scrape_with_plugin(plugin_path):
    with sync_playwright() as p:
        # 处理 crx 文件
        extension_path = extract_crx_if_needed(plugin_path)

        browser = p.chromium.launch(
            headless=False,  # 插件可能需要非无头模式
            args=[
                f"--disable-extensions-except={extension_path}",
                f"--load-extension={extension_path}"
            ]
        )

        # 创建带上下文的页面
        context = browser.new_context()
        page = context.new_page()

        page.goto("https://example.com")
        content = page.text_content("body")

        browser.close()

        # 清理临时目录
        if extension_path != plugin_path:
            shutil.rmtree(extension_path)

        return content

# 使用
plugin_path = "/path/to/your/extension.crx"
# 或者解压后的插件目录
# plugin_path = "/path/to/unpacked-extension"
print(scrape_with_plugin(plugin_path))
```

### 3. 带认证的抓取

```python
from playwright.sync_api import sync_playwright
import json

def scrape_with_login():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()

        # 方式一：使用 Cookie
        context.add_cookies([
            {
                "name": "session",
                "value": "your_session_token",
                "domain": ".example.com",
                "path": "/",
            }
        ])

        page = context.new_page()
        page.goto("https://example.com/dashboard")

        # 方式二：表单登录
        # page.goto("https://example.com/login")
        # page.fill("#username", "your_username")
        # page.fill("#password", "your_password")
        # page.click("button[type='submit']")
        # page.wait_for_url("**/dashboard")

        # 抓取数据
        data = page.query_selector_all(".data-row")
        results = []

        for row in data:
            results.append({
                "id": row.get_attribute("data-id"),
                "name": row.query_selector(".name").text_content(),
                "value": row.query_selector(".value").text_content(),
            })

        browser.close()
        return results

print(json.dumps(scrape_with_login(), ensure_ascii=False, indent=2))
```

### 4. 处理分页

```python
from playwright.sync_api import sync_playwright
import json
import time

def scrape_with_pagination(max_pages=5):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto("https://example.com/list")
        all_results = []

        for page_num in range(max_pages):
            # 等待内容加载
            page.wait_for_selector(".item")

            # 抓取当前页
            items = page.query_selector_all(".item")
            for item in items:
                all_results.append({
                    "title": item.query_selector(".title").text_content(),
                    "price": item.query_selector(".price").text_content(),
                })

            # 点击下一页
            next_button = page.query_selector("a.next-page:not(.disabled)")
            if not next_button:
                break

            next_button.click()
            time.sleep(1)  # 等待加载

        browser.close()
        return all_results

print(json.dumps(scrape_with_pagination(), ensure_ascii=False, indent=2))
```

### 5. 滚动加载更多

```python
from playwright.sync_api import sync_playwright
import json
import time

def scrape_infinite_scroll():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto("https://example.com/feed")
        page.wait_for_selector(".feed-item")

        previous_height = 0
        results = []

        while len(results) < 100:  # 最多抓取 100 条
            # 滚动到底部
            page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            time.sleep(1)

            # 获取当前高度
            current_height = page.evaluate("document.body.scrollHeight")
            if current_height == previous_height:
                break  # 没有新内容了
            previous_height = current_height

            # 抓取新内容
            items = page.query_selector_all(".feed-item")
            for item in items[len(results):]:
                results.append({
                    "title": item.query_selector(".title").text_content(),
                })

        browser.close()
        return results

print(json.dumps(scrape_infinite_scroll(), ensure_ascii=False, indent=2))
```

## 高级示例

### 6. 截图

```python
from playwright.sync_api import sync_playwright

def take_screenshot(url, output_path="screenshot.png", full_page=True):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto(url, wait_until="networkidle")
        page.screenshot(path=output_path, full_page=full_page)

        browser.close()
        return output_path

# 使用
take_screenshot("https://example.com", "example.png")
```

### 7. 导出为 CSV

```python
from playwright.sync_api import sync_playwright
import csv

def scrape_to_csv(filename="output.csv"):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        page.goto("https://example.com/products")
        page.wait_for_selector(".product")

        items = page.query_selector_all(".product")

        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Title', 'Price', 'Image', 'Link'])

            for item in items:
                title = item.query_selector(".title").text_content()
                price = item.query_selector(".price").text_content()
                image = item.query_selector("img").get_attribute("src")
                link = item.query_selector("a").get_attribute("href")
                writer.writerow([title, price, image, link])

        browser.close()
        return filename

# 使用
scrape_to_csv()
```

### 8. 使用代理

```python
from playwright.sync_api import sync_playwright

def scrape_with_proxy():
    with sync_playwright() as p:
        browser = p.chromium.launch(
            proxy={
                "server": "http://proxy.example.com:8080",
                "username": "user",
                "password": "pass"
            }
        )
        page = browser.new_page()

        page.goto("https://example.com")
        content = page.text_content("body")

        browser.close()
        return content
```

### 9. 等待策略

```python
from playwright.sync_api import sync_playwright

def scrape_with_wait():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # 等待导航完成
        page.goto("https://example.com", wait_until="networkidle")

        # 等待特定元素
        page.wait_for_selector(".data-loaded", state="visible")

        # 等待特定条件
        page.wait_for_function("() => document.querySelectorAll('.item').length > 0")

        # 等待请求完成
        with page.expect_response("**/api/data") as response_info:
            page.click("button.load-data")
        response = response_info.value

        browser.close()
```

### 10. 完整配置类

```python
from playwright.sync_api import sync_playwright, Browser, BrowserContext, Page
from dataclasses import dataclass
from typing import List, Dict, Optional
import json
import tempfile
import zipfile
import shutil

@dataclass
class ScrapeConfig:
    url: str
    timeout: int = 30000
    headless: bool = True
    browser_type: str = "chromium"
    plugin_path: Optional[str] = None
    viewport: Dict = None
    user_agent: Optional[str] = None
    proxy: Optional[Dict] = None
    cookies: List[Dict] = None

    def __post_init__(self):
        if self.viewport is None:
            self.viewport = {"width": 1920, "height": 1080}
        if self.cookies is None:
            self.cookies = []


class PlaywrightScraper:
    def __init__(self, config: ScrapeConfig):
        self.config = config
        self._extension_temp_dir = None

    def __enter__(self):
        self.playwright = sync_playwright().start()
        launch_args = self._get_launch_args()
        self.browser = getattr(self.playwright, self.config.browser_type).launch(**launch_args)
        self.context = self._create_context()
        self.page = self.context.new_page()
        return self

    def __exit__(self, *args):
        self.browser.close()
        self.playwright.stop()
        if self._extension_temp_dir:
            shutil.rmtree(self._extension_temp_dir)

    def _get_launch_args(self):
        args = {
            "headless": self.config.headless,
        }

        # 处理插件
        if self.config.plugin_path:
            if self.config.plugin_path.endswith('.crx'):
                self._extension_temp_dir = tempfile.mkdtemp()
                with zipfile.ZipFile(self.config.plugin_path, 'r') as zip_ref:
                    zip_ref.extractall(self._extension_temp_dir)
                extension_path = self._extension_temp_dir
            else:
                extension_path = self.config.plugin_path

            args["headless"] = False  # 插件需要非无头模式
            args["args"] = [
                f"--disable-extensions-except={extension_path}",
                f"--load-extension={extension_path}"
            ]

        # 处理代理
        if self.config.proxy:
            args["proxy"] = self.config.proxy

        return args

    def _create_context(self):
        context_args = {"viewport": self.config.viewport}

        if self.config.user_agent:
            context_args["user_agent"] = self.config.user_agent

        context = self.browser.new_context(**context_args)

        # 添加 cookies
        if self.config.cookies:
            context.add_cookies(self.config.cookies)

        return context

    def goto(self, url: Optional[str] = None):
        target_url = url or self.config.url
        self.page.goto(target_url, timeout=self.config.timeout)

    def scrape_list(self, selector: str, fields: List[Dict]) -> List[Dict]:
        items = self.page.query_selector_all(selector)
        results = []

        for item in items:
            row = {}
            for field in fields:
                element = item.query_selector(field["selector"])
                if element:
                    if field.get("type") == "attribute":
                        value = element.get_attribute(field["attribute"])
                    else:
                        value = element.text_content()

                    # 应用转换
                    transform = field.get("transform")
                    if transform == "int":
                        value = int(value.strip()) if value else None
                    elif transform == "float":
                        value = float(value.strip()) if value else None
                    elif transform == "clean":
                        value = " ".join(value.split()) if value else None

                    row[field["name"]] = value
            results.append(row)

        return results

    def save_json(self, data, filename):
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)


# 使用示例
if __name__ == "__main__":
    config = ScrapeConfig(
        url="https://example.com/products",
        headless=True,
        plugin_path="/path/to/extension.crx",  # 可选
        cookies=[
            {"name": "session", "value": "xxx", "domain": ".example.com"}
        ]
    )

    with PlaywrightScraper(config) as scraper:
        scraper.goto()
        scraper.page.wait_for_selector(".product")

        results = scraper.scrape_list(
            selector=".product",
            fields=[
                {"name": "title", "selector": ".title", "type": "text"},
                {"name": "price", "selector": ".price", "type": "text", "transform": "float"},
                {"name": "image", "selector": "img", "type": "attribute", "attribute": "src"},
            ]
        )

        scraper.save_json(results, "output.json")
        print(f"抓取完成，共 {len(results)} 条记录")
```

## 命令行使用

```bash
# 安装依赖
pip install playwright
playwright install chromium

# 运行脚本
python scraper.py

# 使用浏览器插件
python scraper.py --plugin /path/to/extension.crx

# 非无头模式（可以看到浏览器）
python scraper.py --headless false
```
