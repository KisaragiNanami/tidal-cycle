---
title: 「NOIP Record」#2 基环树
tags:
  - 基环树
  - DP
  - 图论
  - 博弈论
  - 计数
categories:
  - Record
pubDate: 2023-05-07
description: '少年的后脚超越了前脚'
---

突破口永远在环上。

&nbsp;

找环是常用操作，但是并没有一个合适的模板。

笔者在写这篇文章之前就做过一些基环树的简单题，但是每一次写的找环都不尽相同。仅仅用`dfs`的回溯模拟一个栈，显然是不够公式化的，且容易出 bug，因此我们需要确定一种可靠的写法。

关于`dfn`的那套理论再合适不过了。

当然这玩意只能找一个环。

```cpp
int cnt, num, fa[N], dfn[N], cir[N];
void get_cir(int x) {
    dfn[x]=++num;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa[x]) continue;
        if(dfn[y]) {
            if(dfn[y]<dfn[x]) continue;
            cir[++cnt]=y;
            while(y!=x) {
                cir[++cnt]=fa[y];
                y=fa[x];
            }
        } else fa[y]=x, get_cir(y);
    }
}
```



还可以使用拓扑排序。

最终没有入队的就是环上节点。



```cpp
// 基环树
void toposort1(){ 
    queue<int> q;
    for(int i=1;i<=n;++i) if(in[i]==1) q.push(i);
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(in[y]>1){
                // do sth.
                if(--in[y]==1) q.push(y);
            }
        }
    }
}
// 内向树
void toposort2(){ 
    queue<int> q;
    for(int i=1;i<=n;++i) if(!in[i]) q.push(i);
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            // do sth.
            if(--in[y]==0) q.push(y);
        }
    }
}
```



### luogu2607 [ZJOI2008] 骑士

> 基环树森林， $n$ 个点。求带权最大独立集。
> 
> $n \le 10^6$

树的情况是平凡的。

基环树的本质是若干树挂在一个环上，因此对于环上每个节点为根都跑一遍。然后断环为链，钦定一个元素选还是不选，做两遍即可。

### luogu4381 [IOI2008] Island

> 求 $n$ 个点的基环树直径。
> 
> $n \le 10^6$

答案一定是环上两点连接它们子树的直径。

断环为链，这里采用复制一遍的方法。

答案就是

$$
\max_{i \le j} \{d_i + d_j + dis(i,j)\}
$$



把 $dis(i,j)$ 拆成前缀和相减的形式，发现对于一个 $j$，最优策略是前面距离不超过 $n$ 的最大值，单调队列维护。

### CF835F Roads in the Kingdom

> $n$ 个结点的基环树，边有边权。需要从删去一条边，保证连通且最小化直径。

首先删掉的边一定是环上的，否则不连通。

断开环上一边 $(x,y)$，此时的直径是环上 $x$ 到 $y$ 的路径加上二者子树的直径，或者某个子树的直径。

而删边的影响仅仅是干掉某些环上的路径。

长度为 $n$ 的那个滑动窗口能够做到“删掉某条边”。

由于这个单调队列一次能干掉的决策只有一个，所以用`std::set`即可，但是要注意判断最优决策相等的情况，维护次大值。



### CF1454E Number of Simple Paths

> $n$ 点 $n$ 边的无向图，问一共有多少条简单路径。
> 
> $n \le 2 \cdot 10^5$

如果两个点之间的路径跨越环上某一部分，那么就有两条简单路径，否则只有一条。对环上每棵子树分别考虑即可。



### CF1770D Koxia and Game

> 给定 $n$ 和长度为 $n$ 的序列 $a,b$，考虑另一个序列 $c$。
> 
> 先手在第 $i$ 次操作，可以拿走可重集 $\{a_i,b_i,c_i\}$ 中的一个元素，后手再二选一拿走一个。
> 
> 做完 $n$ 次操作后，如果后手拿走的所有元素是 $1 \sim n$ 的一个排列，那么先手胜，否则先手败。
> 
> 求有多少个 $c$，满足先手能胜利。对 $998244353$ 取模。
> 
> $n \le 10^5$，$a_i,b_i \in [1,n]$

博弈，但并不是传统的博弈论题目。

正着想很困难，考虑先手能赢的条件。

对于 $\{a_n,b_n,c_n\}$，如果不存在两者相同，那么无论先手拿走哪一个，后手都有办法使得先手输掉。所以 $\{a_n,b_n,c_n\}$ 存在两者相同是一个必要条件。

考虑 $\{a_{n-1},b_{n-1},c_{n-1}\}$，假设 $\{a_n,b_n,c_n\}$ 满足上述条件，发现 $\{a_{n-1},b_{n-1},c_{n-1}\}$ 满足上述条件依然是必要的。

由此递归下去，得到对于任意 $i$，$\{a_i,b_i,c_i\}$ 满足上述条件是充要的。

问题转化为对于任意 $i$，要在 $(a_i,b_i)$ 中选择一个数，求选出的数构成 $[1,n]$ 的一个排列的方案数。对于 $a_i = b_i$ 的情况，对方案的贡献是 $n$。

转化为图论问题。将 $a_i$ 与 $b_i$ 视为点，在 $(a_i,b_i)$ 间连一条无向边，这样就会得到一些连通块。由数据范围可知最多有 $n$ 个点与 $n$ 条边。

由于一条边连接的两个点中必然有一个被选择且不允许重复（要构成排列），所以如果一个联通块点数不等于边数，无解。那么有解的连通块一定是一棵基环树。

容易发现方案只有 $2$ 种，区别在环上选择的方向。环也有可能是自环，就是 $a_i=b_i$ 的情况，方案是 $1$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=1e5+5, mod=998244353;
int T, n, ans, fg, v[N], a[N], b[N];
int cnt;
vector<int> p[N];
#define pb push_back
struct DSU {
    int fa[N], sz[N], cnte[N];
    bool slp[N];
    int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
    void merge(int x,int y) {;
        int tx=get(x), ty=get(y);
        if(fa[tx]!=ty) fa[tx]=ty, sz[ty]+=sz[tx], cnte[ty]+=cnte[tx];
        ++cnte[ty];
        slp[ty]|=slp[tx];
        if(x==y) slp[ty]=1;
    }
    // 经过某道题的教训，终于老老实实写些并查集维护起来相对容易的信息了
} dsu;
void solve() {
    n=read();
    ans=1;
    rep(i,1,n) v[i]=0, dsu.fa[i]=i, dsu.cnte[i]=dsu.slp[i]=0, dsu.sz[i]=1, a[i]=read();
    rep(i,1,n) {
        b[i]=read();
        int x=a[i], y=b[i];
        dsu.merge(x,y);
    }
    rep(i,1,n) if(i==dsu.get(i)) {
        if(dsu.sz[i]!=dsu.cnte[i]) {
            puts("0");
            return;
        }
        if(dsu.slp[i]) (ans*=n)%=mod;
        else (ans*=2)%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
}
```

贴上`DFS`版本的 std。

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 1e5 + 5;
const int P = 998244353;
int n, a[N], b[N];
vector <int> G[N];
bool vis[N];
int vertex, edge, self_loop;
void dfs(int x) {
    if (vis[x]) return ;
    vis[x] = true;
    vertex++;
    for (auto y : G[x]) {
        edge++;
        dfs(y);
        if (y == x) self_loop++;
     }
}
void solve() {
    scanf("%d", &n);
    for (int i = 1; i <= n; i++) scanf("%d", &a[i]);
    for (int i = 1; i <= n; i++) scanf("%d", &b[i]);

    for (int i = 1; i <= n; i++) G[i].clear();

    for (int i = 1; i <= n; i++) {
        G[a[i]].push_back(b[i]);
        G[b[i]].push_back(a[i]);
    }

    int ans = 1;

    for (int i = 1; i <= n; i++) vis[i] = false;
    for (int i = 1; i <= n; i++) {
        if (vis[i]) continue ;
        vertex = 0;
        edge = 0;
        self_loop = 0;
        dfs(i);
        if (edge != 2 * vertex) ans = 0;
        else if (self_loop) ans = 1ll * ans * n % P;
         else ans = ans * 2 % P;
    }
    printf("%d\n", ans);
}
int main() {
    int t;
    scanf("%d", &t);
    while (t--) solve();
    return 0;
}
```



### CF512D Fox And Travelling

~~不知道和基环树有什么关系~~。

首先可以发现，环中的节点和链接两个环的链上的节点是不能选的。

用上文的无向图拓扑排序可以找到所有上述节点，这样的话就会得到一个森林。

注意选点是有顺序的，考虑一棵树中，一定是从叶子开始自底向上选，且如果一个点没有被选，其一定不会产生任何贡献。

设 $f_{x,i}$ 为以 $x$ 为根的子树，选择 $i$ 个点，其中 $x$ 必须选择的方案数。

$$
g_j = \binom{j}{k} \times f_{x,k} \times f_{y,j-k}
$$



$\binom{j}{k}$ 的含义是从 $j$ 个位置中选择 $k$ 个给当前以 $x$ 为根的子树。

能发现 $x$ 是最后被选择的。

对于挂在环上的树，这种选择方式显然是唯一的。

考虑孤立的树。由于 $n \le 100$，所以直接以每个点为根做一次树形 DP。设选择 $i$ 个节点，这样只能保证选 $sz_{root}$ 个点时没有重复。

考虑选出的 $i$ 个节点，这个方案一定在以剩下 $sz_{root}-i$ 个节点为根时都被算过一次，除掉即可。

### luogu5049 [NOIP2018 提高组] 旅行 加强版

> 给定一棵 $n$ 个点的树或基环树，起点为 $1$。
> 
> 有两种操作
> 
> 1. 到达一个当前点能直接到达的，没有到达过的点。
> 2. 沿着到达当前点的边退回这条边的另一个端点。
> 
> 要求遍历所有点，最小化节点遍历的字典序。
> 
> $n \le 5 \cdot 10^5$

对于一棵树，必须按照子节点编号递增的顺序`DFS`，所以下文访问顺序指的就是兄弟节点之间的编号顺序。

对于基环树，多了的操作是「从环上往后退」。

什么时候可以往后退呢？当且仅当对于环上的父子节点 $(x,y)$，$y$ 是 $x$ 最后遍历的子节点（这样才能从另一边绕回来），同时回溯到 $y$ 的祖先时，能够到达编号小于 $y$ 的点。

更进一步地，如果选择了退回，那么不可能再次后退。所以这个编号小于 $y$ 的点，一定是回溯过程中遇到的第一个祖先的儿子，满足它是这个祖先下一个应访问的节点，否则就无法遍历到了。

因此就变成了树的做法。

如何实现？对于节点 $x$，维护最小子节点编号，`DFS`时记录之，这样一定能找到最优退回的地方。

顺带一提，优先队列的内存优化优于队列。

```cpp
#include<bits/stdc++.h>
using namespace std;
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
int n, m, num, fg, root, dfn[N], fa[N];
bool v[N], cir[N];
vector<int> p[N], ans;
#define pb emplace_back
void dfs(int x,int fa) {
    ans.pb(x);
    for(auto y:p[x]) if(y!=fa) dfs(y,x);
}
void get_cir(int x) {
    dfn[x]=++num;
    for(auto y:p[x]) if(y!=fa[x]) {
        if(dfn[y]) {
            if(dfn[y]<dfn[x]) continue;
            cir[y]=1;
            while(y!=x) {
                cir[fa[y]]=1;
                y=fa[y];
            }
        } else fa[y]=x, get_cir(y);
    }
}
void DFS(int x,int pre) {
    v[x]=1;
    ans.pb(x);
    priority_queue<int,vector<int>,greater<int> > q;
    for(auto y:p[x]) if(!v[y]) q.push(y);
    while(q.size()) {
        int y=q.top(); q.pop();
        if(!fg&&q.empty()&&cir[x]&&cir[y]&&pre<y) {
            fg=1;
            return;
        }
        if(v[y]) continue;
        if(cir[x]&&q.size()) DFS(y,q.top());
        else DFS(y,pre);
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    rep(i,1,n) sort(p[i].begin(),p[i].end());
    if(m==n-1) dfs(1,0);
    else get_cir(1), DFS(1,1e9);
    for(auto x:ans) printf("%d ",x);
    puts("");
}
```

- 欲穷千里目，更上一层楼。

### luogu8288 「DAOI R1」Fireworks

题面较复杂，就不放了。

本题相当缝合。

坚持自己的想法，让我得到了无数次 WA。最终也是放弃了自己的框架，参考了 std。

这么多次写挂，背后的原因，不全是因为此题代码实现相对复杂。经过教练的指导，我也明白了我深层的不足。

为了不留下遗憾，勇敢面对吧！





连边 $(a_x \rightarrow x)$，权值 $b_x$。

如果没有系列的限制，相当于在外向树森林上做一个简单 DP。

有了限制，就把同一个系列的点缩成一个，其权值为所有点权之和。

设 $f_{x,0/1}$ 为以 $x$ 为根的子树，$x$ 选还是不选的最大价值。每个节点的入边最多为 $1$，因此无入度点一定不会进入环，直接搜。

如果有环，强制环上一点选或者不选，两次 DP 即可。

设主节点为 $p$，对于非主要点 $x$，如果 $a_x$ 所在系列是 $x$ 所在的系列，让点权减少 $b_x$；否则如果 $a_x$ 所在的系列和 $a_p$ 所在系列相同，就让边权加上 $b_x$。

注意如果 $a_p$ 就是 $p$ 所在系列，优先执行前者。而这对应的就是无入度点。

如果有点不属于任何一个系列，新建立一个系列，只有这个点。

主要问题在于实现。

代码详细解释。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(b))
#define rep(i,j,k) for(int i=(j);i<=(k);++i)
#define per(i,j,k) for(int i=(j);i>=(k);--i)
ll read() {
    ll a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=5e5+5;
int n, m, num, cnt, a[N], p[N], bel[N];
ll b[N], v[N], v2[N], ww[N], f[N][2];
vector<int> s[N];
vector<pair<int,ll> > g[N];
pair<int,int> cir[N];
bool vis[N];
#define pb emplace_back
struct DSU {
    int fa[N];
    int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
} dsu;
void dfs(int x,int i) {
    f[x][0]=0, f[x][1]=v2[x];
    // 赋初值避开清空数组
    for(auto t:g[x]) {
        int y=t.first;
        ll z=t.second;
        dfs(y,i);
        // 出边可能不止有一条。虽然断开了环上那条边，但cir[i].second也可能到达其他点
        // 因此还要往下DFS，这时候就能看出避免连环上这条边的重要性
        // 只需要在更新cir[i].second的父节点时候特判
        if(i&&y==cir[i].second) {
            f[x][0]+=max(f[y][0],f[y][1]-ww[i]);
            f[x][1]+=max(f[y][0],f[y][1]-ww[i]-z);
            // 无论如何必须减掉i这条边的权值
        } else {
            f[x][0]+=max(f[y][0],f[y][1]);
            f[x][1]+=max(f[y][0],f[y][1]-z);
        }
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) v[i]=read(), a[i]=read(), b[i]=read();

    rep(i,1,m) {
        p[++num]=read(); int k=read();
        dsu.fa[num]=num;
        while(k--) {
            int x=read();
            v2[num]+=v[x], bel[x]=num;
            s[num].pb(x);
        }
        // num表示有多少个系列
        // 只有系列才是有用的，因此直接重新编号，避免不必要的麻烦
        // 笔者在写的时候，没有进行重新编号，而是用DSU进行缩点
        // 不重新编号，会带来各种各样的麻烦
        // 重新编号则没有什么坏处
        // 因为原来的点的编号在预处理完之后就没有任何用处了
    }

    rep(i,1,n) if(!bel[i]) {
        p[++num]=i, bel[i]=num, v2[num]=v[i];
        s[num].pb(i);
        dsu.fa[num]=num;
        // 处理不在任何系列中的点
    }


    rep(i,1,num) {
        int tp=bel[a[p[i]]];
        ll res=0;
        for(auto x:s[i]) {
            int tx=bel[a[x]];
            if(tx==i) v2[i]-=b[x];
            // 优先执行这个
            else if(tx==tp) res+=b[x];
        }
        if(tp==i) continue;
        // 无入度点
        vis[i]=1;
        if(dsu.get(i)==dsu.get(tp)) {
            // DSU判环
            // 但注意不要烦笔者这样的错误
            // 突然降智，过于依赖DSU的结构，用DSU存每个连通块那一条环上边
            // 自找麻烦罢了
            cir[++cnt].first=i, cir[cnt].second=tp, ww[cnt]=res;
            // ww[cnt]为这条边的权值
        } else {
            dsu.fa[dsu.get(i)]=dsu.get(tp);
            g[tp].pb(make_pair(i,res));
            // 成环的时候不连边，保证DFS无环
            // 否则就连反边
        }
    }
    ll ans=0;
    rep(i,1,num) if(!vis[i]) {
        dfs(i,0);
        ans+=max(f[i][0],f[i][1]);
        // 这样的点可以直接搜
    }
    rep(i,1,cnt) {
        int x=cir[i].first;
        ll aa=0;
        dfs(x,i);
        // 强制cir[i].first必须选，cir[i].second->cir[i].first必须考虑
        aa=f[x][1];
        dfs(x,0);
        aa=max(aa,f[x][0]);
        // 不选，不考虑cir[i].second->cir[i].first
        ans+=aa;
    }
    printf("%lld\n",ans);
}
```

- 不要过于依赖提交，认真分析程序。
- 思路应该更广阔些，本题应该在发现建图后就是外向树森林，进而分析图的特殊形态而简化实现

必须要把我的某一版 sb 程序贴出来，以作警示。

想不到还有 30pts。

```cpp
const int N=5e5+5;
int n, m, ans, v[N], vv[N], a[N], b[N], p[N], f[N][2];
int to[N][2];
bool vis[N];
vector<int> s[N];
vector<pair<int,int> > g[N];
#define pb emplace_back
#define fi first
#define se second
struct DSU {
    int fa[N];
    pair<int,int> cir[N];
    void init() { rep(i,1,n) fa[i]=i, cir[i].fi=cir[i].se=0; }
    int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
    void merge(int x,int y) {
        int dx=get(x), dy=get(y);
        if(dx!=dy) fa[dx]=dy;
        else if(x!=y) cir[dy]={x,y};
    }
} dsu, dsu2;
void dfs(int x,int root) {
    vis[x]=1;
    f[x][0]=0, f[x][1]=v[x];
    for(auto t:g[x]) {
        int y=t.fi, z=t.se;
        if(y==root) continue;
        dfs(y,root);
        f[x][0]+=max(f[y][0],f[y][1]);
        f[x][1]+=max(f[y][0],f[y][1]-z);
    }
}
void dfs1(int x,int root) {
    f[x][0]=0;
    f[x][1]=v[x];
    for(auto t:g[x]) {
        int y=t.fi, z=t.se;
        if(y==root) {
            f[x][1]-=z;
            continue;
        } else dfs1(y,root);
        f[x][0]+=max(f[y][0],f[y][1]);
        f[x][1]+=max(f[y][0],f[y][1]-z);
    }
    // printf("x=%lld f=%lld %lld\n",x,f[x][0],f[x][1]);
}
void redirect() {
    rep(i,1,n) if(dsu.get(i)==i) {
        int y=to[i][0], z=to[i][1];
        g[y].pb(make_pair(i,z));
    }
}
void rebuild() {
    rep(i,1,n) if(dsu.get(i)==i) {
        dsu2.merge(i,to[i][0]);
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) v[i]=read(), a[i]=read(), b[i]=read();
    dsu.init(), dsu2.init();
    rep(i,1,m) {
        p[i]=read();
        int k=read();
        while(k--) {
            int x=read();
            if(x==p[i]) continue;
            v[p[i]]+=v[x];
            s[p[i]].pb(x);
            dsu.merge(x,p[i]);
        }
    }
    rep(i,1,n) if(dsu.get(i)==i) {
        to[i][0]=dsu.get(a[i]), to[i][1]=b[i];
        if(!s[i].size()) continue;
        for(auto x:s[i]) {
            int px=dsu.get(a[x]);
            if(px==i) v[i]-=b[x];
            else if(px==to[i][0]) to[i][1]+=b[x];
        }
    }

    redirect();

    rebuild();

    rep(i,1,n) if(!vis[i]&&dsu.get(i)==i) {
        int aa=0;
        int root=0, pi=dsu2.get(i);
        if(dsu2.cir[pi].fi!=0) root=dsu2.cir[pi].fi;
        else {
            root=pi;
            dfs(root,root);
            ans+=max(f[root][0],f[root][1]);
            continue;
        }
        dfs(root,root);
        aa=f[root][0];
        SET(f,0);
        dfs1(root,root);
        aa=max(aa,f[root][1]);
        ans+=aa;
    }
    printf("%lld\n",ans);
}
```



### luogu6890 [CEOI2006] Link

首先执行拓扑排序，将 $1$ 和无入度点加入队列，$1$ 一定会对它们连边。每求出一个 $f_x > k$ 就将其置为 $1$，再更新别的点。

把环拎出来，考虑别的点进入环后只能到达环上一个区间，可以用差分维护。这些点肯定不需要连边。对于剩下的点，如果第一个连边的点确定了，那么就直接贪心。

考虑枚举第一个连边的点，设环长为 $m$，发现只会跳 $O(\frac{m}{k})$ 次。由于开头 $k$ 个点必然至少有一个连边，所以复杂度就是 $O(m)$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
int n, m, k, ans, cnt, to[N], in[N], f[N], c[N];
bool v[N];
vector<int> cir[N];
void toposort() {
    queue<int> q;
    rep(i,1,n) {
        if(!in[i]||i==1) {
            f[i]=i==1? 0:1;
            if(i>1) ++ans;
            q.push(i);
        } else f[i]=k+1;
    }
    while(q.size()) {
        int x=q.front(); q.pop();
        v[x]=1;
        if(f[x]>k) ++ans, f[x]=1;
        int y=to[x];
        if(y<=1) continue;
        f[y]=min(f[y],f[x]+1);
        if(--in[y]==0) q.push(y);
    }
}
void getcir() {
    rep(i,1,n) if(!v[i]) {
        v[i]=1;
        cir[++cnt].pb(114514), cir[cnt].pb(i);
        int x=i;
        while(to[x]!=i) v[to[x]]=1, cir[cnt].pb(to[x]), x=to[x];
    }
}
void solve(int x) {
    m=cir[x].size()-1;
    memset(c,0,(m+1)<<3);
    rep(i,1,m) {
        if(f[cir[x][i]]>k) continue;
        int R=i+k-f[cir[x][i]];
        if(R<=m) ++c[i], --c[R+1];
        else ++c[i], --c[m+1], ++c[1], --c[R+1-m];
    }
    vector<int> v; v.pb(1919810);
    rep(i,1,m) {
        c[i]+=c[i-1];
        if(c[i]==0) v.pb(i);
    }
    int res=v.size()-1, mm=v.size()-1;
    for(int i=1;i<=min(mm,k);++i) {
        int a=0;
        for(int j=v[i];j<v[i]+m;++j) {
            int jj=j>m? j-m:j;
            if(c[jj]==0) ++a, j+=k-1;
        }
        res=min(res,a);
    }
    ans+=res;
}
signed main() {
    n=read(), k=read();
    rep(i,1,n) {
        int x=read(), y=read();
        to[x]=y, ++in[y];
    }
    toposort();
    getcir();
    rep(i,1,cnt) solve(i);
    printf("%lld\n",ans);
}
```
