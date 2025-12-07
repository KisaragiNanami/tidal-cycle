---
title: luogu4819 杀人游戏 题解
tags:
  - 图论
  - 强连通分量
categories:
  - 题解
pubDate: 2021-09-20
description: 'Solution'
---

## update 2022.2.9 修改了代码

不妨假设平民为白点，杀手为黑点，认识的关系为一条有向边。

求不访问黑点并且知道黑点的最小代价。

若有 $n$ 个点，显然每个点为黑的概率为 $\frac{1}{n}$。

而每访问一个白点，都能得知与它出边相连的点的颜色。

考虑强连通分量。

不难发现，对于每个强连通分量，只要以概率增加 $\frac{1}{n}$ 为代价访问其中一个点，就能得知整个强连通分量的颜色情况。。

所以求出强连通分量后进行缩点，我们就得到了一个 DAG。

为了减少总访问次数，访问入度不为 0 的 SCC 是不划算的。

简单证明：设缩点后存在 $(x \rightarrow y)$ 的边，则访问完 $x$ 中所有的点后，必定能知道 $y$ 中一个点的信息，所以对于 $y$，不需要增加 $\frac{1}{n}$ 的访问代价。

所以设缩点后入度为 0 的点的数量为 $s$，则访问到黑点的概率为 $\frac{s}{n}$，答案为 $ \frac{n-s}{n}$。

&nbsp;

考虑只含一个点的 SCC，设其为 $c$，若其入度为 0，且其能够到达的点的入度均大于 1，那么若最后访问 $c$，整张图的情况已经被确定了。若未找到黑点，则 $ c$  为黑点。如果包含超过 1 个节点，那么必须再访问它再能确定黑点。这样可以减少一次访问，且对于任意图，能且仅能减少一次。

所以若存在 $c$，令 $s-1$ 即可。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
const int N=1e5+6;
int n, m, k, num, ans, dfn[N], low[N], st[N];
int scc, c[N], deg[N], sz[N];
int cnt, h[N], ver[3*N], nxt[3*N];
int tc, hc[N], vc[3*N], nc[3*N];
bool v[N];
void add(int x,int y) { ver[++cnt]=y, nxt[cnt]=h[x], h[x]=cnt; }
void adc(int x,int y) { vc[++tc]=y, nc[tc]=hc[x], hc[x]=tc; }
void tarjan(int x) {
    dfn[x]=low[x]=++num, st[++k]=x;
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(!dfn[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
        } else if(!c[y]) low[x]=min(low[x],dfn[y]);
    }
    if(dfn[x]==low[x]) {
        ++scc;
        do y=st[k--], c[y]=scc, ++sz[scc]; while(x!=y);
    }
}
bool f(int x) {
    if(deg[x]||sz[x]!=1) return 0;
    for(int i=hc[x];i;i=nc[i]) if(deg[vc[i]]==1) return 0;
    return 1;
}
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1,x,y;i<=m;++i) scanf("%d%d",&x,&y), add(x,y);
    for(int i=1;i<=n;++i) if(!dfn[i]) tarjan(i);
    for(int x=1;x<=n;++x) {
        memset(v,0,sizeof(v));
        for(int i=h[x];i;i=nxt[i]) {
            int y=ver[i];
            if(c[x]!=c[y]&&!v[c[y]]) {
                v[c[y]]=1, ++deg[c[y]], adc(c[x],c[y]);
            }
        }
    }
    for(int i=1;i<=scc;++i) if(!deg[i]) ++ans;
    for(int i=1;i<=scc;++i) if(f(i)) { --ans; break; }
    printf("%.6lf\n",1.0*(n-ans)/n);
}
```
