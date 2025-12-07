---
title: 夏令营的一些图论题
tags:
  - 图论
  - 最短路
  - 最近公共祖先
  - 拓扑排序
categories: 题解
pubDate: 2022-07-25
description: '做题记录'
---

这篇文章收录了一些夏令营期间写的不是那么复杂的图论题目。



## CF715B Complete The Graph

### 分析

注意到如果改权值为 $0$ 的边，那么把它改成 $1$ 一定收益最大。

于是乎用 Dijkstra 算法求出以 $s$ 为起点，不含 $0$ 边情况的最短路。

如果此时 $dis(t) < L$，那么由于改边不会让这时候的最短路更大，所以一定无解。

如果 $dis(t) = L$，那么最优解就是让改动后的边不会改变 $dis(t)$ 的值，将他们改为 $10^{18}$ 即可。

如果 $dis(t) > L$，那么就依次把一条 $0$ 边改为 $1$ 且加入图中，再跑最短路。如果此时 $dis(t) \le L$，那么就让某一条边的权值加上 $L-dis(t)$，此时 $(s \rightarrow t)$ 的最短路长度为 $L$。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define fr first
#define sc second
const int N=10005, inf=1e18;
int n, m, L, s, t, cnt, fg, d[N], a[N], b[N], c[N];
int tot, h[N], to[200010], nxt[200010], w[200010];
bool v[N];
vector<int> e; 
void add(int x,int y,int z) {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    } 
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
void dijkstra(int s) {
    priority_queue<pair<int,int> > q;
    for(int i=0;i<=n;++i) d[i]=inf, v[i]=0;
    d[s]=0, q.push({0,s});
    while(q.size()) {
        int x=q.top().sc; q.pop();
        if(v[x]) continue;    
        v[x]=1;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i], z=w[i];
            if(d[y]>d[x]+z) {
                d[y]=d[x]+z, q.push({-d[y],y}); 
            }
        }
    }
}
void sdasdsad() {
    puts("YES");
    for(int i=1;i<=m;++i) {
        if(c[i]==0) {
            if(i<fg) printf("%lld %lld %lld\n",a[i],b[i],1ll);
            if(i==fg) printf("%lld %lld %lld\n",a[i],b[i],L-d[t]+1);
            if(i>fg) printf("%lld %lld %lld\n",a[i],b[i],inf);
        } else printf("%lld %lld %lld\n",a[i],b[i],c[i]);
    }
}
signed main() {
    n=read(), m=read(), L=read(), s=read(), t=read();
    for(int i=1;i<=m;++i) {
        a[i]=read(), b[i]=read(), c[i]=read();
        if(c[i]==0) { e.push_back(i); continue; }
        add(a[i],b[i],c[i]), add(b[i],a[i],c[i]);
    }
    dijkstra(s);
    if(d[t]<L) { puts("NO"); return 0; }
    if(d[t]==L) {
        puts("YES");
        for(int i=1;i<=m;++i) {
            if(c[i]==0) printf("%lld %lld %lld\n",a[i],b[i],inf);
            else printf("%lld %lld %lld\n",a[i],b[i],c[i]);
        }
        return 0;
    }
    if(d[t]>L) {
        for(int i=0;i<e.size();++i) {
            add(a[e[i]],b[e[i]],1), add(b[e[i]],a[e[i]],1);
            dijkstra(s);
            if(d[t]>L) continue;
            if(d[t]<=L) {
                fg=e[i];
                sdasdsad();
                return 0;
            }
        }
    }
    puts("NO");
}
```

## CF1076D Edge Deletion

### 分析

最短路树。

起点到所有点以及对应的最短路径构成一棵树，称为最短路树。其他的边全部删去也不会影响到达任何点的最短路。那我们可以贪心选择最短路树之外的边，如果全都删完了，那么只能从最短路树里删。

由于不包含 $1$ 号节点，所以答案即为 $\min{\{ k,n-1 \}}$。

至于输出方案，遍历最短树，优先输出前 $\min{\{ k,n-1 \}}$ 个就好了。由于建立双向边，所以对于边 $i$ 的边，其真实编号为 $\lfloor \frac{i}{2} \rfloor$。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define fr first
#define sc second
const int N=3e5+5, inf=1e18;
int n, m, k, cnt, d[N], ans[N], pre[N];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
bool v[N];
struct node { int x, y, to; };
bool operator<(node a,node b) { return a.x<b.x; }

void add(int x,int y,int z) {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    } 
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
void dijkstra(int s) {
    priority_queue<pair<int,int> > q;
    memset(d,0x3f,sizeof(d));
    d[s]=0, q.push({0,s});
    while(q.size()) {
        int x=q.top().sc; q.pop();
        if(v[x]) continue;    
        v[x]=1;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i], z=w[i];
            if(d[y]>d[x]+z) {
                d[y]=d[x]+z, pre[y]=i, q.push({-d[y],y}); 
            }
        }
    }
}
void dfs(int x,int fa) {
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        if(pre[y]==i) {
            ++cnt;
            if(cnt>k||cnt==n) return;
            printf("%lld ",(i+1)/2);
            dfs(y,x);
        }
    }
}
signed main() {
    n=read(), m=read(), k=read();
    for(int i=1;i<=m;++i) {
        int x=read(), y=read(), z=read();
        add(x,y,z), add(y,x,z);
    }
    printf("%lld\n",min(k,n-1));
    dijkstra(1); 
    dfs(1,0);
}

```

## CF1343E Weights Distributing

### 分析

自然是将边权排序。

分别以 $a$，$b$，$c$ 为起点进行 BFS 求出到每个节点的距离，设他们为 $da(i)$，$db(i)$，$dc(i)$。枚举一个点 $i$，前 $da(i)+db(i)+dc(i)$ 小的边权加上前 $db(i)$ 小的边权即为这部分的答案，取最小值即可。

下面证明可以取到所有情况。

如果 $a$，$b$，$c$ 在同一条简单路径上，那么最优解一定是取 $i=b$，此时 $db(i)=0$，将最小的边权放到这条路径上即可。

如果不在同一条简单路径上，由于树上两点之间有且仅有一条简单路径，而路径是 $(a \rightarrow b)$ 和 $(b \rightarrow c)$，所以取 $i=lca(a,c)$，此时保留了 $(a \rightarrow c)$ 的简单路径且 $db(lca(a,b))$ 被计算了 $2$ 次，贪心地让这一块取最小的几个权值即可。

这题最好自己画图。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define fr first
#define sc second
const int N=3e5+5, inf=1e18;
int n, m, a, b, c, d[N], da[N], db[N], dc[N], w[N], sum[N];
int tot, h[N], to[N<<1], nxt[N<<1];
bool v[N];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    } 
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
void bfs1(int s) {
    for(int i=1;i<=n;++i) da[i]=-1;
    queue<int> q;
    da[s]=0, q.push(s); 
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(da[y]==-1) da[y]=da[x]+1, q.push(y);
        }
    }
}
void bfs2(int s) {
    for(int i=1;i<=n;++i) db[i]=-1;
    queue<int> q;
    db[s]=0, q.push(s); 
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(db[y]==-1) db[y]=db[x]+1, q.push(y);
        }
    }
}
void bfs3(int s) {
    for(int i=1;i<=n;++i) dc[i]=-1;
    queue<int> q;
    dc[s]=0, q.push(s); 
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(dc[y]==-1) dc[y]=dc[x]+1, q.push(y);
        }
    }
}
void solve() {
    for(int i=1;i<=n;++i) h[i]=0;
    tot=0;
    int ans=1ll<<60;
    n=read(), m=read(), a=read(), b=read(), c=read();
    for(int i=1;i<=m;++i) w[i]=read();
    for(int i=1;i<=m;++i) {
        int x=read(), y=read();
        add(x,y), add(y,x);
    }
    bfs1(a), bfs2(b), bfs3(c);
    sort(w+1,w+m+1);
    for(int i=1;i<=m;++i) sum[i]=sum[i-1]+w[i];
    for(int i=1;i<=n;++i) {
        if(da[i]+db[i]+dc[i]>m) continue;
        ans=min(ans,sum[da[i]+db[i]+dc[i]]+sum[db[i]]);
    } 
    printf("%lld\n",ans);
}
signed main() {
    int t=read();
    while(t--) solve();
}
```

## CF832D Misha, Grisha and Underground

### 分析

不会证明，纯属找规律。

假设 $a,b$ 是起点，$c$ 是终点，答案为

$$
\frac{dis(a,b)+dis(a,c)-dis(a,b)}{2} +1
$$



枚举三种情况取最大值即可。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=5e5+5;
int n, q, fa[N], sz[N], dep[N], son[N];
int num, top[N];
int tot, h[N], w[N], to[2*N], nxt[2*N];
void dfs1(int x) {
    sz[x]=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa[x]) continue;
        fa[y]=x, dep[y]=dep[x]+1;
        dfs1(y);
        sz[x]+=sz[y];
        if(sz[y]>sz[son[x]]) son[x]=y;
    }
}
void dfs2(int x,int tp) {
    top[x]=tp;
    if(!son[x]) return;
    dfs2(son[x],tp);
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y!=fa[x]&&y!=son[x]) dfs2(y,y);
    }
}
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();        
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
int lca(int x,int y) {
    while(top[x]!=top[y]) {
        if(dep[top[x]]<dep[top[y]]) swap(x,y);
        x=fa[top[x]];
    }
    if(dep[x]>dep[y]) swap(x,y);
    return x;
}
int dis(int x,int y) {
    int z=lca(x,y);
    return dep[x]+dep[y]-2*dep[z];
}
int solve(int x,int y,int z) {
    int ans1=(dis(x,z)+dis(y,z)-dis(x,y))/2;
    int ans2=(dis(x,y)+dis(y,z)-dis(x,z))/2;
    int ans3=(dis(x,y)+dis(x,z)-dis(y,z))/2;
    return max(ans1,max(ans2,ans3))+1;
}
signed main() {
    n=read(), q=read();
    for(int i=2;i<=n;++i) {
        int x=read();
        add(x,i), add(i,x);
    }
    dfs1(1), dfs2(1,0);
    while(q--) {
        int x=read(), y=read(), z=read();
        printf("%lld\n",solve(x,y,z));
    }
}
```

## D. Toss a Coin to Your Graph...

### 分析

最大值最小，二分答案。设 $check(x)$ 表示只经过权值小于等于 $x$ 的节点，能不能满足条件。

具体实现时可以只将满足 $(x \rightarrow y)$，其中 $a_x,a_y \le x$ 的边加入图中。

如果此时有环，那么在这个环上走就行了，显然是能够经过 $k$ 个节点的。

如果没有环，那么此时图是一个 DAG。设 $f_i$ 为从 $i$ 出发，最多能经过的节点个数。起初 $f_i =1$，然后拓扑排序。

$$
f_y= \max_{(x \rightarrow y)}\{ f_x +1\}
$$



转移即可。如果存在 $f_i \ge k$，那么就能满足条件。

可以直接利用拓扑排序判断是否存在环。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=2e5+5; 
int n, m, k, a[N], b[N], f[N], deg[N];
int tot, h[N], to[N], nxt[N];
struct edge { int u, v; } e[N];
bool v[N];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar(); 
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
void add(int x,int y) { to[++tot]=y, nxt[tot]=h[x], h[x]=tot; }
bool check(int x) {
    tot=0;
    for(int i=1;i<=n;++i) h[i]=v[i]=deg[i]=0, f[i]=1;
    for(int i=1;i<=m;++i) {
        int u=e[i].u, v=e[i].v;
        if(a[u]<=x&&a[v]<=x) {
            add(u,v), ++deg[v];
        }
    }
    int cnt=0, ans=0;
    queue<int> q;
    for(int i=1;i<=n;++i) if(!deg[i]) q.push(i);
    while(q.size()) {
        int x=q.front(); q.pop();
        ans=max(ans,f[x]);
        ++cnt;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            f[y]=max(f[y],f[x]+1);
            if(--deg[y]==0) q.push(y);
        }
    }
    if(cnt!=n) return 1;
    // 存在环
    if(ans>=k) return 1;
    return 0;
}
signed main() {
    n=read(), m=read(), k=read();
    for(int i=1;i<=n;++i) b[i]=a[i]=read();
    for(int i=1;i<=m;++i) {
        e[i].u=read(), e[i].v=read();
    }
    sort(b+1,b+n+1);
    int l=1, r=n;
    while(l<r) {
        int mid=(l+r)/2;
        if(check(b[mid])) r=mid; else l=mid+1;
    }
    printf("%lld\n",check(b[l])? b[l]:-1);
}
```

## CF1131D Gourmet choice

### 分析

差分约束板子题……

如果 $a_i = b_j$，合并 $i$ 和 $j+n$。如果 $a_i < b_j$，连边 $(i \rightarrow j+n,1)$。否则反过来。

由于要最小化每个数，所以边权均为 $1$。而这样建出来的图如果不是 DAG，那么一定无解。

所以设 $f_i$ 表示 $i$ 最小是多少。初始值和转移同上题。

用并查集实现合并操作，具体有些细节看代码。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=2005;
int n, m, fa[N], deg[N], f[N], op[N][N];
int tot, h[N], to[N*N], nxt[N*N];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
void merge(int x,int y) {
    x=get(x), y=get(y);
    if(x!=y) fa[x]=y;
}
void add(int x,int y) { to[++tot]=y, nxt[tot]=h[x], h[x]=tot; }
void toposort() {
    int cnt=0;
    queue<int> q;
    for(int i=1;i<=n+m;++i) if(!deg[i]) f[i]=1, q.push(i);
    // 把所有没有入度的节点入队即可，不会影响答案
    // 只把合并后的节点入队一次，是一件吃力不讨好的事
    // 主要是因为节点数不再是n+m了，不好判断是否存在环
    while(q.size()) {
        int x=q.front(); q.pop();
        ++cnt;
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            f[y]=max(f[y],f[x]+1);
            if(--deg[y]==0) q.push(y);
        }
    }
    if(cnt!=n+m) { puts("No"); return; }
    puts("Yes");
    for(int i=1;i<=n;++i) printf("%lld%c",f[get(i)]," \n"[i==n]);
    for(int i=1;i<=m;++i) printf("%lld%c",f[get(i+n)]," \n"[i==m]);
}
signed main() {
    n=read(), m=read();
    for(int i=1;i<=n+m;++i) fa[i]=i;
    for(int i=1;i<=n;++i) for(int j=1;j<=m;++j) {
        char c; scanf(" %c",&c);
        if(c=='=') merge(i,j+n);
        else op[i][j]=c=='<'? 1:2;
        // 一定要先合并
    }
    for(int i=1;i<=n;++i) for(int j=1;j<=m;++j) {
        int x=get(i), y=get(j+n);
        if(op[i][j]&&x==y) { puts("No"); return 0; }
        // 已经合并的节点之间又出现了大小关系，矛盾
        if(op[i][j]==1) add(x,y), ++deg[y];
        else if(op[i][j]==2) add(y,x), ++deg[x];
    }
    toposort();
}
```
