---
title: luogu6563 [SBCOI2020] 一直在你身旁 题解
pubDate: 2023-09-07
tags:
  - DP
  - 区间DP
  - 单调队列
  - 决策单调性
categories:
  - 题解
description: 'Solution'
---

### luogu6563 [SBCOI2020] 一直在你身旁

不妨称需要的电线为答案电线。

注意到购买长度为 $k$ 的电线本质上是把答案电线的取值范围从 $[i,j]$ 缩小到了 $[i,k]$ 或 $[k+1,j]$。虽然无法确定到底是在哪一个区间，但是最坏的情况一定是答案电线在二者中代价更大的里面，同时我们完成了对子问题的划分，直接上区间 DP。

我们把拓扑序反过来，使得这个过程符合区间 DP。设 $f(i,j)$ 为答案电线的取值范围是 $[i,j]$ 时，最坏情况下找到答案电线还需要的最小代价。

显然有

$$
f(i,j) = \min_{k \in [i,j-1]} \Big\{ \max \Big(f(i,k),f(k+1,j) \Big) + a_k \Big\}
$$



考虑优化。

打表发现确实有决策单调性，但是是分段单调，不太容易下手。

从实际意义的角度似乎不是很显然。

套路地把 $\max$ 拆开，考虑会在哪边取到。

注意到 $\{a_i\}$ 单调不降，再感性理解一下，$f(i,k)$ 关于 $k$ 单调增，$f(k+1,j)$ 关于 $k+1$ 单调减，从而 $f(i,k)-f(k+1,j)$ 关于 $k$ 单调不降，也就是存在临界点。

可以用二分找到最小的使得 $f(i,k)>f(k+1,j)$ 的 $k$，记为 $p$。

然而有 $f(i,j) \le f(i,j+1)$，所以在 $i$ 或者 $j$ 变化时，$p$ 也是单调的，用一个指针维护即可。

接下来讨论一个决策点 $k$ 与 $p$ 的关系。

- $k < p$。此时取到的是 $f(k+1,j)+a_k$，发现这东西和 $i$ 无关。在 $j$ 固定时可以用单调队列维护。
- $k \ge p$，此时取到的时 $f(i,k)+a_k$，它关于 $k$ 单调增，最终取到的一定是 $f(i,p)+a_p$。

综上所述，在右端点固定，左端点递减时，我们可以做到均摊 $O(1)$ 地转移。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
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
const int N=7105;
int T, n, a[N];
int q[N];
ll f[N][N];
void solve() {
    n=read();
    rep(i,1,n) a[i]=read();
    for(int j=2;j<=n;++j) {
        int l=1, r=0;
        f[j-1][j]=a[j-1];
        q[++r]=j-1;
        for(int i=j-2,k=j;i;--i) {
            while(k>i&&f[i][k-1]>f[k][j]) --k;
            while(l<=r&&q[l]>=k) ++l;
            f[i][j]=f[i][k]+a[k];
            if(l<=r) f[i][j]=min(f[i][j],f[q[l]+1][j]+a[q[l]]);
            while(l<=r&&f[q[r]+1][j]+a[q[r]]>=f[i+1][j]+a[i]) --r;
            q[++r]=i;
        }
    }
    printf("%lld\n",f[1][n]);
}
signed main() {    T=read();
    while(T--) solve();
    return 0;
}
```
