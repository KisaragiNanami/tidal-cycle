---
title: luogu3953 逛公园 题解
tags:
  - 最短路
  - DP
categories:
  - 题解
description: 'Solution'
pubDate: 2021-10-02
---

首先跑最短路，本题并不卡那个死掉的算法。

求出 1 号节点到每个点的最短路 $d$。

然后考虑计数。



计数可以考虑 DP，但是必须满足无后效性。

设计一个类似于分层图的状态。

$f(x,k)$ 为 1 号节点到 $x$ 号节点，距离为 $d(x)+k$ 的方案数。

考虑转移，假定 $f(y,k_2)$ 能转移到 $f(x,k_1)$。

设 $(x \rightarrow y)$ 边权为 $z$，则有

$$
d(y)+z+k_2=d(x)+k_1
$$

$$
k_2=d(x)-d(y)-z+k_1
$$



于是

$$
f(x,k)= \sum_{x \rightarrow y} {f(y,d(x)-d(y)+k-z)}
$$




对于 $(x \rightarrow y)$，关于 $x$ 的状态反而依赖关于 $y$ 的状态。那么必定是建反图，然后记忆化搜索。

边界 $f(1,0)=1$

答案

$$
\sum_{0 \le i \le K} f(n,i)
$$



&nbsp;

考虑无解的情况。

题目描述中告诉我们有 0 边。

我们发现，有无穷多条合法路径，当且仅当有边权为 0 的环。又因为没有负边权，所以 0 环一定由若干 0 边构成。

如何找出 0 环呢？

观察我们的转移，不难想到，在 0 边上，$k=d(x)-d(y)+k-z$，即会递归到 $f(y,k)$

如果有 0 环，那么一定又会再次访问到 $f(x,k)$。

所以对于每个 $f(x,k)$，用 $v(x,k)$ 来记录访问情况。每访问到一个状态，将其记为 1，访问完之后就改回 0。如果访问到 1 的状态，就证明有 0 环，无解。

这也恰好说明了，这个状态是“无环”的。并不是真的不可能存在环，但是如果访问一圈回到 $f(x,k)$，说明存在环，也就直接无解了，不需要再考虑别的。



```cpp
#include<bits/stdc++.h>
using namespace std;
#define PII pair<int,int>
#define mp make_pair
#define SET(x,y) memset(x,y,sizeof(x))
const int N=1e5+10;
int t, n, m, K, P, ans, QwQ, f[N][66], d[N], fa[N];
int cnt, h[N], ver[N<<1], nxt[N<<1], w[N<<1];
int cnt2, h2[N], ver2[N<<1], nxt2[N<<1], w2[N<<1];
bool v[N], vis[N][66];
int r_() {
    int a=0; char c=getchar();
    for(;!isdigit(c);c=getchar());
    for(;isdigit(c);a=(a<<1)+(a<<3)+(c^48),c=getchar());
    return a;
}
void add(int x,int y,int z) { ver[++cnt]=y, w[cnt]=z, nxt[cnt]=h[x], h[x]=cnt; }
void add2(int x,int y,int z) { ver2[++cnt2]=y, w2[cnt2]=z, nxt2[cnt2]=h2[x], h2[x]=cnt2; }
void dijk() {
    priority_queue<PII > q;
    SET(d,0x3f);
    d[1]=0, q.push(mp(0,1));
    while(q.size()) {
        int x=q.top().second; q.pop();
        if(v[x]) continue;
        v[x]=1;
        for(int i=h[x];i;i=nxt[i]) {
            int y=ver[i], z=w[i];
            if(d[y]>d[x]+z) {
                d[y]=d[x]+z;
                q.push(mp(-d[y],y));    
            }
        }
    }
}
int dp(int x,int k) {    
    if(k<0) return 0;
    if(vis[x][k]) { QwQ=1; return 0; }
    if(f[x][k]) return f[x][k];
    int ans=0;
    vis[x][k]=1;
    for(int i=h2[x];i;i=nxt2[i]) {
        int y=ver2[i], z=w2[i];
        (ans+=dp(y,d[x]-d[y]+k-z))%=P;
        if(QwQ) return 0;
    }
    vis[x][k]=0;
    return f[x][k]=ans;
}
int main() {
    for(int t=r_();t--;) {
        n=r_(), m=r_(), K=r_(), P=r_();
        while(m--) {
            int x=r_(), y=r_(), z=r_();
            add(x,y,z), add2(y,x,z);
        }
        dijk();
        dp(1,0);
        f[1][0]=1, ans=0;
        for(int i=0;i<=K;++i) ans=(ans+dp(n,i))%P;
        if(QwQ) puts("-1"); else printf("%d\n",ans);
        QwQ=cnt=cnt2=0;
        SET(v,0), SET(vis,0), SET(f,0), SET(h,0), SET(h2,0);
    }
} 
```
