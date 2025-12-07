---
title: luogu4582 [FJOI2014] 树的重心 题解
pubDate: 2023-10-23
tags:
  - DP
  - 树形DP
  - 树的重心
categories:
  - 题解
math: true
comment: true
---

## Solution

考虑用 DP 求一个东西： $f(x,i)$ 表示以 $x$ 为根的子树中，选出包含 $x$ 的大小为 $i$ 的连通块的方案数。

分重心的数量进行讨论。

### 两个重心

如果原树有两个重心，由于这两个重心必然相邻，设其为 $cen_1$ 与 $cen_2$，那么答案一定是二者各带上一个大小相同的连通块加上边 $(cen_1,cen_2)$ 构成的子图。

分别以两个重心为根，跑上述 DP 即可。

$$
\sum_{i=1}^{\lfloor \frac{n}{2} \rfloor} \Big( f(cen_1,i) \times f(cen_2,i) \Big)
$$



### 一个重心

由于数据范围不大，我们考虑枚举子图的大小 $siz$，然后我们一定要保留重心，所以重心的每一棵子树大小的 $2$ 倍必须小于 $siz$。

把重心拎起来跑上述 DP，然后对在重心处暴力卷积即可。

### CODE

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
const int N=205, mod=10007;
int T, n, tim, sz[N], f[N][N], g[N];
int h[N];
int cen, cen2;
vector<int> p[N];
void getcen(int x,int fa) {
    sz[x]=1, h[x]=0;
    for(auto y:p[x]) if(y!=fa) {
        getcen(y,x);
        sz[x]+=sz[y];
        h[x]=max(h[x],sz[y]);
    }
    h[x]=max(h[x],n-sz[x]);
    if(!cen||h[x]<=h[cen]) cen=x;
}
void dfs(int x,int fa) {
    sz[x]=1;
    f[x][0]=f[x][1]=1;
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        for(int i=1;i<=sz[x]+sz[y];++i) g[i]=f[x][i];
        for(int i=1;i<=sz[x];++i)
            for(int j=1;j<=sz[y];++j)
                (g[i+j]+=f[x][i]*f[y][j]%mod)%=mod;
        sz[x]+=sz[y];
        for(int i=1;i<=sz[x];++i) f[x][i]=g[i];
    }
}
namespace sub1 {
    int calc(int siz) {
        int x=cen;
        SET(f[x],0);
        sz[x]=1;
        f[x][0]=f[x][1]=1;
        for(auto y:p[x]) {
            for(int i=1;i<=sz[x]+sz[y];++i) g[i]=f[x][i];
            for(int i=1;i<=sz[x];++i)
                for(int j=1;j<=sz[y]&&2*j<siz;++j)
                    (g[i+j]+=f[x][i]*f[y][j]%mod)%=mod;
            sz[x]+=sz[y];
            for(int i=1;i<=sz[x];++i) f[x][i]=g[i];
        }
        return f[x][siz];
    }
    void solve() {
        SET(f,0);
        dfs(cen,0);
        int ans=0;
        rep(i,1,n) (ans+=calc(i))%=mod;
        printf("Case %lld: %lld\n",tim,ans);
    }
};
namespace sub2 {
    void solve() {
        SET(f,0);
        dfs(cen,cen2);
        dfs(cen2,cen);
        int ans=0;
        rep(i,1,n/2) (ans+=f[cen][i]*f[cen2][i]%mod)%=mod;
        printf("Case %lld: %lld\n",tim,ans);
    }
};
void solve() {
    n=read();
    rep(i,1,n) p[i].clear();
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    cen=cen2=0;
    getcen(1,0);
    if(2*h[cen]<n) {
        sub1::solve();
        return;
    }
    for(auto x:p[cen]) {
        if(h[cen]==sz[x]) { cen2=x; break; }
    }
    sub2::solve();
}
signed main() {
    T=read();
    for(tim=1;tim<=T;++tim) solve();
    return 0;
}
```
