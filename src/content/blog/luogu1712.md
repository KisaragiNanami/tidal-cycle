---
title: luogu1712 区间 题解
urls: lg1712-solution
tags: 线段树
categories:
  - 题解
pubDate: 2022-05-28 17:11:52

---

## 分析

既然要最小化选出的最长区间长度减去最短区间长度，那么很容易想到一个典型的双指针算法：

将区间长度递增排序，维护指针 $l$ 和 $r$，表示选择 $[l,r]$ 中所有的线段。



依次选择每条线段（也就是 $r$ 在递增），在满足有一个点被覆盖 $m$ 次的条件下，尽可能将 $l$ 提前并删去对应的线段。答案就是 $\min{ \{len_r-len_l \} }$。

所以离散化，在离散化后的值域上建一棵线段树，维护区间内的点被覆盖的最多次数。

那么只要根节点的值大于等于 $m$，就是合法的选取方案。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
int n, m, cnt, c[N<<1];
struct L { int l, r, len; } a[N];
bool operator<(L a,L b) { return a.len<b.len; }
struct Segment_Tree {
    int l, r, w, tag;
    #define l(u) t[u].l
    #define r(u) t[u].r
    #define w(u) t[u].w
    #define tag(u) t[u].tag
} t[N<<2];
void maketag(int u,int val) { tag(u)+=val, w(u)+=val; }
void pushup(int u) { w(u)=max(w(u<<1),w(u<<1|1)); }
void pushdown(int u) {
    if(tag(u)) {
        maketag(u<<1,tag(u));
        maketag(u<<1|1,tag(u));
        tag(u)=0;
    }
}
void build(int u,int l,int r) {
    l(u)=l, r(u)=r;
    if(l==r) { w(u)=tag(u)=0; return; }
    int mid=(l+r)/2;
    build(u<<1,l,mid), build(u<<1|1,mid+1,r);
    pushup(u);
}
void modify(int u,int l,int r,int val) {
    if(l<=l(u)&&r(u)<=r) maketag(u,val);
    else if(!(r(u)<l||r<l(u))) {
        pushdown(u);
        int mid=(l(u)+r(u))/2;
        if(l<=mid) modify(u<<1,l,r,val);
        if(r>mid) modify(u<<1|1,l,r,val);
        pushup(u);
    }
}
int query() { return w(1); }
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=n;++i) {
        int l, r; scanf("%d%d",&l,&r);
        a[i].l=l, a[i].r=r, a[i].len=r-l;
        c[++cnt]=l, c[++cnt]=r;
    }
    sort(a+1,a+n+1);
    sort(c+1,c+cnt+1);
    cnt=unique(c+1,c+cnt+1)-c-1;
    for(int i=1;i<=n;++i) {
        a[i].l=lower_bound(c+1,c+cnt+1,a[i].l)-c;
        a[i].r=lower_bound(c+1,c+cnt+1,a[i].r)-c;
    }
    // 离散化
    int l=1, ans=(1<<30);
    build(1,1,cnt);
    for(int i=1;i<=n;++i) {
        // r是递增的，直接用i代替
        modify(1,a[i].l,a[i].r,1);
        while(query()>=m) {
            ans=min(ans,a[i].len-a[l].len);
            modify(1,a[l].l,a[l].r,-1);
            ++l;
        }
    }
    printf("%d\n",ans!=(1<<30)? ans:-1);
}
```
