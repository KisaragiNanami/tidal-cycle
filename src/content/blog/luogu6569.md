---
title: luogu6569 魔法值 题解
tags:
  - DP
  - 矩阵
  - 倍增
categories:
  - 题解
description: 'Solution'
pubDate: 2022-08-12
---



## 分析

天数异常大，但是节点数很小，由于异或运算满足结合律，直接考虑矩阵优化。

将初始魔法值搞成一个向量，$n$ 行 $1$ 列。

$$
\begin{bmatrix}w_1\\w_2\\\vdots\\w_n\end{bmatrix}
$$



考虑转移矩阵 $A$。

要达到的目的是，如果 $(i,k)$ 之间有边才进行运算。那么设 $A_{i,k}$ 表示 $(i,k)$ 是否相连。所以

$$
w'_i = \bigoplus_{k=1}^n A_{i,k} \cdot w_k
$$



所以 $A_{x,y} = A_{y,x} = 1$。

好像就没有然后了。

因为有多次询问，直接做的话复杂度是 $O(qn^3 \log_2 k)$ 的，较高。但是由于不仅做 $O(n^3)$ 的矩阵乘法，还要做上面那种 $O(n^2)$ 的矩阵向量乘法，所以可以预处理矩阵次幂，对询问进行二进制拆分优化。

复杂度 $O \Big( n^3\log_2 \max\{a_i\}  + q n^2 \log_2 \max\{a_i\} \Big)$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long 
const int N=105, mod=998244353;
int n, m, q, w[N];
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
    int m[105][105];
    void clear() { memset(m,0,sizeof(m)); }
    void id() { for(int i=0;i<n;++i) m[i][i]=1; }
} f, rec[35];
Mat operator*(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=0;i<n;++i)
        for(int k=0;k<n;++k)
            for(int j=0;j<n;++j)
                c.m[i][j]^=a.m[i][k]*b.m[k][j];
    // 注意n比较大，不要直接for i 1->100
    return c;
}
Mat mul(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=0;i<n;++i)
        for(int k=0;k<n;++k)
            c.m[i][0]^=a.m[i][k]*b.m[k][0];
    return c;
    // 这是矩阵向量乘法
}
int query(int x) {
    f.clear();
    for(int i=0;i<n;++i) f.m[i][0]=w[i];
    for(int i=31;~i;--i) if((x>>i)&1) f=mul(rec[i],f);
    return f.m[0][0];
}
signed main() {
    n=read(), m=read(), q=read();
    for(int i=0;i<n;++i) w[i]=read();
    while(m--) {
        int x=read()-1, y=read()-1;
        // 编号为0~n-1
        rec[0].m[x][y]=rec[0].m[y][x]=1;
    }
    for(int i=1;i<32;++i) rec[i]=rec[i-1]*rec[i-1];
    while(q--) {
        int x=read();
        printf("%lld\n",query(x));
    }
}
```
