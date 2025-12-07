---
title: luogu1477 假面舞会 题解
pubDate: 2023-08-24
tags:
  - 图论
  - 数论
categories: 题解
description: 'Solution'
---

考虑如果 $a$ 能看见 $b$，那么从 $a$ 到 $b$ 连边。

先从简单的图上开始分析。

考虑在 DAG 上的情况，发现还是不太容易确定。

### Part1

不妨先只考虑有向链，这个很简单，最大就是链长（超过 $3$ 的话），最小是 $3$。然而当我们把若干形态的链拼成一张 DAG 时，则会出现一个点到达另一个点的路径不止一条，从而导致很诡异的事情，似乎不太容易找到最大值了。然后我们能发现要是不存在这种情况，也就是 DAG 是个有向树，那么答案就是最长链。

可以发现，链这种结构不会使原本合法的 $k$ 变小。

观察这种情况，设较长链长度为 $l_1$，较短链长度为 $l_2$，那么能发现答案就是 $l_1-l_2$，更确切地说，合法环长是 $l_1-l_2$ 的约数。那么根据上一段的结论，最大值是所有 $l_1-l_2$ 的 $\gcd$。

如何找到这样的情况，是我们亟待解决的第一个问题。

### Part2

然后加入对环的讨论。设一个简单环环长为 $len$，那么 $len$ 必须是 $k$ 的倍数。不难想到 $k$ 最大能取所有环长的 $\gcd$。同时对于链来说 $k$ 是啥都无所谓，因此此时最大值就是环长 $\gcd$，最小值取 $\gcd$ 大于 $3$ 的约数即可。然而这还是简单环，如何解决有公共边的环，这是我们亟待解决的第二个问题。

### Part3

下面不加推导地给出解决两个问题的办法：对于关系 $(a,b)$，从 $a$ 向 $b$ 连权值为 $1$ 的边，从 $b$ 向 $a$ 连权值为 $-1$​ 的边。直接钦定一个连通块中的节点为 $0$，然后顺着边权求出每个点的权值。

- 每个连通块的最大权值减掉最小权值再加上 $1$ 就是最长链长度。
- 重复访问到一个节点时，将两个值做差得到环的权值，取 $\gcd$ 即可。

### Part4

首要明确连完反边之后就成了无向图，图中的每一个环，都对应着上述结构中的一个，即到一个点的两条路径、有或无公共边的环。

对于第一个问题，在无向图上搜完一圈回来得到的就是 $l_1-l_2$。

对于第二个问题，取公共部分的末端为起点，公共部分的始端为重点，这就是第一个问题的情况又复合上了一条链，而链是不会对种类数产生限制的。因此，第二个问题规约到了第一个问题上。

设较长环长度为 $x$，较短环长度为 $y$，二者公共部分长度为 $z$。那么这个东西所对应的最大值是 $(x-z)-(y-z) = x-y$。这个结构的贡献是 $\gcd(x,y)$。

假设已经搜完了较长环，进入环的时机以及走的路径不同，会导致上述做法得到的较短环的权值也不同。但是塔可以保证这个权值只会是 $y$ 或 $x-y$，并且 $\gcd(x,y) = \gcd(x,x-y)$，所以是对的。

具体证明设计大量分类讨论，此处不予展开。

比较抽象，可以对着图理解。

![](https://cdn-us.imgs.moe/2023/08/19/64e0aacc8995b.png)



### CODE

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
const int N=1e5+5, M=2e6+5;
int n, m, t, mx, mn, ans, dis[N];
bool v[N];
int tot, h[N], to[M], w[M], nxt[M];
void add(int x,int y,int z) {
    to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
int gcd(int x,int y) { return y? gcd(y,x%y):x; }
void dfs(int x,int fa,int k) {
    if(v[x]) {
        ans=gcd(ans,abs(dis[x]-k));
        return;
    }
    v[x]=1, dis[x]=k;
    mx=max(mx,k), mn=min(mn,k);
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i], z=w[i];
        if(y!=fa) dfs(y,x,k+z);
        // 判一下不要往回搜是因为二元环是一种很没用的东西
        // 搜不搜反正都是和1取gcd
    }
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int x=read(), y=read();
        add(x,y,1);
        add(y,x,-1);
    }
    rep(i,1,n) if(!v[i]) {
        mx=-1e9, mn=1e9;
        dfs(i,0,1);
        t+=mx-mn+1;

    }
    int ans2=0;
    if(!ans) ans=t, ans2=3;
    else {
        ans2=3;
        while(ans2<ans&&ans%ans2) ++ans2;
    }
    if(ans<3) puts("-1 -1");
    else printf("%lld %lld\n",ans,ans2);
    return 0;
}
```


