---
title: luogu3778 商旅 题解
categories: 题解
tags:
  - 图论
  - 分数规划
  - 二分答案
description: 'Solution'
pubDate: 2021-08-01
---





本文重构于 2023.9.4



预处理 $w(i,j)$ 表示从 $i$ 出发到达 $j$ 能得到的最大收益，$d(i,j)$ 表示 $i$ 到 $j$ 的最短路。



然后我们把任意 $(i,j)$ 都提取出来，当成一张新图。

套路性地二分答案 $mid$，这个答案可行的条件是存在环 $C$ 使得

$$
\sum_{(x,y) \in C} w(x,y) - mid \times \sum_{(x,y) \in C} d(x,y) \ge 0
$$

把总和摊到每条边上。具体地，新图上 $(x,y)$ 之间的边权为 $w(x,y) - mid \times d(x,y)$。

用 $\text{Floyd}$ 算法找一下是否存在权值非负的环即可。

```cpp
// Problem: P3778 [APIO2017] 商旅
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3778
// Author: yozora0908
// Memory Limit: 500 MB
// Time Limit: 3000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=105, M=1005, inf=1e15;
int n, m, cnt;
int s[N][M], b[N][M], w[N][N];
int d[N][N], f[N][N];
int l, r;
void floyd() {
    rep(k,1,n) rep(i,1,n) if(d[i][k]!=inf) {
        rep(j,1,n) if(d[k][j]!=inf) d[i][j]=min(d[i][j],d[i][k]+d[k][j]);
    }        
}
void prework() {
    rep(i,1,n) rep(j,1,n) {
        rep(k,1,cnt) if(b[i][k]!=-1&&s[j][k]!=-1) {
            w[i][j]=max(w[i][j],s[j][k]-b[i][k]);
        }
        r=max(r,w[i][j]);
    }
    floyd();
}
bool check(int mid) {
    int ans=-inf;
    rep(i,1,n) rep(j,1,n) {
        if(i==j) f[i][j]=-inf;
        else if(d[i][j]==inf) f[i][j]=-inf;
        else f[i][j]=w[i][j]-mid*d[i][j];
    }
    rep(k,1,n) rep(i,1,n) if(f[i][k]!=-inf) {
        rep(j,1,n) if(f[k][j]!=-inf) {
            f[i][j]=max(f[i][j],f[i][k]+f[k][j]);
        }
    }
    rep(i,1,n) ans=max(ans,f[i][i]);
    return ans>=0;
}
signed main() {
    n=read(), m=read(), cnt=read();
    rep(i,1,n) rep(j,1,n) d[i][j]=inf;
    rep(i,1,n) {
        rep(j,1,cnt) {
            b[i][j]=read();
            s[i][j]=read();
        }
    }
    rep(i,1,m) {
        int x=read(), y=read(), z=read();
        d[x][y]=min(d[x][y],z);
    }
    prework();
    while(l<r) {
        int mid=(l+r+1)>>1;
        if(check(mid)) l=mid; else r=mid-1;
    }
    printf("%lld\n",l);
    return 0;
}
```








