---
title: luogu1854 花店橱窗布置 题解
tags: DP
categories:
  - 题解
pubDate: 2022-03-30
description: 'Solution'
---

朴素的状态为 设 $f_{i,j}$ 为前 $i$ 束花，放在前 $j$ 个花瓶的最大收益。

由题意得，如果把花的编号看作数值，它所在的花瓶编号为下标，那么是不允许逆序对的存在的。编号为 $i$ 的花必须放在 $i+1$ 的左边。



也就是说，对于一个 $(i,j)$，前 $i-1$ 束花只能在 $[1,j-1]$ 这个区间内放置，与后面怎么放无关，「无后效性」。于是我们只需要考虑第 $i$ 束花要不要放在第 $j$ 个花瓶中。

所以转移的时候把放与不放两种决策比较一下就好了。

$$
f_{i,j} = \max{\{ f_{i-1,j-1}+c_{i,j},f_{i,j-1} \}}
$$



具体看代码。

```cpp
#include<cstdio>
#include<cstring> 
#include<iostream>
using namespace std;
const int N=105;
int n, m, c[N][N], f[N][N], pre[N][N];
void print(int x,int y) {
    if(!x||!y) return;
    if(pre[x][y]) print(x-1,y-1), printf("%d ",y);
    else print(x,y-1);
}
int main() {
    scanf("%d%d",&n,&m);
    memset(f,0xcf,sizeof(f));
    // 初始化为-inf
    for(int i=1;i<=n;++i) 
        for(int j=1;j<=m;++j) scanf("%d",&c[i][j]);
    for(int i=0;i<=m;++i) f[0][i]=0;
    // 初值
    for(int i=1;i<=n;++i) for(int j=i;j<=m;++j) {
        // j从i到m，减少一些无用状态
        if(f[i-1][j-1]+c[i][j]>f[i][j-1]) f[i][j]=f[i-1][j-1]+c[i][j], pre[i][j]=1;
        // 放置在j
        else f[i][j]=f[i][j-1]; // 不放
    }
    printf("%d\n",f[n][m]);
    print(n,m); puts("");
}
```
