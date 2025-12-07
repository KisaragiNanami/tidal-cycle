---
title: luogu6419 Kamp 题解
pubDate: 2023-10-23
  - DP
  - 树形DP
  - 换根法
categories:
  - 题解
description: 'Solution'
---

## Solution

貌似算是经典问题。

考虑定点怎么做，不令设它为根。

发现答案就是到所有关键点边权和的 $2$ 倍再减掉最长链。

维护最长链长度，次长链长度，子树内关键点数量，子树内边权和即可换根。

当然觉得不放心维护个最长链来源也行。

复杂度 $O(n)$。

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
const int N=5e5+5;
int n, k, f[N][2], g[N], cnt[N], ans[N];
bool v[N];
vector<PII > p[N];
void dfs(int x,int fa) {
    f[x][0]=f[x][1]=g[x]=cnt[x]=0;
    if(v[x]) cnt[x]=1;
    int mx=0;
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
        if(y==fa) continue;
        dfs(y,x);
        if(cnt[y]) {
            cnt[x]+=cnt[y];
            if(f[y][0]+z>f[x][0]) f[x][1]=f[x][0], f[x][0]=f[y][0]+z;
            else if(f[y][0]+z>f[x][1]) f[x][1]=f[y][0]+z;
            g[x]+=g[y]+2*z;
        }
    }
}
void dfs2(int x,int fa) {
    ans[x]=g[x]-f[x][0];
    int fx0=f[x][0], fx1=f[x][1], gx=g[x], cx=cnt[x];
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
        if(y==fa) continue;
        int fy0=f[y][0], fy1=f[y][1], gy=g[y], cy=cnt[y];
        if(cnt[y]) {
            cnt[x]-=cnt[y];
            g[x]-=g[y]+2*z;
        }
        if(cnt[x]) {
            cnt[y]+=cnt[x];
            g[y]+=g[x]+2*z;
            if(cnt[x]&&f[x][0]!=f[y][0]+z) {
                if(f[x][0]+z>f[y][0]) f[y][1]=f[y][0], f[y][0]=f[x][0]+z;
                else if(f[x][0]+z>f[y][1]) f[y][1]=f[x][0]+z;
            } else if(cnt[x]) {
                if(f[x][1]+z>f[y][0]) f[y][1]=f[y][0], f[y][0]=f[x][1]+z;
                else if(f[x][1]+z>f[y][1]) f[y][1]=f[x][1]+z;
            }
        }





        dfs2(y,x);

        f[x][0]=fx0, f[x][1]=fx1, g[x]=gx;
        f[y][0]=fy0, f[y][1]=fy1, g[y]=gy;
        cnt[x]=cx, cnt[y]=cy;
    }
}
signed main() {
    n=read(), k=read();
    rep(i,2,n) {
        int x=read(), y=read(), z=read();
        p[x].pb({y,z}), p[y].pb({x,z});
    }
    rep(i,1,k) {
        int x=read();
        v[x]=1;
    }
    // rep(i,1,n) {
    //     dfs(i,0);
    //     printf("%lld\n",g[i]-f[i][0]);
    // }
    dfs(1,0);
    dfs2(1,0);
    rep(i,1,n) printf("%lld\n",ans[i]);
    return 0;
}
```
