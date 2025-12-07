---
title: luogu8313 [COCI2021-2022#4] Izbori
pubDate: 2023-11-10
tags:
  - 分治
categories:
  - 题解
description: 'Solution'
---

## Solution

区间扩展不能维护绝对众数，尝试区间拼接。

设拼接后的区间 $[l,r]$ 存在绝对众数 $x$，设其出现次数为 $c_x$，那么一定满足 $2c_x  > r-l+1$。更进一步的，设 $L,R$ 分别表示左右区间长度，$lc_x,rc_x$ 分别表示左右区间中 $x$ 出现的次数，那么有 $2(lc_x+rc_x) > L + R$，移相得到 $2lc_x - L > R - 2rc_x$。

不过新区间的绝对众数是难以确定的。

考虑一个性质：如果一个数不是二者中任意一个区间的绝对众数，那么它一定不是新区间的绝对众数。所以对于两个区间的合并，我们就有了较为快速的解决方法。

然而这样还是远远不够，我们尝试大力分治后同时处理多个区间。不难发现对于一个端点固定的区间，其另一个端点在任意扩展的情况下，不同的绝对众数个数是 $\log$ 的，感性理解一下显然。

因此我们把两边能成为绝对众数的数提取出来，枚举 $x$。然后扫左边，把 $2lc_x-L$ 扔到桶里面再做后缀和，接着就能扫右边并查询大于 $R-2rc_x$ 的值的个数了。

复杂度 $O(n \log^2 n)$。

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
const int N=2e5+5, dlt=2e5;
int n, m, ans, a[N], t[N];
int c[N<<1];
bool v[N];
vector<int> vec;
void lsh() {
    sort(t+1,t+m+1);
    m=unique(t+1,t+m+1)-(t+1);
    rep(i,1,n) a[i]=lower_bound(t+1,t+m+1,a[i])-t;
}
void solve(int l,int r) {
    if(l==r) {
        ++ans;
        return;
    }
    if(l+1==r) {
        ans+=2;
        if(a[l]==a[r]) ++ans;
        return;
    }
    int mid=(l+r)>>1;
    solve(l,mid);
    solve(mid+1,r);
    per(i,mid,l) {
        ++c[a[i]];
        if(!v[a[i]]&&2*c[a[i]]>(mid-i+1)) vec.pb(a[i]), v[a[i]]=1;
    }
    per(i,mid,l) --c[a[i]];
    rep(i,mid+1,r) {
        ++c[a[i]];
        if(!v[a[i]]&&2*c[a[i]]>(i-mid)) vec.pb(a[i]), v[a[i]]=1;
    }
    rep(i,mid+1,r) --c[a[i]];
    rep(i,l,r) v[a[i]]=0;
    int L=-max(mid-l+1,r-mid)+dlt, R=max(mid-l+1,r-mid)+dlt;
    for(auto x:vec) {
        int cnt=0;
        per(i,mid,l) {
            if(a[i]==x) ++cnt;
            ++c[2*cnt-(mid-i+1)+dlt];
        }
        per(i,R-1,L) c[i]+=c[i+1];
        cnt=0;
        rep(i,mid+1,r) {
            if(a[i]==x) ++cnt;
            ans+=c[(i-mid)-2*cnt+dlt+1];
        }
        rep(i,L,R) c[i]=0; 
    }
    vec.clear();
}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read(), t[++m]=a[i];
    lsh();
    solve(1,n);
    printf("%lld\n",ans);
    return 0;
}

```
