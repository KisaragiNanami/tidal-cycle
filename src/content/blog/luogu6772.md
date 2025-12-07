---
title: luogu6772 美食家 题解
pubDate: 2023-06-28
tags:
  - DP
  - 图论
  - 矩阵
  - 倍增
categories: 题解
description: 'Solution'
---



上古时代写的题解了。

## 分析

先不考虑美食节的影响。

考虑到节点数和边权都很小，不妨拆点。将每个点拆为 $5$ 个点，其中第 $5$ 个点是起始点，第 $1$ 个点是终点。这样边权就变化为了经过的节点数。也就是说，到达节点 $x$ 转化为到达 $x$ 的第 $5$ 个节点，而从 $x$ 到达 $y$ 权值为 $z$，转化为从 $x$ 的第 $6-z$ 个节点到达 $y$ 的第 $5$ 个节点，权值全部为 $1$。同时，五个节点之间边权全部为 $0$。

这样做的好处就是，所谓代价，也就是天数，就转化为了阶段。

设 $f(i,x)$ 表示第 $i$ 天在第 $x$ 个城市，所能获得的最大收益。
$$
f(i+1,x) = \max_{(x,y) \in E} \Big\{ f(i,y) + c_x \Big\}
$$
边界是 $f(0,1)=c_1$，其余为负无穷。

其中 $c_x$ 表示到达节点 $x$ 的收益。转化过来就是到达 $x$ 的第 $5$ 个节点的收益。

设 $id(i,x)$ 为 $x$ 的第 $i$ 个节点，答案为 $f \Big( T,id(5,1) \Big)$。

但是 $T$ 太大了，又因为 $(\max,+)$ 的运算满足结合律，考虑矩阵加速。常规操作是把要转移的这个东西搞成一个向量，做 $O(n^2)$ 的矩阵向量乘法，但是由于 $T$ 的存在，数组是开不下的，只能用滚动数组优化，这样就不能封装成向量，必须手写一个广义矩阵向量乘法了。

考虑转移矩阵 $A$，要满足
$$
f(i+1,x) = \max_{}\Big\{ f(i,y) + A_{y,x}  \Big\}
$$
所以 $A_{y,x}$ 必须表示从 $y$ 到达 $x$ 的收益。

所以跑个 $A$ 的 $T$ 次幂再乘起来就行了。

这时候考虑存在美食节，不难发现美食节 $i$ 仅仅对 $t_i$ 天的 $x_i$ 有效。所以可以求出 $i-1$ 天的状态之后，手动给 $f \Big(t_i,id(5,x_i) \Big)$ 加上 $y_i$，显然不会有更优的方案了。

于是将 $t_i$ 递增排序，分段处理即可。和上题处理询问相同，预处理倍增次幂，对每一段进行二进制拆分优化，做复杂度为 $O(n^2)$ 的矩阵向量乘法。

如果最后答案小于 $0$，那么无解。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int n, m, T, k, lim, cur, ans, w[256], f[2][256];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
struct Festival { int t, x, y; } fs[205];
bool operator<(Festival a,Festival b) { return a.t<b.t; }
struct Mat {
    int m[256][256];
    void clear() { memset(m,-0x3f,sizeof(m)); }
    void id() { for(int i=0;i<lim;++i) m[i][i]=1; }
} rec[35];
Mat operator*(Mat a,Mat b) {
    Mat c; c.clear();
    for(int i=0;i<lim;++i)
        for(int k=0;k<lim;++k)
            for(int j=0;j<lim;++j)
                c.m[i][j]=max(c.m[i][j],a.m[i][k]+b.m[k][j]);
    return c;
}
void trans(int x) {
    for(int i=30;~i;--i) if((x>>i)&1) {
        memset(f[cur^1],-0x3f,sizeof(f[cur^1]));
        for(int k=0;k<lim;++k) for(int j=0;j<lim;++j)
            f[cur^1][j]=max(f[cur^1][j],f[cur][k]+rec[i].m[k][j]);
        // 广义矩阵向量乘法
        cur^=1;
    }
}
int id(int i,int j) { return (i-1)*n+j; }
signed main() {
    n=read(), m=read(), T=read(), k=read();
    lim=5*n;
    rec[0].clear();
    for(int i=0;i<n;++i) w[i]=read();
    while(m--) {
        int x=read()-1, y=read()-1, z=read();
        rec[0].m[id(6-z,x)][id(5,y)]=w[y];
        // 一定要记清楚，自己的转移矩阵表示的是什么
    }
    for(int i=1;i<=k;++i) fs[i].t=read(), fs[i].x=read()-1, fs[i].y=read();
    sort(fs+1,fs+k+1);
    for(int i=1;i<5;++i) for(int j=0;j<n;++j) rec[0].m[id(i+1,j)][id(i,j)]=0;
    // 拆开的点相互到达不计代价
    for(int i=1;i<=30;++i) rec[i]=rec[i-1]*rec[i-1];
    memset(f,-0x3f,sizeof(f));
    f[cur][id(5,0)]=w[0];
    for(int i=1;i<=k;++i) {
        int dlt=fs[i].t-fs[i-1].t;
        trans(dlt);
        f[cur][id(5,fs[i].x)]+=fs[i].y;
    }
    if(fs[k].t<T) trans(T-fs[k].t);
    // 如果还有时间就再变换
    ans=f[cur][id(5,0)];
    printf("%lld\n",ans>=0? ans:-1);
}
```
