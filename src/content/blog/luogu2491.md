---
title: luogu2491 消防 题解
tags:
  - 树的直径
  - 单调队列
categories:
  - 题解
description: 'Solution'
pubDate: 2021-10-01
---

实际上就是 [树网的核](https://www.luogu.com.cn/problem/P1099) 的数据加强版。



原题暴力枚举即可，本题也可以用复杂度为 $O(n\log SUM)$ 的二分答案，这里只讲述单调队列的 $O(n)$ 算法。

题意：在树的直径上选择两个距离不超过 $s$ 的点，最小化「偏心距」。

「偏心距」：考虑选出的两个点构成的路径，偏心距即为所有点到这条路径的距离取最大值。

显然，可以用单调队列维护。

设直径为 $u$，其节点数为 $o$，直径上两点为 $(u_i,u_j)$，$f(x)$ 为从 $x$ 出发，不经过直径上的其他点，能够到达的最远距离。$dis(x,y)$ 为 $(x,y)$ 之间的距离。

不难想到此时偏心距为

$$
\max_{dis(i,j)\in [1,s]} {\{\max_{i \le k \le j} { \{ f(k) \},dis(u_1,u_i),dis(u_j,u_s) \} } }
$$



仔细观察不难发现，$f(k)$ 的定义域为 $[1,s]$，而无论如何选择两个点，最终一定取到 $\max_{k \in [1,s]} { \{f(s)\} }$。

所以上式可化为

$$
\max_{dis(i,j) \in [1,s]} { \{ \max_{k \in [1,s]}{\{ f(k) \}},dis(u_1,u_i),dis(u_j,u_o) \} }
$$



而 $\max_{k \in [1,s]} { \{f(s)\} }$ 

是一个定值，设其为 $K$。

求出 $u$ 上节点距离的前缀和数组 $S$。

则

$$
\max_{dis(i,j) \in [1,s]}{ \{ K, \max ( S(i),S(o)-S(j) ) \} }
$$



用单调队列维护队头为 满足 $S(j)-S(i) \le s$ 的最大的  $j$ 即可。

写的很麻烦……

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=3e5+10;
int n, s, t, mx, o, d[N], f[N], sum[N], a[N], b[N];
int c, h[N], ver[N<<1], w[N<<1], nxt[N<<1];
bool v[N];
void add(int x,int y,int z) { ver[++c]=y, w[c]=z, nxt[c]=h[x], h[x]=c; }
void DFS(int x,int fa) {
    // 这个是用来找直径的
    f[x]=fa;
    for(int i=h[x];i;i=nxt[i]) if(ver[i]!=fa) {
        int y=ver[i], z=w[i];
        d[y]=d[x]+z;
        if(d[y]>mx) mx=d[y], o=y;
        DFS(y,x);
    }
}
void dfs(int x) {
    v[x]=1;
    for(int i=h[x];i;i=nxt[i]) if(!v[ver[i]]) {
        // 不经过直径上的点
        int y=ver[i], z=w[i];
        dfs(y);
        f[x]=max(f[x],f[y]+z);
    }
    // 找距离
}
void ddfs(int x,int fa) {
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i], z=w[i];
        if(v[y]&&y!=fa) a[++t]=x, b[t]=z, ddfs(y,x);
    }
    // a[]存直径节点编号，b[]存边权
    // 这种做法会漏掉直径最后一个点，不过不影响
}
int main() {
    int k=0, ans=1<<30;
    scanf("%d%d",&n,&s);
    for(int i=1;i<n;++i) {
        int x, y, z; scanf("%d%d%d",&x,&y,&z);
        add(x,y,z), add(y,x,z);
    }
    int p, q;
    DFS(1,0), p=o, mx=d[o]=0;
    DFS(p,0), q=o;
    // 这时候f[x]表示x的父亲
    while(p!=q) v[q]=1, q=f[q];
    // 标记直径上的点
    ddfs(q,0);
    // 累加直径上的边
    memset(f,0,sizeof(f));
    for(int i=1;i<=t;++i) {
        dfs(a[i]);
        // 这时候f[]表示能到达的最远距离
        k=max(k,f[a[i]]);
        sum[i]=sum[i-1]+b[i];
    }
    int l, r, qq;
    // qq记录到直径最远的距离
    for(l=1,r=1;l<=t;++l) {
        while(r<t&&sum[r+1]-sum[l]<=s) ++r;
        qq=max(k,max(sum[l],sum[t]-sum[r]));
        ans=min(ans,qq);
    }
    printf("%d\n",ans);
}
```
