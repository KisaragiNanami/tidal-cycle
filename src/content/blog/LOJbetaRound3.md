---
title: 「LibreOJ β Round」#3 题解
pubDate: 2023-09-21
tags:
  - 贪心
  - 构造
  - DP
  - 拓扑排序
categories:
  - LOJ β Round
  - 比赛
description: '个人题解'
---

## 绯色 IOI（开端）

> 这个都出烂了。—— Elegia

结论：

对 $\{w_i\}$ 递增排序，然后对于节点 $i > 1$，连边 $(i \rightarrow i+2)$，然后连边 $(n-1 \rightarrow n)$，$(1 \rightarrow 2)$。这张图的边权和就是最优解。

证明：

我们把点 $i$ 看作平面直角坐标系上的点 $(w_i,w_i)$，这样他们都在 $y=x$ 这条直线上了。然后以点 $(w_i,w_i)$ 为左下角，$(w_{i+1},w_{i+1})$ 为右上角构造正方形，就能得到下图这样的东西。

![geogebra-export](https://cdnjson.com/images/2023/09/21/geogebra-export.png)

任何一条满足限制的回路，其权值和都可以由每个正方形的面积带上一定系数表示。

我们证明任何其他做法得到的回路都不可能比上述做法更优。

设 $l_i = w_{i+1}-w_i$。

在上述做法中，对于矩形 $(i,i+1)$，其中 $i \neq 1$，$i+1 \neq n$，它对答案的贡献可以被表示为 $2l_i^2 + l_il_{i-1} + l_i l_{i+1}$。说白了就是，每个正方形都被经过了 $2$ 次，相邻两个正方形的边围成的矩形都被算了 $1$ 次。而第一个和最后一个正方形只会被经过 $1$ 次。

对于其他任意做法，手玩一下就能知道每个矩形被经过的次数都不会比上述情况更小。

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
const int N=1e5+5;
int n, w[N];
int squ(int x) { return x*x; }
signed main() {
    n=read();
    rep(i,1,n) w[i]=read();
    sort(w+1,w+n+1);
    int ans=0;
    for(int i=1;i+2<=n;i+=2) ans+=squ(w[i+2]-w[i]);
    for(int i=2;i+2<=n;i+=2) ans+=squ(w[i+2]-w[i]);
    ans+=squ(w[2]-w[1])+squ(w[n]-w[n-1]);
    printf("%lld\n",ans);
    return 0;
}
```

## 绯色 IOI（抵达）

> 引理：
> 
> 给树定根后，设 $x$ 是 $y$ 的父节点。如果 $x$ 的庇护所是 $y$，那么 $y$ 的庇护所也是 $x$。
> 
> 证明：
> 
> 反证法。如果 $y$ 的庇护所不是 $x$，那么只能是 $y$ 的一个子节点 $z$。由于任意两个节点的庇护所不同，所以 $z$ 的庇护所只能是它的一个子节点。由此递归下去直到一个叶子，它一定没有可以选择的庇护所，这与每个城市都有庇护所矛盾。

那么我们对这棵树随便求一个匹配就行了，随便 $\text{DFS}$ 几下。

设 $\text{match}(x)$ 为与节点 $x$ 匹配的点，钦定它与 $x$ 互为庇护所。然后就有一个明显的大小关系了：$x$ 的危险程度要小于所有与 $\text{match}(x)$ 相邻的节点。

新建一张图，连边 $(x \rightarrow y)$，其中在 $y$ 与 $\text{match}(x)$ 在原树上相邻并且 $x \neq y$，表示 $x$ 的危险程度要小于 $y$。

显然是个 DAG，对其拓扑排序即可。

过程中用小根堆贪一个最小字典序。

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
int n, in[N], match[N];
vector<int> p[N], g[N];
void dfs(int x,int fa) {
    for(auto y:p[x]) if(y!=fa) dfs(y,x);
    if(!match[x]) {
        if(!fa||match[fa]) { puts("-1"); exit(0); }
        match[x]=fa, match[fa]=x;
    }
}
void build() {
    rep(x,1,n) for(auto y:p[match[x]]) if(x!=y) {
        g[x].pb(y), ++in[y];
    }
}
signed main() {
    n=read();
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    dfs(1,0);
    build();
    priority_queue<int,vector<int>,greater<int> > q;
    rep(i,1,n) if(!in[i]) q.push(i);
    while(q.size()) {
        int x=q.top(); q.pop();
        printf("%lld ",x);
        for(auto y:g[x]) {
            if(--in[y]==0) q.push(y);
        }
    }
    puts("");
    return 0;
}
```

## 绯色 IOI（危机）



题目给出的性质都不是很显然，所以先尝试避开性质直接打暴力。

发现复杂度爆炸，大概是 $O(n^2 n!)$。

不过最基本的思考也让我们会用第一个性质了：如果 $i$ 能直接或间接地引爆 $j$，那么连边 $(i \rightarrow j)$。由性质一可知这会得到一张 DAG。拓扑排序即可求出以任意点结尾的答案，复杂度 $O(n^2)$。

但是这个直接或间接很难受，如果用 $\text{Floyd}$ 算法跑传递闭包的话，复杂度就会达到 $O(n^3)$。

我们考虑只连能直接引爆的边，这样暴力建图就是 $O(n^2)$ 的，不过也相应地少了很多信息。

怎么办？把这些信息放到 DP 中去。设 $f(x,i)$ 为考虑到节点 $x$，以节点 $i$ 结尾的答案，转移时随便讨论一下。复杂度 $O(n^2)$。

实际得分 $36 \text{pts}$。

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
const int N=3005, mod=998244353;
int n, pos[N], r[N], v[N], in[N];
int f[N][N];
vector<int> p[N];
void build() {
    rep(i,1,n) rep(j,1,n) if(i!=j) {
        if(pos[i]-r[i]<=pos[j]&&pos[j]<=pos[i]+r[i]) {
            p[i].pb(j), ++in[j];
        }
    }
}
int F(int x,int y) { return ((x^y)+x*y)%mod; }
void toposort() {
    SET(f,-1);
    queue<int> q;
    rep(i,1,n) {
        f[i][i]=0;
        if(!in[i]) q.push(i);
    }
    while(q.size()) {
        int x=q.front(); q.pop();
        for(auto y:p[x]) {
            for(int i=1;i<=n;++i) if(~f[x][i]) {
                f[y][i]=max(f[y][i],f[x][i]);
                f[y][y]=max(f[y][y],f[x][i]+F(v[i],v[y]));
            }
            if(--in[y]==0) q.push(y);
        }
    }
}
signed main() {
    n=read();
    rep(i,1,n) pos[i]=read();
    rep(i,1,n) r[i]=read();
    rep(i,1,n) v[i]=read();
    build();
    toposort();
    rep(i,1,n) {
        int res=0;
        rep(j,1,n) res=max(res,f[i][j]);
        printf("%lld\n",res);
    }
    return 0;
}
```



这样还是有冗余的，能不能只连 $d(i,j)=2$ 的边呢？

其实是可以的，并且对于任意 $i$，满足 $d(i,j)=2$ 的 $j$ 最多在 $i$ 左右各一个。证明略。

如何建图？用左右端点在坐标序列上二分即可，复杂度 $O(n \log_2 R)$。这样就能建出一张边数为 $O(n)$ 的 DAG。

对于 $v_i=1$ 的测试点，由于 $F(1,1)=1$，所以等价于求 DAG 最长路，随便做。

对于 $v_i \in \{ 0,1 \}$ 的测试点，由于 $F(1,1)=F(1,0)=F(0,1)=1$，$F(0,0)=0$，所以我们处理出能间接到达节点 $i$ 的，拓扑序最大的权值非 $0$ 节点的编号 $a_i$。然后就跑普通的 DAG 最长路，顺便从 $a_i$ 转移一下即可。



&nbsp;

下面讨论正解。

> 引理：能够直接或间接到达一个节点的节点个数是 $O(\log_2 R)$ 的。

证明引用自[官方题解](https://loj.ac/d/129)。

{% note primary %}

证明方法如下：首先可以证明 $\forall x,i$，满足 $d(j,i)=x$ 的 $j$ 左右各不超过一个。
证法类似算法四中的引理。如果一侧有两个，离 $i$ 较远的一个炸弹 $k$ 在炸到 $i$ 的过程中必定可以炸到较近的一个 $j$，于是 $d(k,i)>d(j,i)$ 矛盾了。

其次我们可以证明 $\forall i,j$ 有 $d(i,j)\leq O(\log R)$。考虑一条最长的引爆序列 $a_1,a_2,...,a_n$，前一个能直接引爆后一个。那么在序列中必有 $d(a_i,a_j)=|i-j|+1$。

那么设势函数 $\phi(i)=R_{a_i}$。若 $X_{a_i}$ 在 $X_{a_{i-1}}$ 和 $X_{a_{i-2}}$ 之间，则由性质一 $\phi(i)\leq\lfloor\frac{\phi(i-2)}{2}\rfloor$。

否则 $X_{a_{i-1}}$ 一定在 $X_{a_{i-2}}$ 和 $X_{a_i}$ 之间。则由性质二 $R_{a_i}+R_{a_{i-1}}\leq R_{a_{i-2}}$，再由性质一 $R_{a_i}<R_{a_{i-1}}$，仍然有 $\phi(i)\leq\lfloor\frac{\phi(i-2)}{2}\rfloor$。

那么 $\phi$ 会在不超过 $2\log_2 R$ 长度之内衰减到 $0$。显然 $R=0$ 的炸弹无法引爆任何其它炸弹。故有 $n=O(\log R)$。

两个结论合在一起可得能直接或间接引爆一个炸弹的炸弹数不超过 $4\log_2 R$。证毕。

{% endnote %}

所以我们处理出每个节点 $i$ 能直接或间接到达的左右边界 $l_i$ 和 $r_i$，从 $i$ 向 $[l_i,r_i]$ 中的所有其他节点连边，拓扑排序时从 $i$ 向 $[l_i,r_i]$ 中的所有其他节点暴力转移即可。

唯一问题在于建图。

我们先令 $l_i$ 和 $r_i$ 分别表示能直接到达的最左和最右的节点，然后分别对 $l_i$ 与 $r_i$ 做一遍单调栈。以 $l_i$ 为例，每个 $l_i$ 会弹掉栈中所有满足 $j \ge l_i$ 的点 $j$，在过程中令 $l_i \leftarrow \min(l_i,l_j)$。

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
const int N=3e5+5, mod=998244353;
int n, ans[N];
int in[N], l[N], r[N], f[N];
int tp, st[N];
struct node {
    int x, r, v, id;
    node() {}
    node(int _x,int _r,int _v,int _id) { x=_x, r=_r, v=_v, id=_id; }
    bool operator<(const node& b) const { return x<b.x; } 
} a[N];
int F(int x,int y) { return ((x^y)+x*y)%mod; }
void toposort() {
    queue<int> q;
    rep(i,1,n) if(!in[i]) q.push(i);
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int y=l[x];y<=r[x];++y) if(x!=y) {
            f[y]=max(f[y],f[x]+F(a[x].v,a[y].v));
            if(--in[y]==0) q.push(y);
        }
    }
}
signed main() {
    n=read();
    rep(i,1,n) a[i].x=read(), a[i].id=i;
    rep(i,1,n) a[i].r=read();
    rep(i,1,n) a[i].v=read();
    sort(a+1,a+n+1);
    rep(i,1,n) {
        l[i]=lower_bound(a+1,a+n+1,node(a[i].x-a[i].r,0,0,0))-a;
        r[i]=upper_bound(a+1,a+n+1,node(a[i].x+a[i].r,0,0,0))-a-1;
    }
    tp=0;
    rep(i,1,n) {
        while(tp&&st[tp]>=l[i]) {
            l[i]=min(l[i],l[st[tp]]);
            --tp;
        }
        st[++tp]=i;
    }
    tp=0;
    per(i,n,1) {
        while(tp&&st[tp]<=r[i]) {
            r[i]=max(r[i],r[st[tp]]);
            --tp;
        }
        st[++tp]=i;
    }
    rep(i,1,n) for(int j=l[i];j<=r[i];++j) if(i!=j) ++in[j];
    toposort();
    rep(i,1,n) ans[a[i].id]=f[i];
    rep(i,1,n) printf("%lld\n",ans[i]);
    return 0;
}
```

## 绯色 IOI（悬念）

不会。😥
