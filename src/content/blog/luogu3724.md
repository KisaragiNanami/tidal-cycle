---
title: luogu3724 [AHOI2017/HNOI2017] 大佬 题解
pubDate: 2023-07-15
tags:
  - 搜索
  - DP
  - 双指针
categories: 题解
description: 'Solution'
---

## Solution

题意很复杂，我们要从中提取关键信息。

增加等级、嘲讽能力都是为了怼大佬服务，而怼大佬最多使用 $2$ 次，我们尝试把这个操作单独拿出来，这样要考虑的就只剩下了还嘴和做水题。

考虑这样一个东西：由于我们保证自己不死，所以除了做水题回血之外，剩下的时间都可以空出来，在我们需要的时候手动添加具体操作。

设 $f_{i,j}$ 为考虑前 $i$ 天，空出来了 $j$ 天，所剩下的最大体力。

$$
f_{i,j} = \max\begin{cases}\min(f_{i-1,j} - a_i + w_i,mc) & f_{i-1,j} \ge a_i\\f_{i-1,j-1} - a_i & f_{i-1,j-1} \ge a_i\end{cases}
$$



然后取 $maxd$ 为所有满足 $f_{i,j} \ge 0$ 的最大的 $j$，表示能空出的最大天数。

注意不一定要取 $f_{n,j}$，因为如果在第 $n$ 天之前把大佬干掉并且自己存活，那么也算胜利。因此如果 $maxd$ 不在 $f_{n,j}$ 处取得并且能在 $maxd$ 天之内干掉大佬，那么无妨；如果干不死，那么取 $f_{n,j}$ 处的也干不掉。

如果 $C \le maxd$，那么每天还嘴就行，否则就需要在 $maxd$ 天之内安排一次或两次怼大佬，但是怼大佬也不一定总是比还嘴优，不太好处理。

但是 $maxd$ 并不大，考虑把所有合法的怼大佬方法都搜索出来。设 $(d,F,L)$ 为用时 $d$ 天，能力为 $F$，等级为 $L$ 的状态。

如果是怼一次大佬，那么直接枚举所有状态，找到 $F+maxd-d \ge C$ 的状态即可。

如果一次不够，那么我们就找两个满足 $F_1+F_2+maxd-d_1-d_2 \ge C$ 的状态。注意到式子的值与 $F$ 正相关，与 $d$ 负相关，那就按照 $F$ 递增为第一关键字，$d$ 递减为第二关键字排序。这样对于一个 $(d_1,F_1,L_1)$，其最优决策就是满足 $F_1+F_2 \le C$ 的编号最大的 $(d_2,F_2,L_2)$，同时 $F_1$ 具有单调性，决策也就单调了，用双指针做就行。

最后是如何搜索的问题。虽然状态有三维，直观上数量不在少数，但是只有 $(F,L)$ 才有用，$d$ 这一维是要用最优化的。$d$ 每次只会增长 $1$，用 $\text{BFS}$ 即可。记录状态可以用`std::map<pair<int,int>,bool>`，但效率不高。

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
const int N=105;
int n, m, mc, maxd, a[N], w[N];
int f[N][N];
struct node {
    int d, L, F;
    node() {};
    node(int _d,int _L,int _F) { d=_d, L=_L, F=_F; };
};
bool operator<(node a,node b) {
    if(a.F!=b.F) return a.F<b.F;
    if(a.d!=b.d) return a.d>b.d;
    return a.L<b.L;
}
vector<node> st;
map<PII,bool> p;
void bfs() {
    queue<node> q;
    q.push(node(1,0,1)), st.pb(node(1,0,1));
    // 初始d设置为1，把怼大佬那一天提前算了
    p[MP(0,1)]=1;
    // pair要存(L,F)，否则TLE
    while(q.size()) {
        node x=q.front(), s; q.pop();
        if(x.d>=maxd) continue;
        PII t=MP(x.L+1,x.F);
        if(p[t]) continue;
        if(x.d<maxd) {
            p[t]=1;
            s=node(x.d+1,x.L+1,x.F);
            q.push(s), st.pb(s);
        }
        t=MP(x.L,x.F*x.L);
        if(t.fi<=1||t.se>1e8||p[t]) continue;
        p[t]=1;
        s=node(x.d+1,x.L,x.F*x.L);
        q.push(s), st.pb(s);
    }
    sort(st.begin(),st.end());
}
signed main() {
    n=read(), m=read(), mc=read();
    rep(i,1,n) a[i]=read();
    rep(i,1,n) w[i]=read();
    SET(f,-1);
    f[0][0]=mc;
    rep(i,1,n) rep(j,0,i) {
        if(f[i-1][j]>=a[i]) f[i][j]=max(f[i][j],min(f[i-1][j]-a[i]+w[i],mc));
        if(j&&f[i-1][j-1]>=a[i]) f[i][j]=max(f[i][j],f[i-1][j-1]-a[i]);
    }
    rep(i,1,n) rep(j,1,i) if(f[i][j]>=0) maxd=max(maxd,j);
    bfs();
    while(m--) {
        int C=read();
        if(C<=maxd) { puts("1"); continue; }
        int l=0, r=st.size()-1;
        for(int i=0;i<st.size();++i) {
            if(st[i].F<=C&&st[i].F+maxd-st[i].d>=C) { puts("1"); goto qwq; }
        }
        for(;l<=r;++l) {
            while(l<=r&&st[l].F+st[r].F>C) --r;
            if(l<=r&&st[l].F+st[r].F+maxd-st[l].d-st[r].d>=C) { puts("1"); goto qwq; }
        }
        puts("0");
        qwq:;
    }
}
```
