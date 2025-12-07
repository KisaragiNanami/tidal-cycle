---
title: luogu8564 ρars/ey 题解
tags:
  - DP
  - 树形DP
categories: 题解
pubDate: 2022-10-21
description: 'Solution'
---

设 $c(i)$ 为一次删去同一棵子树内不包括根的 $i-1$ 个节点的代价。

### 链

将 $1$ 号节点作为链首，不难想到设 $f_i$ 为删掉以 $i$ 为根的子树的最小代价，每次删掉的都是连续的一段，所以

答案 $f_1$。

### 菊花

显然，答案为 $c(n)$。

### 正解

设 $f_{x,j}$ 为以 $x$ 为根的子树，完成所有子节点的删除操作后，还剩下 $j$ 个节点的最小代价。

注意到 $j$ 就是 $x$ 的所有儿子节点剩下的节点数量之和，这个可以转化为用一个类似于树形背包的转移。

树形背包的实现方式是「对于一个节点 $x$，将其子树 $y$ 依次加入以 $x$ 为根的子树，同时合并信息」。这个状态也可以这样去合并。但为什么这个不是树形背包呢？因为并没有所谓「一个固定的容积」，这就导致了处理 $f$ 时必须严格维护当前树的大小，同时只处理 $sz(x)$ 位，

先对于 $x$ 的儿子节点 $y$，进行一个合并

$$
f_{x,j+k} = \min_{k \in [1,sz(y)]}\{ f_{x,j} + f_{y,k} \}
$$

并且 $j \in [cnt+1,s+1]$，

其中 $cnt$ 是在加入 $y$ 之前，已经加入的子树个数，$s$ 就是这些子树的大小之和。

然后进行 $x$ 的一次删除。

$$
f_{x,1} = \min\{ f_{x,k} + c(k) \}
$$



复杂度是 $O(n^2)$ 的，实现不当则会退化成 $O(n^3)$。

## CODE

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
const int N=5005;
int n, a[N], sz[N], f[N][N], F[N], deg[N];
int tot, h[N], to[2*N], nxt[2*N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
    add(x,y), add(y,x);
}
namespace sub1 {
    void solve() {
        printf("%lld\n",a[n]);
    }
};
namespace sub2 {
    void solve() {
        SET(F,0x3f);
        F[n]=0;
        for(int i=n;i;--i) {
            for(int j=i+1;j<=n;++j) {
                F[i]=min(F[i],F[j]+a[j-i+1]);
            }
        }
        printf("%lld\n",F[1]);
    }
}
namespace bf {
    void dfs(int x,int fa) {
        sz[x]=1;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(y==fa) continue;
            dfs(y,x);
            sz[x]+=sz[y];
        }
    }
    void dp(int x,int fa) {
        for(int i=1;i<sz[x];++i) f[x][i]=1e15;
        f[x][1]=0;
        int cnt=0, s=0;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(y==fa) continue;
            dp(y,x);
            for(int j=s+1;j>=cnt+1;--j) {
                // 倒序循环
                for(int k=1;k<=sz[y];++k) f[x][j+k]=min(f[x][j+k],f[x][j]+f[y][k]);
                f[x][j]=1e15;
                // 顺便置为正无穷
            }
            ++cnt, s+=sz[y];
            for(int j=cnt;j;--j) f[x][j]=1e15;
        }
        f[x][1]=a[sz[x]];
        for(int k=cnt+1;k<=sz[x];++k) f[x][1]=min(f[x][1],f[x][k]+a[k]);
    }
    void solve() {
        dfs(1,1);
        dp(1,1);
        printf("%lld\n",f[1][1]);
    }
};
signed main() {
    n=read();
    for(int i=2;i<=n;++i) a[i]=read();
    for(int i=1;i<n;++i) {
        int x=read(), y=read();
        ++deg[x], ++deg[y];
        addedge(x,y);
    }
    int fg=1;
    for(int i=2;i<=n;++i) if(deg[i]>=2) fg=0;
    if(deg[1]!=1&&fg) sub1::solve(); else if(deg[1]==1&&fg) sub2::solve();
    else bf::solve();
}
```
