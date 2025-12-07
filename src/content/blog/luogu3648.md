---
title: luogu3648 序列分割 题解
tags:
  - DP
  - 斜率优化
categories: 题解
description: 'Solution'
pubDate: 2022-03-13
---

## 分析

根据小学学的乘法分配律，并且手算一下，能够发现，如果要把整个序列分成若干段，那么不同的分割顺序不会对最终得分产生影响。

比如样例的方法是`1 3 5`，如果我们按照`5 3 1`来分，答案也是一样的。

然后划分方法就没有后效性了，我们可以定义一个固定的划分顺序。按照习惯都是从左往右去分。



设 $f_{i,k+1}$ 为前 $i$ 个数字，划分成 $k+1$ 段的最大得分。状态看起来是没有错的，但是怎么去转移呢？如果像样例一样做的话，不还要记录某一块区间的长度吗？看数据范围，如果加一维的话肯定是不行的。

不知道是因为我太弱还是太长时间不做 OI 题了，我竟然连这么简单的问题都考虑很久……

后来想到，大可不必像样例一样分。

对于一个 $f_{i,k+1}$，找到一个 $j$，满足 $j < i$，把从 $j$ 分割开看作第一次划分，这样就能准确地计算对答案的贡献，也不用关心区间。再者，规定之后只能在 $[1,j]$ 这个区间里划分。而这一部分就是 $f_{j,k}$。这样就不需要记录划分的那个区间的长度了。

所以转移为

$$
f_{i,k+1} = \min _ {j \in [1,i)}{\{ f_{j,k} + s_j \cdot (s_i-s_j) \}}
$$



其中右边那一项就是把这一次划分看作第一次划分产生的贡献，剩下的就由之前的状态转移过来。相当于把划分顺序颠倒了，而事实上根据开头的讨论，这是正确的。

复杂度 $O(n^2k)$，显然不够。

然后就是斜率优化的套路了。

对于一个决策 $j'$ 优于 $j$，则有

$$
f_{j',k} + s_{j'} \cdot (s_i-s_{j'}) < f_{j,k} + s_j \cdot (s_i-s_j)
$$

$$
f_{j',k} + s_is_{j'} -s^2_{j'} < f_{j,k} + s_is_j - s_j^2
$$

$$
f_{j',k} - f_{j,k} + s_j^2 -s^2_{j'} < s_is_j - s_is_{j'}
$$

$$
\frac{f_{j',k} - f_{j,k} + s_j^2 -s^2_{j'}}{s_j - s_{j'}} < s_i
$$

套路地去维护下凸包就好了。

内存不太足，滚动数组优化。开 long long。

复杂度 $O(nk)$

## code

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
#define ll long long
const int N=1e5+5, K=205;
int n, k_, p, l, r, a[N], q[N], ans[K][N];
ll s[N], f[2][N];
ll squ(ll x) { return x*x; }
double calc(int j,int k) {
    return s[j]!=s[k]? 1.0*(f[p^1][k]-f[p^1][j]-squ(s[k])+squ(s[j]))/(s[j]-s[k]):-1e18;
}
void solve(int x,int k) {
    if(k==0) return;
    solve(ans[k-1][x],k-1);
    printf("%d ",x);
}
int main() {
    scanf("%d%d",&n,&k_);
    for(int i=1;i<=n;++i) scanf("%d",&a[i]), s[i]=s[i-1]+a[i];
    for(int k=1;k<=k_;++k,p^=1) {
        q[l=r=1]=0;
        for(int i=1;i<=n;++i) {
            while(l<r&&calc(q[l],q[l+1])<s[i]) ++l;
            f[p][i]=f[p^1][q[l]]+s[q[l]]*(s[i]-s[q[l]]);
            ans[k][i]=q[l];
            while(l<r&&calc(q[r],i)<calc(q[r-1],q[r])) --r;
            q[++r]=i;
        }
    }
    printf("%lld\n",f[p^1][n]);
    solve(ans[k_][n],k_);
    puts("");
}
```
