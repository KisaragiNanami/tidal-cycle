---
title: 北大版《组合数学》#1
pubDate: 2024-01-20
tags: 组合数学
categories: 学习笔记
description: '第一章 笔记与习题'
---



## 偏序集相关

设 $X$ 为一个非空集合，$\leqslant$ 是定义在 $X$ 上的，具有**自反性**，**反对称性**和**传递性**的二元关系，则称 $\textbf{P}=(X,\leqslant)$ 为一个偏序集。

对于偏序集 $(X,P)$，若 $\forall x,y \in X$，存在 $x \leqslant y$ 或 $y \leqslant x$，则称 $P$ 为一个**全序集**，也称为**链**。

对于偏序集 $(X,P)$，若 $\forall x,y \in X$，不存在 $x \leqslant y$ 和 $y \leqslant x$，则称 $P$ 为一个**反链**。

偏序集 $\textbf{P}$ 的最长子链的长度称为 $\textbf{P}$ 的高度，最长子反链的长度称为 $\textbf{P}$ 的宽度。

称 $z$ 为偏序集 $\textbf{P}$ 的极小元，当且仅当 $\forall x \in X \land x \neq z$，有 $z \leqslant x$。显然所有极小元可以构成一个反链。

称 $z$ 为偏序集 $\textbf{P}$ 的最小元，当且仅当 $\forall x \in X$，有 $z \leqslant x$。

$\text{Lemma}$

> 设偏序集 $(X,\leqslant)$ 的高度为 $n$，则存在划分 $X = \bigcup_{i=1}^n A_i$，是的每个 $A_i$ 都是反链。

$\text{Dilworth's theorem}$

> 设有限偏序集 $(X,\leqslant)$ 的宽度为 $m$，则存在划分 $X = \bigcup_{i=1}^m C_i$，是的每个 $C_i$ 都是反链。

## 初等计数方法

$\text{Problem}$

> 考虑划分一个大小为 $n$ 的集合，对于 $i \in [1,k] \cap \mathbb{Z}$，要求存在 $b_i$ 个大小为 $i$ 的无标号集合，并且满足 $\sum_{i=1}^k i \times b_i=n$，求方案数。

$\text{Solution}$

先做多重组合，然后对大小相同的集合下标号。

$$
\frac{1}{\prod_{i=1}^k b_i!} \binom{n}{1,\ldots,1,2,\ldots,2,\ldots,k,\ldots,k}
$$



$\text{Problem}$

> 对于字符串`NASHVILLETENNESSEE`，有多少本质不同的排列满足
> 
> 1. 第一个`N`在所有的`S`之前。
> 2. `T`在第一个`E`之后。
> 
> 其中有 $3$ 个`N`，$2$ 个`L`，$3$ 个`S`，$5$ 个`E`，`A`，`H`，`V`，`I`，`T`各 $1$ 个。

$\text{Solution}$

先划分再合并。

不受限制的字符可以任意排列，方案数 $\binom{6}{2,1,1,1,1}$。

对于限制 1，得到`NSSS`后插入 $2$ 个`N`即可，方案数 $\binom{5}{2}$。（为了放置重复，事实上这个是 $3$ 个`S`与 $2$ 个`N`的多重集全排列）。还有另一种方法，即先任意排列，然后非法方案一定满足开头不是`N`，这样的排列数量正好占一半，即 $\frac{\binom{6}{3}}{2} = \binom{5}{2}$。

对于限制 2，直接插入`T`即可，方案数 $\binom{5}{1}$。最后合并各个部分，要求每个部分的相对顺序不变。注意到每个部分无关，因此等价于多重集全排列，方案数 $\binom{18}{6,6,6}$。

综上，答案为 $\binom{5}{1}\binom{5}{2}\binom{6}{2,1,1,1,1}\binom{18}{6,6,6}$。

&nbsp;

## Exercise 1

### 2

利用虚数单位 $\text{i}$ 的性质。

$X = \{a+b \text{i}| a \in [1,l] \cap \mathbb{Z}, b \in [1,w] \cap \mathbb{Z}\}$。

$x \leqslant y$，当且仅当 $x - y \ge 0$。

### 3

(e) 按照字典序排序，本质上就是相同字符不考虑标号，因此答案就是 $\binom{26+4-1}{4}$。

(i) $\sum_{i=1}^{12} [x^i]\Big((\sum_{j=0}^{5}x^j)(\sum_{j=0}^{7}x^j)\Big)$

### 4

随便插空即可。

$7!\binom{8}{5};(7-1)!\binom{7}{5}$

### 5

固定住 $2$ 个`I`后再安排别的字符会产生重复。

容斥掉即可。

$\binom{11}{1,2,4,4} - \binom{7}{1,2,4}\binom{8}{4}$。

### 6

懒得做。

### 7

枚举第一个集合选多少个然后推式子。

$$
\sum_{i=0}^5 \binom{r-i+k-1-1}{k-1-1} = \sum_{i=r-5}^r \binom{k-2+1}{k-2} = \binom{k+r-1}{k-2} - \binom{k+r-7}{k-1}
$$



### 8

枚举二者再推式子。

$$
\begin{align*}\sum_{i=0}^n \sum_{j=0}^m \binom{i+j}{i} - 1 &= \sum_{i=0}^n \binom{i+m+1}{i+1} -1\\&= \sum_{i=1}^{n+1} \binom{i+m}{m} - 1\\&= \binom{n+m+2}{m+1}-2\end{align*}
$$



### 9

$$
\sum_{i=0}^{2011} \binom{i-1}{9-1} = \sum_{i=-8}^{2022} \binom{i+8}{8} = \binom{2002+8+1}{8+1}
$$

$$
\sum_{i=0}^{2011}\binom{i+8}{8} = \binom{2020}{9}
$$

### 10

考虑大小为 $kn$ 的集合，划分成 $k$ 个大小为 $n$ 的有标号集合的方案数。

### 11

#### a

显然

#### b

$$
\sum_{k} (-1)^k \binom{n-k}{m-k}\binom{n}{k} = \binom{n}{m} \sum_{k} (-1)^k \binom{m}{k}
$$

#### c

$$
\sum_{k} \binom{n-k}{n-m}\binom{n}{k} = \binom{n}{m} \sum_{k} \binom{m}{k}
$$

#### d

记 $a_n= \sum_{k=0}^n \binom{n+k}{n}2^{-k}$，则

$$
\begin{align*}a_n &= \sum_{k=0}^{n} \binom{n+k}{n}2^{-k}\\&= \sum_{k=0}^{n} \left(\binom{n+k-1}{n-1}+\binom{n+k-1}{n} \right) 2^{-k}\\&= \sum_{k=0}^{n} \binom{n+k-1}{n-1}2^{-k} + \sum_{k=0}^n \binom{n+k}{n}2^{-(k+1)}\\&= a_{n-1}+ \frac{1}{2}a_n\end{align*}
$$



因此 $a_1=1, a_n = 2a_{n-1}$。

#### e

$$
\sum_{j}\binom{k}{j}\binom{l}{j}\binom{n+k+l-j}{k+l} = \binom{n+k}{k} \binom{n+l}{l}
$$

考虑 $(1+x)^{n+l}(1+y)^{l}(1+x+y)^{k}$ 中 $x^{l+k}y^l$ 的系数。

对于左边，以 $y^l$ 为主元，枚举 $(1+x+y)^k$ 对 $y^l$ 的贡献 $y^i$，然后另外两者的贡献都能确定，不再赘述。

对于右边，以 $x^{l+k}$ 为主元，枚举 $(1+x)^{n+l}$ 的贡献 $x^i$，故技重施，得到

$$
\begin{align*}\sum_{i=l}^{n+l} \binom{n+l}{i} \binom{k}{l+k-i}\binom{i}{l} &= \sum_{i=0}^{n} \binom{n+l}{i+l}\binom{k}{k-i}\binom{i+l}{l}\\&= \sum_{i=0}^{n}\binom{n+l}{l}\binom{n}{i}\binom{k}{k-i}\\&= \binom{n+l}{l}\binom{n+k}{k}\end{align*}
$$



#### f

$$
\begin{align*}
\binom{n+m}{m+j} = \sum_{k=0}^{m+j}\binom{n}{k}\binom{m}{m+j-k} &= \sum_{k=j}^{m+j}\binom{n}{k}\binom{m}{m+j-k}
\\
&= \sum_{k=0}^{m} \binom{n}{k+j}\binom{m}{m-k}
\\
&= \sum_{k=0}^m \binom{n}{k+j}\binom{m}{k}
\end{align*}
$$

#### g

$$
\begin{align*}
\binom{-\alpha}{n} &= \frac{(-\alpha)(-\alpha-1)\cdots(-\alpha-n+1)}{n!}
\\
&= \frac{(-\alpha)(-\left(\alpha+1)\right)\cdots\left(-(\alpha+n-1)\right)}{n!}
\\
&= (-1)^n \binom{\alpha+n-1}{n}
\end{align*}
$$

## 递推关系

## GF相关
