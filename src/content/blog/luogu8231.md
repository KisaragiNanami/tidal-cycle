---
title: luogu8231 沈阳大街 2 题解
tags:
  - DP
  - 二分图
categories:
  - 题解
description: 'Solution'
pubDate: 2022-10-04
---

## 分析

以下部分内容来自洛谷题解

把两个序列看成二分图，对于一个排列 $p$，左面点 $i$ 和右面点 $p_i$ 连一条边，这样就恰好形成一组完美匹配。

现在我们变成这样一个问题：$(i,j)$ 的边权是 $\min(A_i,B_j)$，定义一个完美匹配权值是所有边权的积，你要求所有完美匹配权值之和。

这样还是不太好做，考虑两个序列都从大到小排序，然后把边定向，定义成点权较小的点向点权较大的点的有向边。

这样定向后就有一个性质：**每个点的出边边权相同并且为这个点的点权，而且这些边指向的点为对面点一个前缀。**

设 $f(i,j)$ 为考虑 $[1,i]$ 的匹配，匹配了 $j$ 个的值。

设 $k$ 为 $[1,i-1]$ 中与 $i$ 在二分图中不在同一边的节点个数，$c_i$ 为 $i$ 的值。

$$
f(i,j) = f(i-1,j-1) \cdot c_i \cdot \big(k-(j-1)\big) + f(i-1,j)
$$



答案是 $f(2n,n)$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=5005, mod=998244353;
int n, f[2*N][N], sa[2*N], sb[2*N];
struct IEE {
    int q, val;
} a[2*N];
bool operator<(IEE a,IEE b) {
    if(a.val!=b.val) return a.val>b.val;
    return a.q<b.q;
}
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
signed main() {
    n=read();
    for(int i=1;i<=n;++i) a[i]=(IEE){1,read()};
    for(int i=1;i<=n;++i) a[i+n]=(IEE){2,read()};
    sort(a+1,a+2*n+1);
    for(int i=1;i<=2*n;++i) sa[i]=sa[i-1]+(a[i].q==1), sb[i]=sb[i-1]+(a[i].q==2);
    f[0][0]=1;
    for(int i=1;i<=2*n;++i) {
        int lim=a[i].q==1? sb[i]:sa[i];
        for(int j=0;j<=min(n,i);++j) {
            if(j&&lim-j+1>0) f[i][j]=f[i-1][j-1]*a[i].val%mod*(lim-j+1)%mod;
            (f[i][j]+=f[i-1][j])%=mod;
        }
    }
    int d=1;
    for(int i=2;i<=n;++i) d=d*i%mod;
    printf("%lld\n",f[2*n][n]*fp(d,mod-2)%mod);
}

```




