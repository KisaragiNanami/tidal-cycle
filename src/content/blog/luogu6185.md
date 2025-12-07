---
title: luogu6185 序列 题解
tags:
  - 二分图
  - 并查集
categories: 题解
pubDate: 2022-05-01
description: 'Solution'
---

## 分析

把每个点的点权都搞成 $a_i - b_i$，问题转化为把所有节点权值都搞成 $0$。

有两种思路。

1. 用并查集维护 $1$ 操作，因为一个连通块内可以同加减。

2. 用并查集维护 $2$ 操作，因为一个连通块内可以多次使用，从而让任意节点加$1$，任意节点减 $1$。

虽然前者也具有传递性，但是对问题却没有帮助。

而后者隐藏着总和不变的信息——只有当总和为 $0$  时才有解。

同时连通块之间的 $1$ 操作，就相当于在二者差不变的情况下任意加减。

如果图是二分图，不存在奇环，那么就只能在上述情况下修改，因此要求这张二分图左部右部权值和相等。

否则连续使用 $1$ 操作，就能在节点权值奇偶性不变的情况下任意修改点权，别的点权也能往环上传递。因此对图黑白染色后，两种颜色的权值和要求同奇偶。这个黑白染色可以直接用上一步判断二分图剩下的。

## CODE

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
const int N=1e5+5;
int T, n, m, a[N], b[N];
int fa[N], w[N], col[N];
int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
void merge(int x,int y) {
    x=get(x), y=get(y);
    if(x!=y) fa[x]=y, w[y]+=w[x];
}
vector<int> p[N];
void add(int x,int y) {
    p[x].pb(y), p[y].pb(x);
}
int sum[5];
bool dfs(int x,int color) {
    col[x]=color;
    sum[color]+=w[x];
    int res=1;
    for(auto y:p[x]) {
        if(col[y]==color) res=0;
        if(!col[y]) res&=dfs(y,3-color);
    }
    return res;
}
void solve() {
    n=read(), m=read();
    rep(i,1,n) a[i]=read(), col[i]=0, p[i].clear(), fa[i]=i;
    rep(i,1,n) b[i]=read(), w[i]=a[i]-b[i];
    vector<PII > opt;
    rep(i,1,m) {
        int op=read(), x=read(), y=read();
        if(op==2) merge(x,y);
        else opt.pb({x,y});
    }
    for(auto t:opt) {
        int x=get(t.fi), y=get(t.se);
        add(x,y);
    }
    rep(i,1,n) if(i==fa[i]&&!col[i]) {
        sum[1]=sum[2]=0;
        bool isbin=dfs(i,1);
        if(isbin&&sum[1]!=sum[2]) { puts("NO"); return; }
        if(!isbin&&(sum[1]+sum[2])&1) { puts("NO"); return; }
    }
    puts("YES");
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}

```
