---
title: luogu8162 让我们赢得选举 题解
tags:
  - 贪心
  - DP
categories: 题解
description: 'Solution'
pubDate: 2022-10-22
---

## 分析

首先让自己和协作者在多个不同的州演讲一定不优。

证明：反证法。假设更优，那么由于自己和协作者的演讲速度相同，所以在同样的时间里，让协作者为自己「加速」和分头演讲的总量是不变的。而让自己加速能够在更短的时间里得到正在演讲的那个州的票，矛盾。

其次，对于任意一个州，它的演讲时间只能为 $A_i$，$B_i[B_i \neq -1]$，$0$。这个是显然的。为了方便起见，分别称之为 2 类州，1 类州和 3 类州。

对于所有 1 类州，一定最先被演讲完。

证明：微扰。如果存在一个 1 类州在一个 2 类州之后，将二者交换后，在 $j$ 演讲的时候就多了一个演讲者，在 $B_i$ 演讲时演讲者数量不变，显然更优。

对于所有 1 类州，一定按照 $B_i$ 为第一关键字，$A_i$ 为第二关键字递增排序。

证明：微扰。如果存在一种不符合这个法则的方案，设他们为 $(i,j)$，那么得到两张票的用时

$$
\frac{B_i}{k} + \frac{B_j}{k+1}
$$



交换后为

$$
\frac{B_i}{k+1} + \frac{B_j}{k}
$$



同乘 $k(k+1)$

$$
B_i(k+1) + B_jk
$$

$$
B_ik + B_j (k+1)
$$

由于 $B_i > B_j$，根据排序不等式，后者不劣于前者。

具体实现时只要将所有州按照这个法则排序即可。

&nbsp;

设 $f(i,j,k)$ 表示前 $i$ 个州，得到了 $j$ 张票，其中总管有 $d$  1 类州，已经完成了 $k$ 个的最小代价。

$$
f(i,j,k) \rightarrow f(i+1,j,k)
$$



$$
f(i,j,k) + \lfloor \frac{A_{i+1}}{d+1} \rfloor \rightarrow f(i,j+1,k)
$$

$$
f(i,j,k) + \lfloor \frac{B_{i+1}}{k+1} \rfloor  \rightarrow f(i+1,j+1,k+1)
$$

采用刷表法的原因：转移方式较多，状态较为复杂。

由于 1 类州的数量无法确定且没有什么性质，所以要枚举。

复杂度 $O(n^3K)$，可以得到 56pts 的高分。

```cpp
double solve(int d) {
    for(int i=0;i<=n;++i) for(int j=0;j<=n;++j) for(int k=0;k<=n;++k) f[i][j][k]=1.0*inf;
    f[0][0][0]=0.0;
    for(int i=0;i<n;++i) {
        for(int j=0;j<=K;++j) {
            for(int k=0;k<=d;++k) {
                f[i+1][j][k]=min(f[i+1][j][k],f[i][j][k]);
                f[i+1][j+1][k]=min(f[i+1][j+1][k],f[i][j][k]+1.0*s[i+1].a/(d+1));
                f[i+1][j+1][k+1]=min(f[i+1][j+1][k+1],f[i][j][k]+1.0*s[i+1].b/(k+1));
            }
        }
    }
    return f[n][K][d];
}
```

考虑下面那一档性质分。发现 $K=n$ 时可以略去 $j$ 那一维，复杂度 $O(n^2K)$，可以多拿 11pts。

```cpp
double solve2(int d) {
    for(int i=0;i<=n;++i) for(int j=0;j<=n;++j) g[i][j]=1.0*inf;
    g[0][0]=0.0;
    for(int i=0;i<n;++i) {
        for(int j=0;j<=d;++j) {
            g[i+1][j]=min(g[i+1][j],g[i][j]+1.0*s[i+1].a/(d+1));
            g[i+1][j+1]=min(g[i+1][j+1],g[i][j]+1.0*s[i+1].b/(j+1));
        }
    }
    return g[n][d];
}
```

考虑优化。

当完成了所有 1 类州的演讲时，剩下的肯定是挑选时间最小的那些州进行演讲。

设 $f(i,j)$ 为前 $i$ 个州，选出了 $j$ 个 1 类州的最小时间。

由于边界条件的原因，不能使用刷表法了。

不选 $i$

$$
f(i-1,j) + \lfloor \frac{A_i}{d+1} \rfloor \rightarrow f(i,j)
$$


选

$$
f(i-1,j-1) + \lfloor \frac{B_i}{j} \rfloor \rightarrow f(i,j)
$$



然后取一个 $\delta = \min_{i=K}^n \{ f(i,d) \}$，这代表在寻找最优的 1 类州时已经完成 $K$ 张票的最小时间。

枚举 $i \in [d,K-1]$，找到 $[i,n]$ 中前 $K-i$ 小的 $A_i$ 的和 $val$，$f(i,d) + \lfloor \frac{val}{d+1} \rfloor$ 即为这部分的最小时间。

取最小值即可。

这样复杂度就变成了 $O(nK^2)$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=505, inf=1e9;
int n, K;
double ans=1.0*inf, t[N], f[N][N];
struct node {
    int a, b;
} s[N];
bool operator<(node x,node y) {
    if(x.b!=y.b) return x.b<y.b;
    return x.a<y.a;
}
double solve(int d) {
    for(int i=1;i<=n;++i) t[i]=1.0*s[i].a;
    double ans=1.0*inf;
    for(int i=0;i<=n;++i) for(int j=0;j<=n;++j) f[i][j]=1.0*inf;
    f[0][0]=0.0;
    for(int i=1;i<=n;++i) for(int j=0;j<=min(d,i);++j) {
        f[i][j]=f[i-1][j]+1.0*s[i].a/(d+1);
        if(j&&s[i].b!=1e15) f[i][j]=min(f[i][j],f[i-1][j-1]+1.0*s[i].b/j);
    }
    for(int i=K;i<=n;++i) ans=min(ans,f[i][d]);
    for(int i=K-1;i>=d;--i) {
        sort(t+i+1,t+n+1);
        // 对这个后缀排序
        double val=0;
        for(int j=1;j<=K-i;++j) val+=t[i+j];
        ans=min(ans,f[i][d]+val/(d+1));
    }
    return ans;
}
signed main() {
    n=read(), K=read();
    for(int i=1;i<=n;++i) {
        s[i].a=read(), s[i].b=read();
        if(s[i].b==-1) s[i].b=1e15;
    }
    sort(s+1,s+n+1);
    for(int i=0;i<=K;++i) ans=min(ans,solve(i));
    printf("%.15lf\n",ans);
}
```
