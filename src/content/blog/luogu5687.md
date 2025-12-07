---
title: luogu5687 网格图 题解
tags: 生成树
categories: 题解
pubDate: 2022-06-22
description: 'Solution'
---

## 分析

直接建图跑最小生成树只有 $64pts$。

注意到对于一个节点 $(i,j)$，同在第 $i$ 行的节点向它们的右边节点连边的代价都是 $a_i$，同在 $j$ 列的节点向它们的下方节点连边的代价都是 $b_j$。那么把 $\{a\}$ 与 $\{ b\}$ 递增排序，此时就相当于把网格图交换了行与列。

这时候 $(1,1)$ 既对应着最小的 $a_1$，又对应着最小的 $b_1$，那么第一行与第一列都是要选择的，否则一定不是最小的。同时也可以推广到对于一个 $a_i$ 或 $b_j$，要么不连，要么能连的连起来，才能保证最优性。

最小生成树不能有环。画图不难发现，在第一行和第一列都被选择的情况下，如果在格子图中出现了环（格子图中的最简单环是个正方形），那么一定存在 $(i,j)$，在某个时刻（不关心先后顺序）既选择了所有 $a_i$，又选择了所有 $b_j$，其中 $i,j$ 均不为 1。为了防止出现这种情况，已经考虑过的部分不能被后面的决策影响。

所以就很明确了，维护变量 $row$ 记录当前行，$col$ 记录当前列，维护指针 $p1$ 表示 $a_{p1}$，$p2$ 表示 $b_{p2}$。

当 $a_{p1} \le b_{p2}$ 时，连起来这一行能连的边，前 $col$ 列已经使用过了，贡献为 $a_{p1} \cdot (m-col)$，这一行不能再考虑，$a_{p1}$ 不能再使用，$row+1$，$p1+1$。反之贡献为 $b_{p2} \cdot (n-row)$，$col+1$，$p2+1$。

当 $p1>n$ 或者 $p2> m$ 的时候，图已经连通，也就求出了最小生成树。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int N=3e5+5;
int n, m;
ll a[N], b[N], ans;
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=n;++i) scanf("%lld",&a[i]);
    for(int i=1;i<=m;++i) scanf("%lld",&b[i]);
    sort(a+1,a+n+1), sort(b+1,b+m+1);

    ans+=a[1]*(m-1)+b[1]*(n-1);
    int row=1, col=1, c1=2, c2=2;
    while(c1<=n&&c2<=m) {
        if(a[c1]<=b[c2]) ans+=a[c1++]*(m-col), ++row;
        else ans+=b[c2++]*(n-row), ++col; 
    }
    printf("%lld\n",ans);
}
```
