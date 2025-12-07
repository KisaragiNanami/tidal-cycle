---
title: luogu2403 所驼门王的宝藏 题解
tags:
  - 图论
  - 强连通分量
categories:
  - 题解

pubDate: 2022-02-09
---

把能够到达的宫室连边。



具体地，对于一个横天门，将它与同一行中的普通点连单向边，横天门连双向边。对于一个纵寰门，将它与同一列中的普通点连单向边，纵寰门连双向边。对于一个任意门，向周围的 8 个点连单向边（前提是不越界）。

由于只要到达一个强连通分量里，周围的点都能到达，所以求出所有强连通分量，缩点。点权为改强连通分量中点的个数。然后 DP 最长路就行了。

这题主要是实现麻烦。

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5, M=1e6+5;
const int dx[]={0,0,-1,1,-1,1,-1,1}, dy[]={1,-1,0,0,-1,-1,1,1};
int k, n, m, num, top, scc, ans, x[N], y[N], op[N], dfn[N], low[N], stk[N], c[N], ccnt[N];
int cnt, h[N], ver[M], nxt[M];
bool v[N];
map<int,int> mp[N];
vector<int> a[M], b[M];
inline void add(int x,int y) { ver[++cnt]=y, nxt[cnt]=h[x], h[x]=cnt; }

inline void init() {
    for(int i=1;i<=n;++i) {
        int x=0, len=a[i].size();
        for(int j=0;j<len;++j) if(op[a[i][j]]==1) { x=a[i][j]; break; }
        // 找到了一个横天门
        for(int j=0;j<len;++j) if(x!=a[i][j]) { add(x,a[i][j]); if(op[a[i][j]]==1) add(a[i][j],x); }
        // 连边
    }
    for(int i=1;i<=m;++i) {
        int x=0, len=b[i].size();
        for(int j=0;j<len;++j) if(op[b[i][j]]==2) { x=b[i][j]; break; }
        // 找到了一个纵寰门
        for(int j=0;j<len;++j) if(x!=b[i][j]) { add(x,b[i][j]); if(op[b[i][j]]==2) add(b[i][j],x); }
    }
        // 同上
    for(int i=1;i<=k;++i) if(op[i]==3) for(int j=0;j<8;++j) {
        if(mp[x[i]+dx[j]].find(y[i]+dy[j])!=mp[x[i]+dx[j]].end())
            add(i,mp[x[i]+dx[j]][y[i]+dy[j]]);
    // 如果是任意门，那么找有没有对应的位置，有的话连边
    }
}
inline void tarjan(int x) {
    dfn[x]=low[x]=++num, stk[++top]=x;
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(!dfn[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
        } else if(!c[y]) low[x]=min(low[x],dfn[y]);
    }
    if(dfn[x]==low[x]) {
        ++scc; int y;
        do y=stk[top--], c[y]=scc, ++ccnt[scc]; while(x!=y);
        // c[x]: x属于哪个强连通分量
        // ccnt[x]: x这个强连通分量有多少个节点
     }
}

int tc, hc[N], vc[M], nc[M];

int f[N];

inline void addc(int x,int y) { vc[++tc]=y, nc[tc]=hc[x], hc[x]=tc; }

inline void suodian() {
    for(int x=1;x<=k;++x) for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(c[x]!=c[y]) addc(c[x],c[y]);
    }
}

inline void dp() {
    for(int x=scc;x;--x) {
        f[x]+=ccnt[x];
        ans=max(f[x],ans);
        for(int i=hc[x];i;i=nc[i]) {
            int y=vc[i];
            f[y]=max(f[x],f[y]);
        }
    }
}

int main() {
    scanf("%d%d%d",&k,&n,&m);
    for(int i=1;i<=k;++i) {
        scanf("%d%d%d",&x[i],&y[i],&op[i]);
        a[x[i]].push_back(i), b[y[i]].push_back(i);
        // a为同一行，b为同一列。
        mp[x[i]][y[i]]=i;
        // map记录(x,y)的节点编号
    }
    init();
    for(int i=1;i<=k;++i) if(!dfn[i]) tarjan(i);
    suodian();
    dp();
    printf("%d\n",ans);
}
```
