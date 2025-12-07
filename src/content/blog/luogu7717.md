---
title: luogu7717「EZEC-10」序列 题解
pubDate: 2023-09-22
tags:
  - DP
  - Trie
  - 数位DP
  - 计数
categories:
  - 题解
description: 'Solution'
---



想了想还是把这题单独拿出来了。



## Solution

由于异或运算满足交换律和结合律，所以我们对于限制 $(x_i,y_i,z_i)$，连边 $(x_i, y_i)$，权值为 $z_i$，这样只要确定了连通块中一个点，其他点的点权也可以确定。

会构成若干连通块，对于每个连通块分别考虑。

随便钦定一个点为根，进行 $\text{DFS}$ 得到每个点 $x$ 与根的关系 $d_x$，满足 $a_{root} \oplus a_x = d_x$。

先把存在环且不合法的情况判掉，然后我们把 $d_x$ 插入 0-1 Trie。

考虑 Trie 树上 $\text{DFS}$。设 $f(x,\delta,k)$ 为在节点 $x$，考虑了前 $\delta$ 位，此时最大值为 $k$ 的方案数。

唯一的限制在于每个数必须在 $[0,K]$ 之间。

规定左儿子为 $0$ 儿子，右儿子为 $1$ 儿子。

如果节点 $x$ 同时存在左右儿子，那么无论根取什么值，最大值一定会加上 $2^{\delta}$，所以

$$
f(x,\delta,k) = f\Big(son_0(x),\delta-1,k+2^{\delta}\Big) + f\Big(son_1(x),\delta-1,k+2^{\delta}\Big)
$$


如果只有左儿子或右儿子，那么

- 只有左儿子且 $k+2^{\delta} \le K$。那么如果这一位放 $1$，那么方案就是 $f\Big(son_0(x),\delta-1,k+2^{\delta}\Big)$，否则无论后面放什么都不会超过 $k$，方案数 $2^{\delta}$。
- 只有左儿子且 $k+2^{\delta} > K$。那么只能放 $1$，方案数 $f\Big(son_0(x),\delta-1,k\Big)$

只有右儿子的情况类似。

特判孤点，方案是 $k+1$，直接乘起来。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=5e5+5, mod=1e9+7;
int n, m, K, ans=1, d[N], deg[N];
bool vis[N];
struct Gr {
    int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
    void add(int x,int y,int z) {
        to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
    }
} G;
namespace Trie {
    int cnt=1, t[N*29][2];
    void init() {
        rep(i,0,cnt) t[i][0]=t[i][1]=0;
        cnt=1;
    }
    void insert(int S) {
        int x=1;
        for(int i=29;~i;--i) {
            int a=(S>>i)&1;
            if(!t[x][a]) t[x][a]=++cnt;
            x=t[x][a];
        }
    }
    int Dfs(int x,int d,int k) {
        if(k>K) return 0;
        if(!t[x][0]&&!t[x][1]) return 1;
        if(t[x][0]&&t[x][1]) return Dfs(t[x][0],d-1,k+(1<<d))+Dfs(t[x][1],d-1,k+(1<<d));
        if(t[x][0]) {
            if(k+(1<<d)<=K) return (1<<d)+Dfs(t[x][0],d-1,k+(1<<d));
            return Dfs(t[x][0],d-1,k);
        } else {
            if(k+(1<<d)<=K) return (1<<d)+Dfs(t[x][1],d-1,k+(1<<d));
            return Dfs(t[x][1],d-1,k);
        }
    }
};
void dfs(int x) {
    vis[x]=1;
    Trie::insert(d[x]);
    for(int i=G.h[x];i;i=G.nxt[i]) {
        int y=G.to[i], z=G.w[i];
        if(d[y]!=-1&&(d[x]^z^d[y])!=0) {
            puts("0");
            exit(0);
        }
        d[y]=d[x]^z;
        if(!vis[y]) dfs(y);
    }
}
signed main() {
    n=read(), m=read(), K=read();
    rep(i,1,m) {
        int x=read(), y=read(), z=read();
        G.add(x,y,z), G.add(y,x,z);
        ++deg[x], ++deg[y];
    }
    SET(d,-1);
    for(int i=1;i<=n;++i) {
        if(vis[i]) continue;
        if(!deg[i]) { (ans*=K+1)%=mod; continue; }
        Trie::init();
        d[i]=0;
        dfs(i);
        (ans*=Trie::Dfs(1,29,0))%=mod;
    }
    printf("%lld\n",ans);
}
```
