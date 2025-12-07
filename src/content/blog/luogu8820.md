---
title: luogu8820 数据传输 题解
pubDate: 2023-09-07
tags:
  - 树论
  - 树上倍增
  - DP
categories: 题解
description: 'Solution'
---



下文用 $step$ 代替题目中的 $k$。

## 部分分

先考虑一下暴力怎么打。

$k=1$ 的情况等于送的，就不说了。

对于前 $11$ 个点，可以用 $n$ 次 $\text{BFS}$ 预处理出树上任意两点距离，对能够到达的点连边，跑 $n$ 遍 $\text{Dijkstra}$ 再回答询问，实测 LOJ 可以通过。

虽然题目没有设置特殊图的部分分，但是这里仍然提一嘴。

链怎么做？我们能发现在链上通过反复横跳来避免到达某些节点是不优的，所以设 $f(i)$ 为到达位置 $i$ 的最小点权和，有

$$
f(i) = \min_{j=1}^{step} \{ f(i-j) \}
$$



可以矩阵加速。

菊花是送的。

## 正解

由于本人不会动态 DP，所以只能参考 Dottle 的树上倍增做法。

我们遇到的最大困难，就是从 $x$ 往 $y$ 跳的过程可以不只经过路径 $(x,y)$ 上的点，从而大大增多了要考虑的情况。

先转化一下图论模型：寻找代价最小的一条从 $x$ 到 $y$ 的路径，其中代价定义为路径中的若干节点的点权。可以自己指定哪些点权计入答案，但是不允许出现连续的 $step$ 个点不计入答案。

设二元组 $(x,k)$ 表示到达节点 $x$，包括 $x$ 在内，最后一段已经有 $k$ 个节点没有标记。

建议新图，连两种边：

1. 如果树中有边 $(x,y)$，连边 $(x,k) \rightarrow (y,0)$，权值为 $v_y$。
2. 如果树中有边 $(x,y)$，且 $k+1<step$那么连边 $(x,k) \rightarrow (y,k+1)$，权值为 $0$。
   
   

由于 $(x,y)$ 路径上的点可能不被计入答案，但是一定会以某种方式被经过，可以用倍增来优化。

设 $f(x,i)$ 表示原树中 $x$ 的 $2^i$ 级祖先， $d(x,i,a,b)$ 表示在新图中，从 $(x,a)$ 到达 $\Big( f(x,i),b\Big)$ 的最小边权。

下面讨论如何求出 $d(x,0,a,b)$，为了方便就不打公式了。

```cpp
// int d[N][18][3][3];

auto D=d[x][0];
if(step==1) D[0][0]=v[fa];
else if(step==2) D[0][0]=D[1][0]=v[fa], D[0][1]=0;
else {
    D[0][0]=D[1][0]=D[2][0]=v[fa];
    D[0][1]=D[1][2]=0;
    D[0][2]=D[2][2]=mn[x];
    // mn[x]表示与x相邻点中的最小点权
}
// D[k][0]与D[k][k+1]的边就是上文叙述的
// 比较特殊的是从x跳到一个中转点，贡献中转点的点权后再到达fa，同时不贡献v[fa]
// 不难发现当step=1和2时，都一定会贡献出v[fa]
// 想要贡献出mn[x]而不是v[fa]，那么D的第二维一定是2
```

然后就是常规倍增，把状态从中间拼起来即可。

对于一个询问 $(x,y)$，我们求出  $z = \text{LCA}(x,y)$，分别从 $x$ 和 $y$ 往 $z$ 跳，倍增出关于所有状态的最优解，最后从 $z$ 处拼起来即可。

注意有 corner case。

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
const int N=2e5+5, inf=0x0f0f0f0f0f0f0f0f;
int n, Q, lim, step, v[N], mn[N];
int f[N][18], dep[N];
int d[N][18][3][3];
vector<int> p[N];
void dfs(int x,int fa) {
    f[x][0]=fa;
    dep[x]=dep[fa]+1;
    for(int i=1;(1<<i)<=dep[x];++i) f[x][i]=f[f[x][i-1]][i-1];
    auto D=d[x][0];
    if(step==1) D[0][0]=v[fa];
    else if(step==2) D[0][0]=D[1][0]=v[fa], D[0][1]=0;
    else {
        D[0][0]=D[1][0]=D[2][0]=v[fa];
        D[0][1]=D[1][2]=0;
        D[0][2]=D[2][2]=mn[x];
    }
    for(int i=1;(1<<i)<=dep[x];++i) rep(a,0,2) rep(b,0,2) rep(c,0,2) {
        d[x][i][a][c]=min(d[x][i][a][c],d[x][i-1][a][b]+d[f[x][i-1]][i-1][b][c]);
    }
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
    }
}
int lca(int x,int y) {
    if(dep[x]<dep[y]) swap(x,y);
    for(int i=lim;~i;--i) if(dep[f[x][i]]>=dep[y]) x=f[x][i];
    if(x==y) return x;
    for(int i=lim;~i;--i) if(f[x][i]!=f[y][i]) x=f[x][i], y=f[y][i];
    return f[x][0];
}
vector<int> calc(int x,int y) {
    vector<int> res(3,v[x]);
    // 小技巧，把所有状态的答案扔进一个vector里面
    for(int i=lim;~i;--i) if(f[x][i]&&dep[f[x][i]]>=dep[y]) {
        vector<int> t(3,inf);
        rep(a,0,2) rep(b,0,2) t[b]=min(t[b],res[a]+d[x][i][a][b]);
        x=f[x][i];
        res=t;
    }
    return res;
}
int solve(int x,int y) {
    int z=lca(x,y);
    auto F=calc(x,z), G=calc(y,z);
    int res=inf;
    rep(i,0,step-1) rep(j,0,step-1) if(F[i]!=inf&&G[j]!=inf) {
        if(i==0&&j==0) res=min(res,F[i]+G[j]-v[z]); // 此时v[z]会被重复计算
        else if(i+j>step) res=min(res,F[i]+G[j]+mn[z]); // 此时必须找一个落脚点才能拼起来
        else res=min(res,F[i]+G[j]);
    }
    return res;
}
signed main() {
    freopen("transmit.in","r",stdin);
    freopen("transmit.out","w",stdout);
    n=read(), Q=read(), step=read();
    rep(i,1,n) v[i]=mn[i]=read();
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
        mn[x]=min(mn[x],v[y]);
        mn[y]=min(mn[y],v[x]);
    }
    while((1<<(lim+1))<=n) ++lim;
    SET(d,0x0f);
    dfs(1,0);
    while(Q--) {
        int x=read(), y=read();
        printf("%lld\n",solve(x,y));
    }
    return 0;
}
```


