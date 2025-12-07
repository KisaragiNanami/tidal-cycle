---
title: luogu3594 WIL 题解
tags:
  - 双指针
  - 单调队列
categories:
  - 题解
description: 'Solution'
pubDate: 2022-10-01
---

## Solution

显然置零的区间长度一定为 $d$，否则一定不优。

暴力做法，枚举左右端点 $[i,j]$，贪心地减去区间里长度为 $d$ 的最大的一块，用前缀和搞一下，$O(n^3)$。

双指针，固定左端点 $i$，贪心地让右端点在 $[i+d,n]$ 中增长，维护区间内最大的长度为 $d$ 的块。如果区间和大于 $p$ 了，那么看减去最大块之后是否合法，$O(n^2)$。

考虑优化这个做法。设 $c_i = \sum_{j=0}^{d-1} a_{i-j}$，那么问题转化为维护当前区间内的最大值。双指针左右端点均单调，因此用单调队列即可维护，复杂度 $O(n)$。



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
const int N=2e6+5;
int n, p, d, ans, a[N], s[N], c[N];
int q[N];
signed main() {
    n=read(), p=read(), d=read();
    rep(i,1,n) a[i]=read(), s[i]=s[i-1]+a[i];
    rep(i,d,n) c[i]=s[i]-s[i-d];
    ans=d;
    int l=1, r=0, sum=c[d];
    q[++r]=d;
    for(int i=d+1,j=1;i<=n;++i) {
        sum+=s[i]-s[i-1];
        while(l<=r&&c[q[r]]<=c[i]) --r;
        q[++r]=i;
        while(l<=r&&(sum-c[q[l]])>p) {
            sum-=a[j++];
            if(q[l]-d+1<j) ++l;
        }
        if(l<=r&&(sum-c[q[l]])<=p) ans=max(ans,i-j+1);
    }
    printf("%lld\n",ans);
    return 0;
}
```
