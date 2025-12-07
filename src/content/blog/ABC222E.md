---
title: ABC222E Red and Blue Tree 题解
pubDate: 2023-10-23
tags:
  - 计数
  - DP
categories:
 - 题解
description: 'Solution'
---

## Solution

$n$ 不大，可以预处理出第 $i$ 条边被经过的次数 $c_i$，记 $sum = \sum_{i=1}^{n-1} c_i$。

设 $f(i)$ 为经过 $i$ 条红边的方案数，不难发现就是个背包。

然后枚举经过 $i$ 条红边，如果 $i-(sum-i)=k$，那么累加 $f(i)$。

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
const int N=1005, M=1e5+5, mod=998244353;
int n, m, k, a[N], f[M];
int c[N], sum;
vector<PII > p[N];
int dfs(int x,int fa,int tar) {
    if(x==tar) return 1;
    for(auto t:p[x]) {
        int y=t.fi, id=t.se;
        if(y==fa) continue;
        if(dfs(y,x,tar)) {
            ++c[id];
            return 1;
        }
    }
    return 0;
}
signed main() {
    n=read(), m=read(), k=read();
    rep(i,1,m) a[i]=read();
    rep(i,1,n-1) {
        int x=read(), y=read();
        p[x].pb({y,i});
        p[y].pb({x,i});
    }
    rep(i,1,m-1) dfs(a[i],0,a[i+1]);
    rep(i,1,n-1) sum+=c[i];
    f[0]=1;
    rep(i,1,n-1) per(j,sum,c[i]) {
        (f[j]+=f[j-c[i]])%=mod;
    }
    int ans=0;
    rep(i,0,sum) if(i-(sum-i)==k) (ans+=f[i])%=mod;
    printf("%lld\n",ans);
    return 0;
}
```
