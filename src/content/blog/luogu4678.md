---
title: luogu4678 全排列 题解
tags:
  - DP
  - 组合数学
categories: 题解
pubDate: 2022-07-25
description: 'Solution'
---

## 分析

显然统计贡献。

题面有个描述不清楚的地方，“相似”的不一定是一个完整的“排列”，否则这题就没法做了。不过这个笔误也启发我们思考这个东西的本质，注意到 $A$ 与 $B$ 相似，当且仅当对于任意 $i$，$A_i$ 在 $A$ 中的相对大小与 $B_i$ 在 $B$ 中的相对大小相同。 说人话就是，$A$ 与 $B$ 离散化后是相同的。

那么最终答案一定是通过 $[1,d]$ 所有包含不超过 $E$ 个逆序对的排列的数量来进行计算的，其中 $d \in [1,n]$。

这是一个经典问题。设 $f(i,j)$ 为包含 $j$ 个逆序对的 $[1,i]$ 的排列的个数。一个显然~~但我不会证明~~的结论就是把 $i$ 插入 $[1,i-1]$ 的任意排列中，能够增加的逆序对数量取遍 $[0,i-1]$，所以转移很显然

$$
f(i,j) = \sum_{k= \max(0,j-i+1)}^j f(i-1,k)
$$



前缀和优化即可。设 $g(i,j)$ 为包含不超过$j$ 个逆序对的 $[1,i]$ 的排列的个数，可以表示为

$$
g(i,j) = \sum_{k=0}^j f(i,k)
$$



得到

$$
f(i,j) = g(i-1,j) - \Delta
$$



其中当 $j \ge i$ 时，$\Delta = g(i-1,j-i)$，否则 $\Delta = 0$。实现的时候直接把 $f$ 当作 $g$，求两遍即可。

对于每一个询问，不难想到等价于规定区间长度为 $i$，询问离散化后为逆序对个数不超过 $E$ 的 $[1,i]$ 的排列的产生方案，其中 $i \in [1,n]$。

设 $m_i = \min{( E,\frac{i \cdot (i-1)}{2} )}$。

首先确定 $[1,i]$ 方案数为 $n-i+1$，因为要离散化，只要相对大小相同就行。比如 $[2,3,4]$ 和 $[1,2,3]$。这些方案每一种都有 $g(i,m_i)$ 确定满足条件的排列。

接着考虑从 $[1,n]$ 中构造这样的排列的方案数。在 $[1,n]$ 中选出 $i$ 个数，它们离散化后一定是 $[1,i]$ 的一个排列，并且每一种选择方法对应着唯一排列方案，方案数 $C^i_n$。由于乘上了 $n-i+1$，所以相当于这 $i$ 个数的位置被固定了，所以剩下的 $n-i$ 个数字在 $n-i$ 个位置中自由排列，方案数 $(n-i)!$。要确定两个排列，所以要乘两边。

综上所述，对于一组 $(n,E)$，答案为

$$
\sum_{i=1}^n f(i,m_i) \cdot (n-i+1) \cdot (C_n^i) ^2 \cdot \big((n-i)!\big)^2
$$



这个还是感性理解一下比较好（）

## CODE

```cpp
#include <bits/stdc++.h>
#define int long long
using namespace std;
const int N=505, mod=1e9+7;
int t, n, E, f[N][N*N/2], fac[N], c[N][N];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
void init() {
    for(int i=0;i<=500;++i) f[i][0]=1;
    f[1][1]=1;
    for(int i=2;i<=500;++i) {
        int k=i*(i-1)/2;
        for(int j=1;j<=k;++j) f[i][j]=(f[i-1][j]+(j>=i? mod-f[i-1][j-i]:0))%mod;
        k=i*(i+1)/2;
        for(int j=1;j<=k;++j) f[i][j]=(f[i][j]+f[i][j-1])%mod;
    }
    c[0][0]=1;
    for(int i=1;i<=500;++i) {
        c[i][0]=c[i][i]=1;
        for(int j=1;j<i;++j) c[i][j]=(c[i-1][j]+c[i-1][j-1])%mod;
    }
    fac[0]=fac[1]=1;
    for(int i=2;i<=500;++i) fac[i]=fac[i-1]*i%mod;
}
int squ(int x) { return x*x%mod; }
void solve() {
    n=read(), E=read();
    int ans=0;
    for(int i=1;i<=n;++i) {
        int k=min(E,i*(i-1)/2);
        (ans+=f[i][k]*(n-i+1)%mod*squ(c[n][i])%mod*squ(fac[n-i])%mod)%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    t=read();
    init();
    while(t--) solve();
}
```
