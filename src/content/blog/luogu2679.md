---
title: luogu2679 子串 题解
tags: DP
categories: 题解
description: 'Solution'
pubDate: 2022-05-21
---

## 分析

莫名其妙地想把这道题的题解写了。

设 $f(i,j,k)$ 为 A 的前 $i$ 个字符取出了 $k$ 段，恰好匹配到 B 中 $j$ 的位置的方案数。



如果 $A_i \neq B_j$，那么不会产生任何贡献。

如果 $A_i = B_j$，那么有两种情况

1. $i$ 接着上一段那么 $f(i-1,j-1,k) \rightarrow f(i,j,k)$
2. $i$ 是下一段的第一个。那么它的前继状态有 $k-1$ 段，匹配到了 $B_{j-1}$，但是 $i$ 能取 $[1,i-1]$ 中任何一个位置。所以维护 $g(i,j,k) = \sum_{x=1}^i f(x,j,k)$，转移就是 $g(i-1,j-1,k-1) \rightarrow f(i,j,k)$。

另一种理解，$f(i,j,k)$ 就相当于 $i$ 这个位置必须选的方案数，$g(i,j,k)$ 则是选不选都可以。后者显然是包含前者的，所以最终答案是后者。

这样会爆内存，可以滚动数组优化掉 $i$ 这一维。

## CODE

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
const int N=1005, M=205, mod=1e9+7;
int n, m, K, f[N][M][2];
// f[i][j][0]是上文的g，f[i][j][1]是上文f
char a[N], b[M];
int main() {
    scanf("%d%d%d%s%s",&n,&m,&K,a+1,b+1);
    f[0][0][0]=f[0][0][1]=1;
    // 简单设初值就够了
    for(int i=1;i<=n;++i) for(int j=m;j;--j) for(int k=1;k<=K;++k) {
        if(a[i]!=b[j]) { f[j][k][1]=0; continue; }
        // 因为有滚动数组，所以要置为0
        f[j][k][1]=(f[j-1][k][1]+f[j-1][k-1][0])%mod;
        f[j][k][0]=(f[j][k][0]+f[j][k][1])%mod;
    }
    printf("%d\n",f[m][K][0]);
}
```
