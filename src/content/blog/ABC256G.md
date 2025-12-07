---
title: ABC256G Black and White Stones 题解
tags:
  - DP
  - 矩阵
categories:
 - 题解
pubDate: 2022-08-12
description: 'Solution'
---

## 分析

下面定义白色黑色石头为染白色黑色。

套路性地断环为链。如图中，把顶点拆成两个点，$i$ 和 $i'$，显然 $i$ 与 $i'$ 的颜色必定相同，即上一条链的尾等于下一条链的首，所以每条链首尾的颜色都要记录。



![](https://s2.loli.net/2022/08/13/2lFo64mduNpKWEI.png)

![](https://s2.loli.net/2022/08/13/ulvDh5mFIis2Tet.png)

枚举每条链防放置石头的个数 $k$，设 $f_{i,0/1,0/1}$ 为考虑前 $i$ 条链，它们按顺序首尾相连后形成一个长链，其中这个长链的头是黑/白色，尾是黑/白色的方案数。

只有 $1$ 条链时没有限制，相当于 $d-1$ 个位置（去掉首尾）染成白色，所以有


$$
\begin{cases}
f_{1,0,0} = \binom{d-1}{k}
\\
f_{1,0,1} = f_{1,1,0} = \binom{d-1}{k-1}
\\
f_{1,1,1} = \binom{d-1}{k-2}
\end{cases}
$$



考虑将 $i-1$ 条链相连后，扩展成 $i$ 条链的过程。一个很重要的思想是，所有的单链，本质上是相同的。

首先，对于 $f_{i,0,0}$，必须用 $i-1$ 条链相连且首是 $0$ 的长链，接上一条首和长链的尾相同，且尾是 $0$ 的单链。


$$
f_{i,0,0} = \sum_{k=0}^1 f_{i-1,0,k} \cdot f_{1,k,0}
$$


对于 $f_{i,1,1}$，也是差不多的。

$$
f_{i,1,1} = \sum_{k=0}^1 f_{i-1,1,k} \cdot f_{1,k,1}
$$


其他两种就很显然了，不再赘述。

不难发现，这个式子就是矩阵乘法的形式，正好 $N$ 特别大，所以可以用矩阵加速递推。

建立矩阵 $A$，有

$$
A =\begin{bmatrix}f_{1,0,0} & f_{1,0,1}\\f_{1,1,0} & f_{1,1,1}\end{bmatrix}
$$





通过观察不难得出，求 $i=N$ 时的答案，等于求 $A^n$。

矩阵快速幂就行了。

最后，由于整个链还要接成一个环，所以首尾必须相同，即答案累加 $f_{n,0,0} + f_{n,1,1}$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long 
#define ll long long
const int  mod=998244353;
int n, d, ans, c[10005];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
struct Mat {
    int m[2][2];
    void clear() { memset(m,0,sizeof(m)); }
    void id() { for(int i=0;i<2;++i) m[i][i]=1; }
} f;
Mat operator*(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=0;i<2;++i)
        for(int k=0;k<2;++k)
            for(int j=0;j<2;++j)
                (c.m[i][j]+=a.m[i][k]*b.m[k][j]%mod)%=mod;
    return c;
}
Mat fp(Mat a,int b) {
    Mat c; c.clear(), c.id();
    for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
    return c;
}
int power(int a,int b) {
    int c=1; a%=mod;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
int C(int x) {
    if(x<0||x>(d-1)) return 0;
    return c[x];
}
signed main() {
    n=read(), d=read();
    c[0]=1;
    for(int i=1;i<d;++i) c[i]=c[i-1]*(d-i)%mod*power(i,mod-2)%mod;
    // 递推c[d-1][i]
    for(int i=0;i<=d+1;++i) {
        f.clear();
        f.m[0][0]=C(i), f.m[0][1]=C(i-1);
        f.m[1][0]=C(i-1), f.m[1][1]=C(i-2);
        f=fp(f,n);
        (ans+=(f.m[0][0]+f.m[1][1])%mod)%=mod;
    }
    printf("%lld\n",ans);
}
```
