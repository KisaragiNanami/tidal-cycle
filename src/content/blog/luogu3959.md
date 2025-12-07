---
title: luogu3959 宝藏 题解
tags:
  - DP
  - 状态压缩
categories: 题解
description: 'Solution'
pubDate: 2022-01-28
---

### 这题我只想称之为神

最优解中，开凿的道路一定联通，且一定是一棵树。这是因为如果最终不连通，那么显然不符合题意；如果最后不是一棵树，那么删去若干一条边后，不仅仍然可能连通，而且会减少代价。

暴搜显然不合适，那就考虑状压 DP。



DP 需要一定的顺序。和树形 DP 一样设子树信息为状态？不行，一开始并不是一棵树，直接 pass 掉。节点编号？也不行，根本转移不动。考虑到最后求出的实际上是一棵生成树，那么可以用生成树高度作为顺序，将免费打通的节点看作根。

于是就有了状态。设 $f(i,S)$ 为联通的节点集合为 $S$，当前生成树高度为 $i$ 时，需要的最小代价。由于可以免费打通一个点，不难想到边界为

$$
f(i,S) = \begin{cases}0 & i=1, |S|=1 \\\infty & \text{otherwise}\end{cases}
$$



设全集为 $U$，答案为 $\min \limits_{i \in [1,n]}{ \{ f(i,U) \} }$

&nbsp;

接下来就是转移了。显然，设 $S_0 \subseteq S$，一定能从 $f(i-1,S_0)$ 转移到 $f(i,S)$。

因为不管高度为 $S_0$ 的这一棵树是怎么打通的，只要打通 $S-S_0$ 中的所有点，就一定能够达到 $S$ 这个状态。我们可以枚举每一个子集 $S_0$，然后将这个状态加上转移所需要的最小代价，满足最优子结构性，这样一定是正确的。

代价怎么计算呢？道路长度可以贪心地选择最小的。由于是按照树高由低到高的顺序计算，所以经过的节点数就是`i-1`。那么所有新打通的边的 $K$ 都是相同的（就是题目中的 $K$）。所以设 $d(i,j)$ 为状态 $i$ 转移到状态 $j$ 的最小边权和。

转移为

$$
f(i,j) = \min \limits_{k \subseteq j} { \{ f(i-1,k)+ (i-1) \cdot d(k,j) \} }
$$



$d(i,j)$ 可以直接预处理，参考下面代码。

### 复杂度分析

预处理要枚举子集，枚举能够打通的点，复杂度为 $O(n^23^n)$。

DP 时要枚举树高，枚举子集，复杂度为 $O(n3^n)$。

总复杂度为 $O(n^23^n)$。

当然你也可以用 预处理完一个 $d(i,j)$ 后马上转移 来降低常数。

不过这也完全足够了，而且看着思路很清晰。

关于如下枚举子集的两个循环复杂度为何是 $3^n$，这里不做赘述。

```cpp
for(int i=0;i<=(1<<n)-1;++i) for(int j=i;j;j=(j-1)&1)
```

### code

这题实现并不显然，注意代码，具体看注释。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
#define SET(x,y) memset(x,y,sizeof(x))
const int N=13, M=1<<N, inf=0x3f3f3f3f;
int n, m, U, ans=inf, a[N][N], f[N][M], d[M][M];

void init() {
    scanf("%d%d",&n,&m);
    U=(1<<n)-1;
    SET(a,0x3f), SET(f,0x3f);
    for(int i=1,x,y,z;i<=m;++i) {
        scanf("%d%d%d",&x,&y,&z);
        a[x][y]=a[y][x]=min(a[x][y],z);
    }
}

void pre() {
    for(int i=0;i<=U;++i) for(int j=i;j;j=(j-1)&i) {
        int fg=1, u=i^j;
        // j这个循环意思是枚举i的所有子集
        // u是j关于i的补集，就是j->i要打通的节点集
        for(int k=0;k<n;++k) if((u>>k)&1) {
            // 枚举u的每一位，如果是1的话就找到达这个节点的最短边
            // 这个点记为a
            int t=inf;
            for(int o=0;o<n;++o) if((j>>o)&1)
            // 枚举j的每一位，如果是1的话，就记录这个点到达p的边权
            // 记为b，取b->a的最小值
                t=min(t,a[o+1][k+1]);
                // 注意这里o和k都是要+1的，因为上面枚举的是二进制位。
            if(t==inf) { fg=0; break; }
            // t=inf 不存在b->a的边
            d[j][i]+=t;
            //直接累加
        }
        if(!fg) d[j][i]=inf;
        // 不存在的话，自然是inf了
    }
}

int main() {
    init(), pre();
    for(int i=0;i<n;++i) f[1][1<<i]=0;
    // 预处理
    for(int i=2;i<=n;++i) for(int j=0;j<=U;++j)
        for(int k=j;k;k=(k-1)&j)
        // 枚举树高，状态以及它的子集
            if(d[k][j]!=inf) f[i][j]=min(f[i][j],f[i-1][k]+(i-1)*d[k][j]);
            // d[k][j]!=inf 可以转移
    for(int i=1;i<=n;++i) ans=min(ans,f[i][U]);
    printf("%d\n",ans); // 很友好，不会爆int
}
```
