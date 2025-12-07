---
title: luogu2680 运输计划 题解
tags:
  - 二分答案
  - 树上差分
  - 树论
categories:
  - 题解
description: 'Solution'
pubDate: 2021-10-04
---

## Solution

首先答案是可以二分的。

问题转化为：判定是否能通过把一条边的权值置为 $0$，使得给定的路径中，最长的路径不超过 $mid$，

我们考虑所有长度超过 $mid$ 的路径，设其的数量为 $cnt$。那么 $mid$ 可行当且仅当存在一条被经过 $cnt$ 次，并且其长度大于等于 $\max_{i=1}^m \big\{dis(u_i,v_i) \big\} - mid$。

怎么做？把路径差分了再做子树和，求出每条边被覆盖的次数，检查一遍即可。

但是这题卡常，需要预处理出 $\text{DFS}$ 序再倒着做子树和。

```cpp
// Problem: P2680 [NOIP2015 提高组] 运输计划
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P2680
// Author: yozora0908
// Memory Limit: 292 MB
// Time Limit: 1000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

#include<bits/stdc++.h>
using namespace std;
#define ll long long
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
const int N=3e5+5;
int n, m, c[N];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
int sz[N], fa[N], son[N], dep[N], d[N], top[N];
int num,  idf[N];
struct node {
    int x, y, z, d;
} a[N];
void add(int x,int y,int z)  {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
void dfs1(int x,int fr) {
    fa[x]=fr, dep[x]=dep[fr]+1;
    idf[++num]=x;
    sz[x]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i], z=w[i];
        if(y==fr) continue;
        d[y]=d[x]+z;
        dfs1(y,x);
        if(!son[x]||sz[y]>sz[son[x]]) son[x]=y;
        sz[x]+=sz[y];
    }
}
void dfs2(int x,int tp) {
    top[x]=tp;
    if(!son[x]) return;
    dfs2(son[x],tp);
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa[x]||y==son[x]) continue;
        dfs2(y,y);
    }
}
int lca(int x,int y) {
    while(top[x]!=top[y]) {
        if(dep[top[x]]<dep[top[y]]) swap(x,y);
        x=fa[top[x]];
    }
    return     dep[x]<dep[y]? x:y;
}
bool check(int x) {
    int mx=0, cnt=0;
    rep(i,1,n) c[i]=0;
    for(int i=1;i<=m;++i) if(a[i].d>x) {
        ++c[a[i].x], ++c[a[i].y], c[a[i].z]-=2;
        mx=max(mx,a[i].d-x);
        ++cnt;
    }
    per(i,n,1) c[fa[idf[i]]]+=c[idf[i]];
    rep(i,2,n) if(d[i]-d[fa[i]]>=mx&&c[i]==cnt) {
        return 1;
    }
    return 0;
}
signed main() {
    n=read(), m=read();
    rep(i,2,n) {
        int x=read(), y=read(), z=read();
        add(x,y,z), add(y,x,z);
    }
    dfs1(1,0);
    dfs2(1,1);
    int L=0, R=0;
    rep(i,1,m) {
        a[i].x=read(), a[i].y=read();
        a[i].z=lca(a[i].x,a[i].y);
        a[i].d=d[a[i].x]+d[a[i].y]-2*d[a[i].z];
        R=max(R,a[i].d);
    }
    while(L<R) {
        int mid=(L+R)>>1;
        if(check(mid)) R=mid; else L=mid+1;
    }
    printf("%d\n",L);
    return 0;
}
```
