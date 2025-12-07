---
title: luogu8863 「KDOI-03」 构造数组 题解
pubDate: 2023-11-03
tags:
  - DP
  - 计数
  - 组合数学
categories:
  - 题解
description: 'Solution'
---

## Solution

如果 $2 \nmid \sum_{i=1}^n b_i$，那么一定无解，否则令 $m = \frac{1}{2} \sum_{i=1}^n b_i$。

操作序列是难以直接刻画的东西，考虑将原问题进一步形式化：

> $n$ 个有标号集合，集合内部元素不带标号，第 $i$ 个集合的大小为 $b_i$。求将所有元素填入 $m$ 个有标号无序二元组，满足每个二元组中的元素不属于同一个集合的方案数。
> 
> 两种方案不同，当且仅当存在两个无序二元组不同。
> 
> 容易证明与原问题形成双射。

 尝试依次放置每个集合。对于第 $i$ 个集合，有用的信息只有此时有多少可以放置的二元组。具体地，设 $f(i,m_1,m_2)$ 为考虑到第 $i$ 个集合，其中有 $m_1$ 个二元组填入 $1$ 个数，$m_2$ 个二元组填入 $2$ 个数，$m-m_1-m_2$ 个空二元组的方案数。

转移枚举填入两种集合的个数即可。

$$
f(i,m_1,m_2) = \sum_{k=0}^{\min(b_i,m_2)}f(i-1,m_1+k,m_2-k)\binom{m_0}{b_i-k}\binom{m_1}{k}
$$



复杂度 $O((n+m)m^2)$。

注意到状态有冗余：由于我们是直接填完一个集合中所有的元素，所以一定有 $2m_2 + m_1 = \sum_{j=1}^i b_i$，也就是说 $m_1$ 这一维是不需要的。

设 $f(i,m_2)$ 为考虑了前 $i$ 个集合，其中有 $m_2$ 个填满两个元素的二元组的方案数。容易得到 $m_0$ 和 $m_1$。

$$
f(i,m_2) = \sum_{k=0}^{\min(b_i,m_2)} f(i-1,m_2-k) \binom{m_0}{b_i-k}\binom{m_1}{k}
$$



这样复杂度就是 $O\big((n+m)m \big)$。

上界能卡的很死，所以常数较小。空间仍然不乐观，使用滚动数组。

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
const int N=30005, mod=998244353;
int n, m, b[N], s[N], f[2][N];
int fac[N], inv[N];
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void prework() {
    fac[0]=inv[0]=1;
    rep(i,1,m) fac[i]=fac[i-1]*i%mod;
    inv[m]=fp(fac[m],mod-2);
    per(i,m-1,1) inv[i]=inv[i+1]*(i+1)%mod;
}
int binom(int n,int m) {
    if(n<m) return 0;
    return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
signed main() {
    n=read();
    rep(i,1,n) {
        b[i]=read();
        s[i]=s[i-1]+b[i];
    }
    if(s[n]&1) {
        puts("0");
        exit(0);
    }
    m=s[n]>>1;
    prework();
    f[0][0]=1;
    for(int i=1;i<=n;++i) {
        memset(f[i&1],0,(m+1)<<3);
        for(int c2=0;c2<=m&&2*c2<=s[i-1];++c2) if(f[(i-1)&1][c2]) {
            int c1=s[i-1]-2*c2, c0=m-c1-c2;
            if(c1<0||c0<0) continue;
            rep(k,0,b[i]) if(k<=c1&&b[i]-k<=c0) {
                (f[i&1][c2+k]+=f[(i-1)&1][c2]*binom(c1,k)%mod*binom(c0,b[i]-k)%mod)%=mod;
            }
        } 
    }
    printf("%lld\n",f[n&1][m]);
    return 0;
}
```
