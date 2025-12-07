---
title: divide 题解
pubDate: 2023-11-16
urls: divide-solution
tags:
  - DP
  - 计数
  - 组合数学
  - 倍增
categories:
  - 题解
description: '某神秘数数题'
---

## 题意

构造 $K$ 个正整数序列，第 $i$ 个序列为 $a_i$，长度为 $l_i$，满足 $\forall i, \sum_{j=1}^{l_i} a_{i,j} = n$，且
$$
\prod_{i=1}^k \min_{j=1}^{l_i} \{a_{i,j}\} \le m
$$
给定 $n,K,m$，求构造的方案数，对 $998244353$ 取模。

两种方案不同，当且仅当存在一个 $i$，满足两种方案的 $a_i$ 不同。

$1 \le n,m \le 10^5$，$1 \le K \le 10^9$。

## Solution

先考虑一个序列怎么构造。

设 $g(k)$ 构造一个序列，满足每个数都大于 $i$ 的方案数，有

$$
g(k) = \sum_{i=1}^{n-ik} \binom{n-ik-1}{i-1}
$$



设 $f(i,j)$ 为已经构造了 $i$ 个序列，当前最小值为 $j$ 的方案数。最小值恰好为 $i$ 的序列数就是 $f(1,i) = g(i-1) - g(i)$。

转移

$$
f(i,j) \times f(1,k) \rightarrow f(i+1,j \times k) 

$$

其中 $j \times k \le m$

所以上述 DP 的复杂度是 $O(Kn \log m)$

虽然 $K$ 很大，但是转移很机械，并且有结合律，考虑倍增。

考虑对每个 $i$，预处理 $f^k(i)$ 表示构造 $2^k$ 个序列，最小值乘积为 $i$ 的方案数。

复杂度 $O(n \log K \log m)$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
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
const int N=1e5+5, mod=998244353;
int n, K, m, g[N], f[30][N], h[2][N];
int fac[N], inv[N];
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
int C(int n,int m) {
    if(n<0||m<0||n<m) return 0;
    return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
namespace sub1 {
    void solve() {
        int ans=0;
        rep(i,1,m) (ans+=(g[i-1]-g[i]+mod)%mod)%=mod;
        printf("%lld\n",ans);
    }
};
signed main() {
    n=read(), K=read(), m=read();
    fac[0]=inv[0]=1;
    rep(i,1,n) fac[i]=fac[i-1]*i%mod;
    inv[n]=fp(fac[n],mod-2);
    per(i,n-1,1) inv[i]=inv[i+1]*(i+1)%mod;
    rep(k,0,n) for(int i=1;n-i*k-1>=i-1;++i) (g[k]+=C(n-i*k-1,i-1))%=mod;
    if(K==1) {
        sub1::solve();
        return 0;
    }
    rep(i,1,n) f[0][i]=(g[i-1]-g[i]+mod)%mod;

    rep(i,1,29) rep(j,1,m) if(f[i-1][j]) {
        for(int k=1;j*k<=m;++k) (f[i][j*k]+=f[i-1][j]*f[i-1][k]%mod)%=mod;
    }

    int cur=1;
    h[0][1]=1;
    rep(i,0,29) if((K>>i)&1) {
        K-=(1<<i);
        rep(j,1,m) h[cur][j]=0;
        rep(j,1,m) if(h[cur^1][j]) {
            for(int k=1;j*k<=m;++k) (h[cur][j*k]+=h[cur^1][j]*f[i][k]%mod)%=mod;
        }
        cur^=1;
    }
    int ans=0;
    rep(i,1,m) (ans+=h[cur^1][i])%=mod;
    printf("%lld\n",ans);
}
```
