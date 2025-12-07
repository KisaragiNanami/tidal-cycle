---
title: luogu3573 [POI2014] RAJ-Rally 题解
pubDate: 2023-10-23
tags:
  - DP
  - 图论
categories: 题解

---

设 $f_x$ 为以 $x$ 结尾的最长路径，$g_x$ 为以 $x$ 开头的最长路径，那么答案就是 $\max_{(x,y) \in E} \{f_x+1+g_y\}$。

考虑一个性质：对于一个点 $x$，设拓扑序小于它的点集为 $S$，拓扑序大于它的点集为 $T$，以 $S$ 中节点 $y$ 结尾的路径 $f_y$ 和以 $T$ 中节点 $z$ 开头的路径 $g_z$ 均与 $x$ 无关。最长路径可以刻画为 $S$ 内部的最长路径、$T$ 内部的最长路径，$S$ 到 $T$ 的最长路径。

按照拓扑序枚举点 $x$，考虑如何维护删掉点 $x$ 后的最长路径。初始所有点都在 $T$ 中，每枚举到一个点，就把它从 $T$ 中删除，同时干掉所有形如 $f_y + 1 + g_x$ 的路径，其中存在边 $(y,x)$。此时最长的路径就是删掉 $x$ 时的答案。然后把 $x$ 加入 $S$，增加的新路径是 $f_x+1+g_y$，其中存在边 $(x,y)$。

用一个支持插入删除查询最大值的神秘数据结构即可维护。

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
int n, m, in1[N], in2[N], f[N], g[N];
int cnt, topo[N];
vector<int> p[N], b[N];
void toposort1() {
    queue<int> q;
    rep(i,1,n) if(in1[i]==0) q.push(i);
    while(q.size()) {
        int x=q.front(); q.pop();
        topo[++cnt]=x;
        for(auto y:p[x]) {
            f[y]=max(f[y],f[x]+1);
            if(--in1[y]==0) q.push(y);
        }
    }
}
void toposort2() {
    for(int i=n;i;--i) {
        int x=topo[i];
        for(auto y:b[x]) {
            g[y]=max(g[y],g[x]+1);
        }
    }
}
struct heap {
    priority_queue<int> a, b;
    void push(int x) { a.push(x); }
    void pop(int x) { b.push(x); }
    int top() {
        while(b.size()&&a.top()==b.top()) a.pop(), b.pop();
        return a.top();
    }
};
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        p[x].pb(y), b[y].pb(x);
        ++in1[y], ++in2[x];
    }
    toposort1();
    toposort2();
    heap q;
    int ans=0, len=0;
    rep(i,1,n) q.push(g[i]);
    len=q.top();
    rep(i,1,n) {
        int x=topo[i];
        q.pop(g[x]);
        for(auto y:b[x]) {
            q.pop(f[y]+1+g[x]);
        }
        int t=q.top();
        if(t<len) ans=x, len=t;
        for(auto y:p[x]) {
            q.push(f[x]+1+g[y]);
        }
        q.push(f[x]);
    }
    printf("%lld %lld\n",ans,len);
    return 0;
}

```
