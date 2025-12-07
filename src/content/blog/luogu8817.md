---
title: luogu8817 假期计划 题解
tags:
  - 图论
categories:
  - 题解
pubDate: 2022-11-12
description: 'Solution'
---

## 分析

用 $n$ 次 BFS 求出任意两点之间的距离。

枚举 $b,c$，预处理 $p(b,0/1/2)$，表示能到达 $1$ 和 $b$ 的最大/次大/第三大值，$q(c,0/1/2)$ 同理。

那么接下来就是要求选出的两个点不等于 $b,c$ 且不相等，是一个大分类讨论。

但是注意到最多 $9$ 种搭配，所以只要求合法的最大值即可。

教训：不要上来就刚分类讨论，一定要把思路完善到底。对于这类有着很有限的情况和很复杂的分类，可以枚举所有合法方案取最优。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=2505;
int n, m, k, ans, a[N], p[N][3], q[N][3], d[N][N];
int tot, h[N], to[8*N], nxt[8*N];
// 边数用了2*N，调了好久才破案，教训+1
int v[N], vis[N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
    add(x,y), add(y,x);
}
void bfs(int s,int* d) {
    queue<int> q;
    for(int i=1;i<=n;++i) vis[i]=0;
    d[s]=0;
    vis[s]=1;
    q.push(s);
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(vis[y]) continue;
            vis[y]=1;
            d[y]=d[x]+1;
            q.push(y);
        }
    }
}
void doit() {
    for(int i=2;i<=n;++i) {
        for(int j=2;j<=n;++j) {
            if(i==j) continue;
            if(d[1][j]>k+1||d[j][i]>k+1) continue;
            if(a[j]>a[p[i][0]]) {
                p[i][2]=p[i][1], p[i][1]=p[i][0], p[i][0]=j;
            } else if(a[j]>a[p[i][1]]) {
                p[i][2]=p[i][1], p[i][1]=j;
            } else if(a[j]>a[p[i][2]]) p[i][2]=j;
            if(a[j]>a[q[i][0]]) {
                q[i][2]=q[i][1], q[i][1]=q[i][0], q[i][0]=j;
            } else if(a[j]>a[q[i][1]]) {
                q[i][2]=q[i][1], q[i][1]=j;
            } else if(a[j]>a[q[i][2]]) q[i][2]=j;
        }
    }
}
void check() {
    for(int i=1;i<=n;++i) for(int j=1;j<=n;++j) if(!d[i][j]) d[i][j]=114514;
    // 图可能不连通，这个函数很重要
}
signed main() {
    n=read(), m=read(), k=read();
    for(int i=2;i<=n;++i) a[i]=read();
    for(int i=1;i<=m;++i) {
        int x=read(), y=read();
        addedge(x,y);
    }
    for(int i=1;i<=n;++i) bfs(i,d[i]);
    check();
    doit();
    for(int b=2;b<=n;++b) for(int c=2;c<=n;++c) {
        if(!p[b][0]) break;
        if(b==c||d[b][c]>k+1||p[c][0]==0) continue;
        for(int i=0;i<3;++i) for(int j=0;j<3;++j) {
            if(p[b][i]&&q[c][j]&&p[b][i]!=q[c][j]&&p[b][i]!=c&&q[c][j]!=b)
                ans=max(ans,a[p[b][i]]+a[q[c][j]]+a[b]+a[c]);
        }
    }
    printf("%lld\n",ans);
}
```
