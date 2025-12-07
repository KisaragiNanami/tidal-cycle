---
title: luogu2446 大陆争霸 题解
urls: lg2446-solution
tags: 最短路
categories:
  - 题解
description: 'Solution'
pubDate: 2021-10-02
---

每个点都必须在到到达所有保护它的点后才能进入，我们用一种类似拓扑排序的方式求解。



设 $p(x)$ 为能够到达节点 $x$ 最早的时间，$q(x)$ 为能够进入节点 $x$ 最早的时间，$d(x)$ 为摧毁 $x$ 最早的时间。

设 $ind(x)$ 为保护节点 $x$ 的点的个数。

显然 $p(x)$ 可以直接用最短路算法求出。

设 $(x \rightarrow y)$，则

$$
q(y)= \max{\{d(x)\}}
$$



$x$ 被摧毁后自然能够到达 $y$。

当保护节点 $x$ 的点处理完之后，就能进行 $d(x)$ 的转移。

因为有无限多的机器人，所以节点 $x$ 能够到达的那一刻就能够被摧毁。

$$
d(x)= \max{\{ p(x),q(x) \}}
$$



具体细节看代码。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define R register
#define PII pair<int,int>
#define mp make_pair
const int N=3e3+10, M=1e6+10;
int n, m, d[N], p[N], q[N], ind[N];
int cnt, h[N], ver[M<<1], nxt[M<<1], w[M<<1];
int tc, hc[N], vc[M<<1], nc[M<<1];
bool v[N];
void add(int x,int y,int z) { ver[++cnt]=y, w[cnt]=z, nxt[cnt]=h[x], h[x]=cnt; }
void addc(int x,int y) { vc[++tc]=y, nc[tc]=hc[x], hc[x]=tc; }
void dijk() {
    R int i, x, y, z;
    R priority_queue<PII > pq;
    memset(d,0x3f,sizeof(d)), memset(p,0x3f,sizeof(p));
    d[1]=p[1]=q[1]=0, pq.push(mp(0,1));
    while(pq.size()) {
        x=pq.top().second, pq.pop();
        if(v[x]) continue;
        v[x]=1;
        for(i=h[x];i;i=nxt[i]) {
            y=ver[i], z=w[i];
            if(p[y]>d[x]+z) {
                p[y]=d[x]+z;
                if(!ind[y]) d[y]=max(p[y],q[y]), pq.push(mp(-d[y],y));
            }
        }
        for(i=hc[x];i;i=nc[i]) {
            y=vc[i], q[y]=max(q[y],d[x]);
            if(--ind[y]==0) {
                d[y]=max(p[y],q[y]);
                pq.push(mp(-d[y],y));
            }
        }
    }
}
int main() {
    R int i, j, x, y, z;
    scanf("%d%d",&n,&m);
    for(i=1;i<=m;++i) scanf("%d%d%d",&x,&y,&z), add(x,y,z);
    for(i=1;i<=n;++i) {
        scanf("%d",&x);
        while(x--) scanf("%d",&y), ++ind[i], addc(y,i);
    }
    dijk();
    printf("%d\n",d[n]);
}
```
