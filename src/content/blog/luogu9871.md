---
title: luogu9871 [NOIP2023] 天天爱打卡 题解
pubDate: 2025-07-24
categories: 
  - 题解
tags: 
  - DP
  - 线段树
  - 贪心
description: 'Solution'
---

## $\text{Solution}$

贪心一下，不为了完成任务，我们不会打卡。

容易得出一个 DP。设 $f(i)$ 为最后一次不打卡是在第 $i$ 天时，最高的能量值大小。

转移枚举上一次不打卡的时间 $j$，有

$$  
f(i)=\max\_{j \in [i-k,i-1] } \Big\{f(j) + w(j+1,i-1) \; - \; (i-j-1)d \Big\}  
$$

其中 $w(l,r)$ 表示在 $[l,r]$ 连续打卡能得到的最大能量值。

直接做复杂度 $O(nk)$。

展开，有

$$  
f(i) = \max_{j \in [i-k,i-1]} \Big\{ f(j) + jd + w(j+1,i-1) \; - \; (i-1)d \Big\}  
$$

末项是常数。我们可以在线段树上动态维护 $f(j) + jd + w(j+1,i-1)$。具体地，把每个任务挂在右端点那一天，到了那一天后就更新对应区间的 $w$ 就行。

这样复杂度来到 $O(n\log n)$。

更进一步的，我们绝对不会在非任务期间打卡。令 $l_i=x_i-y_i+1,r_i=x_i$，那么有用的转移点只有 $l_i-1$，$r_i+1$。离散化一下即可。

复杂度 $O(m \log m)$。

## $\text{Code}$

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
#define pb push_back
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
const int N=1e5+5;
int type, T, n, m, k, d;
int lt[N], rt[N], val[N];
int cnt, t[N<<1];
vector<PII > vec[N<<1];
int mx[N<<3], tag[N<<3];
void pushup(int x) { mx[x]=max(mx[x<<1],mx[x<<1|1]); }
void maketag(int x,int d) {
    mx[x]+=d;
    tag[x]+=d;
}
void pushdown(int x) {
    if(tag[x]) {
        maketag(x<<1,tag[x]);
        maketag(x<<1|1,tag[x]);
        tag[x]=0;
    }
}
void build(int x=1,int l=1,int r=cnt) {
    mx[x]=tag[x]=0;
    if(l==r) return;
    int mid=(l+r)>>1;
    build(x<<1,l,mid);
    build(x<<1|1,mid+1,r);
}
void upd(int L,int R,int d,int x=1,int l=1,int r=cnt) {
    if(L<=l&&r<=R) {
        maketag(x,d);
        return;
    }
    int mid=(l+r)>>1;
    pushdown(x);
    if(L<=mid) upd(L,R,d,x<<1,l,mid);
    if(R>mid) upd(L,R,d,x<<1|1,mid+1,r);
    pushup(x);
}
int query(int L,int R,int x=1,int l=1,int r=cnt) {
    if(L<=l&&r<=R) return mx[x];
    int mid=(l+r)>>1, res=0;
    pushdown(x);
    if(L<=mid) res=max(res,query(L,R,x<<1,l,mid));
    if(R>mid) res=max(res,query(L,R,x<<1|1,mid+1,r));
    return res;
}
namespace RUN {
    void solve() {
        n=read(), m=read(), k=read(), d=read();
        cnt=0;
        rep(i,1,m) {
            int x=read(), y=read(), w=read();
            lt[i]=x-y+1, rt[i]=x, val[i]=w;
            t[++cnt]=lt[i]-1;
            t[++cnt]=rt[i]+1;
        }
        sort(t+1,t+cnt+1);
        cnt=unique(t+1,t+cnt+1)-(t+1);
        rep(i,1,m) {
            lt[i]=lower_bound(t+1,t+cnt+1,lt[i]-1)-t;
            rt[i]=lower_bound(t+1,t+cnt+1,rt[i]+1)-t;
            vec[rt[i]].pb(MP(lt[i],val[i]));
        }
        build();
        upd(1,1,t[1]*d);
        int ans=0, lst=1;
        rep(i,2,cnt) {
            for(auto x:vec[i]) upd(1,x.fi,x.se);
            while(t[i]-t[lst]-1>k) ++lst;
            // 找到距离不超过k的有用转移点的边界
            if(lst<=i-1) ans=max(ans,query(lst,i-1)-(t[i]-1)*d);
            upd(i,i,ans+t[i]*d);
        }
        printf("%lld\n",ans);
        rep(i,1,m) if(vec[rt[i]].size()) vec[rt[i]].clear();
    }
}
signed main() {
    type=read(), T=read();
    while(T--) RUN::solve();
    return 0;
}
```
