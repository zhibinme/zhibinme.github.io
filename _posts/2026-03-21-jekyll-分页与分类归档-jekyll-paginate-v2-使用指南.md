---
layout: post
title: Jekyll 分页与分类归档：jekyll-paginate-v2 使用指南
categories:
- tutorial
tags:
- Jekyll
date: 2026-03-21 16:07 +0800
---
Jekyll 官方维护的 `jekyll-paginate` 早已停止更新，且不支持 `autopages`（自动生成分类/标签分页）。`jekyll-paginate-v2` 是目前更推荐的方案，支持分页和自动生成分类/标签归档页面。

<!--more-->

## 添加依赖

```ruby
# Gemfile
group :jekyll_plugins do
  gem "jekyll-paginate-v2"
end
```

然后执行 `bundle install`。

## 配置 `_config.yml`

```yaml
plugins:
  - jekyll-paginate-v2

# 分页配置
pagination:
  enabled: true
  per_page: 10                    # 每页文章数
  permalink: '/page/:num/'         # 分页 URL 格式
  title: ':title - 第 :num 页'     # 页面标题
  sort_field: 'date'               # 按日期排序
  sort_reverse: true               # 倒序（最新的在前）

# 自动生成分类/标签页面（核心！）
autopages:
  enabled: true                    # 总开关

  categories:
    enabled: true
    layouts:
      - 'archive.html'             # 指定布局文件
    title: '分类：:cat'
    permalink: '/categories/:cat'  # URL 结构
    slugify:
      mode: 'default'

  tags:
    enabled: true
    layouts:
      - 'archive.html'
    title: '标签：:tag'
    permalink: '/tags/:tag'
    slugify:
      mode: 'default'
```

## 首页启用分页

在 `index.markdown` 中开启：

```yaml
---
layout: home
pagination:
  enabled: true
---
```

## 修改布局

`home.html` 和 `archive.html` 需要使用 `paginator.posts` 替代 `site.posts`：

{% raw %}
```html
{%- assign posts = paginator.posts | default: site.posts -%}
{%- if posts.size > 0 -%}
  {%- include ariticle-list.html posts=posts -%}
{%- endif -%}

{% if paginator %}
  <nav class="flex justify-between text-sm text-gray-500">
    {% if paginator.previous_page %}
      <a href="{{ paginator.previous_page_path | relative_url }}">上一页</a>
    {% endif %}
    <span>第 {{ paginator.page }} / {{ paginator.total_pages }} 页</span>
    {% if paginator.next_page %}
      <a href="{{ paginator.next_page_path | relative_url }}">下一页</a>
    {% endif %}
  </nav>
{% endif %}
```
{% endraw %}

`archive.html` 的标题需要改为：

{% raw %}
```html
<h1>{{ page.autopages.display_name | default: page.title }}</h1>
```
{% endraw %}

## 导航栏配置

用数据文件管理导航更清晰。在 `_data/navigation.yml` 中定义：

```yaml
- name: Home
  link: /
- name: About
  link: /about/
- name: Categories
  link: /categories/
- name: Tags
  link: /tags/
```

在 `header.html` 中引用：

{% raw %}
```html
<nav class="flex items-center justify-between">
  {%- for item in site.data.navigation -%}
    <a href="{{ item.link }}" class="mr-4 {% if item.link == page.url %}font-bold{% endif %}">
      {{ item.name | escape }}
    </a>
  {%- endfor -%}
</nav>
```
{% endraw %}

## 注意事项

- `jekyll-paginate-v2` 与旧版 `jekyll-paginate` 互斥，不要同时使用
- `autopages` 会自动为每个分类和标签生成分页页面，无需手动创建
- 如果不需要某个插件的功能，可以在 `_config.yml` 中注释掉对应配置
