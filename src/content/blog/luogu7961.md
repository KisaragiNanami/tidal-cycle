---
title: luogu7961 数列 题解
tags:
  - DP
  - 状态压缩
  - 计数
categories: 题解
description: 'Solution'
pubDate: 2022-06-21
---



于 2023 年 6 月 20 日重构此文。

## 暴力

首先明确 $a_i \in [0,m]$

设 $f(x,S)$ 为当前 $\{a_i\}$ 有 $x$ 项，其中 $S = \sum_{i=1}^x 2^{a_i}$，能够产生的贡献。

状态总数为 $O(2^{m}nm)$

枚举 $k$，转移 $O(m)$

$$
f(x,S) = \sum_{i=0}^m f(x+1,S+2^{m}) \cdot v_i
$$



边界用 $\operatorname{popcount}$ 判断。

复杂度 $O(2^m m^2 n)$。

期望得分 $50 \text{ pts}$

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
const int N=35, M=105, mod=998244353;
int n, m, k, v[M], f[N][1<<18];
int ctz(int x) {
    int cnt=0;
    while(x) cnt+=x&1, x>>=1;
    return cnt;
}
int dfs(int x,int S) {
    if(~f[x][S]) return f[x][S];
    if(x==n) return f[x][S]=ctz(S)<=k;
    int& res=f[x][S];
    res=0;
    for(int i=0;i<=m;++i) {
        (res+=v[i]*dfs(x+1,S+(1<<i)))%=mod;
    }
    return res;
}
signed main() {
    n=read(), m=read(), k=read();
    rep(i,0,m) v[i]=read();
    SET(f,-1);
    printf("%lld\n",dfs(0,0));
    return 0;
}
```

## 正解

暴力状态无论如何优化都无法承受了，考虑重新设计状态。

瓶颈在于状态数量太多。

在暴力的做法中，我们把 $S$ 看作是一个真实的数，从而绕不开 $S$ 的表示方法，计算贡献的方法也因此被限制。

尝试转化问题，我们实际上要确定一个长度为 $n$ 的序列，元素的值域是 $[0,m]$，元素 $j$ 出现 $k$ 次的贡献是 $v_j^k$。限制是 $\operatorname{popcount}(S) \le k$，把 $S$ 看作 $m$ 位二进制数的话，可以从进位的角度下手，按照数位从低到高处理，其实也就是确定了构造 $a$ 序列的顺序。

$f(k,i,x,y)$，表示已经确定了 $S$ 二进制的 $k$ 位，其中 $\{a\}$ 数列确定了 $i$ 项，有 $x$ 个 $1$，同时第 $k-1$ 位进了 $y$ 个 1 到 $k$ 位，还能够产生的贡献。

状态数量是 $O(mn^3)$ 的。

转移枚举第 $k$ 位上放多少个 $1$，也就是 $v_k$ 用多少次。
$$
f(k,i,x,y) = \sum_{j=0}^{n-i} f \Big(k+1,i+j,x+op(y+j),\lfloor \frac{y+j}{2} \rfloor \Big) \times \binom{n-i}{j} \times v_k^j
$$
$op(x) = [x \text{ is } \mathrm{odd}]$。

当 $i=n$ 的时候，此时 $[1,k]$ 位上有 $x$ 个 $1$，前面进了 $y$ 个 $1$。 $y$ 个 $1$ 最后产生的 $1$ 数量是它的二进制中 1 的个数。

复杂度 $O(mn^4)$。

期望得分 $100 \text{ pts}$。

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
const int N=35, M=105, mod=998244353;
int n, m, k, v[M][N], c[N][N], f[M][N][N][N];
int popcount(int x) {
    int cnt=0;
    while(x) cnt+=x&1, x>>=1;
    return cnt;
}
void init() {
    rep(i,0,m) rep(j,2,n) v[i][j]=v[i][j-1]*v[i][1]%mod;
    c[0][0]=1;
    rep(i,1,n) {
        c[i][0]=c[i][i]=1;
        rep(j,1,i-1) c[i][j]=(c[i-1][j]+c[i-1][j-1])%mod;
    }
}
int dfs(int p,int i,int x,int y) {
    if(~f[p][i][x][y]) return f[p][i][x][y];
    int& res=f[p][i][x][y];
    res=0;
    if(i==n) return res=(x+popcount(y)<=k);
    if(p>m) return res;
    for(int j=0;j<=n-i;++j) {
        (res+=c[n-i][j]*v[p][j]%mod*dfs(p+1,i+j,x+(y+j)%2,(y+j)/2)%mod)%=mod;
    }
    return res;
}
signed main() {
    n=read(), m=read(), k=read();
    rep(i,0,m) v[i][0]=1, v[i][1]=read();
    init();
    SET(f,-1);
    printf("%lld\n",dfs(0,0,0,0));
    return 0;
}
```
