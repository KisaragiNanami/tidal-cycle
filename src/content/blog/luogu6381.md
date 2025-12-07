---
title: luogu6381 Odyssey 题解
tags:
  - DP
  - 拓扑排序
  - 数论
categories:
  - 题解
pubDate: 2022-10-21
description: 'Solution'
---

对于 $ab = c^k$，不难想到把 $a$ 和 $b$ 都分解。

$$
a= \prod_{i=1}^{c_a} p^{x_i}_i
$$

$$
b=\prod_{i=1}^{c_b} p^{y_i}_i
$$

对于一个 $p_i$，一定有 $x_i + y_i \equiv 0 \pmod{k}$。

不难想到，一旦 $a$ 确定了，就可以限定 $b$，这样就是一个分层图的结构。

对于一个 $w$， 可以预处理出其分解中所有指数在对 $k$ 取模的意义下的值。

$$
w_1 = \prod_{i=1}^{c_w} p^{x_i \bmod k}_i
$$



和

$$
w_2 = \prod_{i=1}^{c_w} p^{k - x_i \bmod k}_i
$$



将所有 $w_i$ 都这样处理，合法路径就都被确定了。两条边 $(i,j)$ 形成的路径合法，当且仅当 $w_2(i) = w_1(j)$。这相当于是一张分层图。

为了处理点与边，所以状态设计得比较不可读。

设 $f_{x,d}$ 为以节点 $x$ 结尾，出边 $i$ 满足 $w_2(i)=d$ 的最长路径。拓扑排序即可。

$$
f_{x,w2(i)} + z \rightarrow f_{y,w1(i)}
$$

其中 $z=l(i)$。

$w_1$ 和 $w_2$ 的范围可能很大，但数量不多，使用`std::unordered_map`实现。

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
const int N=1e5+5;
int n, m, k, ans, in[N];
int tot, h[N], to[2*N], nxt[2*N], w[2*N], e[2*N], l[2*N];
unordered_map<int,int> f[N];
int devide1(int x) {
    int ans=1;
    for(int i=2;i*i<=x;++i) if(x%i==0) {
        int c=0;
        while(x%i==0) x/=i, ++c;
        c%=k;
        while(c--) ans*=i;
    }
    if(x>1&&k!=1) ans*=x;
    return ans;
}
int devide2(int x) {
    int ans=1;
    for(int i=2;i*i<=x;++i) if(x%i==0) {
        int c=0;
        while(x%i==0) x/=i, ++c;
        c%=k;
        if(c) {
            int tc=k-c;
            while(tc--) ans*=i;
        }
    }
    if(x>1) {
        int tc=k-1;
        while(tc--) ans*=x;
    }
    return ans;
}
void add(int x,int y,int z,int li) {
    to[++tot]=y, w[tot]=devide1(z), e[tot]=devide2(z), l[tot]=li;
    nxt[tot]=h[x], h[x]=tot;
}
void toposort() {
    queue<int> q;
    for(int i=1;i<=n;++i) if(!in[i]) q.push(i);
    // do DP
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i], w1=w[i], w2=e[i], z=l[i];
            f[y][w1]=max(f[y][w1],f[x][w2]+z);
            ans=max(ans,f[y][w1]);
            if(--in[y]==0) q.push(y);
        }
    }
}
signed main() {
    n=read(), m=read(), k=read();
    for(int i=1;i<=m;++i) {
        int x=read(), y=read(), z=read(), li=read();
        add(x,y,z,li), ++in[y];
    }
    toposort();
    printf("%lld\n",ans);
}

```
