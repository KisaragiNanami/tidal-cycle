---
title: luogu6835 线形生物 题解
pubDate: 2023-06-28
tags:
  - DP
  - 概率论
  - 数学期望
categories: 题解
description: 'Solution'
---

上古时期写的，那时候竟然还会期望……

## 分析

是上一题的加强版。

由于每个台阶都多了若干出边，所以不能采用上题第一种状态了。

参考了洛谷第一篇题解的推式子方式。

设 $E(x,y)$ 为线性生物从 $x$ 爬到 $y$ 的期望步数，$\operatorname{deg}_x$ 表示 $x$ 节点的入度，不包含 $(x-1 \rightarrow x)$。

此时有

$$
E(x,x+1) = \frac{1}{\operatorname{deg}_x+1} \cdot 1 + \frac{1}{\operatorname{deg}_x +1} \sum_{(x \rightarrow y)} 1 +E(y,x+1)
$$



含义：在 $deg_x+1$ 种走法中，有一条正好是 $(x \rightarrow x+1)$，权值为 $1$。对于其他每一条 $(x,y)$，都要从 $y$ 走到 $x+1$，且还要加上走到 $y$ 的 $1$。

化简原式。根据期望的线性性，有 $E(y,x+1) = \sum_{i=y}^x E(i,i+1)$，带进去得到

$$
E(x,x+1) = 1 + \frac{1}{\operatorname{deg}_x+1} \cdot \sum_{(x \rightarrow y)} \sum_{i=y}^x E(i,i+1)
$$



含义：不管走到哪里，肯定要走一步。后面的部分就是走到不同的点的不同权值。 

此时所有代表状态都是从一个点到编号 $+1$ 的点。不妨设 $f_x = E(x,x+1)$，$g_x= \sum_{i=0}^x f_i$ 则

$$
f_x = 1 + \frac{1}{\operatorname{deg}_x + 1} \cdot \sum_{(x \rightarrow y)} g_x - g_{y-1}
$$



注意到右边含有一个 $\frac{\operatorname{deg}_x}{\operatorname{deg}_x+1} \cdot f_x$，化简得到

$$
f_x = \frac{\operatorname{deg}_x}{\operatorname{deg}_x +1} \cdot f_x + 1 + \frac{1}{\operatorname{deg}_x + 1} \cdot \sum_{(x \rightarrow y)} g_{x-1} - g_{y-1}
$$



$$
\frac{f_x}{\operatorname{deg}_x+1} = 1 + \frac{1}{\operatorname{deg}_x + 1} \cdot \sum_{(x \rightarrow y)} g_{x-1} - g_{y-1}
$$

$$
f_x = \operatorname{deg}_x + 1 + \sum_{(x \rightarrow y)} g_{x-1} - g_{y-1}
$$

由于 $y=x+1$ 时没有贡献，$y \neq x+1$ 时一定有 $y \le x$，所以很容易按照编号从小到大的拓扑序求出 $f_x$ 和 $g_x$。

最终答案为 $g_n$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e6+5, mod=998244353;
int id, n, m, f[N], g[N], deg[N];
int tot, h[N], to[N<<1], nxt[N<<1];
bool v[N];
void add(int x,int y) { to[++tot]=y, nxt[tot]=h[x], h[x]=tot; }
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
signed main() {
    id=read(), n=read(), m=read();
    for(int i=1;i<=m;++i) {
        int x=read(), y=read();
        add(x,y), ++deg[x];
    }
    for(int x=1;x<=n;++x) {
        f[x]=deg[x]+1;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            (f[x]+=(g[x-1]-g[y-1]+mod)%mod)%=mod;
        }
        g[x]=(g[x-1]+f[x])%mod;
    }
    printf("%lld\n",g[n]);
}
```
