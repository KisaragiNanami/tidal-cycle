---
title: luogu9561 [SDCPC 2023] Colorful Segments 题解
pubDate: 2025-07-15
categories: 
  - 题解
tags: 
  - DP
  - 线段树
  - 计数
description: 'Solution'
---

[link](https://www.luogu.com.cn/problem/P9561)

## $\texttt{Solution}$

较为复杂的计数直接考虑 DP。

区间相关的题目排了序才能做，就是按照左端点还是右端点排的问题。

我们考虑当前区间 $i$，如果要选它，那么我们需要保证与其异色的区间右端点小于 $l_i$。

这个就是后效性的源头，把它加入状态即可。

设 $f_k,0/1$ 为选出的最后一个区间右端点为 $k$，颜色为 $0/1$ 时的方案数。

为了保证 DP 的转移顺序，我们需要把所有区间按照右端点递增排序。

这时候我们会发现一个很尴尬的事情：我们只能知道最后一个区间的信息，如果我们选择了区间 $i$，$l_i$ 还特别小，那么就有可能把一个异色区间包含在内，同时这个异色区间还不是之前选的最后一个区间。

怎么办呢？枚举最后一个异色区间位置即可，此时中间所有的同色区间都能随便选。

于是写出状态转移方程

$$  
2^{cnt} \times \sum_{k=1}^{l_i-1} f_{k,c_i \oplus 1} \rightarrow f_{r_i,c_i}  
$$

其中 $cnt$ 为 $[k,r_i]$ 包含的 $i$ 同色区间数量。

直接做是 $O(n^3)$ 的，不可接受。

```
void solve() {
    n=read();
    m=0;
    rep(i,1,n) {
        a[i].l=read(), a[i].r=read(), a[i].c=read();
        b[++m]=a[i].l, b[++m]=a[i].r;
    }
    sort(b+1,b+m+1);
    m=unique(b+1,b+m+1)-(b+1);
    rep(i,1,n) {
        a[i].l=lower_bound(b+1,b+m+1,a[i].l)-b;
        a[i].r=lower_bound(b+1,b+m+1,a[i].r)-b;
    }
    sort(a+1,a+n+1);
    f[a[1].r][a[1].c]=1;
    rep(i,2,n) {
        ll x=1;
        rep(j,1,a[i].l-1) {
            ll t=f[j][a[i].c^1], w=0;
            rep(k,1,i-1) if(a[k].c==a[i].c&&j<a[k].l) ++w;
            (x+=t*fp(2ll,w)%mod)%=mod;
        }
        int cnt=0;
        rep(j,1,i-1) if(a[j].c==a[i].c) ++cnt;
        (x+=(fp(2ll,cnt)-1+mod)%mod)%=mod;
        (f[a[i].r][a[i].c]+=x)%=mod;
    }
    ll ans=1;
    rep(i,1,m) (ans+=(f[i][0]+f[i][1])%mod)%=mod;
    printf("%lld\n",ans);
    rep(i,0,m) f[i][0]=f[i][1]=0;
}
```

考虑优化。

瓶颈在于统计同色区间数量。虽然单次查询很容易快速实现，但干掉这个后还有一个 $O(n)$ 的枚举亟待优化。这两步必须合起来做。

我们能发现在上述代码的枚举同色区间数量部分，随着 $l_i$ 的增长，这个数量是单调增的。进一步可以考虑到，一个区间 $[l_i,r_i]$ 存在的意义是在枚举到 $k \in [1,l_i-1]$ 时让对应的 $f_{k,c_i \oplus 1}$ 乘上 $2$。因为 $r$ 单增，这个区间在此时被纳入随便选的区间集合。

发现这个操作是区间乘法，其他操作是单点加法与区间查询，线段树维护即可。

还有一些要考虑的细节：

- 离散化。

- 什么都不选，贡献 $1$。

- 单独选择某一个区间，贡献 $1$。

- 可以只选择一个区间以及它前面的同色区间。开一个 $0$ 号位置即可。

## $\texttt{Code}$

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb push_back
#define pf push_front
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
const int N=1e5+5, mod=998244353;
int T, n, cnt[N];
int m, b[N<<1];
struct node { int l, r, c; } a[N];
bool operator<(const node& a,const node& b) {
    return a.r<b.r;
}
namespace seg {
    ll t[N<<3][2], tag[N<<3][2];
    void pushup(int x) {
        t[x][0]=(t[x<<1][0]+t[x<<1|1][0])%mod;
        t[x][1]=(t[x<<1][1]+t[x<<1|1][1])%mod;
    }
    void maketag(int x,int c,ll d) {
        (t[x][c]*=d)%=mod;
        (tag[x][c]*=d)%=mod;
    }
    void pushdown(int x) {
        if(tag[x][0]!=1) {
            maketag(x<<1,0,tag[x][0]);
            maketag(x<<1|1,0,tag[x][0]);
            tag[x][0]=1;
        }
        if(tag[x][1]!=1) {
            maketag(x<<1,1,tag[x][1]);
            maketag(x<<1|1,1,tag[x][1]);
            tag[x][1]=1;
        }
    }
    void build(int x=1,int l=0,int r=m) {
        if(l==r) {
            t[x][0]=t[x][1]=0;
            tag[x][0]=tag[x][1]=1;
            return;
        }
        int mid=(l+r)>>1;
        build(x<<1,l,mid);
        build(x<<1|1,mid+1,r);
        t[x][0]=t[x][1]=0;
        tag[x][0]=tag[x][1]=1;
        pushup(x);
    }
    void upd(int p,int c,ll d,int x=1,int l=0,int r=m) {
        if(l==r) { (t[x][c]+=d)%=mod; return; }
        int mid=(l+r)>>1;
        if(p<=mid) upd(p,c,d,x<<1,l,mid);
        else upd(p,c,d,x<<1|1,mid+1,r);
        pushup(x);
    }
    void upd_lr(int L,int R,int c,ll d,int x=1,int l=0,int r=m) {
        if(L>R) return;
        if(L<=l&&r<=R) {
            maketag(x,c,d);
            return;
        }
        pushdown(x);
        int mid=(l+r)>>1;
        if(L<=mid) upd_lr(L,R,c,d,x<<1,l,mid);
        if(R>mid) upd_lr(L,R,c,d,x<<1|1,mid+1,r);
        pushup(x);
    }
    ll query(int L,int R,int c,int x=1,int l=0,int r=m) {
        if(L>R) return 0ll;
        if(L<=l&&r<=R) return t[x][c];
        pushdown(x);
        int mid=(l+r)>>1;
        ll res=0;
        if(L<=mid) (res+=query(L,R,c,x<<1,l,mid))%=mod;
        if(R>mid) (res+=query(L,R,c,x<<1|1,mid+1,r))%=mod;
        return res;
    }
};
void solve() {
    n=read();
    m=0;
    rep(i,1,n) {
        a[i].l=read(), a[i].r=read(), a[i].c=read();
        b[++m]=a[i].l, b[++m]=a[i].r;
    }
    sort(b+1,b+m+1);
    m=unique(b+1,b+m+1)-(b+1);
    sort(a+1,a+n+1);
    rep(i,1,n) {
        a[i].l=lower_bound(b+1,b+m+1,a[i].l)-b;
        a[i].r=lower_bound(b+1,b+m+1,a[i].r)-b;
    }
    seg::build();
    seg::upd(0,0,1ll);
    seg::upd(0,1,1ll);
    seg::upd(a[1].r,a[1].c,1ll);
    seg::upd_lr(0,a[1].l-1,a[1].c^1,2ll);
    ll ans=2;
    rep(i,2,n) {
        ll res=(seg::query(0,a[i].l-1,a[i].c^1))%mod;
        seg::upd(a[i].r,a[i].c,res);
        seg::upd_lr(0,a[i].l-1,a[i].c^1,2ll);
        (ans+=res)%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}

```
