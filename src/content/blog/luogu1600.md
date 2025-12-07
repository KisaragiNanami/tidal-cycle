---
title: luogu1600 天天爱跑步 题解
tags:
  - 树上差分
  - 树论
categories: 题解
pubDate: 2021-10-02
description: 'Solution'
---



本文重构于 2023.9.4。

&nbsp;



考虑能观察到玩家的条件。

设 $\text{dep}(x)$ 为节点 $x$ 的深度，$z_i=\text{LCA}(s_i,t_i)$。

我们把路径 $(s_i,t_i)$ 分成 $(s_i,z_i)$ 和 $(z_i,t_i)$。观察员 $x$ 能观察到玩家 $i$，一定满足二者之一

1. $ \text{dep}(s_i) - \text{dep}(x) =w_x$
2. $ \text{dep}(s_i) - \text{dep}(z_i)+ \text{dep}(x)-\text{dep}(z_i) =w_x$

同时注意需要满足 $\text{dep}(x) \ge \text{dep}(z_i)$。

整理可得

1. $w_x + \text{dep}(x) = \text{dep}(s_i)$
2. $w_x - \text{dep}(x) = \text{dep}(s_i) - 2\text{dep}(z_i)$

问题转化为对于一个 $x$，求满足上述条件的 $i$ 的数量，同时限定 $x$ 必须在路径 $(s_i,t_i)$ 上。

把路径的贡献差分成前缀贡献，放到 $s_i,t_i,z_i,fa(z_i)$ 上，在 $s_i$ 与 $t_i$ 处产生贡献，在 $z_i$ 与 $fa(z_i)$ 处消去贡献即可。问题转化为求对应值的子树和。

注意到值域不大，我们可以开一个桶，访问时和回溯时做个差就是答案。

```cpp
// Problem: P1600 [NOIP2016 提高组] 天天爱跑步
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P1600
// Author: yozora0908
// Date: 2023-07-17 19:45:32
// Memory Limit: 512 MB
// Time Limit: 2000 ms
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
const int N=3e5+5;
int n, m, a[N], ans[N], c1[N<<1], c2[N<<1];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
int sz[N], fa[N], son[N], dep[N], top[N]; 
vector<int> a1[N], a2[N], b1[N], b2[N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dfs1(int x,int fr) {
    fa[x]=fr, dep[x]=dep[fr]+1;
    sz[x]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i], z=w[i];
        if(y==fr) continue;
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
void dfs(int x) {
    int dlt=c1[a[x]+dep[x]]+c2[a[x]-dep[x]+n];
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa[x]) continue;
        dfs(y);
    }
    for(auto y:a1[x]) ++c1[y];
    for(auto y:b1[x]) --c1[y];
    for(auto y:a2[x]) ++c2[y+n];
    for(auto y:b2[x]) --c2[y+n];
    ans[x]=c1[a[x]+dep[x]]+c2[a[x]-dep[x]+n]-dlt;
}
signed main() {
    n=read(), m=read();
    rep(i,2,n) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    rep(i,1,n) a[i]=read();
    dfs1(1,0);
    dfs2(1,1);
    rep(i,1,m) {
        int x=read(), y=read();
        int z=lca(x,y);
        a1[x].pb(dep[x]), b1[fa[z]].pb(dep[x]);
        a2[y].pb(dep[x]-2*dep[z]), b2[z].pb(dep[x]-2*dep[z]);
    }
    dfs(1);
    rep(x,1,n) printf("%lld ",ans[x]);
    return 0;
}
```
