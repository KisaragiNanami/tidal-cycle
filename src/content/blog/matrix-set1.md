---
title: 矩阵乘法简单题 1
tags:
  - DP
  - 矩阵
categories:
  - 题解
description: '矩阵专题做题记录'
pubDate: 2022-08-11
---

以下是简单矩阵乘法题目大赏。

注意我这时候的矩阵乘法还没有形成固定的码风，所以代码看起来差异较大且比较别扭，见谅。

## luogu5343 分块

### 分析

分的块长必须同时满足二人的要求，所以必然是二者的交集。

设 $f_i$ 为长度为 $i$ 序列的分块方案数，有 $f_0 = 1$

$$
f_i = \sum_{j=1}^m f_{i-a_j}
$$



其中 $a_i$ 是第 $i$ 种合法分块长度，$m$ 是序列 $a$ 的长度。

数据范围明显要用矩阵加速递推。下面放图是因为我对我当时的写法实在是无语了，与我现在的习惯大相径庭，为了便于理解就用这张图了。

![借用洛谷题解的图片，侵删](https://s2.ax1x.com/2019/05/05/Ewtapd.png)

先把 $f$ 搞成一个向量。

考虑从 $f_{i-1}$ 推得 $f_i$ 的过程，不难发现首先要整体平移一下，也就是在转移矩阵 $A$ 中，有 $A_{i+1,i}=1$，表示 从 $f_{i-1}$ 数第 $i+1$ 个要转移到第 $i$ 个的位置，于是乎 $1$，也就是要求的 $f_i$ 空了出来。此时，表示如果 $a_j$ 合法，那么就让 $A_{1,a_j}=1$，表示从 $f_{i-1}$ 数第 $a_j$ 个，也就是 $f_{i-a_j}$ 要转移到 $1$，也就是 $f_i$ 的地方。

初始 $f_0 = 1$，求 $n$ 次幂即可，注意要预处理 $1 \sim 100$ 的 $f$ 值，因为块最大是 $100$，这样做不会漏掉信息。

好了，我已经受不了这奇葩的写法了。上代码，看得懂的就看，看不懂尽量别死磕这个 SB 写法。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int mod=1e9+7;
int n, p, q, c[105][105], f[105];
bitset<105> a, b;
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
void mul() {
    static int ans[105]; memset(ans,0,sizeof(ans));
    for(int j=1;j<=100;j++)
        for (int i=1;i<=100;i++)
            ans[i]=(ans[i]+f[j]*c[j][i]%mod)%mod;
    memcpy(f,ans,sizeof(f));
}
void mulself() {
    static int ans[105][105]; memset(ans,0,sizeof(ans));
    for(int i=1;i<=100;i++)
        for(int k=1;k<=100;k++)
            for (int j=1;j<=100;j++)
                ans[i][j]=(ans[i][j]+c[i][k]*c[k][j]%mod)%mod;
    memcpy(c,ans,sizeof(c));
}
signed main() {
    n=read();
    f[1]=1;
    for(int i=1;i<100;++i) c[i+1][i]=1;
    p=read();
    while(p--) {
        int x=read();
        a[x]=1;
    }
    q=read();
    while(q--) {
        int x=read();
        b[x]=1;
    }
    a&=b;
    for(int i=1;i<=100;++i) if(a[i]) c[1][i]=1;
    // f[1]-f[100]的信息都在c里面
    // 注意用的是bitset，a[i]是上述的下标j，i才是a[j]
    for(;n;mulself(),n>>=1) if(n&1) mul();
    printf("%lld\n",f[1]);
}

```

## luogu3758 可乐

### 分析

设 $f(i,x)$ 为时刻 $i$，在城市 $x$ 的方案数。增加一个节点 $n+1$ 表示自爆。

$$
f(i,x) = \sum_{(x,y) \in E} f(i-1,y)
$$





每次处理完一个时间，都让答案累计已经自爆的 $f(i,n+1)$，最后加上 $f(t,x)$，其中 $x \in [1,n]$。

这样能水过原题，但是复杂度实在太高，考虑矩阵加速。

和上题相同，只不过还更简单了，$x$ 与 $y$ 互相转移，$x$ 和 $x$，$x$ 和 $n+1$ 都能转移。预处理 $i=0$ 时的初始矩阵，求 $t$ 次幂即可。

### CODE

```cpp
#include <bits/stdc++.h>
#define int long long
using namespace std;
const int mod=2017;
int n, m, t, ans;
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
    int m[35][35];
    void id() { for(int i=1;i<=31;++i) m[i][i]=1; }
    void clear() { memset(m,0,sizeof(m)); }
} a;
Mat operator*(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=1;i<=31;++i)
        for(int k=1;k<=31;++k)
            for(int j=1;j<=31;++j)
                c.m[i][j]=(c.m[i][j]+a.m[i][k]*b.m[k][j]%mod)%mod;
    return c;
}
Mat fp(Mat a,int b) {
    Mat c; c.clear(), c.id();
    for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
    return c;
}
signed main() {
    n=read(), m=read(); 
    for(int i=1;i<=m;++i) {
        int x=read(), y=read();
        a.m[x][y]=a.m[y][x]=1;
    }
    for(int i=1;i<=n;++i) a.m[i][i]=a.m[i][n+1]=1;
    a.m[n+1][n+1]=1;
    // 尽管没有实际意义，但是为了能够做矩阵乘法，需要让m[n+1][n+1]=1
    t=read();
    a=fp(a,t);
    for(int i=1;i<=n+1;++i) ans=(ans+a.m[1][i])%mod;
    printf("%lld\n",ans);
}
```

## luogu5337 甲苯先生的字符串

### 分析

设 $f(i,j)$ 为写完了 $s2$ 的前 $i$ 个字符，其中最后一个字符为 $j$ 的方案数。

$$
f(i,j) = \sum_{k=1}^{26} f(i-1,k) \cdot b(k,j)
$$






其中 $b(k,j)$ 表示能不能先出现 $k$，再出现 $j$。

标准的矩阵乘法。矩阵乘法本质是对相同转移方式的处理，所以设 $A_{i,j}$ 为当前阶段，倒数第二个字符为 $i$，最后一个字符为 $j$ 的方案数。当 $i=1$ 时，很容易写出。不相邻的为 $1$，否则为 $0$。

求它的 $n-1$ 次幂就行了。

## CODE

```cpp
#include <bits/stdc++.h>
#define int long long
using namespace std;
const int mod=1e9+7;
int n, f[30];
char s[100005];
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
    int m[30][30];
    void id() { for(int i=1;i<=26;++i) m[i][i]=1; }
    void clear() { memset(m,0,sizeof(m)); }
} a;
Mat operator*(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=1;i<=26;++i)
        for(int k=1;k<=26;++k)
            for(int j=1;j<=26;++j)
                c.m[i][j]=(c.m[i][j]+a.m[i][k]*b.m[k][j]%mod)%mod;
    return c;
}
Mat fp(Mat a,int b) {
    Mat c; c.clear(), c.id();
    for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
    return c;
}
signed main() {
    n=read(); scanf("%s",s+1);
    for(int i=1;i<=26;++i) for(int j=1;j<=26;++j) a.m[i][j]=1;
    int len=strlen(s+1);
    for(int i=2;i<=len;++i) a.m[s[i-1]-'a'+1][s[i]-'a'+1]=0;
    a=fp(a,n-1);
    int ans=0;
    for(int i=1;i<=26;++i) for(int j=1;j<=26;++j) (ans+=a.m[i][j])%=mod;
    printf("%lld\n",ans);
}
```
