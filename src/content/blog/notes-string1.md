---
title: 「字符串学习笔记」#1 KMP算法、Trie和自动机概念
tags:
  - KMP算法
  - Trie
  - 字符串
categories:
  - 学习笔记
description: '字符串滚出OI'
pubDate: 2022-08-08
---

## 基础概念

定义 $S$ 为一个字符串，其长度为 $n=|S|$，不特殊说明的情况下，下标从 $1$ 开始，$S_i$ 为 $S$ 中从左往右第 $i$ 个字符。

$S[l,r]$ 为 $S_l,S_{l+1} , \ldots S_{r}$，称为 $S$ 的一个子串。$S[1,i]$ 称为 $S$ 的一个前缀 (prefix)，$S[i,n]$ 为 $S$ 的一个后缀 (suffix)。

对于 $S$ 的一个子串 $S_0$，满足 $S_0$ 不仅是 $S$ 的一个前缀，还是 $S$ 的一个后缀，那么称 $S_0$ 或其长度为 $S$ 的一个 Border。Border 不能是 $S$ 本身。

![](https://pic2.zhimg.com/80/v2-c3cd7adda369b334a8065b7eadf8e2cd_720w.jpg)

举个例子，对于一个字符串`s=QwQorzQwQ`，其中`QwQ`就是`s`的一个 Border。

## KMP 算法



KMP 算法主要来解决两个字符串的匹配问题，能够在线性时间内判断一个字符串是否为另一个字符串的子串并求出其出现位置。

对于字符串 $S$，设 $next_i$ 为 $S[1,i]$  中最长的 Border 的长度。

如何求出 $next_i$？

朴素的做法是，枚举 $j \in [1,i-1]$，判断 $S[1,j]$ 与 $S[i-j+1,i]$ 是否相同，如果相同，那么 $j$ 就是 $next_i$ 的一个“候选项”。取最大的 $j$ 即可。

但是复杂度奇高，不够。

引理：若 $j_0$ 是 $next_i$ 的一个“候选项”，那么小于 $j_0$ 的最大的 $next_i$ 的“候选项”是 $next_{j_0}$。

>证明：反证法。假设存在 $next_{j_0} < j_1 < j_0$，且 $j_1$ 是 $next_i$ 的一个“候选项”，那么一定有 $S[1,j_1]=S[i-j_1+1,i]$。由于 $S[1,j_0]=S[i-j_0+1,i]$，所以分别取 $S[1,j_0]$ 和 $S[i-j_0+1,i]$ 的后 $j_1$ 个字符，显然也相等，也就是 $S[j_0-j_1+1,j_0] = S[1,j_1]$，从而 $j_1$ 是 $S[1,j_0]$ 的一个 Border，这与 $next_{j_0}$ 是 $j_0$ 的最大的 Border 相矛盾。由于 $next_{j_0}$ 是 $j_0$ 的前后缀，所以显然也是 $next_i$ 的一个 Border。
>
>综上，命题得证。

考虑如何求解。根据引理，当 $next_{i-1}$ 被计算完毕之后，就能够得到所有 $next_{i-1}$ 的“候选项”。如果 $j$ 是 $next_i$ 的“候选项”，那么 $j-1$ 必然是 $next_{i-1}$ 的“候选项”。这个通过手动模拟一下就能知道。

也就是说，我们可以用 $next_{i-1}$ 的最大候选项 $j$ 来得到 $next_i$ 的最大候选项。如果 $next_{i-1}=j$ 且 $S_i = S_{j+1}$，那么很显然，$j+1$ 就能够称为 $next_i$ 的候选项，且一定是最大的。否则，对于任何 $next_{i-1}$ 非最大的候选项，如果满足上述条件，也能变成 $next_i$ 的候选项。因此，只要枚举 $next_{i-1}$ 的所有候选项，取满足条件且最大的即可。

流程。

首先有 $next_1 = 0$，详见 Border 的定义。

初始化 $j=0$，表示当前匹配的长度，假设 $next_{1 \sim i-1}$ 都已经求解完成。如果 $j \neq 0$ 且 $S_i \neq S_{j+1}$，那就不断令 $j=next_j$。如果 $S_i = S_{j+1}$ 了，那就让 $j+1$。此时 $next_i = j$。

```cpp
nxt[1]=0;
for(i=2,j=0;i<=n;++i) {
    while(j&&s[i]!=s[j+1]) j=nxt[j];
    if(s[i]==s[j+1]) ++j;
    nxt[i]=j;
}
```

此外，如果要得到字符串 $A$ 与 $B$ ($|B| \le |A| $) 匹配的结果，还要求出 $f$，表示一个 $A$ 与 $B$ 之间的广义 Border 的长度。$f_i$ 表示 $A[1,i]$ 与 $B$ 中以 $i$ 结尾的子串的最长匹配长度。形式化地
$$
f_i = \max{\{j\}}
$$
其中 $j \le i$ 并且 $A[1,j] = B[i-j+1,i]$。注意 $next_i$ 不能为 $i$，但是 $f_i$ 能为 $i$。

方法也是类似的。

```cpp
nxt[1]=0;
for(int i=2,j=0;i<=m;++i) {
    while(j&&b[i]!=b[j+1]) j=nxt[j];
    if(b[i]==b[j+1]) ++j;
    nxt[i]=j;
}
// 先求出较小串的next
for(int i=1,j=0;i<=n;++i) {
    // 这里i从1开始
    while(j&&b[j+1]!=a[i]) j=nxt[j];
    if(b[j+1]==a[i]) ++j;
    f[i]=j;
    // f[i]==m 表示b在a中出现了
    if(j==m) printf("%d\n",i-m+1), j=nxt[j];
}
```

KMP 算法的复杂度是 $O(N+M)$ 的，如果只用来求 $next$ 则是 $O(N)$ 的。证明略。

### 失配树

见 [这篇博客](https://miku01ck.xyz//string-solution-1) 的倒数第三题。

早晚会补上的。

## Trie

像字典那样把字符串串在一棵树上哦~

没啥可写的，直接上板子好了。

这东西念作`Tree`……

```cpp
int tot, trie[N][26];
// N要大于字符串个数*字符串长度
// 26是字符集
void insert(char* s) {
	int x=0, len=strlen(s);
	for(int i=0;i<len;++i) {
		int a=s[i]-'a';
		if(!trie[x][a]) trie[x][a]=++tot;
        // 建立新结点
		x=trie[x][a];
	}
    // 插入一个字符串
}
int find(char* s) {
	int x=0, len=strlen(s);
	for(int i=0;i<len;++i) {
		int a=s[i]-'a';
		if(!trie[x][a]) return -1;
        // 找不到节点
		x=trie[x][a];
	}
	return 114514; // 返回你想要的信息
}
```

这玩意是典型的空间换时间……

### 一个简单应用 0-1 Trie

把`int`当作长度为 $31$ 的字符串插入 Trie 中。

下面放板子，可以快速处理最大异或和的。

```cpp
int tot, trie[N*31][2];
// [数字个数*数位][每一位不是0就是1]
void insert(int S) {
	int x=0;
	for(int i=31;i>=0;--i) {
		int a=(S>>i)&1;
		if(!trie[x][a]) trie[x][a]=++tot;
		x=trie[x][a];
	}
}
int find(int S) {
	int x=0, ans=0;
	for(int i=31;i>=0;--i) {
		int a=(S>>i)&1;
		if(trie[x][a^1]) ans+=(1<<i), x=trie[x][a^1];
        // 尽量往数字相反的地方走，这样异或值为1
		else x=trie[x][a];
	}
	return ans;
}
```

## DFA 是个啥？

有限自动机 (FA)，确定有限状态自动机 (DFA)。

下面都是一些概念，~~我甚至还没有完全理解~~，还是太菜了。

我们通常用确定有限状态自动机 (DFA) 解决大部分字符串的问题。

DFA 可以用一个 $5$ 元组 $(Q,\Sigma,\delta,q_0,F)$  表示，其中 $Q$ 为状态集, $\Sigma$ 为字符集，$\delta$ 为转移函数，$q_0$ 为起始状态，$F$ 为终态集。

如何判断一个字符串是否能被一个 DFA 接受呢？一开始时，自动机在起始状态 $q_0$ ，每读入一个字符 $c$ 后，状态转移到 $\delta(q,c)$ ，其中 $q$ 为当前状态。当整个字符串读完之后, 当且仅当 $q$ 在终态集 $F$ 中时，DFA 接受这个字符串。

$Trie$ 是一种最简单的 DFA。

插入每个模式串的时候，从前往后依次考虑每一位 $c$ ，然后记当前所在的状态 $q$ ，如果不存在 $\delta(q,c)$ 那么添加一个 $\delta(q,c)$ 的转移。接下来 $q \rightarrow \delta(q,c)$。终态的 $q$ 作为 DFA 的一个 $F$ 的一个元素。

$Trie$ 能接受的所有字符串就是插入的所有的串。

至于 AC 自动机啥的，目前不会……😥

为啥你的学习笔记里面一道题都没有呢？

一是因为懒，而是因为想加进来的题目有点多……



## 参考

- [字符串学习笔记(1) 基础概念与kmp前置](https://zhuanlan.zhihu.com/p/545135464)
- [字符串学习笔记(2) 字典树与Border树](https://zhuanlan.zhihu.com/p/546135224)
- [从0开始的字符串学习--KMP与失配树 ](https://www.cnblogs.com/Y25t/p/12459152.html)
