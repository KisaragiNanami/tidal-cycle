---
title: luogu6748 Fallen Lord 题解
tags:
  - DP
  - 树形DP
  - 贪心
categories:
  - 题解
description: 'Solution'
pubDate: 2022-10-23
---

$\texttt{analysis}$

发现每条边 $(x,y)$ 的权值只可能是 $a_x$，$a_y$，$m$。

对于一个节点 $x$，与它相连的所有边权的中位数不超过 $a_x$，那么 $deg_x$ 条边中，最多有 $\lfloor \frac{deg_x}{2} \rfloor + 1$ 条边小于等于 $a_x$，也就是至多有 $\lceil \frac{deg_x}{2} \rceil - 1$ 条边权大于 $a_x$。设其为 $t$。

设 $f(x,0/1)$ 表示以 $x$ 为根的子树的最大价值，其中 $(x,fa_x)$ 的权值是小于等于还是大于 $a_x$。

对于 $f(x,0)$，在 $x$ 连向子节点的边中，最多可以有 $t$ 条边大于 $a_x$。对于 $f(x,1)$，这样的边数为 $t-1$。

考虑 $x$ 的子节点 $y$，分类讨论一下其对 $0$ 和 $1$ 状态的贡献 $g_{0/1}$，那么 $f(x,0)$ 能取 $t$ 个 $g_1$，$f(x,1)$ 少 $1$ 个。

$$
g_0 = \begin{cases}\max\Big(f(y,0)+a_y, f(y,1)+a_x\Big) & a_y \le a_x \\ \max\Big(f(y,0)+a_x, f(y,1)+a_x \Big) & a_y > a_x\end{cases}
$$



$$
g_1 = \begin{cases}
\max\Big(f(y,0)+a_y, f(y,1)+m \Big) & a_y \le a_x
\\
\max\Big( f(y,0)+a_y, f(y,1)+m \Big) & a_y > a_x
\end{cases}
$$

能发现 $g1 \ge g_0$，因此先求 $g_0$ 的和，把 $g_1-g_0$ 扔进一个优先队列里面，换出最大的几个 $g_1$ 即可。

特别的，当 $t=0$ 时，$f(x,1) = -\infty$。

答案是 $\max \Big( f(1,0),f(1,1)\Big)$。

$\texttt{code}$

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long 
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
const int N=5e5+5;
int n, m, a[N], deg[N], f[N][2], s[N], g[N];
vector<int> p[N];
#define pb emplace_back
void dfs(int x,int fa) {
    int dlt=0, t=(deg[x]+1)/2-1;
    priority_queue<int> q;
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        int g0=max(f[y][0]+min(a[x],a[y]),f[y][1]+a[x]);
        int g1=max(f[y][0]+a[y],f[y][1]+m);
        dlt+=g0;
        q.push(g1-g0);
    }
    f[x][0]=f[x][1]=dlt;
    for(int i=1;i<=t;++i) {
        int z=q.top(); q.pop();
        f[x][0]+=z;
        if(i!=t) f[x][1]+=z;
        // 这个最好循环到t，特判i!=t时不给f[x][1]
        // 为了避免t=0和1时f[x][0]没有被修改
    }
    if(!t) f[x][1]=-1e15;
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) a[i]=read();
    rep(i,2,n) {
        int x=read(), y=read();
        ++deg[x], ++deg[y];
        p[x].pb(y), p[y].pb(x);
    }
    dfs(1,0);
    printf("%lld\n",max(f[1][0],f[1][1]));
}
```
