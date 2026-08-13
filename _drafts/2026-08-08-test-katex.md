---
layout: post
title: 'katex：前端 LaTeX 渲染笔记'
categories: [Tutorial]
tags: [Jekyll, LaTeX, Math, katex, KaTeX]
katex: true
---

这篇教程记录了给 Jekyll 博客接入 `katex` 前端 LaTeX 渲染

<!--more-->

**要点提示**

- 正整数可以写成正分数的形式，例如 $2=\dfrac{2}{1}$；负整数可以写成负分数的形式，例如 $-3=-\dfrac{3}{1}$；0 也可以写成分数的形式 \(\dfrac{0}{1}\)。这样，**整数可以写成分数的形式**。
- $0.1=\dfrac{1}{10}$，$-0.5=-\dfrac{1}{2}$，$0.3̇=\dfrac{1}{3}$，…，事实上，有限小数和无限循环小数都可以化为分数，因此它们也可以看成分数。
- 引入负数后，我们对数的认识就扩大到了有理数范围。
- 非负数，是指 $$0$$ 和整数。


#### 解法二 · 方程法（高年级标准解法）

联立方程组：

$$
\begin{cases}
c + r = H \\
2c + 4r = F
\end{cases}
\;\Longrightarrow\;
c = \frac{4H - F}{2}, \quad r = \frac{F - 2H}{2}
$$

\[\frac{1}{2}\]