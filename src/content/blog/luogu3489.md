---
title: luogu3489 WIE-Hexer 题解
tags:
  - DP
  - 状态压缩
  - 最短路
categories: 题解
description: 'Solution'
pubDate: 2022-02-09
---

## 分析

预处理出每个铁匠能够打造的剑能够打败的怪物集合 $s(x)$ 与每条道路上的怪物集合 $u(x)$。还是正常连边。

设 $f(i,S)$ 为从起点到节点 $i$，能够打败的怪物集合为 $S$ 时，花费的最小时间。状态是一张图，用 Dijkstra 算法转移。



边界自然是 $f(1,s(1)=0)$。考虑 $x$ 的子节点 $y$，$i$ 为 $x \rightarrow y$ 的边。如果 $u(i)$ 中包含 $S_x \cup s(x)$ 中不包含的元素，那么在 $x$ 打造的剑和之前的剑就不能打败路上的怪物，不能转移。更数学一点，若 $S_0 =S_x \cup s(x)$，$S_0 \cup u(i) \neq S_0$，那么不能转移。然后就是板子了。

答案：第一次到达 $n$ 时的最小时间。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=205, M=6005, O=(1<<13)+5, inf=0x3f3f3f3f;
int n, m, p, k, ans=inf, d[N][O], s[N];
int cnt, h[N], ver[M], nxt[M], w[M], u[M];
bool v[N][O];
struct node { int x, y, z; };
// 节点编号，集合，最小时间
inline bool operator<(node a,node b) { return a.z>b.z; }
priority_queue<node> q;
inline void add(int x,int y,int z,int s0) {
    ver[++cnt]=y, w[cnt]=z, u[cnt]=s0, nxt[cnt]=h[x], h[x]=cnt;
}
inline void dijkstra() {
    memset(d,0x3f,sizeof(d));
    d[1][s[1]]=0, q.push((node){1,s[1],0});
    while(q.size()) {
        int x=q.top().x, s0=q.top().y;
        q.pop();
        if(x==n) { ans=d[x][s0]; break; }
        // 答案
        if(v[x][s0]) continue;
        v[x][s0]=1;
        int S=s0|s[x];
        // 造完剑后的集合
        for(int i=h[x];i;i=nxt[i]) {
            int y=ver[i], z=w[i];
            if(v[y][S]||(S|u[i])!=S) continue;
            // 已经到达或不合法
            if(d[y][S]>d[x][s0]+z) {
                d[y][S]=d[x][s0]+z;
                q.push((node){y,S,d[y][S]});
            }
        }
    }
}
int main() {
    scanf("%d%d%d%d",&n,&m,&p,&k);
    for(int i=1;i<=k;++i) {
        int u, v, w;
        scanf("%d%d",&u,&v);
        while(v--) scanf("%d",&w), s[u]|=1<<(w-1);
        // 预处理一定要-1
    }
    for(int i=1;i<=m;++i) {
        int x, y, z, u, v, w=0;
        scanf("%d%d%d%d",&x,&y,&z,&u);
        while(u--) scanf("%d",&v), w|=1<<(v-1);
        add(x,y,z,w), add(y,x,z,w);
    }
    dijkstra();
    printf("%d\n",ans!=inf? ans:-1);
}
```
