---
title: luogu5664 Emiya 家今天的饭 题解
tags:
  - DP
categories:
  - 题解
pubDate: 2022-04-10
description: 'Solution'
---

## 分析

这题很有启发意义：不要为了 DP 而去 DP。对于一个计数问题，应当灵活地去划分。

题目中的三个条件，如果直接去计数做的话，信息冗余太多，很难理清思路。但是注意到我们能极其容易地求出满足前两个条件的方案数，而且三个条件都满足的方案一定在满足前两个条件的方案数中。所以如果我们能够单独求出不满足第三个条件的数量，就能够求出满足三个条件的方案数。这是一种常见的套路。

显然对于一种烹饪方法 $i$，能够做出 $A_i = \sum_{j=1}^m a_{i,j}$ 道不同的菜。

由于每一种烹饪方法都可以不选，但是又不能每一种都不选，所以满足前两个条件的方案数为

$$
\prod_{i=1}^n (A_i+1) -1
$$



接下来单独考虑第三个条件。

这个可以 DP，但不是直接用 DP 统计目标方案数。因为太过苛刻的转移条件会大大增加复杂度，而加入可承受范围内的冗余信息有时是能够简化问题的。

所以，设 $f_{i,j,k}$ 为前 $i$ 种方法，选择了 $j+k$ 种方法，其中 $j$ 次用到了当前食材 $x$。

转移比较简单

$$
f_{i,j,k} = f_{i-1,j,k}+a_{i,x} \cdot f_{i-1,j-1,k} + (A_i-a_{i,x} ) \cdot f_{i-1,j,k-1}
$$



最终答案 $\sum f_{n,j,k} \quad j > k$。

这样状态数为 $n^3$，转移为 $O(1)$，但是还要对于 $m$ 种食材分别计算，所以复杂度为 $O(n^3m)$。这个不够优秀。

转移和枚举是优化不了的，只能从状态下手。可以看到，对于食材 $x$，我们只关心使用它的方案数是否占到一半以上，不关心具体选择方案。这也有一种常见的优化技巧。

设 $f_{i,j}$ 为前 $i$ 种方法，其中选择食材 $x$ 的方法数量减去其他方法数量结果是 $j$，若 $j > 0$，那么就说明占到了一半以上。但是这个下标可能为负数，所以要加上一个偏移量。

这样状态数降到了 $n^2$，转移呢？

$$
f_{i,j} = f_{i-1,j}+a_{i,x} \cdot f_{i-1,j-1} + (A_i-a_{i,x}) \cdot f_{i-1,j+1}
$$



依旧是 $O(1)$。

所以这个 DP 的复杂度为 $O(n^2m)$。

答案为 $\prod_{i=1}^n (A_i+1) -1 -\sum f_{n,j} \quad j>0$

具体细节见代码。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=105, M=2005, mod=998244353, dlt=105;
int n, m, S=1, ans, a[N][M], s[N], f[N][2*N];
int calc(int x,int y) { return (s[x]-a[x][y]+mod)%mod; }
signed main() {
    n=read(), m=read();
    for(int i=1;i<=n;++i) {
        for(int j=1;j<=m;++j) {
            a[i][j]=read();
            s[i]=(s[i]+a[i][j])%mod;
        }
        (S*=s[i]+1)%=mod;
    }
    (S-=1)%=mod;
    for(int i=1;i<=m;++i) {
        SET(f,0);
        f[0][n]=1;
        for(int j=1;j<=n;++j) for(int k=n-j;k<=n+j;++k)
            f[j][k]=(f[j-1][k]+f[j-1][k-1]*a[j][i]%mod+f[j-1][k+1]*calc(j,i)%mod)%mod;
        for(int j=1;j<=n;++j) (ans+=f[n][n+j])%=mod;
    }
    printf("%lld",(S-ans+mod)%mod);
}
```


