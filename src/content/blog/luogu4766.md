---
title: luogu4766 Outer space invaders 题解
tags:
  - DP
  - 区间DP
categories:
  - 题解
pubDate: 2022-02-04
description: 'Solution'
---





本文重写于 2023.8.27



把每个外星人的存活时间看成是区间，那么本题又可以转化成那种经典模型。

区间的贡献在交点上。

设 $f(i,j)$ 为消灭被 $[i,j]$ 完全包含的所有区间的最小代价。

我们肯定是找到 $d$ 最大的那个区间一发干掉。

枚举干掉它的时间，以这个为轴，划分子问题 。



```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb push_back
#define eb emplace_back
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(b))
#define rep(i,j,k) for(int i=(j);i<=(k);++i)
#define per(i,j,k) for(int i=(j);i>=(k);--i)
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=605;
int T, n, m, t[N], f[N][N];
struct node {
    int l, r, d;
} a[N];
void lsh() {
    sort(t+1,t+m+1);
    m=unique(t+1,t+m+1)-t-1;
    rep(i,1,n) {
        a[i].l=lower_bound(t+1,t+m+1,a[i].l)-t;
        a[i].r=lower_bound(t+1,t+m+1,a[i].r)-t;
    }
}
void solve() {
    m=0;
    n=read();
    rep(i,1,n) {
        a[i].l=read(), a[i].r=read(), a[i].d=read();
        t[++m]=a[i].l, t[++m]=a[i].r;
    }

    lsh();
    SET(f,0x3f);
    for(int l=1;l<=m;++l) for(int i=1;i+l-1<=m;++i) {
        int j=i+l-1;
        int x=0;
        for(int k=1;k<=n;++k) if(i<=a[k].l&&a[k].r<=j) {
            if(a[k].d>a[x].d) x=k;
        }
        if(!x) { f[i][j]=0; continue; }
        for(int k=a[x].l;k<=a[x].r;++k) f[i][j]=min(f[i][j],f[i][k-1]+a[x].d+f[k+1][j]);
    }
    printf("%lld\n",f[1][m]);
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}

```
