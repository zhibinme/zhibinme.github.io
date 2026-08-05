---
layout: post
title: 'Jekyll 集成 jektex：服务端 LaTeX 渲染笔记'
categories: [Tutorial]
tags: [Jekyll, LaTeX, Math, jektex, KaTeX]
---

这篇教程记录了给 Jekyll 博客接入 `jektex` 服务端 LaTeX 渲染的完整流程，包括安装、配置、语法说明和常见坑。

<!--more-->

## 为什么要选 jektex

jektex 是一个 Jekyll 插件，在构建阶段把 LaTeX 编译成 KaTeX 的 DOM 输出。与客户端 MathJax / KaTeX 方案相比：

- **零客户端 JS**：浏览器不需要加载数学库，首屏更快、SEO 友好
- **缓存友好**：重复公式命中磁盘缓存，增量构建极快
- **不污染 Markdown**：代码块、反引号内的 `$` 不会被误处理
- **官方背书**：被 [katex.org](https://katex.org/docs/libs#jekyll) 收录

## 安装

### 1. 在 Gemfile 添加依赖

`Gemfile` 的 `:jekyll_plugins` group 里加上：

```ruby
group :jekyll_plugins do
  # ... 其他插件 ...
  gem 'jektex'
end
```

然后安装：

```bash
cd notes
bundle install
```

### 2. 在 _config.yml 启用插件

`_config.yml` 的 `plugins:` 列表里追加：

```yaml
plugins:
  - jekyll-archives
  - jekyll-sitemap
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-tailwind
  - jekyll-paginate-v2
  - jektex    # ← 新增
```

### 3. 加载 KaTeX 样式表（关键！）

jektex 只负责把 LaTeX 转成 KaTeX 的 DOM，**不会自动注入样式表**。不挂 CSS 的话，`\sqrt{x}` 会显示成没横线的裸符号、字体回退到系统默认，看起来很怪。

jektex 内置 KaTeX 版本是 `0.17.0`（验证方法：`head -c 300 lib/jektex/katex.min.js | grep version`）。在 [notes/_includes/head.html](notes/_includes/head.html) 里加：

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.17.0/dist/katex.min.css" crossorigin="anonymous">
```

更稳的写法是下载 CSS 放到 `notes/assets/css/` 下本地引用 —— 优点是不依赖第三方 CDN。

### 4. 重启 Jekyll

Gemfile / `_config.yml` 变更后必须重启（`_config.yml` 不会热加载）：

```bash
bundle exec jekyll serve --draft --livereload
```

启动日志里看到 `LaTeX: N expressions rendered` 说明插件生效了。

## 语法

jektex 支持两种写法，可任选其一或混用。

### Kramdown 风格（推荐）

| 模式 | 写法 | 说明 |
| --- | --- | --- |
| 行内 | `$$x^2$$` | 用**双**美元号包起来 |
| 块级 | 上下留空行 + `$$ ... $$` | 同 LaTeX 的 display math |

> ⚠️ **不支持单 `$`**：`$1+2$` 在 Kramdown 里就是普通文本，不会被渲染。这是 Kramdown 解析器的设计选择，不是 jektex 的问题。

### LaTeX 风格

| 模式 | 写法 |
| --- | --- |
| 行内 | `\(x^2\)` |
| 块级 | `\[x^2\]` |

这套写法语义最贴近标准 LaTeX，习惯 MathJax 的读者会更熟悉。

### 行内 vs 块级怎么选

- **行内**：嵌入正文里、跟文字混排时用，比如「方程 \(ax^2 + bx + c = 0\) 的解」
- **块级**：公式独立成段、想要居中 + 单独一行时用

## 示例

### 基本符号

欧拉恒等式 \(e^{i\pi} + 1 = 0\) 是数学里最著名的公式之一。

矩阵：

$$
A = \begin{pmatrix}
a & b \\
c & d
\end{pmatrix}
$$

### 希腊字母与常用算子

\[
\nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0}, \quad
\nabla \times \mathbf{B} = \mu_0 \mathbf{J} + \mu_0 \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t}
\]

### 求和与积分

\[
\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}, \qquad
\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}
\]

### 多行对齐（aligned 环境）

\[
\begin{aligned}
f(x) &= ax^2 + bx + c \\
f'(x) &= 2ax + b \\
f''(x) &= 2a
\end{aligned}
\]

### 中文混排

注意中文与公式之间留一个空格（项目规范要求）。比如：

欧拉恒等式 \(e^{i\pi} + 1 = 0\) 被誉为「数学中最美的公式」。

正态分布的概率密度函数：

\[
f(x) = \frac{1}{\sqrt{2\pi\sigma^2}} e^{-\frac{(x-\mu)^2}{2\sigma^2}}
\]

## 常见坑

### 1. `\sqrt` 不显示根号横线

→ 99% 是忘了加载 `katex.min.css`。回头检查 `_includes/head.html`。

### 2. `$$e^{i\pi} + 1 = 0$$` 不渲染

→ 检查是不是用了**单**美元号 `$e^{i\pi} + 1 = 0$`。Kramdown 不识别单 `$`，必须用双 `$$`。

### 3. 块级公式挤在一行

→ 块级公式必须上下各留一个空行，否则 Kramdown 把它当行内处理：

```markdown
正确：
$$
a^2 + b^2 = c^2
$$

错误（挤一行）：
$$ a^2 + b^2 = c^2 $$
```

### 4. 代码块里的 `$$...$$` 被吃掉了

实际上**不会**。jektex 显式跳过 `<code>`、`<pre>`、`<script>` 等标签里的 LaTeX。比如下面这句会原样输出，不会变成数学符号：

```markdown
Code span should be untouched: `$$e=mc^2$$`.
```

### 5. HTML 块内的公式渲染不出来

Kramdown 默认不处理 HTML 块内的 Markdown，但 jektex 会兜底 —— 块级 HTML 里的 `$$...$$` 仍会被它捕获。例：

```html
<div>The formula $$\beta$$ stays inline, but:

$$ \Psi(\mathbf{r},t) = A e^{i(\mathbf{k}\cdot\mathbf{r} - \omega t)} $$

gets display rendering.</div>
```

## 可选配置

jektex 默认开磁盘缓存（位置 `.jekyll-cache`，会被 `jekyll clean` 清掉）。`_config.yml` 里可以定制：

```yaml
jektex:
  cache_dir: ".jektex-cache"   # 改成不会被 clean 清掉的位置
  ignore: ["*.xml"]            # 某些文件跳过渲染
  silent: false                # 构建时打印每个公式的渲染状态
```

也可以在某一篇文章的 front matter 里关掉：

```yaml
---
title: "Skip math rendering"
jektex: false
---
```

## 编辑器工作流（VS Code）

源文件怎么写、预览怎么显示、Jekyll 怎么渲染，三方一致才省心。下面是 VS Code 上的完整配置。

### 1. 装 Markdown Preview Enhanced

VS Code 默认的 Markdown 预览**不支持** `\(...\)` / `\[...\]` 这套 LaTeX 风格语法，建议装 [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)（MPE），自带 KaTeX 渲染。

预览命令：`Cmd + K V`（侧栏预览），或 `Cmd + Shift + P` → "Markdown Preview Enhanced: Open Preview"。

### 2. 让 MPE 与 jektex 行为一致

**问题**：MPE 默认按 LaTeX 约定识别数学语法 —— `$$...$$` 是块级、单 `$...$` 是行内。但 jektex / Kramdown 的约定相反 —— 单行 `$$...$$` 是行内，单 `$` 是普通文本。

也就是说，你写 `$$x^2$$` 单独一行想 inline：

- MPE 默认渲染成块级
- jektex 渲染成行内

两侧不一致。

**推荐解法**：源文件统一用 LaTeX 风格 —— `\(...\)` 做行内、`\[...\]` 做块级。MPE 默认就识别、jektex 也原生支持，**两边都不用改任何配置**。

```markdown
欧拉恒等式 \(e^{i\pi} + 1 = 0\) 被誉为「数学中最最美的公式」。

\[
\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
\]
```

如果坚持用 `$$...$$` 当行内，需要改 MPE 配置覆盖默认（`settings.json` 里）：

```json
{
  "markdown-preview-enhanced.math.inlineMath": [
    ["$$", "$$"],
    ["INLINE_OPEN", "INLINE_CLOSE"]    // 替换为反斜杠 + 圆括号
  ],
  "markdown-preview-enhanced.math.blockMath": [
    ["BLOCK_OPEN", "BLOCK_CLOSE"]      // 替换为反斜杠 + 方括号
  ]
}
```

代价：块级公式必须写 `\[...\]`，不能用 `$$\n...\n$$` + 空行。

> ⚠️ **关于示例里的占位符**：jektex 在 `pre_render` 阶段扫描**整个原始 markdown**（不区分代码块）寻找 `\(...\)` / `\[...\]` 模式。所以代码块示例里直接写反斜杠 + 括号 / 方括号会被误识别。这里用 `INLINE_OPEN` / `BLOCK_OPEN` 这类安全字符串占位，实际使用时手动替换为反斜杠 + 圆括号 / 方括号即可。

### 3. 配置 markdown snippet

VS Code 用户级 snippets 文件（macOS 路径）：

```
~/Library/Application Support/Code/User/snippets/markdown.json
```

写入：

```json
{
  "KaTeX inline": {
    "prefix": "math ",
    "body": "INLINE_BODY",            // 替换为反斜杠 + ( + $1 + 反斜杠 + )
    "description": "KaTeX inline math"
  },
  "KaTeX block": {
    "prefix": "mathb ",
    "body": "BLOCK_BODY",             // 替换为反斜杠 + [ + 换行 + $1 + 换行 + 反斜杠 + ]
    "description": "KaTeX block math"
  }
}
```

要点：

- **prefix 末尾的空格**是触发字符 —— 输入 `math ` 那一刻 IntelliSense 自动弹
- **prefix 不能含 `(`**：VS Code 的 `editor.autoClosingBrackets` 会自动补全 `)`，snippet 展开后会有半个 `)` 残留
- 保存后无需重启 VS Code，snippets 自动 reload；若没生效，`Cmd + Shift + P` → "Developer: Reload Window"

### 4. 启用 markdown 域的自动 suggestion

VS Code 默认把 markdown 正文当成 "comment" 上下文，`editor.quickSuggestions.comments` 默认是 `false` —— 即使 snippet 注册了 IntelliSense 也**不会自动弹**，只能 `Ctrl + Space` 手动触发。

在 `settings.json`（用户级）加：

```json
{
  "[markdown]": {
    "editor.quickSuggestions": {
      "comments": true,
      "strings": false,
      "other": true
    }
  }
}
```

`comments: true` 是关键 —— 让 markdown 正文也算 quick suggestions 触发范围。保存后输 `math ` 停顿一下就自动弹 IntelliSense。

### 5. macOS 上的额外坑

`Ctrl + Space` 在 macOS 上是**切换输入法**的系统快捷键，VS Code 收不到这个按键。`Ctrl + Space` 不影响自动触发（自动触发走 quickSuggestions 通道），但如果你偏好手动触发，建议三选一：

- **菜单**：`Edit` → `IntelliSense` → `Trigger Suggest`
- **改 macOS 输入法快捷键**：`系统设置` → `键盘` → `键盘快捷键` → `输入法`，把 `⌃Space` 换成别的
- **改 VS Code 键位**：`Cmd + K, Cmd + S` → 搜 `trigger suggest` → 改成 `Cmd + Shift + Space` 等

## 验证

### Jekyll 构建

跑起来后，关注启动 / 增量构建日志里的 `LaTeX: N expressions rendered (M loaded from cache)`：

- **N 跟你写的公式数对得上** → 全部捕获
- **M 越来越大** → 缓存生效，增量构建变快
- **没有 error** → 语法没问题

浏览器里如果看到带横线的 `\sqrt{2}`、漂亮的矩阵、上下标，就说明 Jekyll 链路通了。

### 编辑器链路（VS Code → MPE → Jekyll）

按下面顺序走一遍，确认三方一致：

1. **VS Code 编辑**：在 `.md` 文件里输 `math `（math + 空格）→ 自动弹出 IntelliSense，选 `KaTeX inline math` → 光标落在 `\(cursor\)` 中间
2. **MPE 预览**：`Cmd + K V` 打开预览 → 看到 KaTeX 行内渲染的公式（行高、间距正常）
3. **Jekyll 构建**：`bundle exec jekyll serve --draft --livereload` → 浏览器打开草稿地址 → 跟 MPE 看到的一致

任何一步不一致，回去检查对应的配置项：snippet prefix / `[markdown]` 设置 / MPE `inlineMath` / `blockMath` 覆盖。

## 参考

- [jektex on GitHub](https://github.com/yagarea/jektex)
- [jektex on RubyGems](https://rubygems.org/gems/jektex)
- [KaTeX supported functions](https://katex.org/docs/supported.html) — 不是所有 LaTeX 命令都支持，复杂宏可能报错
- Kramdown issue [#762](https://github.com/gettalong/kramdown/issues/762) — 为什么 Kramdown 用双 `$` 而不是单 `$`