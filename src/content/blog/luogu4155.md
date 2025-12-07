---
title: luogu4155 国旗计划 题解
tags: 倍增
categories: 题解
pubDate: 2022-05-07
description: 'Solution'
---



把区间按照端点递增排序（左右都一样，因为没有包含关系）。断环为链求出每个区间 $i$ 往右经过一个区间能到达的最远区间。注意只有 $l<r$ 的区间才需要复制。

对于满足 $l \le M$ 的区间，倍增求解覆盖 $[l,l+M]$ 即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
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
const int N=2e5+5;
int n, m, cnt, f[2*N][20], ans[N];
struct node { int l, r, id; } a[2*N];
bool operator<(node a,node b) { return a.l!=b.l? a.l<b.l:a.r<b.r; }
int calc(int x) {
    int r=a[x].l+m, t=0;
    for(int i=18;~i;--i) {
        if(f[x][i]&&a[f[x][i]].r<r) x=f[x][i], t|=1<<i;
    }
    return t+2;
    // 算上x与最后的那个区间
}
signed main() {
    n=read(), m=read();
    cnt=n;
    rep(i,1,n) {
        a[i].l=read(), a[i].r=read();
        a[i].id=i;
        if(a[i].l>a[i].r) a[i].r+=m;
        else a[++cnt]={a[i].l+m,a[i].r+m,a[i].id};
    }
    sort(a+1,a+cnt+1);
    a[cnt+1].r=1e15;
    // 特判情况从[1,m]跳到[m,2m]
    int p=0;
    rep(i,1,cnt) {
        while(p<=cnt&&a[p+1].l<=a[i].r) ++p;
        // 找到最后一个满足a[p].l<=a[i].r的区间p
        // 求区间而不是点，相当于离散化
        f[i][0]=p;
    }
    rep(j,1,18) rep(i,1,cnt) f[i][j]=f[f[i][j-1]][j-1];
    rep(i,1,cnt) if(a[i].l<=m) ans[a[i].id]=calc(i);
    rep(i,1,n) printf("%lld ",ans[i]);
}

```

### 
