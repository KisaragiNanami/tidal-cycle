---
title: luogu9361 [ICPC2022 Xi'an R] Contests 题解
pubDate: 2023-11-10
tags:
  - 倍增
  - 贪心
categories: 题解
description: 'Solution'
---

## Solution

题目的形式类似典中典倍增题，但 $m$ 场比赛的条件难以直接处理。

考虑一个性质：如果代价与最终考虑的比赛固定，那么最优解一定是跳到排名最靠前的那个人上。

因此用 $n$ 个 $m$ 元组就能表示出一个无后效性的局部最优解，并且是容易复合的。具体做法就是枚举两场比赛，令其从第一场比赛的最优解位置跳到第二场比赛的最优解位置。

这个做法满足半群性质，所以倍增代价并复合局部最优解。

复杂度 $O((n+q) m^2 \log n)$。

实现有一定的细节。

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
const int N=1e5+5, M=5, lim=16;
int n, m, q, a[M][N], rk[M][N];
struct node {
    int a[M];
    int& operator[](const int& i) { return a[i]; }
    void init() { rep(i,0,m-1) a[i]=n+1; }
    node() { init(); }
} f[N][17];
node trans(node pre,int k) {
    node res=node();
    rep(j,0,m-1) rep(i,0,m-1)  res[i]=min(res[i],f[a[j][pre[j]]][k][i]);
    return res;
}
bool valid(node now,int x) {
    rep(i,0,m-1) {
        if(now[i]<=rk[i][x]) return 1;
    }
    return 0;
}
int calc(int x,int y) {
    node base;
    rep(i,0,m-1) base[i]=rk[i][x];
    int res=0;
    for(int i=lim;~i;--i) if(!valid(trans(base,i),y)) {
        base=trans(base,i);
        res+=(1<<i);
    }
    if(!valid(trans(base,0),y)) return -1;
    if(!valid(base,y)) {
        base=trans(base,0);
        ++res;
    }
    int fg=1;
    rep(i,0,m-1) if(base[i]==rk[i][y]) {
        // 如果已经触及了y，那么就不需要在序列中接上y了
        fg=0;
        break;
    }
    return res+fg;
}
signed main() {
    n=read(), m=read();
    rep(i,0,m-1) rep(j,1,n) {
        a[i][j]=read();
        rk[i][a[i][j]]=j;
        // a[i][j] 第i场比赛排名为j的人
        // rk[i][j] 第i场比赛中j的排名
    }
    rep(i,1,n) f[i][0].init();
    rep(i,0,m-1) rep(j,0,m-1) {
        int x=n+1;
        per(k,n,1) {
            x=min(x,rk[i][a[j][k]]);
            f[a[j][k]][0][i]=min(f[a[j][k]][0][i],x);
        }
    }
    for(int j=1;j<=lim;++j)
        for(int i=1;i<=n;++i)
            f[i][j]=trans(f[i][j-1],j-1);
    q=read();
    while(q--) {
        int x=read(), y=read();
        printf("%d\n",calc(x,y));
    }
    return 0;
}
```


