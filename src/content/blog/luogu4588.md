---
title: luogu4588 数学计算 题解
tags: 线段树
categories:
  - 题解
description: 'Solution'
pubDate: 2022-04-16
---

## 分析

比较巧妙的题目。

乘上一个数再除以它，相当于在 $x$ 中去掉了这个因子。我们的目的是快速找到那个因子并且快速维护 $x$ 的值。

在 $[1,q]$ 上建一颗线段树，起初每个节点值为 1，根节点表示这 $q$ 个数的积。因为每个节点最多操作两次（一次乘一个数，一次去掉），所以对于第 $i$ 个操作`1 m`，就把第 $i$ 个节点改为 $m$，更新根节点；对于操作`2 pos`，把 $pos$ 位置的节点改为 1，更新根节点，相当于除以这个数。

你甚至只需要写建树和单点查询……

## CODE

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
#define ll long long
const int N=1e5+6;
int T, q, mod;
ll t[N<<2];
inline void build(int o,int l,int r) {
    t[o]=1;
    if(l==r) return;
    int mid=(l+r)>>1;
    build(o<<1,l,mid), build(o<<1|1,mid+1,r);
}
inline void update(int o,int l,int r,int pos,ll x) {
    if(l==r) { t[o]=x; return; }
    int mid=(l+r)>>1;
    if(pos<=mid) update(o<<1,l,mid,pos,x);
    else update(o<<1|1,mid+1,r,pos,x);
    t[o]=(t[o<<1]*t[o<<1|1])%mod;
}
inline void sol() {
    int op, m, pos;
    scanf("%d%d",&q,&mod);
    build(1,1,q);
    for(int i=1;i<=q;++i) {
        scanf("%d",&op);
        if(op&1) {
            scanf("%d",&m);
            update(1,1,q,i,m);
            printf("%lld\n",t[1]);
        } else {
            scanf("%d",&pos);
            update(1,1,q,pos,1);
            printf("%lld\n",t[1]);
        }
    }
}
int main() { for(scanf("%d",&T);T--;sol()); }
```
