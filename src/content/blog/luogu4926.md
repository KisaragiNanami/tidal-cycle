---
title: luogu4926 倍杀测量者 题解
tags: 差分约束系统
categories: 题解
pubDate: 2022-05-29
description: 'Solution'
---

## 分析

首先明确，对于 $o=1$ 的选手 $A$，他不用女装的条件是 $X_A \ge X_B \cdot(k-T)$。对于 $o=2$ 的选手 $A$，他不用女装的条件是 $X_A \cdot (k+T) > X_B$。

这个是不能用差分约束系统来求解的，因为变量之间的关系是乘法，但是如果将它们换成同底数的对数，那么相对大小不变且乘法就转化成了加法。所以

$$
X_A \ge X_B \cdot(k-T)
$$



$$
\log_2 (X_A) - \log_2 (X_B) \ge  \log2 (k-T)
$$

从 $B$ 向 $A$ 连一条权值为 $\log2 (k-T)$ 的边。

$$
X_A \cdot (k+T) > X_B
$$



$$
\log_2 (X_A) + \log_2 (k+T) > \log_2 (X_B)
$$

$$
\log_2(X_A) - \log_2 (X_B) > - \log_2(k+T)
$$

从 $B$ 向 $A$ 连一条权值为 $- \log_2 (k+T)$ 的边。

虽然两个式子一个是大于等于一个是大于，但是允许 $10^{-4}$ 的精度误差存在，所以这样连边是没问题的。

注意这样连边要用 SPFA 跑最长路判断正环（其实和最短路判断负环完全一样）。

还要建立一个虚拟源点 $n+1$，保证图连通。

&nbsp;

要找到最大的 $T$，显然二分答案，值域是 $[0,\min{\{ k \}}]$，否则 $k-T$ 就会出现负数。

题目中还给出了一些人的分数，一种方法是直接向虚拟源点 $n+1$ 连边。但是这么做的致命缺陷在于会导致一个节点有过多的子节点，会严重影响 SPFA 算法的速度。~~说不定还会卡掉 DFS-SPFA~~。

所以再建一个虚拟节点 $0$，对于每个 $C,x$，由 $0$ 向 $C$ 连一条权值为 $\log_2(x)$ 的边，由 $C$ 向 $0$ 连一条权值为 $-\log_2(x)$ 的边。这是常见的维护差分约束系统中已知量与未知量相对大小的套路。

这样做比直接连 $n+1$ 要快大概 200ms。

由于 $T$ 是二分确定的，所以加边的时候加的是原来的权值，通过 $o$ 的不同分类讨论确定边权。

最后，如果有正环，说明不全成立，一定有人要女装。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5005, inf=0x3f3f3f3f;
const double eps=1e-4;
int n, s, t;
int tot, h[N], cnt[N];
double d[N];
bool v[N];
struct node { int nxt, to, type; double w; } e[N<<1];
// type1是o=1，type2是o=2，type3是特殊边
void add(int x,int y,double z,int typ) {
    e[++tot].to=y, e[tot].w=z, e[tot].nxt=h[x], e[tot].type=typ, h[x]=tot;
}
bool spfa(double dlt) {
    for(int i=0;i<=n+1;++i) d[i]=-inf, cnt[i]=0, v[i]=0;
    queue<int> q;
    d[n+1]=0, q.push(n+1), v[n+1]=1;
    while(q.size()) {
        int x=q.front(); q.pop();
        v[x]=0;
        for(int i=h[x];i;i=e[i].nxt) {
            int y=e[i].to; double z=e[i].w;
            if(e[i].type==1) z=log2(z-dlt);
            else if(e[i].type==2) z=-log2(z+dlt);
            if(d[y]<d[x]+z) {
                d[y]=d[x]+z, cnt[y]=cnt[x]+1;
                if(cnt[y]>n+1) return 1;
                // 最长路中包含超过n+1条边，说明有正环
                // 比判断入队次数更快
                if(!v[y]) q.push(y), v[y]=1;
            }
        }
    }
    return 0;
}
int main() {
    double l=0, r=10;
    scanf("%d%d%d",&n,&s,&t);
    for(int i=1;i<=s;++i) {
        int op, a, b; double x;
        scanf("%d%d%d%lf",&op,&a,&b,&x);
        add(b,a,x,op);
        if(op&1) r=fmin(r,x);
    }
    for(int i=0;i<=n;++i) add(n+1,i,0,3);
    for(int i=1;i<=t;++i) {
        int c; double x;
        scanf("%d%lf",&c,&x);
        add(0,c,log2(x),3), add(c,0,-log2(x),3);
    }
    if(!spfa(0)) { puts("-1"); return 0; }
    // 最小的T还不成立，无解
    while(r-l>eps) {
        double mid=(l+r)/2;
        if(spfa(mid)) l=mid; else r=mid;
    }
    printf("%.6lf\n",l);
}
```
