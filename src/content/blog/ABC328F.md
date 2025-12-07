---
title: ABC328F Good Set Query 题解
pubDate: 2023-11-16
tags:
  - 并查集
categories:
  - 题解
description: 'Solution'
---

## Solution

使用带权并查集维护这个关系。

具体的，设 $d_x$ 为并查集上每个节点到其父亲的边权，表示 $X_x - d_x = X_{fa_x}$。

合并两个点 $(x,y)$ 所在集合时，设 $rx$ 为 $x$ 所在集合的根，$ry$ 类似。对于 $X_{x} - X_{y} = z$，我们将 $rx$ 合并到 $ry$ 上，从而只需要考虑 $rx$ 的连边。需要满足 $d_x + d_{rx} - d_y = z$，从而 $d_{rx} = z - d_x + d_y$。

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
const int N=2e5+5;
int n, q, a[N], b[N], c[N];
int fa[N], d[N];
vector<int> ans; 
int get(int x) {
    if(x==fa[x]) return x;
    int rt=get(fa[x]);
    d[x]+=d[fa[x]];
    return fa[x]=rt;
}
signed main() {
    n=read(), q=read();
    rep(i,1,q) a[i]=read(), b[i]=read(), c[i]=read();
    rep(i,1,n) fa[i]=i, d[i]=0;
    rep(i,1,q) {
        int x=a[i], y=b[i], z=c[i];
        int fx=get(x), fy=get(y);
        if(fx!=fy||(fx==fy&&d[x]-d[y]==z)) {
            ans.pb(i);
            fa[fx]=fy;
            d[fx]=z+d[y]-d[x];
        }
    }
    for(auto x:ans) printf("%lld ",x);
    puts("");
    return 0;
}
```
