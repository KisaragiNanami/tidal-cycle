---
title: luogu9869 [NOIP2023] 三值逻辑 题解
pubDate: 2025-07-20
categories: 
  - 题解
tags: 
  - 图论
  - 并查集
description: 'Solution'
---

## $\text{Solution}$

一生之敌。

中间的操作既涉及变量间的赋值，又有常量赋值。错误的做法是把这两种操作分开处理，把常量赋值特殊化，然后通过赋值关系推导别的变量再得出矛盾。

错误的原因是这个做法难以实现。

最大的瓶颈在于常量赋值。笔者在场上不由自主地怀疑这种操作会改变初始值，进而误入歧途。

理清逻辑，我们应该是先求出每个变量的最终值，然后再决定其各自的初始值。中间会成为什么样子是不需要考虑的。

我们需要把操作普遍化，寻找一种与初始值无关的终态形式。

不难发现，如果我们建立三个特殊点分别对应`T,F,U`，那么常量赋值也成了变量赋值。这样操作就统一了。这三个点仅仅是初始值确定了而已。

赋值的本质是关系，相同或相反。什么时候要钦定一个变量初始值为`U`呢？当且仅当它与已知信息产生矛盾，即它既是`T`有时`F`。

对于关系 $x_i \leftarrow x_j$，如果我们断开 $i$ 连接的所有边，连一条边 $(i,j)$，那么最终形态一定是一个森林。把相同关系边权设为 $0$，不同设为 $1$，通过异或运算，我们就能得到每棵树内部的等价关系。

遗憾的是，树无法导出矛盾。

更进一步的，由于赋值操作会让被赋值变量断开所有边，操作数 $O(n)$，我们不妨直接建立一个新点表示它。最后，我们将每个点与其终态点连一条 $0$ 边，这样就成了一张图，可以推导矛盾了。进行`DFS`，设 $d_x$ 为从搜索树根到 $x$ 路径边权异或和，找到环时判断一下两边的 $d$ 是否相等即可。

只要存在一个变量有矛盾，整个连通块的必然都会变成 `U`，这一步用并查集做。另外和特殊点`U`有关的变量都只会是`U`。

代码细节较多。

## $\text{Code}$

```
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
const int N=1e5+5;
int c, T, n, m, tot, now[N<<1], lk[N<<1], d[N<<1], w[N<<1];
bool v[N];
map<string,int> mp;
vector<PII > p[N<<1];
namespace DSU {
    int fa[N<<1], unk[N<<1];
    void init() {
        rep(i,1,tot) fa[i]=i, unk[i]=0;
    }
    int get(int x) {
        return x==fa[x]? x:fa[x]=get(fa[x]);
    }
    void merge(int x,int y) {
        x=get(x), y=get(y);
        if(x==y) return;
        fa[x]=y;
        unk[y]|=unk[x];
    }
};
void dfs(int x) {
    v[x]=1;
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
          if(!v[y]) {
             d[y]=d[x]^z;
             dfs(y);
           } else if(d[x]^z!=d[y]) DSU::unk[x]=1;
    }
}
void solve() {
    n=read(), m=read();
    tot=n+3;
    mp["T"]=n+1, mp["F"]=n+2, mp["U"]=n+3;
    rep(i,1,n) now[i]=i;
    rep(i,1,tot+m) {
        p[i].clear();
        lk[i]=d[i]=v[i]=0;
    }
    rep(i,1,m) {
        string s;
        cin>>s;
        if(s=="+") {
            int x=read(), y=read();
            int t=now[y];
            now[x]=++tot;
            lk[now[x]]=t;  
            d[now[x]]=0;
            // 巨大坑点：x可能等于y
        } else if(s=="-") {
            int x=read(), y=read();
            int t=now[y];
            now[x]=++tot;
            lk[now[x]]=t;
            d[now[x]]=1; 
        } else {
            int x=read();
            now[x]=++tot;
            lk[now[x]]=mp[s];
            d[now[x]]=0;
        }
    }
    rep(i,1,tot) if(lk[i]) {
        p[lk[i]].pb(MP(i,d[i]));
        p[i].pb(MP(lk[i],d[i]));
    }
    rep(i,1,n) {
        p[i].pb(MP(now[i],0));
        p[now[i]].pb(MP(i,0));
    }
    DSU::init();
    DSU::unk[n+3]=1;
    rep(i,1,tot) if(!v[i]) dfs(i);
    rep(i,1,tot) if(lk[i]) DSU::merge(i,lk[i]);
    rep(i,1,n) DSU::merge(i,now[i]);
    int ans=0;
    rep(i,1,n) {
        int x=DSU::get(i);
        ans+=DSU::unk[x];
    }
    printf("%d\n",ans);
}
signed main() {
    c=read(), T=read();
    while(T--) solve();
    return 0;
}
```
