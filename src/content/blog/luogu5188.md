---
title: luogu5188 PALACINKE 题解
pubDate: 2023-10-23
tags:
  - DP
  - 容斥原理
  - 子集反演
  - 图论
  - 矩阵
categories: 题解
description: 'Solution'
---

## Solution

注意「采购方式包含了她经过的结点的次序，以及她在每条路上买不买材料，但不计她在哪个商店买了什么」，所以设 $f(i,x,S)$ 表示时间 $i$ 在点 $x$，取得的材料集合为 $S$ 是假的，因为 $S$ 这一维一定会考虑到在每个店买了什么。

考虑把 $S$ 这一维干掉，设 $f(i,x)$ 为时间 $i$ 在点  $x$，合法的购买方案数。状态设计上没有问题，但是因为不知道有没有买完所以转移不动，我们只能求出购买任意物品的方案数。

考虑容斥。设 $F(S)$ 为钦定只能购买 $S$ 内物品的方案数，$G(S)$ 为恰好购买 $S$ 内物品的方案数，有

$$
F(S) = \sum_{T \subseteq S} G(S)
$$






$$
G(S) = \sum_{T \subseteq S} (-1)^{|S|-|T|} F(T)
$$

答案就是 $G(U)$。

所以我们只要枚举集合 $S$，判一下哪些边卖的物品集合是 $S$ 的子集。显然有转移

$$
f(i,x) = \sum_{y \rightarrow x} f(i-1,y) + [s(y \rightarrow x) \subseteq S ]f(i-2,y)
$$



线性变换，$T$ 的范围也很大，考虑矩阵加速。

我们搞一个大小为 $(2n+1) \times 1$ 的向量出来。 

$$
\begin{bmatrix}f(i-1,1)\\f(i-1,2)\\\vdots\\f(i,1)\\f(i,2)\\\vdots\\ans\end{bmatrix}
$$






称上述向量为 $i$ 阶段，考虑如何变换到 $i+1$ 阶段。

考虑转移矩阵。

- $(i,i+n)$ 都应置为 $1$，把 $i$ 时刻的 $n$ 个状态平移上去。

- 对于边 $(x \rightarrow y)$，把 $(y+n,x+n)$ 置为 $1$。

- 对于合法边 $(x \rightarrow y)$，把  $(y+n,x)$ 置为 $1$。

- 对于 $ans$，只需要把 $(2n+1,2n+1)$ 和 $(2n+1,n+1)$ 置为 $1$ 即可。

考虑初始向量。

- $(1,1)$ 置为 $1$。
- 对于边 $(x \rightarrow y)$，把 $(y+n,1)$ 置为 $1$。

然后跑矩阵快速幂即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=40, M=505, mod=5557;
int n, m, U, ans, T;
struct edge {
    int x, y, s;
} e[M];
struct Mat {
    int m[2*N][2*N];
    void clear() { SET(m,0); }
    void init() { for(int i=0;i<=2*n;++i) m[i][i]=1; }
    int* operator[](int i) { return m[i]; }
    Mat operator*(const Mat& b) const {
        Mat c;
        c.clear();
        for(int i=0;i<=2*n;++i)
            for(int k=0;k<=2*n;++k)  
                for(int j=0;j<=2*n;++j)
                    (c.m[i][j]+=m[i][k]*b.m[k][j]%mod)%=mod;
        return c;
    }
} base, trans;
Mat fp(Mat a,int b) {
    Mat c;
    c.clear(); 
    c.init();
    for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
    return c;
}
string str;
unordered_map<char,int> tb;
int get(string str) {
    int res=0;
    for(auto x:str) res|=1<<tb[x];
    return res;
}
int MyGO(int S) {
    base.clear();
    trans.clear();
    base[0][0]=1;
    trans[2*n][2*n]=trans[2*n][n]=1;
    rep(i,0,n-1) trans[i][i+n]=1;
    rep(i,1,m) {
        int x=e[i].x, y=e[i].y;
        ++trans[y+n][x+n];
        if(x==0) ++base[y+n][0];
        if((S&e[i].s)==e[i].s)  ++trans[y+n][x];
    }
    base=fp(trans,T)*base;
    return base[2*n][0];
}
signed main() {
    n=read(), m=read();
    tb['B']=0, tb['J']=1, tb['M']=2, tb['P']=3;
    rep(i,1,m) {
        e[i].x=read()-1, e[i].y=read()-1;
        cin>>str;
        e[i].s=get(str);
    }
    T=read();
    U=(1<<4)-1;
    for(int S=0;S<=U;++S) {
        int cnt=__builtin_popcount(S);
        if((4-cnt)&1) (ans-=MyGO(S)-mod)%=mod;
        else (ans+=MyGO(S))%=mod;
    }
    printf("%lld\n",ans);
    return 0;
}
```
