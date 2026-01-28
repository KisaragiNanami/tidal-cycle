---
title: luogu5858 Golden Sword 题解
tags:
  - DP
  - 单调队列
categories:
  - 题解
description: 'Solution'
pubDate: 2022-01-23
---

设 $f_{i,j}$ 为放入第 $i$ 个原料，炼金锅中共有 $j$ 个原料时的耐久度之和。

边界

$$
f_{i,j}= \begin{cases}0 & i=0,j=0 \\ -\inf & \text{otherwise}\end{cases}
$$





考虑 $j$ 的取值范围。因为最少一个也不拿走，最多拿走 $s$ 个，锅中最多有 $w$ 个原料，所以对于状态 $f_{i,j}$ 的一个决策  $k$

$$
j-1 \le k \le \min{\{w,j-1+s\}}
$$



转移为

$$
f_{i,j}=\max{\{ f_{i-1,k} + a_i \times j\}}
$$





答案为 $\max{\{ f_{n,i} \}} \quad i \in [1,w]$

交上去，光荣地 TLE 了。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
#define ll long long
const int N=5e3+6;
int n, w, s;
ll ans=-1e15, a[N], f[N][N];
int main() {
    scanf("%d%d%d",&n,&w,&s);
    for(int i=0;i<=n;++i) for(int j=0;j<=w;++j) f[i][j]=-1e15
    f[0][0]=0;
    for(int i=1;i<=n;++i) scanf("%lld",&a[i]);
    for(int i=1;i<=n;++i) for(int j=1;j<=w;++j) {
        int t=min(w,j-1+s);
        for(int k=j-1;k<=t;++k) f[i][j]=max(f[i][j],f[i-1][k]+a[i]*j);
    }
    for(int i=1;i<=w;++i) ans=max(ans,f[n][i]);
    printf("%lld\n",ans);
}
```

考虑优化。

注意原转移方程中，$a_i\times j$ 是个定值，将其提出后，我们要做的就是快速查找 $\max{\{ f_{i-1,k} \}}$

使用单调队列维护 $f_{i-1,k}$ 单调减，队首即为最优决策。用 $q_l$ 表示队首，则转移方程为

$$
f_{i,j}=\max_{j \in [1,\min(i,w)]}{\{ f_{i-1,j-1},f_{i-1,q_l} \}}
$$


前者为「不拿走」，后者为「拿就拿波大的」

注意，为了保证队列中的决策都是 $f_{i-1,j}$ 时状态， $j$ 这一维必须倒序循环。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
#define ll long long
const int N=5e3+6;
int n, w, s, l, r, q[N];
ll ans=-1e15, a[N], f[N][N];
int main() {
    scanf("%d%d%d",&n,&w,&s);
    for(int i=0;i<=n;++i) for(int j=0;j<=w;++j) f[i][j]=-1e15;
    f[0][0]=0;
    for(int i=1;i<=n;++i) scanf("%lld",&a[i]);
    for(int i=1;i<=n;++i) {
        l=1, r=0;
        for(int j=min(i,w);j;--j) {
            while(l<=r&&j-1+s<q[l]) ++l;
            while(l<=r&&f[i-1][q[r]]<f[i-1][j]) --r;
            q[++r]=j;
            f[i][j]=max(f[i-1][j-1],f[i-1][q[l]])+a[i]*j;
        }
    }
    for(int i=1;i<=w;++i) ans=max(ans,f[n][i]);
    printf("%lld\n",ans);
}
```
