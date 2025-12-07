---
title: luogu3225 矿场搭建  题解
tags:
  - 双连通分量
categories: 题解
description: 'Solution'
pubDate: 2021-10-16
---

本题思路还是比较清晰的。

显然的，求出 v-DCC 并缩点，然后判断方案数。



在本题中，可以只用 Tarjan 算法求出割点。标记割点，从其他的点依次 DFS，统计每颗搜索树上割点的数量（不重复统计）。

若图中没有割点，那么图中任选两个节点都能满足条件，答案 $ (2,C_n^2)$

若搜索树上割点为 1，则由于树上两点之间有且仅有一条简单路径，所以这颗搜索树中一定至少选一个点，累加答案，累乘方案数。

若割点多于 1，那么对答案是没有贡献的。

因为无论哪一个点被破坏，该搜索树都会分裂成为上述两种情况。

这种做法实现细节较多。

姑且算是 $ O(n^2)$？

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
#define R register
#define SET(x,y) memset(x,y,sizeof(x))
const int N=505;
int t, n, m, num, cnt, fg, ans1, dfn[N], low[N], v[N], w[N];
int c, h[N], ver[N<<1], nxt[N<<1];
long long ans2;
void add(int x,int y) { ver[++c]=y, nxt[c]=h[x], h[x]=c; }
void tarjan(int x) {
    R int i, y;
    dfn[x]=low[x]=++num, v[x]=1;
    for(i=h[x];i;i=nxt[i]) {
        y=ver[i];
        // v数组在一定程度上起到了dfn数组的作用，可以少清空一个数组
        if(!v[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
            if(dfn[x]<=low[y]) ++v[x];
        } else low[x]=min(low[x],dfn[y]);
    }
    if((x==1&&v[x]>2)||(x>1&&v[x]>1)) v[x]=2;
    // 1为普通点，2为割点。注意v[x]在上面已经初始化为1
}
void dfs(int x,int z) {
    R int i, y;
    v[x]=114514, ++cnt;
    // 放置重复搜索，统计节点数
    for(i=h[x];i;i=nxt[i]) {
        y=ver[i];
        if(v[y]==1) dfs(y,z);
        else if(v[y]==2&&w[y]!=z) ++fg, w[y]=z;
        // 防止搜索成环
    }
}
void sol() {
    SET(v,0), SET(w,0), SET(h,0);
    c=ans1=n=0, ans2=1ll;
    R int i, x, y;
    for(i=1;i<=m;++i) {
        scanf("%d%d",&x,&y);
        add(x,y), add(y,x);
        n=max(n,max(x,y));
    }
    tarjan(1);
    // luogu给出的数据是联通的
    for(i=1,num=0;i<=n;++i) if(v[i]==1) {
        fg=cnt=0, ++num;
        dfs(i,num);
        if(fg==1)  ++ans1, ans2*=cnt;
        // 从非割点搜索
    }
    if(!ans1) ans1=2, ans2=n*(n-1)/2;
    printf("Case %d: %d %lld\n",++t,ans1,ans2);
}
int main() { while(scanf("%d",&m)&&m) sol(); }
```
