---
title: luogu8315 [COCI2021-2022#4] Šarenlist
pubDate: 2023-11-10
tags:
  - 容斥原理
  - 子集反演
  - 并查集
categories:
  - 题解
description: 'Solution'
---

## 闲话

模拟赛 T4，然而考场上没发现这是个挺平凡的题，所以就当了暴力老哥。

## Solution

合法方案不太容易做，考虑求非法方案数。

如果每条彩链都不相交，那么问题就很平凡，每条链可以缩成一条边。

如果存在相交的链，那么直接做就存在重复计数。手玩一下不难发现实际上它们必须同色，也可以缩成一条边。

然后我们要求不满足任意约束的方案数，容易求得不满足钦定的约束的方案数。注意到 $m$ 很小，子集反演即可，容斥系数是 $(-1)^{|S|}$。

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
const int N=65, mod=1e9+7;
int n, m, k, ans, dep[N], fa[N], in[N];
int pw[N];
vector<int> c[N];
vector<PII > p[N];
struct DSU {
    int cnt, fa[N];
    void init() { rep(i,1,n-1) fa[i]=i; cnt=n-1; }
    int get(int x) {
        if(x==fa[x]) return x;
        return fa[x]=get(fa[x]);
    }
    void merge(int x,int y) {
        x=get(x), y=get(y);
        if(x!=y) fa[x]=y, --cnt;
    }
} dsu;
int fp(int a,int b) {
    if(a<0||b<0) return 0;
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void dfs(int x,int fat) {
    fa[x]=fat;
    dep[x]=dep[fat]+1;
    for(auto t:p[x]) if(t.fi!=fat) {
        int y=t.fi;
        in[y]=t.se;
        dfs(y,x);
    }
}
signed main() {
//    freopen("escape6.in","r",stdin);
//    freopen("escape.out","w",stdout);
    n=read(), m=read(), k=read();
    pw[0]=1;
    rep(i,1,n-1) {
        pw[i]=pw[i-1]*k%mod;
        int x=read(), y=read();
        p[x].pb({y,i}), p[y].pb({x,i});
    }
    dfs(1,0);
    rep(i,0,m-1) {
        int x=read(), y=read();
        if(dep[x]>dep[y]) swap(x,y);
        while(dep[x]!=dep[y]) {
            c[i].pb(in[y]);
            y=fa[y];
        }
        while(x!=y) {
            c[i].pb(in[x]), c[i].pb(in[y]);
            x=fa[x], y=fa[y];
        }
    }
    int U=(1<<m)-1;
    rep(S,0,U) {
        dsu.init();
        rep(i,0,m-1) if((S>>i)&1) {
            for(int j=0;j+1<c[i].size();++j) dsu.merge(c[i][j],c[i][j+1]);
        }
        int op=__builtin_parity(S);
        if(op) (ans-=pw[dsu.cnt]-mod)%=mod;
        else (ans+=pw[dsu.cnt])%=mod;
    }
    printf("%lld\n",ans);
    return 0;
}

```
