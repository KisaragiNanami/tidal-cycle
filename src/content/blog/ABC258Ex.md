---
title: ABC258Ex Odd Steps 题解
tags:
  - DP
  - 矩阵
categories:
  - 题解
pubDate: 2022-08-12
description: 'Solution'
---

## 分析

问题可以转化为，在一个 $1 \sim S$ 的数轴上，把数轴划分成段若干段，每一段的长度必须是奇数，且对于 $i \in [1,n]$，不能在 $a_i$ 处划分。



先不考虑限制条件。

设 $f_i$ 表示划分 $[1,i]$，且最后一段是奇数的方案数，设 $g_i$ 表示划分 $[1,i]$，且最后一段是偶数的方案数。

考虑 $i-1 \rightarrow i$，$i$ 既可以单独作为一个奇数段，又可以加入 $i-1$ 所在的这一段，改变这一段的奇偶性，所以

$$
\begin{cases}
f_i = f_{i-1} + g_{i-1}
\\
g_i = f_{i-1}
\end{cases}
$$



答案是 $f_{S}$。

$S$ 过大，考虑矩阵加速递推。

构造向量 $\begin{bmatrix} f_i \\ g_i \end{bmatrix}$，初始为 $\begin{bmatrix} f_1 = 1 \\ g_1 = 0 \end{bmatrix}$。 设转移矩阵为 $A$。

$$
A \begin{bmatrix} f_{i-1} \\ g_{i-1} \end{bmatrix} = \begin{bmatrix} f_i \\ g_i \end{bmatrix}
$$





手算不难发现 $A = \begin{bmatrix} 1 & 1 \\ 1 & 0 \end{bmatrix}$，也就是斐波那契数列的转移矩阵。

递推第 $n$ 项，转化为用 $A$ 的 $n-1$ 次幂去变化初始向量。

如果有限制，那么 $i-1 \rightarrow i$ 的这个 $1$ 就必须接在前一段，所以


$$
\begin{cases}
f_i = g_{i-1}
\\
g_i = f_{i-1}
\end{cases}
\Longrightarrow B 

\begin{bmatrix}
f_{i-1}
\\
g_{i-1}
\end{bmatrix} =

\begin{bmatrix}
f_i
\\
g_i
\end{bmatrix}
$$



这个转移矩阵 $B = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}$，也就是把两项交换一下。

可以对没有限制的地方分段处理。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long 
#define ll long long
const int N=2e5+5, mod=998244353;
int n, s, pre;
// pre表示上一次递推完的那一项
struct Mat {
    int m[3][3];
    void clear() { memset(m,0,sizeof(m)); }
    void id() { for(int i=0;i<2;++i) m[i][i]=1; }
} rec1, rec2, f;
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
Mat mul(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=0;i<2;++i)
        for(int k=0;k<2;++k)
            (c.m[i][0]+=a.m[i][k]*b.m[k][0]%mod)%=mod;
    return c;
    // 矩阵向量乘法
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
signed main() {
    n=read(), s=read();
    rec1.m[0][0]=rec1.m[0][1]=rec1.m[1][0]=1, rec1.m[1][1]=0;
    rec2.m[0][1]=rec2.m[1][0]=1, rec2.m[0][0]=rec2.m[1][1]=0;
    f.m[0][0]=1, f.m[1][0]=0;
    // 第1项
    for(int i=1;i<=n;++i) {
        int lim=read();
        if(lim<=pre) continue;
        f=mul(fp(rec1,lim-1-pre),f);
        // 第lim项要单独处理
        f=mul(rec2,f);
        pre=lim;
    }
    f=mul(fp(rec1,s-pre-1),f);
    // 此时第pre项已经递推完毕，f存的是第pre+1项
    printf("%lld\n",f.m[0][0]);
}
```
