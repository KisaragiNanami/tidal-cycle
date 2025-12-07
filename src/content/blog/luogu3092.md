---
title: luogu3092 No Change 题解
tags:
  - DP
  - 状态压缩
categories:
  - 题解
description: 'Solution'
pubDate: 2022-01-27
---

直接设状态为花费的钱数是不行的，硬币的使用顺序与购买顺序都会影响答案，复杂度爆炸。

设 $f(S)$ 为使用的硬币为 $S$ 时，最多能买的物品个数。

对于 $S_0 \subseteq S$，显然能够转移，但方程并不是一个简单的多项式。

不难发现，枚举 $S$ 的子集是不行的，不能直接转移，且复杂度过高。那就考虑枚举硬币。



对于一个集合 $S$，枚举枚举其中每一个硬币用或不用。设 $S_0$ 与 $S$ 中只相差 $j$ 这个硬币，那么 $S_0 = S \text{ xor } 2^{j-1}$，余出来的 $c_j$ 的钱就可以继续往后买。设 $t(i,j)$ 为用 $j$ 的钱，从 $i$ 开始往后买，最多能买到第几个物品。所以转移为

$$
f(S) = \max{ \{ f(S),t(f(S_0),c_j) \} }
$$



用前缀和搞一下物品数组，显然 $t(i,j)$ 是可以二分的。

这一部分复杂度为 $O(2^k \cdot k \log_2 n)$

还是可以的（

&nbsp;

考虑如何计算答案。

设 $g(S)$ 为使用的硬币为 $S$ 时的最小花费。显然可以采用与上面差不多的转移方式。

注意到 $lowbit(x)$ 可以提取出 $x$ 的二进制表示中最后一个 1 以及后面的 0。

举个例子

> $(x)_2 = 011010$
> 
> $lowbit(x) = (10)_2 = 2$

这正好对应了「去掉最后一个硬币」。由于不找零，所以能够直接暴力累加钱数。且因为我们设计了这样的状态，一个状态最多买多少物品是一定的，只需要计算出这些目标状态需要的钱数（也就是 $f$ 的限制）。故可以从 $g(S-lowbit(S))$ 转移到 $g(S)$。

由于 $lowbits$ 运算只能得到 2 的整数次幂，那么我们可以将每个硬币与一个二进制位建立映射关系。

不难想到转移为

$$
g(S)=g(S-lowbit(S))+c_{lowbit(S)}
$$



答案

$$
ans = \max{\{ sum_c - g(i) \}} \quad f(i) = m
$$



注意实现。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
const int N=17;
int n, m, orz, U, ans=-1, c[N], sum[100010], f[1<<N], g[1<<N], p[1<<N];
// ans要初始化为-1
inline int lb(int x) { return x&(-x); }
inline int erfen(int s,int v) {
    int l=s, r=m, mid, pos=-1;
    while(l<=r) {
        mid=(l+r)/2;
        if(sum[mid]-sum[s]<=v) pos=mid, l=mid+1; else r=mid-1;
    }
    return pos;
}
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=n;++i) scanf("%d",&c[i]), orz+=c[i], p[1<<(i-1)]=i;
    // p建立的映射为: c[1]->二进制最低位，c[2]->二进制倒数第二位，以此类推
    for(int i=1,x;i<=m;++i) scanf("%d",&x), sum[i]=sum[i-1]+x;
    U=(1<<n)-1;
    for(int i=1;i<=U;++i) for(int j=0;j<n;++j) if((1<<j)&i) {
        int t=erfen(f[i^(1<<j)],c[j+1]);
        if(t!=-1) f[i]=max(f[i],t);
    }
    for(int i=1;i<=U;++i) {
        g[i]=g[i^lb(i)]+c[p[lb(i)]];
        if(f[i]==m) ans=max(ans,orz-g[i]);
    }
    printf("%d\n",ans);
}
```
