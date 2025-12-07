---
title: luogu3940 分组 题解
pubDate: 2023-08-10
tags:
  - 贪心
  - 并查集
  - 二分图
categories: 题解
description: 'Solution'
---

对于 $K=1$ 的情况，每组里面都不能有冲突，所以从后往前尽可能划分，容易证明这样做是对的。

如何判断冲突？注意到值域不大，可以开一个桶，枚举一个完全平方数 $k^2$，判断 $k^2-x$ 是否出现过即可。完全平方数的个数是 $O(\sqrt{n})$ 的，所以复杂度为 $O(n \sqrt{n})$。

对于 $K=2$ 的情况，如果我们把有冲突的点连边，那么每一组的点都构成一张二分图。

可以像经典题「关押罪犯」中一样，用拆点并查集维护。

记 $v(x)$ 表示 $x$ 是否出现过，$v_2(x)$ 表示 $x$ 是否出现了超过 $1$ 次并且 $2x$  是完全平方数。

如果 $x$ 没有出现过，$v(k^2-x)=1$，分两种情况。

1. 如果 $x$ 与 $k^2-x$ 被合并进了同一个集合，并查集产生冲突，那么 $x$ 不能加入当前组。
2. $v_2(k^2-x)=1$，那么 $x$ 不能加入当前组。

如果 $x$ 出现过，分两种情况。

1. 如果 $2x$ 不是完全平方数，由于 $x$ 与组内其他点能构成二分图，所以加入 $x$ 依然能。
2. 如果 $2x$ 是完全平方数。令 $v_2(x)=1$。枚举 $k^2$，如果 $v(k^2-x)=1$ 并且 $k^2\neq2x$，那么说明会产生冲突，$x$ 不能加入。注意如果一开始 $v_2(x)$ 的值就已经是 $1$，就直接判掉。
   
   

```cpp
// Problem: P3940 分组
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3940
// Author: yozora0908
// Memory Limit: 250 MB
// Time Limit: 1000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

#include<bits/stdc++.h>
using namespace std;
#define ll long long
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
const int N=131075, lim=131072;
int n, m, K, a[N], ans[N], sqr[2*N];
bool v[N], v2[N];
namespace sub1 {
    void solve() {
        for(int i=n,j=n;i;) {
            for(;j;--j) {
                for(int k=1;k*k-a[j]<N;++k) if(a[j]<=k*k) {
                    if(v[k*k-a[j]]) goto out;
                }
                v[a[j]]=1;
            }
            out:;
            if(!j) break;
            ans[++m]=j;
            for(;i>j;--i) v[a[i]]=0;
        }

    }
};
struct DSU {
    int f[2*N];
    void init() { for(int i=1;i<=2*lim;++i) f[i]=i; }
    int get(int x) { return x==f[x]? x:f[x]=get(f[x]); }
    void merge(int x,int y) {
        x=get(x), y=get(y);
        if(x!=y) f[x]=y;
    }

} dsu;
bool check(int x,int y) {
    int x1=dsu.get(x), x2=dsu.get(x+lim);
    int y1=dsu.get(y), y2=dsu.get(y+lim);
    if(x1==y1) return 1;
    if(x2==y2) return 1;
    dsu.merge(x1,y2);
    dsu.merge(x2,y1);
    return 0;
}
namespace sub2 {
    void solve() {
        dsu.init();
        for(int i=n,j=n;i;) {
            for(;j;--j) {
                if(!v[a[j]]) {
                    for(int k=1;k*k-a[j]<N;++k) if(a[j]<=k*k) {
                        if(v[k*k-a[j]]) {
                            if(check(a[j],k*k-a[j])||v2[k*k-a[j]]) goto out;
                        }
                    }
                    v[a[j]]=1;
                } else {
                    if(sqr[2*a[j]]) {
                        if(v2[a[j]]) goto out;
                        v2[a[j]]=1;
                        for(int k=1;k*k-a[j]<N;++k) if(a[j]<=k*k) {
                            if(v[k*k-a[j]]&&k*k!=2*a[j])  goto out;
                        }

                    }
                }
            }
            out:;
            if(!j) break;
            ans[++m]=j;
            for(;i>j;--i) v[a[i]]=v2[a[i]]=0, dsu.f[a[i]]=a[i], dsu.f[a[i]+lim]=a[i]+lim;

        }
    }
};
signed main() {
    n=read(), K=read();
    rep(i,1,n) a[i]=read();
    for(int i=1;i<=512;++i) sqr[i*i]=1;
    if(K==1) sub1::solve();
    else sub2::solve();
    printf("%d\n",m+1);
    per(i,m,1) printf("%d ",ans[i]);
    return 0;
}
```
