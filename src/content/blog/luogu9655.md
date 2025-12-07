---
title: luogu9655「GROI-R2」 Beside You
pubDate: 2023-10-23
tags:
  - DP
  - 树形DP
  - 并查集
  - 启发式合并
  - 树论
  - 括号序列
categories: 题解
description: 'Solution'
---

## Solution

### Subtask 2

考虑合法括号序列的另一种意义。

将 `(`看作 $1$，`)`看作 $-1$，那么合法括号序列满足：

1. 总和为 $0$。
2. 任意前缀和不小于 $0$。

但是从左往右匹配的过程不是很适合树形结构，所以我们反过来，把 `)`看作 $1$，`(`看作 $-1$。设 $f_{x,i}$ 为以 $x$ 为根的子树中，自底向上到达 $x$ 时，总和为 $i$ 的所有路径的点数之和。

可能会有负数，但它们都是废状态，因此有 $i \ge 0$。

求出以 $x$ 为根的最长链 $g_x$，容易得到转移

$$
f_{x,i} = \Big( \sum_{y \in son(x)} f_{y,i+\Delta} \Big) + 1
$$

其中当 $x$ 为 `(`时，$\Delta = 1$，否则 $\Delta=-1$。

具体实现还有若干细节。

1. 只有方程中的和式大于 $0$ 时才会 $+1$。
2. 特判 `)`是叶子的情况。

答案是 $\max\{ f_{x,0} \}$。

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
const int N=3005;
int n, ans, f[N][N], g[N];
vector<int> p[N];
char s[N];
void dfs(int x,int fa) {
    g[x]=1;
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        g[x]=max(g[x],g[y]+1);
        for(int i=0;i<=g[y];++i) {
            if(s[x]==')') f[x][i+1]+=f[y][i];
            else if(i>0) f[x][i-1]+=f[y][i];
        }
    }
    for(int i=0;i<=g[x];++i) if(f[x][i]>0) f[x][i]+=1;
    if(s[x]==')'&&!f[x][1]) f[x][1]=1;
    ans=max(ans,f[x][0]);
}
```

### Subtask 6 Algo#1

由于这个 DP 中有用的值不多，并且转移有明显的合并意味，考虑用树上启发式合并优化。

对每个结点维护一个 `std::map`，同时用标记 $dlt$ 维护下标的偏移量，用标记 $val$ 维护值的偏移量。

具体细节见代码。

复杂度 $O(n \log^2 n)$，可以通过。

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
int n, ans;
vector<int> p[N];
char s[N];
struct node {
    int dlt=0, val=0;
    map<int,int> p;
    void merge(node& x) {
        if(p.size()<x.p.size()) {
            swap(dlt,x.dlt);
            swap(val,x.val);
            swap(p,x.p);
            // 启发式合并
        }
        for(auto t:x.p) {
            int y=t.fi+x.dlt-dlt, cnt=t.se;
            if(!p.count(y)) p[y]=-val;
            p[y]+=cnt+x.val;
        }
    }
    void reduce() {
        while(p.size()&&p.begin()->fi+dlt<0) p.erase(p.begin());
        // 干掉<0的废状态
    }
    void init() {
        if(!p.count(-dlt)) p[-dlt]=-val;
        // 初始化0状态
    }
    int get() {
        if(!p.count(-dlt)) return 0;
        return p[-dlt]+val;
        // 求f[x][0]
    }
} f[N];
void dfs(int x,int fa) {
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        f[x].merge(f[y]);
    }
    f[x].init();
    if(s[x]=='(') --f[x].dlt; else ++f[x].dlt;
    f[x].reduce();
    ++f[x].val;
    ans=max(ans,f[x].get());
}
signed main() {
    n=read();
    scanf("%s",s+1);
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    dfs(1,0);
    printf("%lld\n",ans);
    return 0;
}
```

### Subtask 6 Algo #2

考虑一个性质：以 $x$ 为根的合法连通块，一定可以拆成若干条匹配路径，而与每个点匹配的括号最有只有一个。

设与右括号 $x$ 匹配的左括号为 $\text{match}(x)$，在 $\text{DFS}$ 时维护一个栈就不难求出。并且我们能发现由于 $[\text{match}(x),x]$ 是一个合法串，所以中间那些括号只能加入这个区间里的连通块，从而一定能被 $\Big(\text{match}(x),x\Big)$ 这个连通块代替，因此我们只需要考虑极长括号。

考虑不断把极长括号加入连通块。初始时每个点各为一个集合，在 $\text{DFS}$ 的过程中把 $x$ 合并到 $\text{match}(x)$ 所在集合中，表示这条路径加入了以 $\text{match(x)}$ 为根的连通块。对于极长括号间的合并，在合并完 $x$ 后，尝试把 $\text{match}(x)$ 合并到其父亲处即可。

还有最后一个问题，我们得到的是一个点集，如何确定连通块的大小呢？有一个经典结论：对于一个树上点集 $S$，其导出连通块大小为

$$
\frac{\sum_{x \in \text{cyc}(S)} \text{dis}(x,nxt_x) }{2} + 1
$$

其中 $\text{cyc}(S)$ 是将 $S$ 中所有点按照 $dfn$ 排序后相邻节点形成的环，$nxt_x$ 是对环定向后，环上 $x$ 的相邻节点。注意当 $|S|=1$ 时不合法，不能 $+1$。

用并查集维护连通块，同时启发式合并，复杂度 $O(n \log^2 n)$。

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
int n, num, ans, dfn[N], match[N];
int tp, st[N];
int fa[N], son[N], top[N], dep[N], sz[N];
vector<int> p[N];
char s[N];
struct DSU {
    int fa[N], sz[N];
    vector<int> s[N];
    void init() { rep(i,1,n) fa[i]=i, sz[i]=1, s[i].pb(i); }
    int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
    void merge(int x,int y) {
        x=get(x), y=get(y);
        if(x==y) return;
        if(sz[x]<sz[y]) swap(x,y);
        fa[y]=x, sz[x]+=sz[y];
        for(auto z:s[y]) s[x].pb(z);
    }
} dsu;
void dfs(int x,int fat) {
    fa[x]=fat;
    sz[x]=1;
    dep[x]=dep[fa[x]]+1;
    dfn[x]=++num;
    if(s[x]=='(') st[++tp]=x;
    else {
        if(!tp) match[x]=0;
        else match[x]=st[tp--];
    }
    for(auto y:p[x]) if(y!=fa[x]) {
        dfs(y,x);
        sz[x]+=sz[y];
        if(sz[y]>sz[son[x]]) son[x]=y;
    }
    if(s[x]=='(') --tp; else if(match[x]) st[++tp]=match[x];
}
void dfs2(int x,int TP) {
    top[x]=TP;
    if(!son[x]) return;
    dfs2(son[x],TP);
    for(auto y:p[x]) if(y!=fa[x]&&y!=son[x]) {
        dfs2(y,y);
    }
}
int LCA(int x,int y) {
    while(top[x]!=top[y]) {
        if(dep[top[x]]<dep[top[y]]) swap(x,y);
        x=fa[top[x]];
    }
    if(dep[x]>dep[y]) swap(x,y);
    return x;
}
int dis(int x,int y) {
    int z=LCA(x,y);
    return dep[x]+dep[y]-2*dep[z];
}
void dfs3(int x) {
    for(auto y:p[x]) if(y!=fa[x]) dfs3(y);
    int to=match[x];
    if(!to) return;
    dsu.merge(x,to);
    if(match[fa[to]]) dsu.merge(to,fa[to]);
}
bool cmp(int x,int y) { return dfn[x]<dfn[y]; }
signed main() {
    n=read();
    scanf("%s",s+1);
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    dfs(1,0);
    dfs2(1,1);
    dsu.init();
    dfs3(1);
    rep(i,1,n) if(dsu.get(i)==i) {
        sort(dsu.s[i].begin(),dsu.s[i].end(),cmp);
        int res=0;
        for(int j=0;j+1<dsu.s[i].size();++j) res+=dis(dsu.s[i][j],dsu.s[i][j+1]);
        res+=dis(dsu.s[i][0],dsu.s[i].back());
        res=res/2;
        if(res) ++res;
        ans=max(ans,res);
    }
    printf("%lld\n",ans);
    return 0;
}
```
