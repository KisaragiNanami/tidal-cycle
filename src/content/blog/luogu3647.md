---
title: luogu3647 [APIO2014] 连珠线
pubDate: 2023-10-23
tags:
  - DP
  - 树形DP
  - 换根法
categories:
  - 题解

---

## Solution

首先要读明白题。

一开始**只有一个点**，只能在一个已有点和**刚加入的新点**之间连接红线，同时要保证始终只有一个连通块。

机房里有人因为理解错题意导致做不动。

发现不知道初始点做起来是相当胃疼的，具体怎么胃疼可以自行手玩。

枚举初始点，把初始点作为树根，这样所有的蓝边都是由祖孙生成的。

设 $f(x,0/1)$ 为以 $x$ 为根的子树中，$x$ 不是/是蓝边的中点的最大收益。

转移是平凡的。
$$
f(x,0) = \sum_{y \in son(x)} \max\Big( f(y,0),f(y,1)+z \Big)
$$
对于 $f(x,1)$，我们能发现其相比 $f(x,0)$ 仅仅多了一个限制条件：有且仅有一个儿子作为蓝边端点。

直接令 $f(x,1) = f(x,1)$，然后加上 $\Delta = \max\Big\{ f(y,0)+z - \max\Big( f(y,0),f(y,1)+z \Big) \Big\}$，把最优的那一个换出来即可。

这样做是 $O(n^2)$ 的，考虑优化。

每个子节点都是相对独立的，只需要记录 $\Delta$ 的次大值即可换根，复杂度 $O(n)$。

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
const int N=2e5+5, inf=0x1f1f1f1f1f1f1f1f;
int n, ans, f[N][2], d[N], mx[N][2], w[N];
vector<PII > p[N];
#define calc(y,z) f[y][0]+z-max(f[y][0],f[y][1]+z)
void dfs(int x,int fa) {
    f[x][0]=0, f[x][1]=0;
    mx[x][0]=mx[x][1]=-inf;
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
        if(y==fa) { continue; }
        dfs(y,x);
        f[x][0]+=max(f[y][0],f[y][1]+z);

        int d=calc(y,z);
        if(d>mx[x][0]) mx[x][1]=mx[x][0], mx[x][0]=d;
        else if(d>mx[x][1]) mx[x][1]=d;
    }
    f[x][1]=f[x][0]+mx[x][0];
}
void dfs2(int x,int fa) {
    ans=max(ans,f[x][0]);
    int fx0=f[x][0], fx1=f[x][1];
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
        if(y==fa) continue;

        int fy0=f[y][0], fy1=f[y][1];
        int my0=mx[y][0], my1=mx[y][1];

        f[x][0]-=max(f[y][0],f[y][1]+z);
        int d=calc(y,z);

        f[x][1]=f[x][0]+(d==mx[x][0]? mx[x][1]:mx[x][0]);
        f[y][0]+=max(f[x][0],f[x][1]+z);
        d=calc(x,z);
        if(d>mx[y][0]) mx[y][1]=mx[y][0], mx[y][0]=d;
        else if(d>mx[y][1]) mx[y][1]=d;

        f[y][1]=f[y][0]+mx[y][0];
        dfs2(y,x);

        f[x][0]=fx0, f[x][1]=fx1;
        f[y][0]=fy0, f[y][1]=fy1, mx[y][0]=my0, mx[y][1]=my1;
    }
}
signed main() {
    n=read();
    rep(i,2,n) {
        int x=read(), y=read(), z=read();
        p[x].pb({y,z}), p[y].pb({x,z});
    }
    dfs(1,0);
    dfs2(1,0);
    printf("%lld\n",ans);
    return 0;
}

```
