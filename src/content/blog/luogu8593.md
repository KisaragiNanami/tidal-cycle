---
title: luogu8593 「KDOI-02」 一个弹的投 题解
pubDate: 2023-10-23
tags:
  - 二维偏序
  - 贪心
categories:
  - 题解
description: 'Solution'
---

## Solution

我们先求出最后每个炸弹的威力值。

运用高一物理知识，考虑何时两颗导弹会相撞。

首先一定满足纵坐标相同，然后我们考虑相撞时间 $t$ 的范围，有 $0 \le t \le \sqrt{\frac{2y_i}{g}}$，设其为 $k_i$。把纵坐标离散化，相同的点提取出来分别统计。

考虑 $(x_i,y_i)$ 与 $(x_j,y_i)$，假设它们能相撞，分两种情况讨论：



$x_i< x_j$

此时的方程是

$$
\begin{aligned}x_j - x_i & \le (v_i - v_j) k_i \\ x_j + k_i v_j & \le x_i + k_i v_i\end{aligned}
$$



$x_i > x_j$

此时

$$
\begin{aligned}x_i - x_j & \le (v_j - v_i)k_i \\ x_i + v_ik_i & \le x_j + k_iv_j

\end{aligned}
$$






把 $x_i + v_ik_i$ 离散化，把所有点按照 $x_i$ 递增排序，树状数组一遍正着插入查后缀，一遍倒着插入查前缀即可。

做到这里还没完，因为不同纵坐标的炸弹可能有相同落点，代码里偷懒开了个`std::unordered_map`暴力统计。

最后因为我们要最小化总和，所以贪心选择能减少威力最多的反制武器即可。

注意排序后下标会改变，最好把 $a_i$ 放到结构体里。

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
const double g=9.8;
int n, m, d[N], w[N];
struct node {
    int x, y, v, d, iv;
    double val;
    bool operator<(const node& b) { return x<b.x; }
} a[N];
int tot1, t[N];
int tot;
double tmp[N];
vector<int> p[N];
double k[N];
bool v[N];
void lsh() {
    sort(t+1,t+tot1+1);
    tot1=unique(t+1,t+tot1+1)-(t+1);
    rep(i,1,n) {
        a[i].y=lower_bound(t+1,t+tot1+1,a[i].y)-t;
        p[a[i].y].pb(i);
    }
}
struct pBIT {
    int lim=0, c[N];
    void clear() { for(int i=1;i<=lim;++i) c[i]=0; };
    void upd(int x,int d) {
        for(;x<=lim;x+=x&-x) c[x]+=d;
    }
    int query(int x) {
        int res=0;
        for(;x;x-=x&-x) res+=c[x];
        return res;
    }
} pre;
struct sBIT {
    int lim=0, c[N];
    void clear() { for(int i=1;i<=lim;++i) c[i]=0; };
    void upd(int x,int d) {
        for(;x;x-=x&-x) c[x]+=d;
    }
    int query(int x) {
        int res=0;
        for(;x<=lim;x+=x&-x) res+=c[x];
        return res;
    }
} suf;
unordered_map<double,int> mp;
void solve(vector<int>& v,int i) {
    tot=0;
    for(auto x:v) {
        // printf("x=%lld\n",x);
        tmp[++tot]=a[x].val=1.0*a[x].x+k[i]*a[x].v;
        ++mp[a[x].val];
        // printf("val[%lld]=%.3lf\n",x,a[x].val);
    }
    sort(tmp+1,tmp+tot+1);
    tot=unique(tmp+1,tmp+tot+1)-(tmp+1);
    for(auto x:v) {
        a[x].iv=lower_bound(tmp+1,tmp+tot+1,a[x].val)-tmp;
    }
    pre.clear();
    suf.clear();
    pre.lim=suf.lim=tot;
    for(int i=0;i<v.size();++i) {
        w[v[i]]+=suf.query(a[v[i]].iv);
        suf.upd(a[v[i]].iv,1);
    }
    for(int i=v.size()-1;~i;--i) {
        w[v[i]]+=pre.query(a[v[i]].iv);
        pre.upd(a[v[i]].iv,1);
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) {
        a[i].x=read(), a[i].y=read(), a[i].v=read();
        t[++tot1]=a[i].y;
    }
    rep(i,1,n) a[i].d=read();
    sort(a+1,a+n+1);
    lsh();
    rep(i,1,tot1) {
        k[i]=1.0*sqrt(2.0*t[i]/g);
        solve(p[i],i);
    }
    rep(i,1,tot1) {
        for(auto x:p[i]) --mp[a[x].val];
        for(auto x:p[i]) w[x]+=mp[a[x].val];
        for(auto x:p[i]) ++mp[a[x].val];
    }
    // rep(i,1,n) printf("w[%lld]=%lld\n",i,w[i]);
    int ans=0;
    priority_queue<PII > q;
    rep(i,1,n) {
        q.push({w[i]-max(0ll,w[i]-a[i].d),i});
    }
    int cnt=0;
    while(q.size()&&cnt<m) {
        PII aa=q.top();
        q.pop();
        v[aa.se]=1;
        ans+=w[aa.se]-aa.fi;
        ++cnt;
    }
    rep(i,1,n) if(!v[i]) ans+=w[i];
    printf("%lld\n",ans);
    return 0;
}
```
