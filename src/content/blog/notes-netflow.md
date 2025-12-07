---
title: 「图论学习笔记」#5 网络流定义与最大流
tags:
  - 网络流
  - 最大流
categories:
  - 学习笔记
description: '网络瘤'
pubDate: 2022-07-03
---

## 定义

一个网络 $G= (V,E)$ 是一张有向图，对于每条有向边 $(x \rightarrow y)$ 都有一个权值 $c(x,y)$，称之为这条边的**容量**。另外，存在特殊节点 $S$，称为**源点**；$T$，称为**汇点**。



设函数 $f(x,y)$，其定义域为 $x,y \in V$，满足

1. 容量限制：对于每条边，流经该边的流量不得超过该边的容量，即 $f(x,y) \le c(x,y)$
2. 斜对称性：每条边的流量与其相反边的流量之和为 0，即 $f(x,y) = -f(y,x)$
3. 流守恒性：从源点流出的流量等于汇点流入的流量，即 $\sum_{(u ,x) \in E} f(u,x) = \sum_{(x,v) \in E} f(x,v)$

那么称 $f$ 为这个网络的**流函数**，对于边 $(x \rightarrow y)$，$f(x,y)$ 称为它的**流量**，$c(x,y)-f(x,y)$ 称为它的**剩余容量**。

整个网络的流量为**从源点发出的所有流量之和**，即 $\sum_{(S,x) \in E} f(S,x)$。

由于流量守恒性质，可以知道**除了源点与汇点之外，其他的节点不储存流，「流」只是从源点流出，流经整个网络，最终归于汇点**。

## 最大流

对于一个网络，有很多合法的流函数，但是使得整个网络的流量最大的流函数 $f$，也就是 $\sum_{(S,x) \in E} f(S,x)$，这样的流函数 $f$ 称为该网络的**最大流**。

### Edmonds-Karp 算法

是 Ford-Fulkerson 方法基于 BFS 的一个实现。

如果存在一条从源点 $S$ 到汇点 $T$ 的路径，满足每一条边的剩余容量都大于 $0$，那么称这条路径为一条**增广路**，注意不同于二分图匹配中的增广路。

如果让更多的流沿着 $S$ 流到 $T$，那么就能使网络流量增大，且这个值为路径上最小的剩余容量。Edmonds-Karp 算法的思想是利用 BFS 不断寻找增广路，知道网络中不存在增广路。此时不可能增加网络的流量，那么必然得到了最大流。

具体流程如下

在寻找增广路的过程中，只考虑 $f(x,y) < c(x,y)$ 的边，用 BFS 找到任意 $S$ 到 $T$ 的路径， 计算出路径上最小的剩余容量 $minf$，同时累加总流量。

如果存在一条边满足 $f(x,y) > 0$，那么它的反向边有 $f(y,x) < 0$，此时 $f(y,x) < c(y,x)$，由于 $c(x,y) = c(y,x)$，那么反向边也有可能成为增广路的一部分，应该考虑边集 $E$ 中每条边的反向边。我一开始有一个小问题，网络不是有向图吗？为什么也能用反向边呢？后来想明白了，并不是网络中真的有了反向边，对于 $(x \rightarrow y)$，选择它的反边相当于把通过它的流退了回来，并且能够发现新的增广路。

图解。

![一个普通的网络](https://s2.loli.net/2022/07/03/16qMpVeyK2LswTm.png)

初始状态，钦定 $1$ 为源点，$6$ 为汇点。

手动 BFS 找到一条增广路 $(1 \rightarrow 2 \rightarrow 5 \rightarrow 6)$，同时发现无法再找到增广路了。将增广路上的边都增加上最小的剩余容量 $2$。最大流是 $2$ 吗？

![](https://s2.loli.net/2022/07/03/mLOMUrCnN5JKicV.png)

建立反向边，发现新的增广路 $(1 \rightarrow 4 \rightarrow 5 \rightarrow 2 \rightarrow 3 \rightarrow 6)$，其中只有 $2$ 走的是原来边的反向边。将路径上走正向边都加上最小剩余容量 $1$，走反向边的都减去最小剩余容量 $1$。可以验证这条增广路是合法的，且最大流又增加了 $1$。

![](https://s2.loli.net/2022/07/03/45KP8yjOaHYidJN.png)

注意画出的红蓝箭头指的是两条增广路，不是网络的真是流向，但是根据增广路可以构造出合法的流向。由于 $(2 \rightarrow 5)$ 减去了 $1$，但是在 $(2 \rightarrow 3)$ 又加上了 $1$，所以总流量不变， $(1 \rightarrow 2)$ 的流能通过**分流**的方式到达汇点。$(1 \rightarrow 2)$ 分流导致原来走的 $(5 \rightarrow 6)$ 也腾出了空间，正好能容纳 $(4 \rightarrow 5)$ 流过来的部分。图中写出来的边权 $f(x,y)/c(x,y)$ 是正向边的流量。

图中流的路径为 $(1 \rightarrow 4 \rightarrow 5 \rightarrow 6)$，$(1 \rightarrow 2 \rightarrow 5  \rightarrow 6)$ 和 $(1 \rightarrow 2 \rightarrow 3  \rightarrow 6)$，每条流量都为 $1$。这样做才能求得最大流 $3$。

还有一点，EK 算法遍历的是网络中所有节点和剩余容量大于 $0$ 的边构成的子图，称为**残量网络**。代码中的边权都是**残量网络的边权**，也就是还能容纳多少。对于一条正向边 $(x \rightarrow y)$，容量为 $z$。初始还能容纳 $z$，所以加边`add(x,y,z)`，而其反向边则是`add(y,x,0)`，只有正向边减少才能为反向边腾出空间。

于是乎 EK 算法就没有悬念了，上代码。

复杂度 $O(nm^2)$，实际远远达不到这个上界，~~但依然很慢~~，大概能处理 $n=10^3 \sim 10^4$ 规模的网络。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int inf=0x7fffffff, N=205, M=5005;
int n, m, s, t, pre[N], F[N];
int tot=1, h[N], to[M<<1], nxt[M<<1], w[M<<1];
// 注意tot=1
bool v[N];
ll maxflow;
int read();
// 快读
void add(int x,int y,int z) {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
bool bfs() {
	queue<int> q;
	memset(v,0,sizeof(v));
    // v[i]表示i是否被访问过
	v[s]=1, q.push(s);
	F[s]=inf;
    // 源点为正无穷
	while(q.size()) {
		int x=q.front(); q.pop();
		for(int i=h[x];i;i=nxt[i]) {
			int y=to[i], z=w[i];
			if(v[y]||!z) continue;
            // 被访问过或者剩余容量为0
			F[y]=min(F[x],z);
			pre[y]=i;
            // 记录增广路上的边
			v[y]=1, q.push(y);
			if(y==t) return 1;
            // 到达汇点，找到增广路
		} 
	}
	return 0;
    // 不存在
}
void update() {
	int x=t;
	while(x!=s) {
		int i=pre[x];
		w[i]-=F[t], w[i^1]+=F[t];
        // 正向边剩余容量减少，反向边剩余容量增加
		x=to[i^1];
        // 因为从tot=1开始储存，所以i^1定位到i的反向边
	}
	maxflow+=F[t];
}
int main() {
	n=read(), m=read(), s=read(), t=read();
	for(int i=1;i<=m;++i) {
		int x=read(), y=read(), z=read();
		add(x,y,z), add(y,x,0);
        // 反向边权值（剩余容量）最初为0
	}
	while(bfs()) update();
    // 存在增广路就更新
	printf("%lld\n",maxflow);
}
```

### Dinic 算法

EK 算法每轮可能会遍历整个残量网络，但是最多找出 1 条增广路，效率较低。

设 $d(x)$ 为起点到 $x$ 最小的边数，称为**层次**。在残量网络中，满足 $d(y) = d(x) +1$ 的边 $(x \rightarrow y)$ 构成的子图称为**分层图**，这显然是一张 DAG。使用 BFS 很容易实现。

Dinic 算法基于分层图，其流程如下：

1. 在残量网络上使用 BFS 求出节点的层次，构造分层图。
2. 在分层图上寻找任意一条增广路，进行增广，并将答案加上增广流量。
3. 貌似一次 DFS 能够找出所有增广路。
4. 如果无法再次建立分层图，当前流量即为最大流。

一个重要的优化是**当前弧优化**。定义点 $x$ 的当前弧为 DFS 过程中遍历过的 $x$ 的最后一条出边。首先如果一条边被增广过了，那么他便不会再次被增广，如果再遍历这些边的话相当浪费时间，所以对于节点 $x$，每遍历一条边，都让再次访问 $x$ 时从这条边开始，且不去遍历之前的边。具体实现看代码。

此外，还有一个优化。递归完回溯时，如果返回的是 0，说明已经增广完毕，直接将这个点移出分层图。

效率高于 EK 算法，复杂度为 $O(n^2m)$，但是很难达到这个上界，能够处理 $n = 10^4 \sim 10^5$ 规模的网络。用 Dinic 算法求解二分图最大匹配的复杂度为 $O(m \sqrt n)$，实际表现更快。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int inf=0x7fffffff, N=205, M=5005;
int n, m, s, t, hh[N], d[N];
int tot=1, h[N], to[M<<1], nxt[M<<1], w[M<<1];
ll maxflow;
int read();
// 省略快读
void add(int x,int y,int z) {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
bool bfs() {
	queue<int> q;
	memset(d,0,sizeof(d));
	d[s]=1, q.push(s);
	while(q.size()) {
		int x=q.front(); q.pop();
		hh[x]=h[x];
        // hh[]要把h[]复制一份
		for(int i=h[x];i;i=nxt[i]) {
			int y=to[i], z=w[i];
			if(d[y]||!z) continue;
			q.push(y);
			d[y]=d[x]+1;
			if(y==t) return 1;
		} 
	}
	return 0;
}
int dinic(int x,int flow) {
     // flow表示当前增广路的最小剩余容量
	if(x==t||!flow) return flow;
    // 到达汇点或者增广完毕
	int res=flow;
	for(int& i=hh[x];i;i=nxt[i]) {
        // i是个引用，当前弧优化
       	// i变为nxt[i]时也直接让h[x]变为nxt[i]，最终导致从x出发直接到达它的当前弧
		int y=to[i], z=w[i];
		if(d[y]!=d[x]+1||!z) continue;
        // 不是分层图中节点或者不再残量网络中就不搜索
		int k=dinic(y,min(res,z)); // 取最小值
		if(!k) d[y]=0;
		else w[i]-=k, w[i^1]+=k, res-=k;
        // 优化。移出分层图
		if(!res) return flow;
        // 加这句话快在洛谷的板子 700ms -> 50ms
	}
	return flow-res;
    // 返回的其实就是所有k的和，表示从这个点出发能够增广的值之和
}
int main() {
	n=read(), m=read(), s=read(), t=read();
	for(int i=1;i<=m;++i) {
		int x=read(), y=read(), z=read();
		add(x,y,z), add(y,x,0);
	}
	while(bfs()) maxflow+=dinic(s,inf);
	printf("%lld\n",maxflow);
}
```

### 二分图最大匹配

对于一张 $n$ 个节点，$m$ 条边的二分图，可以新增一个源点 $S$ 和一个汇点 $T$，从 $S$ 到每个左部节点连有向边， 从每个右部节点到 $T$ 连有向边，原本的 $m$ 条边看作左部节点到右部节点的有向边，形成一张 $n+2$ 个节点，$m+n$ 条边的网络。

把网络中每条边的容量都设为 1，该二分图最大匹配数就等于网络的最大流量。求出最大流后，所有存在「流」经过的点和边就是匹配点、匹配边。

如果要求该二分图的多重匹配，只需要把 $S$ 到左部节点 $i$ 的有向边容量设置为匹配数量上限 $kl_i$，右部点到 $j$ 到 $T$ 的有向边容量设置为匹配数量上限 $kr_j$。

参考：

- [最大流算法之一——EK算法](https://blog.csdn.net/qq_39670434/article/details/80952337) by 千杯湖底沙

- [Dinic 学习笔记](https://oi.men.ci/dinic-notes/) by Menci
- [最大流 Dinic](https://2745518585.github.io/post/maximum-flow-Dinic) by 赵悦岑
