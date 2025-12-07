---
title: luogu3304 直径 题解
tags: 树的直径
categories: 题解
description: 'Solution'
pubDate: 2021-10-01
---

两次 DFS 求出树的直径。

显然多条直径必定交于至少一点，且包含它们的中点。



则若舍去他们交点之外的边，剩下的边即为所求。

设直径左右端点为 $ l, r$。

在第二次 DFS 时能够求出 $ l$ 到直径每个节点的距离，所以从 $ r$ 向 $ l$ 遍历。

对于直径上的每个点 $i$，分别求出在不经过直径上其他点的情况的，所能达到的最远距离，记作 $d$。设它到直径左端点距离为 $ ld$，到右端点距离为 $ rd$。

若 $ d=rd$，则令 $ r=i$。

若 $d=ld$，则令 $l=i$，且只会进行一次，这是因为我们的遍历顺序是从右到左。

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
#define R register
#define ll long long
const int N=2e5+10;
int n, f[N];
int c, h[N], ver[N<<1], nxt[N<<1], w[N<<1];
ll p, mxd, d[N];
bool v[N];
void add(int x,int y,int z) { ver[++c]=y, w[c]=z, nxt[c]=h[x], h[x]=c; }
void dfs(int x,int fa) {
    f[x]=fa;
    for(int i=h[x];i;i=nxt[i]) if(ver[i]!=fa) {
        int y=ver[i], z=w[i];
        d[y]=d[x]+z;
        if(d[y]>mxd) { mxd=d[y], p=y; }
        dfs(y,x);
    }
}
void kawaii(int x,int fa) {
    for(int i=h[x];i;i=nxt[i]) if(ver[i]!=fa&&!v[ver[i]]) {
        int y=ver[i], z=w[i];
        d[y]=d[x]+z;
        if(d[y]>mxd) mxd=d[y];
        kawaii(y,x);
    }
}
int main() {
    int ans, l=0, r=0, fg=0;
    scanf("%d",&n);
    for(int i=1;i<n;++i) {
        int x, y, z; scanf("%d%d%d",&x,&y,&z);
        add(x,y,z), add(y,x,z);
    }
    dfs(1,0), l=p, mxd=d[p]=0;
    dfs(p,0), r=p;
    printf("%lld\n",mxd);
    for(int i=r;i;i=f[i]) v[i]=1;
    // 直径上的点打标记
    int l_=l, r_=r;
    for(i=f[r_];i!=l_;i=f[i]) {
        int ld=d[i], rd=d[r_]-d[i];
        // 
        mxd=d[i]=0;
        kawaii(i,0);
        if(mxd==rd) r=i;
        if(mxd==ld&&!fg) fg=1, l=i;
    }
    for(i=f[r];i!=l;i=f[i]) ++ans;
    printf("%d\n",ans);
}
```
