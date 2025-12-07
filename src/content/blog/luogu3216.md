---
title: luogu3216 数学作业 题解
tags:
  - 矩阵
categories:
  - 题解
pubDate: 2022-05-15 19:07:03
description: 'Solution'
---

## 分析

设 $f(i)$ 为 $Concatenate(i) \bmod m$ 的值。

那么显然有 $f(i) = \Big( f(i-1) \cdot 10^k + i \Big) \bmod m$，其中 $k = \lfloor \lg i \rfloor +1$。



这个直接递推绝对是 T 飞的，$n \in [1,10^{18}]$。

但是这明显是个线性递推式，可以用矩阵优化。

定义一个向量为 $\begin{bmatrix} f(i-1) \\ i-1 \\ 1 \end{bmatrix}$，我们的目标是把它变换成 $\begin{bmatrix} f(i) \\ i \\ 1 \end{bmatrix}$，这个 1 是来辅助把 $i-1$ 变换成 $i$ 的。

手算不难得到这个矩阵就是 $\begin{bmatrix}
10^k & 1 & 1
\\
0 & 1 & 1
\\
0 & 0 & 1
\end{bmatrix}$，设它为 $A$。

那么就有

$$
\begin{bmatrix} f(i) \\ i \\ 1 \end{bmatrix} = A \begin{bmatrix} f(i-1) \\ i-1 \\ 1 \end{bmatrix}
$$



进一步得到

$$
\begin{bmatrix} f(n) \\ i \\ 1 \end{bmatrix} = A^{n-1} \begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix}
$$



由于 $\lfloor \lg i \rfloor  +1 $ 在 $[1,9]$，$[10,99]$，$[100,999]$  这一类区间里面都相同，所以可以按照每一段分别处理，具体见代码。

注意上面的矩阵变换！必须保证先处理矩阵的幂，再统计答案。统计答案只需要累乘每一次的结果就行了。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int N=5;
ll n, mod;
struct Matrix {
    ll m[N][N];
    void reset() { for(int i=0;i<3;++i) for(int j=0;j<3;++j) m[i][j]=0; }
    void id() { for(int i=0;i<3;++i) m[i][i]=1; }
} ans, f;
Matrix operator*(Matrix a,Matrix b) {
    Matrix c; c.reset();
    for(int i=0;i<3;++i)
        for(int j=0;j<3;++j)
            for(int k=0;k<3;++k)
                c.m[i][j]=(c.m[i][j]+a.m[i][k]*b.m[k][j]%mod)%mod;
    return c;
}
Matrix operator^(Matrix x,ll y) {
    Matrix z; z.reset(), z.id(); // 矩阵快速幂要把m[i][i]置为1    
    for(;y;x=x*x,y>>=1) if(y&1) z=z*x;
    return z;
}
void solve(ll p,ll b) {
    f.m[0][0]=p%mod;
    ans=(f^b)*ans;
    // 一定是这样的计算顺序，不然WA
} 
int main() {
    scanf("%lld%lld",&n,&mod);
    ans.m[2][0]=1;
    f.m[0][1]=f.m[0][2]=f.m[1][1]=f.m[1][2]=f.m[2][2]=1;
    // f就是上文的A
    ll r=10;
    while(r<=n) solve(r,r-(r/10)), r*=10;
    solve(r,n-r/10+1); // 特殊情况，不是一个完整的形似[10^n,10^(n+1) -1]这样的区间
    printf("%lld\n",ans.m[0][0]);
}
```
