---
title: ABC259G Grid Card Game 题解
tags:
  - 图论
  - 网络流
  - 最小割
categories:
  - 题解
pubDate: 2022-07-13
description: 'Solution'
---

## 分析

既然可以不选择任何一行和任何一列，那么最大收益的最小值为 $0$。



设 $r_i = \sum_{j=1}^m a_{i,j}$，$c_{j} = \sum_{i=1}^n a_{i,j}$。如果 $r_i <0$ 或者 $c_j < 0$，那么选择 $i$ 行或 $j$ 列一定不优，可以直接无视。

选择 $i$ 行 $j$ 列的收益为 $r_i + c_j - a_{i,j}$。由于可以选择任意多行和列，那么一个思路就是先选择所有大于等于 $0$ 的 $r_i$ 和 $c_j$，再减去重复的 $a_{i,j}$。但是如果 $a_{i,j} < 0$，就不能选择 $r_i$ 和 $c_j$。

考虑最小割。

将行作为左部点，列作为右部点。若 $r_i \ge 0$。从源点向左部点 $i$ 连容量为 $r_i$ 边；若 $c_j \ge 0$，从右部点 $j$ 向汇点连容量为 $c_j$ 的边。

对于 $a_{i,j} \ge 0$，从 $i$ 向 $j$ 连容量为 $a_{i,j}$ 的边。对于 $a_{i,j} < 0$，从 $i$ 向 $j$ 连容量为 $\infty$ 的边。

在删去最小割的网络中，$S$ 与 $T$ 不连通，且容量为 $\infty$ 的边一定仍然存在。也就是说，对于容量为 $a_{i,j}$ 的边 $(i,j)$，由于 $r_i$ 与 $c_j$ 都大于等于 $0$，要么是 $r_i$ 和 $c_j$ 其中一个被删去，要么是 $a_{i,j}$ 被删去。对于容量为 $\infty$ 的边 $(i,j)$，一定是 $r_i$ 或者 $c_j$ 其中一个或者两个都被删去。

用所有大于等于 $0$ 的 $r_i$ 和 $c_j$ 的和减去最小割，就得到了最大收益。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=205, M=50005, inf=0x3f3f3f3f3f3f3f3f;
int n, m, s, t, a[N][N], d[N];
int tot=1, h[N], hh[N], to[M], w[M], nxt[M];
int ans, r[N], c[N];
bool v[N];
void add(int x,int y,int z) {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
} 
void addedge(int x,int y,int z) {
    add(x,y,z), add(y,x,0);
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
bool bfs() {
    queue<int> q;
    memset(d,0,sizeof(d));
    d[s]=1, q.push(s);
    while(q.size()) {
        int x=q.front(); q.pop();
        hh[x]=h[x];
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i], z=w[i];
            if(d[y]||!z) continue;
            d[y]=d[x]+1;
            q.push(y);
            if(y==t) return 1;
        }
    }
    return 0;
}
int dfs(int x,int flow) {
    if(x==t||!flow) return flow;
    int res=flow;
    for(int& i=hh[x];i;i=nxt[i]) {
        int y=to[i], z=w[i];
        if(d[y]!=d[x]+1||!z) continue;
        int k=dfs(y,min(res,z));
        if(!k) d[y]=0; else w[i]-=k, w[i^1]+=k, res-=k;
        if(!res) return flow;
    }
    return flow-res;
}
int dinic() {
    int maxflow=0;
    while(bfs()) maxflow+=dfs(s,inf);
    return maxflow;
}
signed main() {
    n=read(), m=read();
    s=0, t=n+m+1;
    for(int i=1;i<=n;++i) for(int j=1;j<=m;++j) {
        a[i][j]=read();
        r[i]+=a[i][j], c[j]+=a[i][j];
        if(a[i][j]>=0) addedge(i,j+n,a[i][j]); else addedge(i,j+n,inf);
    }
    for(int i=1;i<=n;++i) if(r[i]>=0) {
        ans+=r[i];
        addedge(s,i,r[i]);
    }
    for(int i=1;i<=m;++i) if(c[i]>=0) {
        ans+=c[i];
        addedge(i+n,t,c[i]);
    }
    printf("%lld\n",ans-dinic());
}
```
