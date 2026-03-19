---
layout: page
title: Categories
permalink: /categories/
---
<ul class="space-y-2 md:space-y-4 xl:space-y-6 capitalize">
  {% for category in site.categories %}
    {% assign category_name = category[0] %}
    {% assign category_posts = category[1] %}
    <li>
      <a href="/categories/{{ category_name | slugify }}/" class="text-xl font-semibold hover:underline">
        {{ category_name }}
      </a>
      <span class="text-gray-500">({{ category_posts.size }})</span>
    </li>
  {% endfor %}
</ul>