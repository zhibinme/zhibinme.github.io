---
layout: page
title: Tags
permalink: /tags/
---
<div class="space-y-6">
  {% for category in site.tags %}
    {% assign category_name = category[0] %}
    {% assign category_posts = category[1] %}
    <div>
      <h2 class="text-2xl font-semibold">
        <a href="/tags/{{ category_name | slugify }}/" 
           class="hover:underline">
          {{ category_name }}
        </a>
        <span class="text-gray-500 text-lg">({{ category_posts.size }})</span>
      </h2>
    </div>
  {% endfor %}
</div>