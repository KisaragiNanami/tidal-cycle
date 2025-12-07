---
title: 「NOIP Record」#1 树形DP（1）
pubDate: 2023-05-04
tags:
  - DP
  - 树形DP
  - 计数
  - 容斥原理
  - 二项式反演
  - 状态压缩
  - 边双连通分量
categories:
  - Record
description: '一切的开始'
---



树形 DP 计数。

## luogu8867 建造军营

对于图中一条非割边，看守与否都相同，因此可以用 Tarjan 算法求出边双再缩点，把非树边单独拿出来，讨论每一条树边。

然而貌似不是很好做，子树外是否建造会影响子树内。考虑设 $f_x$ 为军营只在以 $x$ 为根的子树中出现，且至少存在 $1$ 个军营的方案数。

转移时对于边 $(x,y)$，如果 $y$ 中没有军营，那么子树 $y$ 中每条边以及 $(x,y)$ 看守与否均可，方案数 $2^{sz_y}$；否则 $(x,y)$ 一定要看守，方案数 $f_y$。

还要乘上 $x$ 所在边双中任意选择的方案数，并且减掉子树中一个都不选的方案。

$$
f_x = 2^{c_x} \prod_{y \in son(x)} (f_y+2^{sz_y}) - 2^{sz_x-1}
$$



但这样求出的并不是答案。

直接对一个 $f_x$ 求对答案的贡献会产生重复，举个例子，如果 $x$ 只有 $y$ 这一个儿子，那么 $y$ 节点上建造了军营，$x$ 没有建造，那么这样的情况就会在 $f_x$ 与 $f_y$ 中被重复统计到。

考虑将节点贡献在 $\operatorname{LCA}$ 处统计。在节点 $x$ 处的贡献，要么是 $x$ 节点中建造了，要么是 $x$ 有至少两个儿子所在子树中建造了。这两种情况都在 $f_x$ 中被统计过。

非法方案是 $x$ 没有建造军营，并且只有一个儿子 $y$ 所在子树中建造了，容易得到这部分就是

$$
2^{dcc-1-(sz_x-1)}\sum_{y \in son(x)} f_y \times 2^{sz_x-sz_y-1}
$$



最后乘上每条非树边可选可不选的方案。

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
const int N=5e5+5, M=1e6+5, mod=1e9+7;
int n, m, num, cnt, pw[M];
int ans, bel[N], c[N], sz[N], f[N];


struct Gr {
    int tot, h[N], to[M<<1], nxt[M<<1];
    void add(int x,int y) { to[++tot]=y, nxt[tot]=h[x], h[x]=tot; }
} G, T;

int dcc, tp, dfn[N], low[N], st[N];
void tarjan(int x,int lst) {
    dfn[x]=low[x]=++num;
    st[++tp]=x;
    for(int i=G.h[x];i;i=G.nxt[i]) {
        int y=G.to[i];
        if(i!=(lst^1)) {
            if(!dfn[y]) {
                tarjan(y,i);
                low[x]=min(low[x],low[y]);
            } else low[x]=min(low[x],dfn[y]);
        }
    }
    if(dfn[x]==low[x]) {
        int y=0; ++dcc;
        do y=st[tp--], ++c[dcc], bel[y]=dcc; while(x!=y);
    }
}
void dfs(int x,int fa) {
    sz[x]=1, f[x]=pw[c[x]];
    for(int i=T.h[x];i;i=T.nxt[i]) {
        int y=T.to[i];
        if(y==fa) continue;
        dfs(y,x);
        (f[x]*=(f[y]+pw[sz[y]])%mod)%=mod;
        sz[x]+=sz[y];
    }
    (f[x]-=pw[sz[x]-1]-mod)%=mod;
    int F=f[x];
    for(int i=T.h[x];i;i=T.nxt[i]) {
        int y=T.to[i];
        if(y==fa) continue;
        (F-=f[y]*pw[sz[x]-sz[y]-1]-mod)%=mod;
    }
    (ans+=F*pw[dcc-sz[x]]%mod)%=mod;
}
void suodian() {
    rep(x,1,n) {
        for(int i=G.h[x];i;i=G.nxt[i]) {
            int y=G.to[i];
            if(bel[x]!=bel[y]) {
                T.add(bel[x],bel[y]);
            } else ++cnt;
        }
    }    
}
signed main() {
    G.tot=1;
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        G.add(x,y), G.add(y,x);
    }
    tarjan(1,0);
    suodian();
    pw[0]=1;
    for(int i=1;i<=max(n,m);++i) pw[i]=pw[i-1]*2%mod;
    dfs(1,0);
    printf("%lld\n",ans*pw[cnt>>1]%mod);
}
```



自己顺着错误的想法推导的过程中，也得到了很多教训。

- 计数的式子，一定再三考虑后再写下
- 不要老是想着容斥掉某些东西
- 对于边双内部的点、边这类“可以提到外面”的东西，尽量不要放到 DP 的过程里面，太容易写错了，而且会让过程复杂化。
- 把板子打熟练

## luogu7727 风暴之眼（Eye of the Storm）

对于此类有着复杂定义的题目，不妨先静下心来进行一些观察。

- 首先如果一个节点是初始为 $0$ 的 $\text{AND}$ 型节点或者初始值为 $1$ 的 $\text{OR}$ 型节点，那么一定不会改变自身的颜色。称其为黑点，其他成为白点。

- 白点最多变化一次。

- 同一个初始权值白色连通块内，要么权值都变化一次，要么都不变。证明略。

- 那么一个白色连通块何时才不会改变权值呢？只需要考虑它周围的一圈黑点。如果是 $(0,\text{AND})$ 与 $(0,\text{OR})$，$(1,\text{OR})$ 与 $(1,\text{AND})$，那么右边就不会因为左边改变权值，而两个不同类型的白点 $(1,\text{AND})$ 与 $(0,\text{OR})$ 或者一黑一白是会影响对方的。因此推出一个白色连通块的权值不改变，当且仅当整个连通块以及周围的一圈黑点，权值都相同。

- 如何让一个白色连通块达到权值相同？需要满足以下两个条件之一。1. 连通块内存在一个白点，满足初始权值等于最终权值。2. 周围存在一个黑点，满足其与这个连通块的最终权值相同。

考虑用树形 DP 来做。

为了方便采用如下标记

- $p(0/1)$，黑点还是白点。
- $q(0/1)$，初始权值是否等于最终权值。
- $r(0/1)$，此时这个连通块内能否满足最终权值的条件。

每一种状态都存在吗？不然。

首先 $q$ 和 $r$ 就存在非法组合。

对于黑点，能接上它的白色连通块一定都满足最终权值的条件，且其初始权值必然等于最终权值。

对于白点，如果其初始权值等于最终权值，那么接上一个合法的白色连通块之后，必然满足最终权值条件。

因此随便钦定一个点为根，然后设 $f_{x,0/1/2/3}$ 为在以 $x$ 为根的子树中

- $p(0),q(0),r(0)$
- $p(1),q(0),r(0)$
- $p(1),q(1),r(0)$
- $p(1),q(1),r(1)$

然后考虑转移，用上上面的结论。方式是将 $x$ 的子节点 $y$ 看作是一个连通块，按照把 $y$ 接到 $x$ 上形成新的连通块来计数，同时根据 $a_x$ 与 $a_y$ 得到对应的转移方案。

开个临时数组 $g$。

对于 $x$ 和 $y \in son(x)$，如果 $a_x = a_y$

$$
g_0 = f_{x,0} \cdot (f_{y,0} + f_{y,1})
$$

$$
g_1 = f_{x,1} \cdot (f_{y,0} + f_{y,1} + f_{y,2} + f_{y,3})
$$



$$
g_2 = f_{x,2} \cdot (f_{y,1}+f_{y,2}+f_{y,3}) + f_{x,3} \cdot (f_{y,1}+f_{y,2})
$$

$$
g_3 = f_{x,3} \cdot f_{y,3}
$$





若 $a_x \neq a_y$

$$
g_0 = 0
$$

$$
g_1 = f_{x,1} \cdot (f_{y,1} + f_{y,2})
$$



$$
g_2 = f_{x,2} \cdot (f_{y,1}+f_{y,2} + f_{y,3}) + f_{x,3} \cdot (f_{y,2} + f_{y,3})
$$

$$
g_3 = f_{x,3} \cdot f_{y,1}
$$



然后

$$
f_x \leftarrow g
$$





答案是 $f_{1,0}+f_{1,1}+f_{1,2}$

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=2e5+5, mod=998244353;
int n, a[N], f[N][4], g[4];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dp(int x,int fa) {
    f[x][0]=f[x][1]=f[x][3]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        SET(g,0);
        if(a[x]==a[y]) {
            g[0]=f[x][0]*(f[y][0]+f[y][1])%mod;
            g[1]=f[x][1]*((f[y][0]+f[y][1])%mod+(f[y][2]+f[y][3])%mod)%mod;
            g[2]=(f[x][2]*(f[y][1]+f[y][2]+f[y][3])%mod+f[x][3]*(f[y][1]+f[y][2])%mod)%mod;
            g[3]=f[x][3]*f[y][3]%mod;
        } else {
            g[0]=0;
            g[1]=f[x][1]*(f[y][1]+f[y][2])%mod;
            g[2]=(f[x][2]*(f[y][1]+f[y][2]+f[y][3])%mod+f[x][3]*(f[y][2]+f[y][3])%mod)%mod;
            g[3]=f[x][3]*f[y][1]%mod;
        }
        memcpy(f[x],g,sizeof(g));
    }
}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    rep(i,1,n-1) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    dp(1,0);
    printf("%lld\n",(f[1][0]+f[1][1]+f[1][2])%mod);
}
```



- 状态间的转移应仔细推敲。
- 见到这种看起来很吓人的题目，千万不要手足无措白白浪费时间，尝试观察性质，哪怕打个暴力呢。

## luogu8973 『GROI-R1』 继续深潜，为了同一个梦想

一个点被这样的点集所包含，只有两种情况。

要么是从子树内到某个祖先的一条链，要么是端点在两个子节点的子树内，跨越这个点的一条链。

考虑一个转化，求 $ans_i$ 时，将 $i$ 钦定为根。那么前者转化为子树内到达 $i$ 的链。

设 $f_r(x)$ 为整棵树以 $r$ 为根，在以 $x$ 为根的子树内，有多少以 $x$ 为端点且满足条件的的链，其实就是在子树内除了 $x$ 选择至少一个节点的方案数。

$$
f_{r}(x) = \sum_{y \in son(x)} (2f_r(y) +1)
$$



然后考虑第二种情况，其实就是两条上述的链拼凑而成，

设 $S = f_r(x)$，$F(x) = 2f_r(x)+1$。

对于一个子节点 $y$，其贡献为 $F(y) \cdot (S-F(y)+1)$，$+1$ 是顺便把第一种情况算上。同时为了避免重复计数，计算完 $y$ 之后令 $S \leftarrow S-F(y)$。

综上，得到以 $r$ 为整棵树的根时，以 $x$ 为根的子树内的答案 $g_r(x)$。

那么如何得到所有结点的答案呢？考虑换根。

发现对于 $(x,y)$，有

$$
f_y(x) = f_x(x) - F(y)

$$

$$
f_y(y) = f_x(y) + F(x)
$$



直接求即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=5e5+5, mod=1e9+7;
int n, f[N], g[N];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
int F(int x) { return (2*f[x]%mod+1)%mod; }
void dfs(int x,int fa) {
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dfs(y,x);
        (f[x]+=2*f[y]+1)%=mod;
    }
}
void dfs2(int x,int fa) {
    int S=0;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        (S+=F(y))%=mod;
    }
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        (g[x]+=F(y)*(S-F(y)+1+mod)%mod)%=mod;
        (S-=F(y)-mod)%=mod;
    }
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        int tx=f[x], ty=f[y];
        (f[x]-=2*f[y]%mod+1-mod)%=mod;
        (f[y]+=2*f[x]%mod+1)%=mod;
        dfs2(y,x);
        f[x]=tx, f[y]=ty;
    }
}
signed main() {
    n=read();
    rep(i,1,n-1) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    dfs(1,0);
    dfs2(1,0);
    int ans=0;
    rep(i,1,n) ans^=g[i]*i;
    printf("%lld\n",ans);
}
```

## luogu8280 「MCOI-08」Photoelectric Effect

思路并不难想。考虑以 $x$ 为根的子树和其若干子节点 $\{y_i\}$。

设 $x$ 颜色为 $c_x$，对于 $y_1$ 和 $y_2$，以 $y_1$ 为根的子树中任何一个节点与 $y_2$ 子树中的任意一个节点颜色之并等于 $c_x$。那么两棵子树的颜色集合两两之并都是 $c_x$，这个可以预处理，同时也能看出子树颜色集合必须加入状态中。

从样例中能看到这个并运算不满足交换律，因此预处理时要注意如果集合 $S_1$ 与 $S_2$ 正反两种并不同，那么不合法。

考虑到颜色关系的特殊性，需要一棵一棵地加入子树来统计答案。特别的，第一棵子树不存在颜色限制。

为了避免包含等不必要的麻烦，设 $S_x$ 为以 $x$ 为根的子树中，不含 $x$ 的颜色集合。同时设 $S_1 \otimes S_2$ 表示 $S_1$ 中任意元素并上 $S_2$ 中任意元素结果为同一种颜色，且满足 $S_1 \otimes S_2 = S_1 \otimes S_1$。

设 $f_{x,i,S}$ 为以 $x$ 为根的子树，$x$ 的颜色是 $i$，其他子树内的颜色集合是 $S$ 的方案数。

考虑 $f_{y,j,S_0}$ 如何转移。

条件是 $T=S_0 \cup \{j\}$，存在 $S$ 满足 $S \otimes T = i$，贡献为

$$
f_{y,j,S_0} \cdot f_{x,i,S} \rightarrow f'_{x,i,S|T}
$$



特别地，对于 $x$ 的第一棵子树

$$
f_{y,j,S_0} \rightarrow f_{x,i,S_0 \cup \{j\}}
$$





复杂度 $O(nk2^{2k})$

相当恐怖，不过剪掉无用状态后就跑不满，可过。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=1e5+5, mod=1e9+7;
int T, n, k, U, son[N], t[5][5], p[32][32], f[N][5][32], g[5][32];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
int get(int x,int y) {
    int res=-2;
    rep(i,0,k-1) if(x&(1<<i)) {
        rep(j,0,k-1) if(y&(1<<j)) {
            if(res==-2) res=t[i][j];
            else if(res!=t[i][j]) res=-1;
        }
    }
    swap(x,y);
    rep(i,0,k-1) if(x&(1<<i)) {
        rep(j,0,k-1) if(y&(1<<j)) {
            if(res==-2) res=t[i][j];
            else if(res!=t[i][j]) res=-1;
        }
    }
    return res;
}
void dp(int x,int fa) {
    if(!son[x]) {
        rep(i,0,k-1) f[x][i][0]=1;
        return;
    }
    int fg=0;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        if(!fg) {
            rep(nw,0,k-1) rep(S,0,U) rep(w,0,k-1) {
                (f[x][nw][S|(1<<w)]+=f[y][w][S])%=mod;
            }
            fg=1;
            continue;
        }
        rep(nw,0,k-1) rep(S,1,U) g[nw][S]=0;
        rep(nw,0,k-1) rep(S0,0,U) if(f[y][nw][S0]) rep(S,1,U) {
            int T=S0|(1<<nw);
            if(p[S][T]==-1) continue;
            (g[p[S][T]][S|T]+=f[x][p[S][T]][S]*f[y][nw][S0]%mod)%=mod;
        }
        memcpy(f[x],g,sizeof(g));
    }
}
void solve() {
    n=read(), k=read();
    U=(1<<k)-1;
    tot=0;
    rep(i,1,n) {
        h[i]=son[i]=0;
        SET(f[i],0);
    }
    SET(p,-1);
    rep(i,0,k-1) rep(j,0,k-1) {
        int x=read()-1;
        t[i][j]=x;
    }
    rep(i,2,n) {
        int x=read();
        ++son[x];
        add(x,i), add(i,x);
    }
    rep(i,1,U) rep(j,1,U) p[i][j]=get(i,j);
    dp(1,0);
    int ans=0;
    rep(i,0,k-1) rep(j,0,U) (ans+=f[1][i][j])%=mod;
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
}
```



- 状态压缩，优先使用刷表法
- **考虑再三后再预处理**
- **预处理时一定不要把初始状态设成无解状态**
- 加入子树的计数思路
- 一开始竟然设 $S_x$ 为以 $x$ 为根的子树的所有颜色，导致很多麻烦且干扰思路与转移。

最后附上我一开始写的 SB 预处理。

之前也在预处理上吃过亏啊，以后要多加小心。

```cpp
void init() {
    rep(i,1,U) rep(j,1,U) if(p[i][j]<0) {
        int kk=-1;
        // 从头开始就错了
        rep(k1,0,4) if(i&(1<<k1)) {
            int q=-1;
            rep(k2,0,4) if(j&(1<<k2)) {
                if(q==-1) q=p[k1][k2];
                else if(q!=p[k1][k2]) { kk=-1; goto pq; }
            }
            if(kk==-1) kk=q;
            else if(kk!=q) { kk=-1; break; }
        }
        pq: p[i][j]=kk;
    }
    rep(i,1,U) rep(j,1,U) if(p[i][j]!=p[j][i]) p[i][j]=p[j][i]=-1;
}
```



## luogu3349 [ZJOI2016]小星星

题意比较裸。

设 $f_{x,i,G_0}$ 为以 $x$ 为根的子树，节点 $x$ 映射到原图中的 $i$，此时子树内映射到图中的节点集合为 $G_0$ 的方案数。

转移则遇到了困难，首先复杂度就很高了，其次 $G_0$ 这一维的转移要把 $G_0$ 不重不漏地划分成 $x$ 的子节点个数个非空子集，也就是一个子集卷积。

考虑困难的来源是「每个节点只能映射一次」这个限制导致了必须记录 $G_0$。不难发现只要有节点映射了超过一次，那么一定有节点没有被映射，这个是可以容斥的。

考虑枚举集合 $S' \subseteq S$，其中 $S$ 是节点集合，表示不能映射 $S'$ 中的节点，进行最原始的集合间的容斥即可。

考虑此时如何求方案数。设 $f_{x,i}$ 表示以 $x$ 为根的子树，节点 $x$ 映射到了图中节点 $i$ 的方案数，容易写出

$$
f_{x,i} = \prod_{y \in son(x)} \sum_{(i,j) \in G} f_{y,j}
$$



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
const int N=20;
int n, m, U, S, popcnt[1<<17];
int lg[1<<17];
int tot, h[N], to[N*N], nxt[N*N];
int t2, h2[N], to2[N*N], nxt2[N*N];
uint ans, f[N][N];
int lowbit(int x) { return x&-x; }
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void add2(int x,int y) {
    to2[++t2]=y, nxt2[t2]=h2[x], h2[x]=t2;
}
void dp(int x,int fa) {
    for(int i=h2[x];i;i=nxt2[i]) {
        int y=to2[i];
        if(y==fa) continue;
        dp(y,x);
    }
    for(int T=S^U;T;T-=lowbit(T)) {
        int a=lg[lowbit(T)];
        f[x][a]=1;
        for(int i=h2[x];i;i=nxt2[i]) {
            int y=to2[i];
            if(y==fa) continue;
            int dlt=0;
            for(int j=h[a];j;j=nxt[j]) dlt+=f[y][to[j]];
            f[x][a]*=dlt;
        }
    }
}
signed main() {
    n=read(), m=read();
    U=(1<<n)-1;
    rep(i,1,m) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    lg[1]=1;
    rep(i,1,n-1) {
        int x=read(), y=read();
        add2(x,y), add2(y,x);
        lg[1<<i]=i+1;
    }
    for(S=0;S<=U;++S) {
        popcnt[S]=popcnt[S>>1]+(S&1);
        int ss=0;
        rep(i,1,n) rep(j,1,n) f[i][j]=0; 
        dp(1,0);
        for(int i=S^U;i;i-=lowbit(i)) ss+=f[1][lg[lowbit(i)]];
        if(popcnt[S]&1) ans-=ss; else ans+=ss;
    }
    printf("%llu\n",ans);
}

```



&nbsp;

树形背包。

用来解决树形 DP 中，子树之间会互相影响的转移。具体方法是先依次合并各子树信息，再处理根的影响。

为什么是「类」树形背包？因为此类题目一般没有给出作为背包容积的上界，因此必须用当前子树大小卡好复杂度，否则会退化。

因此，在实现上是需要注意的。

## ABC287F Components

> 给定一棵树 $T=(V,E)$，求对于 $x=1,2,\ldots,n$，所有 $V$ 的子集与 $E$ 构成的图中，恰好有 $x$ 个连通块的方案数。对 $998244353$ 取模。 
> 
> $n \le 5000$

考虑在各子树的父节点处统计贡献。

设 $f_{x,i,0/1}$ 表示以 $x$ 为根的子树，每个节点可选可不选，恰好存在 $i$ 个连通块，其中 $x$ 有没有被选择的方案数。

用类似树形背包的方式转移，好处是可以容易考虑一棵子树对其它子树的影响。

如果 $x$ 不选择，那么对于子节点 $y$，其

选不选都不收影响，因此

$$

$$





如果 $x$ 选择，那么如果 $y$ 选择了，就会减少一个连通块

$$
f_{x,j,1} \cdot (f_{y,k,0}+f_{y,k+1,1}) \rightarrow g_{j+k,1}
$$





```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=5005, mod=998244353;
int n, sz[N], f[N][N][2], g[N][2];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dp(int x,int fa) {
    sz[x]=f[x][0][0]=f[x][1][1]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        SET(g,0);

            for(int j=0;j<=sz[x];++j)  for(int k=0;k<=sz[y];++k) {
                (g[j+k][0]+=f[x][j][0]*((f[y][k][0]+f[y][k][1])%mod)%mod)%=mod;
                (g[j+k][1]+=f[x][j][1]*((f[y][k][0]+f[y][k+1][1])%mod)%mod)%=mod;
        }
        rep(j,0,sz[x]+sz[y]) f[x][j][0]=g[j][0], f[x][j][1]=g[j][1];
        sz[x]+=sz[y]; 
    }
}
signed main() {
    n=read();
    rep(i,1,n-1) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    dp(1,0);
    rep(i,1,n) printf("%lld\n",(f[1][i][0]+f[1][i][1])%mod);
}
```

## luogu8564 ρars/ey

容易设出状态，$f_{x,i}$ 表示以 $x$ 为根的子树，还剩下 $i$ 个节点，所需要的最小代价。

把转移过程分为两部分，一部分从子树处继承没有被删去的节点数量，另一部分从 $x$ 处删点。

设当前加入了 $cnt$ 棵子树，那么在合并子树的过程中，最少剩下 $cnt+1$ 个节点，这个下界会不断改变，因此要不断更新相应的信息。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=5005, inf=0x3f3f3f3f3f3f3f3f;
int n, a[N], sz[N], f[N][N], g[N];
int tot, h[N], to[2*N], nxt[2*N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
    add(x,y), add(y,x);
}
void dp(int x,int fa) {
    sz[x]=1, f[x][1]=0;
    int cnt=0;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        for(int j=cnt+1;j<=sz[x];++j)
            for(int k=1;k<=sz[y];++k)
                g[j+k]=min(g[j+k],f[x][j]+f[y][k]);
        ++cnt, sz[x]+=sz[y];
        f[x][cnt]=inf;
        for(int j=cnt+1;j<=sz[x];++j) f[x][j]=g[j], g[j]=inf;
    }
    f[x][1]=a[sz[x]];
    for(int k=cnt+1;k<=sz[x];++k) f[x][1]=min(f[x][1],f[x][k]+a[k]);
}
signed main() {
    n=read();
    for(int i=2;i<=n;++i) a[i]=read();
    for(int i=1;i<n;++i) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    SET(g,0x3f);
    dp(1,0);
    printf("%lld\n",f[1][1]);
}
```

## luogu6478 [NOI Online #2 提高组] 游戏

如果出现了平局，那么一定是两个点在以它们的 $lca$ 为根的，不同的子树中。

在树形 DP 中合并信息是容易的。

设 $f_{x,i}$ 为以 $x$ 为根的子树，有 $i$ 个回合没有平的方案数。

合并完子树的过程中，统计出子树内每种颜色的点的数量，然后只要选择和 $x$ 颜色相反的就能让非平局回合数量加 $1$。

但是这样得到的是整棵树中，至少有 $i$ 个非平局回合的方案数。所以套一个二项式反演即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=5005, mod=998244353;
int n, m, a[N], sz[N], c[N][2], F[N], G[N], f[N][N], g[N], fac[N], inv[N];
int tot, h[N], to[N<<1], nxt[N<<1];
char s[N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dp(int x,int fa) {
    ++c[x][a[x]], f[x][0]=sz[x]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        for(int j=0;j<=sz[x]+sz[y];++j) g[j]=0;
        for(int j=0;j<=sz[x];++j)
            for(int k=0;k<=sz[y];++k) (g[j+k]+=f[x][j]*f[y][k]%mod)%=mod;
        sz[x]+=sz[y];
        for(int j=0;j<=sz[x];++j) f[x][j]=g[j];
        c[x][0]+=c[y][0], c[x][1]+=c[y][1];
    }
    for(int i=c[x][a[x]^1];~i;--i) (f[x][i]+=f[x][i-1]*(c[x][a[x]^1]-(i-1))%mod)%=mod;
}
int C(int n,int m) {
    if(n<m) return 0;
    return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void init() {
    fac[0]=inv[0]=1;
    rep(i,1,m) fac[i]=fac[i-1]*i%mod;
    inv[m]=fp(fac[m],mod-2);
    per(i,m-1,1) inv[i]=inv[i+1]*(i+1)%mod;
}
signed main() {
    n=read();
    m=n>>1;
    scanf("%s",s+1);
    rep(i,1,n-1) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    rep(i,1,n) a[i]=s[i]-'0';
    dp(1,0);
    init();
    rep(i,0,m) G[i]=f[1][i]*fac[m-i]%mod;
    rep(i,0,m) rep(j,i,m) {
        int c=((j-i)&1)? -1:1;
        (F[i]+=c*C(j,i)%mod*G[j]%mod)%=mod;
        if(F[i]<0) F[i]+=mod;
    }
    rep(i,0,m) printf("%lld\n",F[i]);
}
```
