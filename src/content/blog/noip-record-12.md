---
title: 「NOIP Record」#12 并查集
pubDate: 2023-08-04
tags:
  - 并查集
  - 二分图
  - 倍增
  - 树论
categories: Record
description: '少年觉察到自己的弱点'
---



并查集是一个森林，每棵树表示一个集合，并且这个集合根据某种具有传递性的关系构建起来。

普通并查集关心的信息只有 $x$ 所在集合的根，$fa_x$ 表示的仅仅是一个传递性关系，即 $fa_x$ 与 $x$ 所在集合的根相同。从任意节点往上跳，都能找到它所在集合的根。

使用路径压缩优化，在向上访问节点时，把路径上所有节点的 $fa$ 都改为根，那么就能做到单次查询均摊 $O(\log_2 n)$。

使用按秩合并优化，在合并两个连通块时，将较小的连通块合并到较大的连通块中，这样就能做到单次查询均摊 $O(\log_2 n)$。为了避免大量修改，在可持久化并查集中，只使用按秩合并的并查集。

二者同时使用，单次查询均摊 $O\Big(\alpha (n)\Big)$。

## 维护具有传递性的关系

### CF28B pSort

如果 $a$ 与 $b$ 能交换，$b$ 与 $c$ 能交换，那么 $a,b,c$ 三者可以任意交换。这个关系具有传递性，用并查集维护。

最后一一检查需要交换的位置 $p_i$，如果 $i$ 与 $p_i$ 在同一个集合中，那么就可以交换。

### 躲避拥挤

>有 $n$ 个景点，$m$ 条双向道路。每条道路有一个人气值 $d$，表示这条道路的拥挤程度。小明不会经过那些人气值 $\ge x$ 的道路，他想知道有多少对景点 $(a,b)$ 使得从 $a$ 出发可以到达 $b$ 景点。你需要处理多次询问，每次询问的 $x$ 不同。
>$n, m, q \le 10^5$。

把询问离线了，倒序加边，用并查集维护连通块大小。

如果加入了一条边 $(x,y)$ 第一次连接了两个连通块 $A$ 和 $B$，那么答案增加  $sz_A \times sz_B$。

### luogu1955 程序自动分析

相等具有传递性，不等不具有传递性。

并查集维护相等关系，最后 check 不等关系即可。

### UVA1316 Supermarket

贪心。将商品按照价格递减排序，然后对于第 $i$ 天，维护最大的 $rt(i)$，满足 $rt(i) \le i$ 并且第 $rt(i)$ 天空闲，不存在就是 $0$。

对于一个商品 $i$，查询 $d_i$ 所在集合的根 $rt(d_i)$ 是否大于 $0$。如果是，那么就占用这一天，合并 $rt(d_i)$ 与 $rt(d_i)-1$ 即可。

### luogu2391 白雪皑皑

倒着做。

用并查集维护每个点之前第一个没有被染色的点。点 $i$ 被染色了之后，就把 $i$ 和 $i-1$ 合并。

对于一个操作 $[l,r]$，从 $r$ 开始往前跳，这样每个点只会被染色一次，记录每个点被染的颜色就行。

### luogu6185 [NOI Online #1 提高组] 序列

只讲关于并查集的部分。

把每个点的点权都搞成 $a_i - b_i$，问题转化为把所有节点权值都搞成 $0$。

有两种思路。

1. 用并查集维护 $1$ 操作，因为一个连通块内可以同加减。

2. 用并查集维护 $2$ 操作，因为一个连通块内可以多次使用，所以能让任意节点加$1$，任意节点减 $1$。

虽然前者也具有传递性，但是对问题却没有帮助。

而后者隐藏着总和不变的信息——只有总和为 $0$ 时才有解。

同时连通块之间的 $1$ 操作，就相当于在二者差不变的情况下任意加减。

&nbsp;

另外有时候还会用并查集把具有某些关系的点合并到一个等价类中。

## 带权并查集

有些时候这个带有传递性的关系需要具体的值来度量。

让 $(x,fa_x)$ 带上边权，在路径压缩时对路径上的权值求和，通过满足结合律和传递性的运算，得到 $x$ 与根的之间的值。

### luogu1196 [NOI2002] 银河英雄传说

用并查集维护第 $i$ 个战舰所在列的前一个战舰 $fa_i$，一个集合的根就是最前面的战舰。维护 $d_i$ 表示 $(i,fa_i)$ 的权值。

在合并 $x,y$ 时更新 $d_{rt(x)}$ 需要知道 $sz_{rt(y)}$，还需要维护 $sz$。

在查询 $(x,y)$ 时，先执行路径压缩并得到 $rt(x),rt(y)$。如果二者相同，那么 $|d_x-d_y|-1$ 就是答案。

```cpp
// Problem: P1196 [NOI2002] 银河英雄传说
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P1196
// Author: yozora0908
// Memory Limit: 128 MB
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
const int N=30005;
int T;
struct DSU {
	int fa[N], d[N], sz[N];
	void init() { rep(i,1,30000) fa[i]=i, sz[i]=1; }
	int get(int x) {
		if(x==fa[x]) return x;
		int rt=get(fa[x]);
		d[x]+=d[fa[x]];
		return fa[x]=rt;
	}
	void merge(int x,int y) {
		x=get(x), y=get(y);
		fa[x]=y, d[x]=sz[y];
		sz[y]+=sz[x];
	}
	int dis(int x) {
		return d[get(x)];
	}
} dsu;
char s[5];
signed main() {
	dsu.init();
	T=read();
	while(T--) {
		scanf("%s",s);
		if(s[0]=='M') {
			int x=read(), y=read();
			dsu.merge(x,y);
		} else {
			int x=read(), y=read();
			int fx=dsu.get(x), fy=dsu.get(y);
			if(fx!=fy) printf("-1\n");
			else printf("%lld\n",abs(dsu.d[x]-dsu.d[y])-1);
		}
	}
	return 0;
}
```

### 数列询问

>有一个长度为 $n$ 的序列 $a$，值域为 $[0,P-1]$。给出 $m$ 个条件，每个条件形如 $(l,r,x)$，表示 $\sum_{i=l}^r a_i = x$。这 $m$ 个条件可能存在自相矛盾的情况。求最大的 $k$，满足前 $k$ 个条件自洽。
>
>$n,m \le 10^6$，$P \le 10^9$。

区间和转化为前缀和的差，令 $S_i = \sum_{j=1}^i a_i$。

当一个序列的前缀和序列确定时，这个序列也被确定了。

用带权并查集维护前缀和的每一项的差，$d_i$ 表示 $S_{fa_i} + d_i = S_i$。同时每个集合的代表元素就是编号最小的元素。

加入一条边 $(l,r,x)$ 时，对 $l-1$ 与 $r$ 路径压缩，。如果它们在同一个集合内，那么如果 $|d_{l-1} - d_r| \neq x$，那么说明冲突。

另外还要解决边权值域的问题。

有一个结论。

>如果 $[l,r]$ 的权值和合法，$[l',r]$ 的权值和合法，且 $l' > l$，那么 $[l,l'-1]$ 的权值和也合法。

>证明：
>$$
>sum(l,r) = S_r - S_{l-1}  \le (r-l+1) \times P
>$$
>$$
>sum(l',r) = S_r - S_{l'-1} \le (r-l'+1) \times P
>$$
>
>$$
>sum(l,l'-1) = S_{l'-1}-S_{l-1} = (l'-l) \times P
>$$
>
>
>
>证毕。

这样我们只要单独`check`每条边即可。

## 拆点并查集

有时候我们想要维护一些关于变量的信息，通过传递性的关系判断是否出现冲突。

具体地，把每个变量拆成若干个点，表示它的若干种情况。在合并时，如果两个变量的一些有冲突的组合在同一个集合中，那么就表示信息出现了冲突。否则将存在等价关系的集合合并。

### luogu1525 [NOIP2010 提高组] 关押罪犯

将关系按照影响力递减排序，然后维护一张二分图，即有冲突的两个犯人放在同一侧。如果加入一个关系后，图不再是二分图，那么这个关系的影响力就是答案。

具体地，$(x,y)$ 拆成 $(\{x_1,x_2\},\{y_1,y_2\})$，分别表示二者在左侧还是右侧。

$x_1$ 等价于 $y_2$，$x_2$ 等价于 $y_1$。如果 $x_1$ 与 $y_1$ 或者 $x_2$ 与 $y_2$ 在同一个集合，那么产生冲突。

### luogu3940 分组

[link](https://yozora0908.github.io/2023/lg3940-solution)

### luogu2024 [NOI2001] 食物链

一个点拆三个点，分别代表同类，捕食，被捕食。

任何一种关系，都能得到两个点之间三种情况的等价关系，不再展开。

### CF1615D X(or)-mas Tree

设 $d_x$ 为根到 $x$ 路径上边权异或和的 $\operatorname{popcount}$ 的奇偶性，那么一个条件 $(x,y,z)$ 等价于 $d_x$ 是否与 $d_y$ 相等。把每个点拆成奇偶两个，拆点并查集维护即可。

如何构造？能发现边权值只需要 $0$ 和 $1$ 来调整奇偶。

这样我们根据 $d_x$ 与 $d_y$ 是否相等来确定 $(x,y)$ 放 $0$ 还是 $1$。

当然这题也可以用带权并查集来做，只不过比较胃疼。

### CF1290C  Prefix Enlightenment

任意三个子集的交集为空，说明任意下标至多存在于 $2$ 个子集中。

对于每个下标，求出包含它的子集。

1. 如果有两个，那么根据当前下标对应元素的值，可以知道它们是只能操作其中一个还是必须同时操作。

2. 如果只有一个，那么可以知道它必须被操作或者必须不被操作。

注意到一个子集需要操作，可能使得很多集合也被操作，且具有传递性，代价也有可加性。

我们把每个元素拆成操作和不操作两个点，一个连通块里的点所代表的信息必须被同时执行，代价就是点权和，然后让操作点的初始点权为 $1$。

对于第一种情况，我们将对应点合并，合并时累加点权。对于第二种，建一个虚点，从不需要执行的那种操纵往虚点连边，虚点权值为正无穷，表示必须不被选择。

从 $1$ 到 $n$ 扫一遍，每次对新加入的点求贡献。

```cpp
// Problem: C. Prefix Enlightenment
// Contest: Codeforces - Codeforces Round 616 (Div. 1)
// URL: https://codeforces.com/problemset/problem/1290/C
// Author: yozora0908
// Memory Limit: 256 MB
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
int n, k;
char s[N];
vector<int> p[N];
struct DSU {
	int fa[2*N], w[2*N];
	void init() {
		rep(i,0,2*k) fa[i]=i;
		rep(i,k+1,2*k) w[i]=1;
        // [1,k]对应不操作点
        // [k+1,2*k]对应操作点
        // 0是虚点
		w[0]=1e9;
	}
	int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
	void merge(int x,int y) {
		x=get(x), y=get(y);
		if(x!=y) fa[x]=y, w[y]+=w[x];
	}
	int getmin(int x) {
		return min(w[get(x)],w[get(x+k)]);
        // 操作或不操作取较小值
	}
} dsu;
signed main() {
	n=read(), k=read();
	scanf("%s",s+1);
	rep(i,1,k) {
		int cnt=read();
		while(cnt--) {
			int x=read();
			p[x].pb(i);
		}
	}
	dsu.init();
	int ans=0;
	rep(i,1,n) {
		if(p[i].size()==1) {
			int x=p[i][0];
			ans-=dsu.getmin(x);
			if(s[i]=='1') dsu.merge(x+k,0);
			else dsu.merge(x,0);
			ans+=dsu.getmin(x);
		} else if(p[i].size()==2){
			int x=p[i][0], y=p[i][1];
			if(dsu.get(x)!=dsu.get(y)&&dsu.get(x)!=dsu.get(y+k)) {
				ans-=dsu.getmin(x)+dsu.getmin(y);
				if(s[i]=='1') dsu.merge(x,y), dsu.merge(x+k,y+k);
				else dsu.merge(x,y+k), dsu.merge(x+k,y);
				ans+=dsu.getmin(x);
			}
		}
		printf("%lld\n",ans);
	}
	return 0;
}
```

## 其他应用

### luogu3295 [SCOI2016] 萌萌哒

考虑一个暴力。对于每个限制，用并查集合并对应点，最后看对每一个连通块集体赋值求方案数。

考虑优化。我们可以用倍增的思路，开若干个并查集，第 $k$ 个并查集合并从两个点开始长度为 $2^k$ 的一段。对于每个限制，$k$ 从大到小尽可能合并一遍。

最后倒序枚举 $k$，如果当前并查集合并了 $i$  与 $j$，那么就在第 $k-1$ 并查集里合并 $i,j$ 和 $i+2^{k-1},j+2^{k-1}$。

最后只考虑 $2^{0}$ 对应的并查集就行了。

```cpp
// Problem: #2014. 「SCOI2016」萌萌哒
// Contest: LibreOJ
// URL: https://loj.ac/p/2014
// Author: yozora0908
// Memory Limit: 256 MB
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
const int N=1e5+5, mod=1e9+7;
int n, m, lgn;
int f[N][17];
int get(int x,int k) { return x==f[x][k]? x:f[x][k]=get(f[x][k],k); }
void merge(int x,int y,int k) {
	x=get(x,k), y=get(y,k);
	if(x!=y) f[x][k]=y;
}
signed main() {
	n=read(), m=read();
	lgn=log2(n);
	rep(i,1,n) rep(j,0,lgn) f[i][j]=i;
	while(m--) {
		int l1=read(), r1=read(), l2=read(), r2=read();
		for(int i=lgn;~i;--i) {
			if(l1+(1<<i)-1<=r1) {
				merge(l1,l2,i);
				l1+=1<<i, l2+=1<<i;
			}
		}
	}
	for(int k=lgn;k;--k) for(int i=1;i+(1<<k)-1<=n;++i) {
		int j=get(i,k);
		if(i==j) continue;
		merge(i,j,k-1);
		merge(i+(1<<k-1),j+(1<<k-1),k-1);
	}
	int ans=1;
	rep(i,1,n) if(f[i][0]==i) {
		if(ans==1) (ans*=9)%=mod;
		else (ans*=10)%=mod;
	}
	printf("%lld\n",ans);
	return 0;
}
```



### CF1253F Cheap Robot

>$n$ 点 $m$ 边的图，$q$ 次询问两点间最短路径上边权的最大值。
>
>$n \le 10^5$，$m, q \le 3 \times 10^5$。

离线，把询问挂在两个点上，所有边按照边权递增排序，依次加入。

如果当前边连接了 $(x,y)$， 那么回答二者所在连通块较小的那个连通块里的询问。如果询问中的两个点此时连通，那么当前边的权值就是答案，否则就按秩合并进较大连通块。



### A

>$n$ 个孤立点，$m$ 次加边操作。$q$ 次询问两个点最早在第几次操作后连通。

OI-wiki 上的做法是建立并查集生成树。如果第 $i$ 此操作的两个点在不同的树中，那么就连接两个点所在的子树，最终得到的一定是一棵树。此时两个点之间的最大边权就是答案。

其实用上面那种做法也可以。

### B

>给定一颗 $n$ 个点的树，有 $m$ 次操作，两种类型。
>
>- 加边
>- 询问两个点之间是否有至少两条不相交路径。

询问转化为两个点是否在一个简单环上。

加边操作转化为，树上两点之间的路径都被覆盖一次。如果两点树上路径都被覆盖过了，那么就一定在至少一个简单环上。

给树定根，用并查集维护每个点到根的路径上第一条没有被覆盖的边，然后加边时搞出 $\operatorname{LCA}$，暴力跳并查集。查询只需要看两个点到根的路径上第一条没有被覆盖的边的深度是否都大于等于 $\operatorname{LCA}$ 即可。
