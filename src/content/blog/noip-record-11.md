---
title: 「NOIP Record」#11 最短路和最小生成树
pubDate: 2023-08-04
tags:
  - 图论
  - 最短路
  - DP
  - 生成树
  - 贪心
  - Trie
categories:
  - Record
description: '少年感受到小路的厚实'
---

图论这一块内容比较多，而且题目涉及的 Trick 也很多，因此分若干篇。

本文略去所有算法本身性质的证明过程。

## 最短路

### Dijkstra和SPFA

$\text{Dijkstra}$ 算法基于一个重要的性质：全局最小值不可能再被任何边更新。这样，在边权为非负数的最短路问题中显然满足，在存在负边时不满足。同时，保证了最多从每个节点处扩展 $1$ 次，从而有了稳定的复杂度。

这也限制了 $\text{Dijkstra}$ 在转移 DP 时的应用。

在某经典问题中，设 $f(x)$ 表示 $1$ 到 $x$ 的最小点权。全局最小值是可能在更新的过程中变小的，具体方法是绕一圈再经过权值更小的点。这种情况下只能用 SPFA 进行转移。

再来看另一个经典问题。

#### luogu4042 [AHOI2014/JSOI2014] 骑士游戏

设 $f(x)$ 为杀死怪物 $x$ 以及其他衍生物的最小代价。
$$
f(x) = \min \Big\{ K_x, S_x+\sum_{y \in to(x)} f(y) \Big\}
$$
这玩意有后效性。

当前全局最小值也是有可能会随着更新而变小的，因此不能使用 $\text{Dijkstra}$ 算法，必须使用 SPFA。在更新完 $f(x)$ 之后，把所有能生成  $x$ 的点都扔到队列里面去更新。复杂度爆炸，但好在是 14 年的题，不会卡 SPFA。

好像做完了。

然而，真的不满足吗？

如果一个 $f(x)$ 在更新其他点的时候把自己更新成更小的值，那么说明杀死中间那些怪物的代价为负数，这是不合理的，因此本题满足 $\text{Dijkstra}$ 的贪心性质。这也说明了，当一个点的代价确定时，就一定是其最优解。

因此本题的正解如下。

任何一个点的最终代价都依赖于它所生成的那些点，因此建一张反图，把所有点都扔到堆里面，初始值就是用魔法攻击干死的代价。

有了贪心性质，我们并不需要无脑迭代。每次取出全局最小值并扩展更新。对于一个 $x$，当它被 $to(x)$ 中的每一个点都更新之后，就能得到 $S_x + \sum_{y \in to(x)} f(y)$，与 $K_x$ 取较小值就能得到最小代价。

这样做的复杂度就是 $O\Big((n+\sum_{i=1}^n R_i) \log_2 (\sum_{i=1}^n R_i )\Big)$。

```cpp
// Problem: P4042 [AHOI2014/JSOI2014] 骑士游戏
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P4042
// Author: yozora0908
// Memory Limit: 125 MB
// Time Limit: 1000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=2e5+5;
int n, c[N], d[N], to[N];
vector<int> p[N];
bool v[N];
void dijkstra() {
    priority_queue<PII > q;
    rep(i,1,n) q.push({-d[i],i});
    while(q.size()) {
        int x=q.top().se; q.pop();
        if(v[x]) continue;
        v[x]=1;
        for(auto y:p[x]) {
            c[y]+=d[x];
            if(--to[y]==0) {
                if(d[y]>c[y]) {
                    d[y]=c[y];
                    q.push({-d[y],y});
                }
            }
        }
    }
}
signed main() {
    n=read();
    rep(x,1,n) {
        c[x]=read(), d[x]=read();
        int cnt=read();
        while(cnt--) {
            int y=read();
            p[y].pb(x);
            ++to[x];
        }
    }
    dijkstra();
    printf("%lld\n",d[1]);
    return 0;
}
```



#### luogu4745 [CERC2017] Gambling Guide

题目中要求最小化期望，指的是在有优劣之分的决策中，选择最优决策。

设 $f(x)$ 为从 $x$ 到 $n$ 的最小期望，有


$$
f(x) = 1 + \frac{1}{\operatorname{deg}_x}\sum_{(x,y) \in E} \min\Big(f(x),f(y)\Big)
$$




这个取 $\min$ 操作很麻烦。考虑 $f(y)$ 对 $f(x)$ 有贡献，一定有 $f(y) < f(x)$。因此，考虑按照期望代价确定每个点的答案，第一次只能确定 $f(n) = 0$。



设满足 $S_x$ 表示 $x$ 的相邻节点中，已经确定代价的点集，那么就有



$$
f'(x) = 1 + \Big(1-\frac{|S_x|}{\operatorname{deg}_x} \Big) f_x + \frac{1}{\operatorname{deg}_x} \sum_{y \in S_x} f(y)
$$





$$
f'(x) = \frac{\operatorname{deg}_x + \sum_{y \in S_x} f(y)}{|S_x|}
$$

最终的 $f(x)$ 就是 $\min \{ f'(x) \}$。

这样就能在图上迭代了，具体做法是取出一个确定了的 $f(x)$，令 $|S_y| := |S_y|+1$，然后那个和式加上 $f(x)$，就能计算出 $f'(y)$。

考虑一个全局最小的 $f(x)$ 更新了 $f(y)$ 得到 $f'(y)$，带入式子中可以有 $f(x) < f'(y) < f(y)$，具体过程略。

用 $\text{Dijkstra}$ 转移。

```cpp
// Problem: P4745 [CERC2017] Gambling Guide
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P4745
// Author: yozora0908
// Memory Limit: 500 MB
// Time Limit: 3000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=3e5+5;
const double eps=1e-6;
int n, m, c[N], v[N];
double f[N], g[N];
vector<int> p[N];
void dijkstra() {
    rep(i,1,n) f[i]=1e10;
    priority_queue<pair<double,int> > q;
    f[n]=0;
    q.push({0.0,n});
    while(q.size()) {
        int x=q.top().se; q.pop();
        if(v[x]) continue;
        v[x]=1;
        for(auto y:p[x]) if(!v[y]) {
            ++c[y];
            g[y]+=f[x];
            if(f[y]>(p[y].size()+g[y])/c[y]) {
                f[y]=(p[y].size()+g[y])/c[y];
                q.push({-f[y],y});
            }
        }
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);                                                            
    }
    dijkstra();
    printf("%.10lf\n",f[1]);
    return 0;
}
```



再提供一道关于 $\text{Dijkstra}$ 算法的贪心性质的题目。

> $n$ 点 $m$ 边的图，边权值域是 $[0,10^9]$。求从每个点出发前 $k$ 近的点。
> 
> $n \le 10^5$，$m \le \min(\frac{n(n-1)}{2},3 \times 10^5)$，$k \le 16$。

由于 $\text{Dijkstra}$ 算法取出的是全局最小值，所以对于每个点，只要取出 $k$ 个点扩展即可。而显然从每个点出发最多有 $k$ 条边有用，所以这样直接做就行了，复杂度 $O(nk^2 \log_2 k^2)$。

注意清空数组的细节，否则复杂度就假了。

```cpp
void dijkstra(int s) {
    bool lst=0;
    priority_queue<pair<int,int> > q;
    d[s]=0, q.push({0,s});
//    puts("doit");
    for(int w=0;w<=k;++w) {
        while(v[q.top().second]) q.pop();
        int x=q.top().second;
        v[x]=1, link[w]=x;
        for(auto i:p[x]) {
            int y=i.second, z=i.first;
            if(d[y]>d[x]+z) {
                d[y]=d[x]+z;
                q.push({-d[y],y});
            }
        }
        if(w) {
            if(lst) printf(" ");
            lst=1;
            printf("%lld",d[x]);
        }
    }
    for(int w=0;w<=k;++w) {
        v[link[w]]=0, d[link[w]]=1e15;
        for(auto y:p[link[w]]) d[y.second]=1e15;
    }
}
```



### 0-1 BFS及其扩展

在边权只有 $0$ 和 $1$ 的图上，我们可以用 0-1 BFS 在 $O(n+m)$ 的时间里求解单源最短路。其原理是在普通队列中，维护队首的元素是全局最小值。可以当作一个退化了的 $\text{Dijkstra}$ 算法来理解。

扩展：边权为 $0,1,2,\cdots, w$ 时怎么做？

依然是维护单调性。开 $w+1$ 个队列，当更新完 $dis(y) = dis(x)+ z$ 时，将 $dis(y)$ 扔到第 $z$ 个队列里。由于每次取出的 $dis(x)$ 单调不降，所以每个队列内部的大小都是单调的。

贪心从权值小的队列取点即可。

### 最短路树

```cpp
for(int i=h[x];i;i=nxt[i]) {
    int y=to[i], z=w[i];
    if(d[y]>d[x]+z) {
        d[y]=d[x]+z, pre[y]=i;
        // pre[y]就是最短路树上x与y之间的边
        q.push({-d[y],y}); 
    }
}
```

性质就像它的名字，源点到每个点的最短路径构成的一棵树。

### 次短路

维护两个数组`dis1[]`和`dis2[]`。如果用当前点更新了到另一个点的最短路，那么把那个点的最短路和次短路都扔进堆里（因为二者都被更新过了）；如果只更新了另一个点的次短路，那么把次短路扔进堆里。

一个节点可能会更新和被更新多次，为了避免复杂度退化，要判断当前取出的节点对应的最短路长度，是否是最短路或次短路之一，或者说判断长度是否已经大于了次短路。

从网上找了份代码。

```cpp
void dijkstra()
{
    for(re int i=1;i<=n;i++) dis1[i]=dis2[i]=1e9;
    dis1[1]=0; q.push((node){0,1});
    while(!q.empty())
    {
        int dt,pt;
        dt=q.top().d; pt=q.top().p; q.pop();
        if(dt!=dis1[pt]&&dt!=dis2[pt]) continue;
        // if(dt>dis2[pt])
        for(re int i=last[pt];i;i=e[i].next)
        {
            int v=e[i].to; int dis=dt+e[i].val;
            if(dis<dis1[v])
            {
                dis2[v]=dis1[v]; dis1[v]=dis;
                q.push((node){dis1[v],v}); 
                q.push((node){dis2[v],v});
            }else
            if(dis>dis1[v]&&dis<dis2[v])
            {
                dis2[v]=dis;
                q.push((node){dis2[v],v});
            }
        }
    }
}
```



### 某道题

> 有向图，求从 $1$ 到 $n$ 必须经过第 $i$ 个点的最短路以及必须经过第 $j$ 条边的最短路。

以 $1$ 为源点，跑最短路。以 $n$ 为源点，在反图上跑最短路。

### luogu5304 [GXOI/GZOI2019] 旅行者

从超级源点向 $k$ 个关键点都连 $0$ 边，求出 $dis_0(x)$，记录到达每个节点距离最小的关键点 $c_0(x)$。然后建反图再跑一次得到 $dis_1(x)$ 和  $c_1(x)$。

这样如果一条边 $(x,y,z)$ 满足 $c_0(x) \neq c_1(y)$，那么说明从 $c_0(x)$ 到 $x$ 的路径与 $c_1(y)$ 到 $y$ 无交，从而 $dis_0(x)+z+dis_1(y)$ 可以作为一个决策。

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
const int N=1e5+5, M=5e5+5, inf=1e15;
int T, n, m, k, a[N], col[2][N], dis[2][N];
int X[M], Y[M], Z[M];
bool v[N];
struct G {
    int tot, h[N], to[M], nxt[M], w[M];
    void add(int x,int y,int z) {
        to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
    }
    void clear() {
        tot=0;
        rep(i,1,n) h[i]=0;
    }
} G;
void dijkstra(int* d,int* c) {
    rep(i,1,n) v[i]=c[i]=0, d[i]=inf;
    priority_queue<PII > q;
    rep(i,1,k) d[a[i]]=0, c[a[i]]=a[i], q.push({0,a[i]});
    while(q.size()) {
        int x=q.top().se; q.pop();
        if(v[x]) continue;
        v[x]=1;
        for(int i=G.h[x];i;i=G.nxt[i]) {
            int y=G.to[i], z=G.w[i];
            if(d[y]>d[x]+z) {
                d[y]=d[x]+z;
                c[y]=c[x];
                q.push({-d[y],y});
            }
        }
    }
}
void solve() {
    n=read(), m=read(), k=read();

    rep(i,1,m) {
        X[i]=read(), Y[i]=read(), Z[i]=read();
        if(X[i]!=Y[i]) G.add(X[i],Y[i],Z[i]);
    }
    rep(i,1,k) a[i]=read();
    dijkstra(dis[0],col[0]);
    G.clear();
    rep(i,1,m) if(X[i]!=Y[i]) G.add(Y[i],X[i],Z[i]);
    dijkstra(dis[1],col[1]);
    G.clear();
    int ans=1e15;
    rep(i,1,m) {
        int x=X[i], y=Y[i], z=Z[i];
        if(col[0][x]&&col[1][y]&&col[0][x]!=col[1][y])
            ans=min(ans,dis[0][x]+dis[1][y]+z);
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

不过这样的做法可能不是很好想到，所以有一种更劣但是思路更自然的做法，

如果我们使用超级源点和超级汇点，那么能够解决两个集合之间两两最短路的最小值，但是无法解决这个问题。如果我们有一种划分关键点的方式，使得划分若干次后任意两个点一定有至少一次不在同一个集合，就能做了。

考虑二进制分组。考虑二进制的每一位，把这一位是 $0$ 的与 $S$ 相连，否则与 $T$ 相连，跑最短路。这样每次划分的两个集合都无交，并且满足任意两个关键点至少出现在一个不同的集合中。

这 $O(\log_2 2\times 10^9)$ 次最短路中，从 $S$ 到 $T$ 的最短路的最小值就是答案。

### luogu7473 [NOI Online 2021 入门组] 重力球

在经过至少一次操作之后，小球一定贴着墙壁或者障碍，也就是有用的状态数量只有 $O(n+m)$。

把有用的状态搞出来，建反边 $\text{BFS}$ 出 $dis(x,y)$ 表示状态 $x$ 与 $y$ 的两个小球，到达同一个点的最小步数。

对于一个询问，枚举第一步的操作，然后取最小值即可。

貌似代码有点难写。

### 某道题

> $n$ 点 $m$ 边一张图，定义一条包含 $l$ 条边的路径的长度为 $\max_{i=1}^l \{ i \times w_i \}$，求 $1$ 到 $n$ 的最短路。
> 
> $n,m \le 3 \times 10^5$。

二分最短路长度 $mid$，则第 $i$ 条经过的边长度不超过 $mid / i$，这样就变成了一个可达性问题，BFS 即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
const int N=3e5+5;
int n, m, d[N];
int tot, h[N], to[N], nxt[N], w[N];
void add(int x,int y,int z) {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
int bfs(int D) {
    memset(d,-1,(n+1)<<3);
    queue<pair<int,int> > q;
    q.push({1,0});
    d[1]=0;
    while(q.size()) {
        pair<int,int> p=q.front(); q.pop();
        int x=p.first, dd=p.second;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i], z=w[i];
            if(z*(dd+1)<=D&&d[y]==-1) {
                d[y]=d[x]+1;
                q.push({y,dd+1});
            }
        }
    }
    if(d[n]!=-1) return 1;
    else return 0;
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read(), z=read();
        add(x,y,z);
    }
    int l=1, r=1e13;
    while(l<r) {
        int mid=(l+r)>>1;
        if(bfs(mid)) r=mid; else l=mid+1;
    }
    printf("%lld\n",l);
}
```

### luogu2446 [SDOI2010] 大陆争霸

设 $dis(x)$ 为到达节点 $x$ 的最短时间，$des(x)$ 为摧毁 $x$ 的最小时间。

然后 $des(x) = \max_{y \in protect(x)} \{ dis(y)\}$。

在完成对 $x$ 节点的扩展后去更新被 $x$ 保护的节点。一个节点在被求出 $des(x)$ 后再次入堆，这样 $des(n)$ 即为答案。

### luogu5663 [CSP-J2019] 加工零件

我们很容易做 $n$ 很小，$m$ 很大的问题，并且容易得到方案数。

然而那个做法和本题没有任何关系。既然本题只关心是否存在，那么不妨做个转化。任何 $1$ 到 $x$ 经过 $L$ 条边的路径，都能转化成走最短路，然后再一条边上左右横跳的路径。从奇偶性处下手即可证明。

那么求出从 $1$ 到 $x$ 经过奇数条边和偶数条边的最短路就能判断。

怎么做？一个点拆成奇点和偶点。

### CF938D Buy a Ticket

建立超级源点 $S$，从 $S$ 往 $i$ 连权值为 $a_i$ 的有向边，然后把原图中的边权都乘 $2$，这样到达 $i$ 点的最短路就是 $i$ 点的答案。

### CF1483D Useful Edges

必经边。

记 $(u,v,l)$ 为 $a(u,v)=l$。

$(x,y,z)$ 满足条件就是看是否存在 $(i,j)$ 满足
$$
dis(i,x)+z+dis(y,j) \le a(i,j)
$$
直接做是 $O(n^4)$ 的。

设 $b(y,i) = \max \{ a(i,j)-dis(y,j) \}$，于是就是
$$
dis(i,x) + z \le b(y,i)
$$
这样就是 $O(n^3)$ 的。

### luogu4366 [Code+#4] 最短路

就一个点。

事实上我们只需要保留 $(i \oplus j) = 2^k,k \in [0,\log_2n]$ 的边。

把 $(i \oplus j)$ 拆成若干二进制位上的 $1$，一个一个地走。这样做的权值依然是不变的。





## 差分约束系统

分为两种。

1. 求最大值。
   把式子整理为 $X_i - X_j \le k$，连边 $(j \rightarrow i)$，权值为 $k$，跑最短路。有负环无解。

2. 求最小值。
   把式子整理为 $X_i -X_j \ge k$，连边 $(j \rightarrow i)$，权值为 $k$，跑最长路。有正环无解。

如果关系要求相等，那么就是 $X_i - X_j \le k \wedge X_i - X_j \ge k$。

一般直接连出的图都不连通，所以需要虚拟源点，同时也可以起到各个变量限制初始值的作用。

### 某经典题。

> 现在有 $[1,m] \cap \mathbb{Z}$ 中的数，有 $n$ 个限制，第 $i$ 个限制表示 $[a_i,b_i]$ 中至少要取 $c_i$ 个数。
> 
> 求至少需要多少个整数。

限制转化为 $[1,b_i]$ 中取数的数量至少比 $[1,a_i-1]$ 中多 $c_i$，因此 $X_{b_i} - X_{a_i -1} \ge c_i$。

直接跑差分约束系统也不对，因为还有隐式的限制，$X_a \le X_{a+1} \le X_a + 1$。

还有一个问题，如果以 $1$ 为起点跑，那么应该有 $X_1 = 0$，实际上并不是。因此必须要有一个虚拟点 $s$，满足限制 $0 \le X_1 - X_S \le 1$。

### luogu3275 [SCOI2011] 糖果

关于 SPFA，它死了。

差分约束建模之后，为了保证连通并且每个变量都是正整数，还要建立超级源点  $S$，满足关系 $X_S - X_i \ge 1$。

然后 SPFA 就被卡掉了。

整张图的权值只有 $0$ 和 $1$。在一个 SCC 里面，如果 $(x \rightarrow y)$ 权值是 $1$，那么就一定存在一个正环，从而差分约束系统无解。再考虑 SCC 的性质，能发现一个 SCC 中的点的取值都是相等的。缩点后求 DAG 最长路即可。





## 最小生成树




一张图的一棵最小生成树，也是这张图的一棵瓶颈生成树。


说人话就是对于任意点对 $(x,y)$，其最小生成树上的路径上的最大边权，就是原图二者所有路径中，最大边权最小的路径所对应的最大边权。

&nbsp;

次小生成树（无论严格与否）一定是在最小生成树的基础上更改一条边。

对于任何不在最小生成树中的边，该边两个端点在最小生成树上的路径的
所有边的权值都小于等于该边。


所以严格次小生成树怎么做呢？枚举换进去非树边 $(x,y,z)$，然后在形成的那个环上找到最大值 $z_1$ 和严格次大值 $z_2$。如果  $z_1 \neq z$，那么换掉 $z_1$，否则换掉 $z_2$。

树上倍增即可。

不要求严格次小的话，只求最大值即可。

### luogu1991 无线通讯网

不妨先确定 $D$，再选点。能发现只有当  $D$ 确定之后，连通块数量不超过 $S$ 时才有解。

问题转化为求出把一张完全图划分成不超过 $S$ 个连通块，使得最大边权最小。

在 $\text{Kruskal}$ 的过程中，当整张图被合并为恰好 $S$ 个连通块时，最后加入的边权就是最优的 $D$。

或者说用 $\text{Prim}$ 算法，可以做到 $O(n^2)$，最后对 $d$ 数组排序即可。

### CF76A Gift

先按照 $g_i$ 递增排序，枚举 $\max\{g_i\}$，这样问题就变成了维护只使用 $[1,i]$ 中的边的生成树。

我们直接暴力加入这条边，排序后做最小生成树（其实要求出的是瓶颈生成树）最小化 $\max\{s_i\}$。

这样做的复杂度是 $O(NM\log_2 M)$，有点大。

不过考虑到每次做完最小生成树后，剩下的边都是有序的，并且新的最小生成树也不会加入上一次没有加入的边，所以可以手动做一次冒泡排序，使得集合内边的 $s_i$ 有序，这样做就是 $O(NM)$ 了。

```cpp
// Problem: A. Gift
// Contest: Codeforces - All-Ukrainian School Olympiad in Informatics
// URL: https://codeforces.com/problemset/problem/76/A
// Author: yozora0908
// Memory Limit: 256 MB
// Time Limit: 2000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=205, M=50005;
int n, m, G, S, cnt, ans=5e18;
struct Edge {
    int x, y, g, s;
} a[M], b[N];
bool operator<(Edge a,Edge b) {
    return a.g<b.g;
}
struct Dsu {
    int f[N];
    void init() { rep(i,1,n) f[i]=i; }
    int get(int x) { return x==f[x]? x:f[x]=get(f[x]); }

} dsu;

signed main() {
    n=read(), m=read(), G=read(), S=read();
    rep(i,1,m) {
        a[i].x=read(), a[i].y=read(), a[i].g=read(), a[i].s=read();
    }
    sort(a+1,a+m+1);
    rep(i,1,m) {
        b[++cnt]=a[i];
        per(j,cnt,2) if(b[j].s<b[j-1].s) swap(b[j],b[j-1]);
        dsu.init();
        int pos=0, maxs=0;
        rep(j,1,cnt) {
            int x=b[j].x, y=b[j].y;
            x=dsu.get(x), y=dsu.get(y);
            if(x!=y) {
                dsu.f[x]=y, b[++pos]=b[j];
                if(pos==n-1) break;
            }
        }
        if(pos==n-1) ans=min(ans,G*a[i].g+S*b[pos].s);
        cnt=pos;
    }
    printf("%lld\n",(ans==5e18? -1:ans));
    return 0;
}
```

### CF1468J Road Reform

先求出最小生成树。

如果 MST 中的存在权值大于 $k$ 的边，那么把这些边调整了一定是最优的。根据上文结论即可证明。

如果 MST 中的边权值小于 $k$ 呢？直接将最大边与 $\min_{(x,y,z) \in G}\{ |z_i - k|\}$ 替换一下就好了。

### CF1245D Shichikuji and Power Grid

建立超级源点 $S$，向 $i$ 连权值为 $c_i$ 的无向边。

求出 MST 即为答案。

使用 $\text{Prim}$ 算法更优。

### CF888G Xor-MST

考虑 $\text{Boruvka}$ 算法。

简介一下它的流程：

> 对于每一个连通块，枚举其出边。取其最小出边，合并两个连通块。
> 
> 每次做完一轮后连通块数量至少减半，最多重复 $O(\log_2 n)$ 次，所以复杂度就是 $O\Big((n+m) \log_2 n\Big)$。

考虑把所有 $a_i$ 都扔到 0-1 Trie 中去，这样每个叶子节点就对应这原图中一个点。

我们一定是贪心连权值小的边,对应的在 Trie 上，一个点集的 $\operatorname{LCA}$ 深度越大，它们之间的边权越小。根据 $\text{B}$ 姓算法，我们能知道一定是一棵子树内所有的叶子节点连成一个连通块后，再向外扩展。所以 0-1 Trie 就是这张完全图对于 $\text{B}$ 姓算法的分治树。

在 Trie 上 $\text{DFS}$，设`dfs(x,dep)`表示把深度为 $dep$ 的节点 $x$ 子树内，所有叶子节点连成一个连通块的最小代价。

如果存在 $son_0(x)$ 与 $son_1(x)$，那么就枚举其中一个儿子对应的 $a_i$，在另一个儿子得子树内查询最小异或值即可，记这个值为 $res$，答案就是它再加上往分别往两个儿子搜的代价。这个枚举的过程可以启发式合并进行优化。不过如果我们按照 $a_i$ 递增的顺序插入 Trie，那么每个节点对应的 $a_i$ 得下标都是连续的区间，这样直接枚举就够了。

否则就直接继承存在的那个儿子的值即可。

如果存在两个点权值相同怎么办？在完全图中，它们算是等价类。

```cpp
// Problem: G. Xor-MST
// Contest: Codeforces - Educational Codeforces Round 32
// URL: https://codeforces.com/problemset/problem/888/G
// Author: yozora0908
// Memory Limit: 256 MB
// Time Limit: 2000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=2e5+5;
int n, a[N];
struct Trie {
    int tot=1;
    int trie[N*30][2], l[N*30], r[N*30];
    void insert(int S,int id) {
        int x=1;
        for(int i=29;~i;--i) {
            int a=(S>>i)&1;
            if(!l[x]) l[x]=id;
            r[x]=max(r[x],id);
            if(!trie[x][a]) trie[x][a]=++tot;
            x=trie[x][a];
        }
    }
    int query(int x,int S,int dep) {
        int res=0;
        if(dep<0) return res;
        for(int i=dep;~i;--i) {
            int a=(S>>i)&1;
            if(!trie[x][a]) x=trie[x][a^1], res+=(1<<i);
            else x=trie[x][a];
        }
        return res;
    }
    int dfs(int x,int dep) {
        if(dep<0) return 0;
        int son0=trie[x][0], son1=trie[x][1];
        if(son0!=0&&son1!=0) {
            int ans=1e15;

            for(int i=l[son0];i<=r[son0];++i)
                ans=min(ans,query(son1,a[i],dep-1)+(1<<dep));
            return dfs(son0,dep-1)+dfs(son1,dep-1)+ans;
        }
        else if(son0!=0) return dfs(son0,dep-1);
        else if(son1!=0) return dfs(son1,dep-1);
        return 0;
    }

} T;
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    sort(a+1,a+n+1);
    rep(i,1,n) T.insert(a[i],i);
    printf("%lld\n",T.dfs(1,29));
    return 0;
}
```

### CF125E MST Company

先对除了 $1$ 之外的 $n-1$ 个点做 MST，然后得到 $d$ 个连通块。

如果 $d>k$，那么无解。

如果 $d<k$，先从 $1$ 往每个连通块连权值最小的那条边，连不完依然无解，然后枚举与 $1$ 相连的剩下的边。每加入一条新边，就会形成一个环，这条边的代价就是它的权值减去环上的最小权值，注意不考虑 $1$ 连出去的那条边。这样取代价前 $k-d$ 小的就行。

找环上最小权值只需要 $\text{DFS}$ 一遍。

复杂度 $O(m \log_2 m + nk)$。

### CF1253F Cheap Robot

注意到只有关键点有实际意义。从 $a$ 走到 $b$，要么是直接走两个关键点，要么是绕道其他关键点。

但是有电量的限制，对于边 $(x,y,z)$，从任何关键点走过来都需要满足 $c \ge dis(x) + dis(y) +z$，其中 $dis(x)$ 表示距离 $x$ 最近的关键点，与 $x$ 的距离。

连边 $\Big(k_x,k_y,dis(x)+dis(y)+z\Big)$，其中 $k_x$ 是使取到 $dis(x)$ 的一个关键点。这样我们只要最小化 $a$ 到 $b$ 路径上权值最大的边就行了。考虑 MST 的一个性质，任意两点之间路径上的最大边权最小，所以连边之后求出 MST，之后用倍增或者树剖做就行了。

还有一种做法。把询问离线了，枚举每条边的权值当作 $c$，然后加边，用并查集判连通性，在连接两个连通块时回答一个连通块内的询问，启发式合并即可。

### CF1707C DFS Trees

[link](https://nanami7.top/blog/cf1707c)

### Kruskal重构树

这个先鸽掉，等到以后有时间再写。
