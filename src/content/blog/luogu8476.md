---
title: luogu8476「GLR-R3」惊蛰 题解
pubDate: 2023-10-23
tags:
  - DP
  - 线段树
  - 决策单调性
categories:
  - 题解
description: 'Solution'
---

## Solution

考虑一个朴素的 DP。设 $g(i,j)$ 为考虑到第 $i$ 个元素，其中 $b_i=j$ 时的最小代价。转移比较显然：

$$
g(i,j) = \min_{k \ge j} \Big\{ g(i-1,k) \Big\} + f(j,a_i)
$$



复杂度  $O(nV)$。

$f$ 关于 $a_i$ 分两段有单调性，所以我们可以把 $\{a\}$ 离散化掉，下文 $a_i$ 均为离散化后的值，其真实值为 $v(a_i)$。重设 $g(i,j)$ 为考虑到第 $i$ 个元素，其中 $b_j=a_i$ 时的最小代价。复杂度 $O(n^2)$。

考虑转移的本质：取后缀 $\min$ 后加上 $f$，而 $f$ 有很强的单调性。

$i-1$ 阶段取后缀 $\min$ 后有 $g(i-1,j) \le g(i-1,j+1)$。对于阶段 $i-1$ 转移到阶段 $i$ 的过程，$j \in [1,a_i-1]$ 的状态都要加上 $C$，$j \in [a_i+1,m]$ 的状态都要加上 $j - v(a_i)$。两部分都不会对各自的单调性产生影响，所以只需要考虑 $j = a_i$ 这个状态的影响。

由于 $j \in [1,a_i-1]$ 的状态有单调性，所以可以二分找到最小的满足 $g'(i-1,j_0) > g(i-1,a_i)$ 的 $j_0$，对那一段赋值即可。

所以我们需要支持以下操作：

- 区间加法。
- 区间关于下标的加法。
- 区间复制。
- 单点查。
- 二分。

把 $j$ 这一维拍到线段树上即可维护。

同时注意为了实现这个线段树上二分，需要维护区间 $\max$。

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
const int N=1e6+5;
int n, m, C, a[N], c[N];
void lsh() {
    sort(c+1,c+n+1);
    m=unique(c+1,c+n+1)-(c+1);
    rep(i,1,n) a[i]=lower_bound(c+1,c+m+1,a[i])-c;
}
int t[N<<2];
struct node {
    int ass=-1, add=0, w=0;
    node() {};
    node(int _ass,int _add,int _w) { ass=_ass, add=_add, w=_w; }
    node operator+(node a) {
        if(~a.ass) return a;
        node b=*this;
        b.add=add+a.add, b.w=w+a.w;
        return b;
    }
    // 为了方便合并标记与进行操作从而定义结构体
} tag[N<<2];
void maketag(int x,int r,node d) {
    if(d.ass!=-1) t[x]=d.ass;
    t[x]+=d.add+c[r]*d.w;
    tag[x]=tag[x]+d;
}
void pushup(int x) { t[x]=max(t[x<<1],t[x<<1|1]); }
void pushdown(int x,int l,int r) {
    if(tag[x].ass!=-1||tag[x].add!=0||tag[x].w!=0) {
        int mid=(l+r)>>1;
        maketag(x<<1,mid,tag[x]);
        maketag(x<<1|1,r,tag[x]);
        tag[x].ass=-1, tag[x].add=tag[x].w=0;
    }
}
void upd(int L,int R,node d,int x=1,int l=1,int r=m) {
    if(L<=l&&r<=R) { maketag(x,r,d); return; }
    pushdown(x,l,r);
    int mid=(l+r)>>1;
    if(L<=mid) upd(L,R,d,x<<1,l,mid);
    if(R>mid) upd(L,R,d,x<<1|1,mid+1,r);
    pushup(x);
}
int query(int p,int x=1,int l=1,int r=m) {
    if(l==r) return t[x];
    pushdown(x,l,r);
    int mid=(l+r)>>1;
    if(p<=mid) return query(p,x<<1,l,mid);
    else return query(p,x<<1|1,mid+1,r);
}
int binsearch(int p,int k,int x=1,int l=1,int r=m) {
    if(l>p) return -1;
    if(r<=p&&t[x]<k) return -1;
    if(l==r) return l;
    pushdown(x,l,r);
    int mid=(l+r)>>1;
    int res=binsearch(p,k,x<<1,l,mid);
    if(~res) return res;
    return binsearch(p,k,x<<1|1,mid+1,r);
}
signed main() {
    n=read(), C=read();
    rep(i,1,n) a[i]=c[i]=read();
    lsh();
    rep(i,1,n) {
        upd(a[i]+1,m,node(-1,-c[a[i]],1));
        if(a[i]==1) continue;
        upd(1,a[i]-1,node(-1,C,0));
        int x=query(a[i]);
        int pos=binsearch(a[i]-1,x);
        if(pos!=-1) upd(pos,a[i]-1,node(x,0,0));
    }
    printf("%lld\n",query(1));
    return 0;
}

```
