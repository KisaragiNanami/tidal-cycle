---
title: luogu8595 「KDOI-02」 一个网的路 题解
pubDate: 2023-10-23
tags:
  - DP
  - 树形DP
  - 贪心
categories: 题解
description: 'Solution'
---

## Solution

考虑点 $x$ 被炸毁后会发生什么。

显然是与其子节点形成的链再连成一条链，它不一定是链头。但这个信息是没用的，因为此时怎么连，连成什么样子的代价都相同，并且没有后效性，到 $fa(x)$ 的边已经没了，再往外连的代价都是 $1$。

而如果不选择炸毁，则不同的形态是有后效性的。由于到 $fa(x)$ 的边保留了，所以要么此时子树搞成一条链，要么 $x$ 是链中的一部分，也就是连了两个儿子的链。后者要想接上就必须干掉到 $fa(x)$ 的边。

对每棵树分别考虑。

设 $f(x,0/1/2)$ 为以 $x$ 为根的子树，其中 $x$

0. 炸毁。
1. 不炸毁，$x$ 是链头。
2. 不炸毁，$x$ 不是链。

使得整个子树为一条链的最小代价。

$$
f(x,0) = 1 + \sum_{y \in son(x)} \min\Big\{ f(y,0),f(y,1),f(y,2)\Big\} + |son_x|
$$

对于 $f(x,1)$，至多有一个儿子没有被炸毁，对于 $f(x,2)$ 则是两个。同时二者的儿子中不允许出现 $f(y,2)$。

可以先令二者为

$$
\sum_{y \in son(x)} \Big( f(y,0)+1 \Big)
$$



然后维护 $\Delta = f(y,1) - f(y,0) - 1$ 的最小和次小值，如果更优就换出来。

注意不要求换够相应的数量。

把每棵树的答案累加，最后加上 $n-m-1$ 即可。

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
const int N=2e6+5, inf=1e15;
int n, m, ans, f[N][3];
vector<int> p[N];
bool v[N];
void dfs(int x,int fa) {
    v[x]=1;
    int dlt=0;
    int w[2]={0,0};
    // 注意这里是取最大值然后减掉
    // 如果<0那么就不换了
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        f[x][0]+=min({f[y][0],f[y][1],f[y][2]});
        dlt+=f[y][0]+1;
        int t=f[y][0]+1-f[y][1];
        if(t>w[0]) w[1]=w[0], w[0]=t;
        else if(t>w[1]) w[1]=t;
    }
    f[x][0]+=p[x].size()-(fa!=0)+1;
    f[x][1]=f[x][2]=dlt;
    f[x][1]-=w[0], f[x][2]-=w[0]+w[1];
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    rep(i,1,n) if(!v[i]) {
        dfs(i,0);
        ans+=min({f[i][0],f[i][1],f[i][2]});
    }
    printf("%lld\n",ans+n-m-1);
    return 0;
}
```
