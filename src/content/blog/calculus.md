--- 
title: 『高等数学』笔记
tags:
 - 高等数学
categories:
 - 笔记
pubDate: 2025-10-11
description: '充实 提高'
---

## 前言

为何要维护这篇笔记呢？

首先，我是一个喜欢看课本上证明过程的家伙（即便是电子版）。

其次，我的初等数学能力很差，因为各种因素高中时没有练出来。

因此，我想通过维护这篇笔记，来提高我的数学能力与思维。

## 极限的四则运算

规定下列极限均为 $x \rightarrow x_0$ 时的函数极限，令 $\lim \limits_{x \rightarrow x_0} f(x) = A, \lim \limits_{x \rightarrow x_0} g(x) = B$。

---

$$
\lim f(x) + \lim g(x) = \lim \Big( f(x)+g(x) \Big)
$$

先给出初等方法的证明。

$\text{Proof}$

只需证明当 $x \rightarrow x_0$ 时，$\forall \varepsilon >0$，存在 $\exist \delta >0$，满足 $\forall 0 < |x-x_0| < \delta$，有 $\Big|f(x)+g(x)- (A+B)\Big| < \varepsilon$。

对右边的式子应用三角不等式，

$$
\Big|f(x)+g(x)- (A+B) \Big| \le \Big| |f(x) - A | + |g(x) - B| \Big|
$$



取 $\frac{\varepsilon}{2}$ 带入 $f,g$ 的极限定义，得到

$$
\Big|f(x)+g(x)- (A+B) \Big| \le \Big| |f(x) - A | + |g(x) - B| \Big| < |\frac{\varepsilon}{2} + \frac{\varepsilon}{2}| = \varepsilon
$$

$\text{Q.E.D.}$



这启发我们绝对值式子与三角不等式是绝配。



然后是同济高数的版本。

一切都出发自这个定理。

> 在自变量的同一变化过程 $x \rightarrow x_0$ 或 $x \rightarrow \infty$ 中，函数 $f(x)$ 具有极限 $A$ 的充要条件是 $f(x)= A + \alpha$，其中 $\alpha$ 为无穷小。

证明略。



$\text{Proof}$

设 $f(x) = A+\alpha,g(x)=B+\beta$，则 $f(x)+g(x) = A+B + \alpha + \beta$。

由于此时 $A+B$ 为常数，$\alpha+\beta$ 依然为无穷小。（两个无穷小的和为无穷小，证明略）

所以 $\lim \Big( f(x)+g(x) \Big) = A+B$。

$\text{Q.E.D.}$



---

$$
\lim f(x) \times \lim g(x) = \lim \Big( f(x) \times g(x) \Big)
$$

$\text{Proof}$

即证当 $x \rightarrow x_0$ 时，$\forall \varepsilon >0$，存在 $\exists \delta >0$，满足 $\forall 0 < |x-x_0| < \delta$，有 $\Big|f(x) \times g(x)- AB\Big| < \varepsilon$。

下面进行操作。

$$
\Big|f(x) \times g(x)- AB\Big| = \Big| f(x)g(x) - AB - Ag(x) + Ag(x)\Big| = \Big| g(x) \big(f(x)-A\big) +A \big(G(x)-B \big) \Big|
$$

应用三角不等式

$$
\Big| g(x) \big(f(x)-A\big) + A \big(G(x)-B \big) \Big| \le \Big| | g(x)| \times |f(x) - A| + |A| \times|g(x)-B| \Big|
$$

由于 $g(x)$ 此时存在极限，所以其在某去心邻域内有界。我们设这个界为 $M > 0$。

对于一个 $\varepsilon>0$，我们

1. 取 $\delta_1 >0$，使得当 $0 < |x-x_0|< \delta_1$ 时，$|g(x) - B| < \frac{\varepsilon}{2|A|+1}$

2. 取 $\delta_2 >0$，使得当 $0 < |x-x_0|< \delta_2$ 时，$|f(x)-A| < \frac{\varepsilon}{2M}$

3. 令 $\delta = \min(\delta_1,\delta_2)$。

当 $0 < |x-x_0| < \delta$ 时，有

$$
\Big|f(x) \times g(x)- AB\Big| \le M \times \frac{\varepsilon}{2M} + |A| \times \frac{\varepsilon}{2|A|+1} < \frac{\varepsilon}{2} + \frac{\varepsilon}{2} = \varepsilon
$$

于是

$$
\lim \Big( f(x) \times g(x) \Big) = AB
$$

$\text{Q.E.D.}$

下面解释步骤。

~~初等方法太恐怖惹。~~

首先把乘积相减转化掉这一步我就观察不出来了。
