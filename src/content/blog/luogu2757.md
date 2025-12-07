---
title: luogu2757 [国家集训队] 等差子序列 题解
pubDate: 2023-10-23
tags:
  - 多项式哈希
  - 线段树
categories:
  - 题解
description: 'Solution'
---

## Solution

关于等差数列的存在问题，一个常见的套路就是枚举中项，只考虑左边右边各一项。然后 $O(n^2)$ 做法就很显然了。

考虑一个很厉害的转化：我们把 $1 \sim n$ 堪称一个 0/1 序列，第 $i$ 位是 $1$ 当且仅当数字 $i$ 已经出现过了。那么存在等差数列的充要条件变成了从左往右扫到数字 $i$ 时，存在一个 $k$，满足序列中 $i-k$ 与 $i+k$ 的值不同；不存在等差数列的充要条件则是 $[i-lim,i+lim]$ 回文，其中 $lim = \min(i-1,n-i)$。

回文可以用哈希解决，我们要支持的操作是单点修改和区间查询哈希值，维护正反哈希值后线段树即可维护。

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
const int N=5e5+5;
const uint P=1610612741ull;
int T, n, a[N];
uint pw[N];
uint ha[N<<2], iha[N<<2];
void pushup(int x,int l,int r) {
    int mid=(l+r)>>1;
    ha[x]=ha[x<<1]+ha[x<<1|1]*pw[mid-l+1];
    iha[x]=iha[x<<1]*pw[r-mid]+iha[x<<1|1];
}
void build(int x=1,int l=1,int r=n) {
    ha[x]=iha[x]=0;
    if(l==r) return;
    int mid=(l+r)>>1;
    build(x<<1,l,mid);
    build(x<<1|1,mid+1,r);
}
void upd(int p,int d,int x=1,int l=1,int r=n) {
    if(l==r) { ha[x]=iha[x]=d; return; }
    int mid=(l+r)>>1;
    if(p<=mid) upd(p,d,x<<1,l,mid);
    else upd(p,d,x<<1|1,mid+1,r);
    pushup(x,l,r);
}
uint getha(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) return ha[x];
    int mid=(l+r)>>1, ll=0;
    uint res=0;
    if(L<=mid) ll=1, res=getha(L,R,x<<1,l,mid);
    if(R>mid) {
        uint t=getha(L,R,x<<1|1,mid+1,r);
        if(ll) res+=t*pw[mid-max(L,l)+1];
        else res=t;
    }
    return res;
}
uint getiha(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) return iha[x];
    int mid=(l+r)>>1, rr=0;
    uint res=0;
    if(R>mid) rr=1, res=getiha(L,R,x<<1|1,mid+1,r);
    if(L<=mid) {
        uint t=getiha(L,R,x<<1,l,mid);
        if(rr) res+=t*pw[min(r,R)-(mid+1)+1];
        else res=t;
    }
    return res;
}
void init() {
    pw[0]=1;
    for(int i=1;i<=5e5;++i) pw[i]=pw[i-1]*P;
}
void solve() {
    n=read();
    int fg=0;
    build();
    rep(i,1,n) a[i]=read();
    rep(i,1,n) {
        if(fg) continue;
        int x=a[i];
        upd(x,1);
        int len=min(x-1,n-x);
        uint l=getha(x-len,x), r=getiha(x,x+len);
        if(l!=r) fg=1;
    }
    if(fg) puts("Y"); else puts("N");
}
signed main() {
    T=read();
    init();
    while(T--) solve();
    return 0;
}
```
