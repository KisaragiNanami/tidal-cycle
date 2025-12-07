---
title: luogu5772 「JSOI2016」 位运算
pubDate: 2023-10-23
tags:
  - DP
  - 状态压缩
  - 矩阵加速
  - 计数
  - 组合数学
categories:
  - 题解
description: 'Solution'
---

## Solution

先考虑确定了 $R$ 之后怎么做。

$n$ 个数的异或和为 $0$，常用的套路就是转化为每一位上出现奇数个 $1$。直接 DP 复杂度是 $O(nR \log R)$ 的，貌似是一个低分暴力，然而我们要求这 $n$ 个数两两不同，这个 DP 不能解决。

~~然后就开题解了~~。

由于要求 $n$ 个数两两不同，所以钦定 $x_0 > x_1 > x_2 > \cdots > x_{n}$，其中 $x_0 = 0$。

我们考虑从高位到低位依次确定这 $n$ 个数。在只考虑前 $i$ 位时，由于这 $n$ 个数的异或和为 $0$，所以它们的前 $i$ 位构成的数的异或和也必然为 $0$，这是一个子问题。

同时可能会出现若干变量相等的情况，这个东西是有后效性的，会对之后的情况产生限制。由于 $n$ 很小，所以我们用一个集合 $S$ 表示状态。它刻画了以下情况：集合含有元素  $j$，其中 $j \in [1,n]$，那么说明在只考虑当前位的情况下，$x_j = x_{j-1}$。

设 $f(i,S)$ 为考虑了每个数的前 $i$ 位，此时的状态为 $S$ 的方案数。转移枚举每个数下一位值构成的集合 $T$，只有当 $|T| \bmod 2 = 0$ 才合法，然后检查是否和 $S$ 冲突。如果不冲突，那么就能得到新状态 $S'$，刷表即可。

然后考虑 $k$。虽然 $k$ 很大，但是我们能发现每一段都是相同的，DP 时都是在做一样的事情，同时转移和具体数位没有关系，考虑矩阵加速。



没写完。

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
const int N=100, M=(1<<8)+5, mod=1e9+7;
int n, m, k, U, f[N][M];
int popcount[M];
char s[N];
struct Mat {
    int m[M][M];
    void clear() { SET(m,0); }
    void init() { for(int i=0;i<=U;++i) m[i][i]=1; }
    int* operator[](int i) { return m[i]; }
    Mat operator*(const Mat& b) const {
        Mat c;
        c.clear();
        for(int i=0;i<=U;++i)
            for(int k=0;k<=U;++k)
                for(int j=0;j<=U;++j)
                    (c.m[i][j]+=m[i][k]*b.m[k][j]%mod)%=mod;
        return c;
    }
} base, trans;
Mat fp(Mat& a,int b) {
    Mat c;
    c.clear();
    c.init();
    for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
    return c;
}
signed main() {
    n=read(), k=read();
    scanf("%s",s+1);
    m=strlen(s+1);
    U=(1<<n)-1;
    rep(i,1,U) popcount[i]=popcount[i>>1]+(i&1);
    rep(ST,0,U) {
        rep(i,0,m) memset(f[i],0,(U+1)<<3);
        f[0][ST]=1;
        rep(i,1,m) rep(S0,0,U) if(f[i-1][S0]) {
            rep(T,0,U) if(popcount[T]%2==0) {
                vector<int> v(n+1);
                v[0]=s[i]-'0';
                rep(j,1,n) v[j]=(T>>(j-1))&1;
                int fg=0, S=0;
                rep(j,1,n) if((S0>>(j-1))&1) {
                    if(v[j]>v[j-1]) { fg=1; break; }
                    if(v[j]==v[j-1]) S|=(1<<(j-1));
                }
                if(fg) continue;
                (f[i][S]+=f[i-1][S0])%=mod;
            }
        }
        for(int S=0;S<=U;++S) {
            trans[S][ST]=f[m][S];
        }
    }
    base[U][0]=1;



    base=fp(trans,k)*base; 
    printf("%lld\n",base[0][0]);
    return 0;
}
```
