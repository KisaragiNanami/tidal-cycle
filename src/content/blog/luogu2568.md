---
title: luogu2568 GCD 题解
tags:
  - 数论
  - 欧拉函数
categories: 题解
pubDate: 2021-08-25
description: 'Solution'
---

设 $p$ 为质数且 $p \le n$。

显然的，若 $\gcd(x,y)=1$，则 $\gcd(x \times p,y \times p)=p$。

问题转化为求互质的数对 $(x,y)$ 的个数。

这时候就要用上欧拉函数了！

由于欧拉函数是与一个数互质，那么用前缀和。

由于 $(x,y)$ 与 $(y,x)$ 算两种，所以计数时要乘 $2$。

设 $m$ 为 $n$ 的约数个数，$p_i$ 为 $n$ 的第 $i$ 个约数。 则答案为

$$
\sum_{i=1}^m{2 \times \varphi \Big(\frac{n}{p_i} \Big)-\varphi(1)}
$$

$$
2 \times  \sum_{i=1}^m{\varphi \Big(\frac{n}{p_i} \Big)-1}
$$

$$
2 \times  \Bigg(\sum_{i=1}^m{\varphi \Big(\frac{n}{p_i}\Big)} \Bigg) - m
$$

实现的时候用欧拉筛。

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
#define ll long long
const int N=1e7+6;
ll n, m, ans, v[N], p[N], phi[N];
int main() {
    int i, j;
    scanf("%lld",&n);
    phi[1]=1;
    for(i=2;i<=n;++i) {
        if(!v[i]) v[i]=i, p[++m]=i, phi[i]=i-1;
        for(j=1;j<=m;++j) {
            if(p[j]>v[i]||p[j]*i>n) break ;
            v[p[j]*i]=p[j];
            phi[p[j]*i]=phi[i]*(i%p[j]?p[j]-1:p[j]);
        }
        phi[i]+=phi[i-1];
    }
    for(i=1;i<=m;++i) ans+=phi[n/p[i]];
    printf("%lld\n",(ans<<1)-m);
}
```
