---
title: 「NOIP Record」#16 欧拉路径与拓扑排序
pubDate: 2023-08-24
tags:
  - 欧拉路径
  - 拓扑排序
  - 图论
categories:
  - Record
description: '少年不放过每一个死角'
---

## 欧拉路径

### 定义

从一个点出发，不重不漏地经过图中每一条边的一条路径，允许重复经过节点。

### 无向图

首先必须是连通图，其次是两种情况。

1. 所有点的度数是偶数。
2. 恰好存在两个点的度数是奇数。

### 有向图

要求连通。

1. 所有点的入度等于出度。
2. 恰好存在一个节点入度比出度多 $1$，一个节点入度比出度少 $1$。

## 欧拉回路

### 定义

起点和终点是一个点的欧拉路径。

### 无向图

连通，所有点的度数都是偶数。

### 有向图

连通，所有点的入度等于出度。

## Hierholzer算法

这个 H 姓算法的实现有很多。

```cpp
dfs(x)
     for each edge (x,y) in E
         if vis[(x,y)]=0
             vis[(x,y)]=1
             dfs(y)
     push_front y to ans
```

直接暴力跑是 $O(nm)$ 的。

使用邻接表存图的话，建完图后访问每个点连出边是有顺序的。

记录一下访问到了哪条边即可。

那么下面代码的复杂度就是 $O(n+m)$。

```cpp
int n, m, tot=1, h[N], to[M<<1], nxt[M<<1];
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dfs(int x) {
	for(int& i=h[x];i;i=nxt[i]) {
		if(!v[i>>1]) {
			v[i>>1]=1;
			dfs(to[i]);
		}
	}
	ans.pb(x);
}
signed main() {
    dfs(1);
    reverse(ans.begin(),ans.end());
}
```

另外还有模拟机器递归的实现，不会爆栈。但是我记不住。

## 题

这个算是冷门知识点了，但是大纲里有。

要么太难要么偏板。

### luogu2731 [USACO3.3] 骑马修栅栏

就是板子。

只不过两点之间可以有多条路径。

我们走一次干掉一条就好了。

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
const int N=1145;
int n, lim, deg[N], e[N][N];
vector<int> ans;
void dfs(int x) {
	for(int y=1;y<=lim;++y) if(e[x][y]) {
		--e[x][y], --e[y][x];
		dfs(y);
	}
	ans.pb(x);
}
signed main() {
	n=read();
	rep(i,1,n) {
		int x=read(), y=read();
		++e[x][y], ++e[y][x];
		++deg[x], ++deg[y];
		lim=max({lim,x,y});
	}
	int cnt=0, st=0;
	rep(i,1,lim) if(deg[i]&1) {
		++cnt;
		if(!st) st=i;
	}
	if(!st) {
		rep(i,1,lim) if(deg[i]) { st=i; break; }
	}
	dfs(st);
	reverse(ans.begin(),ans.end());
	for(auto x:ans) printf("%lld\n",x);
	return 0;
}
```

### UVA10129 Play on Words

其实问题就是二选一：

1. 单词为点。结尾为字母 $\pi$ 的单词向开头为字母 $\pi$ 的单词连边。

2. 字母为点。每个单词的首字母向尾字母连边。

很重要的一点是每个字母必须都出现一次且仅一次。

第一种方式，问题转化哈密顿回路，做不了。

第二种方式，问题转化为欧拉路径，可以做。



### CF547D Mike and Fish

个人感觉这题的建模方式就不太自然了。

对每行每列都建一个点，对于节点 $(x,y)$，在 $x$ 与 $y$ 之间连一条无向边，然后对边定向，使得每个点的入度出度只差不超过 $1$。

然后连边后是个二分图。可以没用。

考虑简化版，所有点的度数都是偶数。

在图上跑欧拉回路，按照路径上经过点的顺序定向，就能得到一组合法解。

考虑原版。如果能将度数为奇数的点改为偶数，那么就能归约到弱化版了。

建一个虚点，把度数为奇数的点向虚点连双向边。奇度点一定有偶数个，所以此时包括虚点在内所有点的度数都是偶数，跑欧拉回路即可。

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
const int N=4e5+5, DLT=2e5;
int n, deg[N], v[N];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void dfs(int x) {
	for(int& i=h[x];i;i=nxt[i]) {
		int j=i>>1;
        // i>>1定位到i这条边对应的横坐标点的编号
		if(!v[j]) {
			v[j]=1+(x<=DLT);
			dfs(to[i]);
		}
	}
}
signed main() {
	n=read();
	tot=1;
    // 注意
	rep(i,1,n) {
		int x=read(), y=read();
		add(x,y+DLT), add(y+DLT,x);
        // [1,DLT]是横坐标域，[DLT+1,2*DLT]的是纵坐标域
		++deg[x], ++deg[y+DLT];
	}
	rep(i,1,2*DLT) if(deg[i]&1) {
		add(0,i), add(i,0);
	}
	rep(i,1,DLT) dfs(i);
	rep(i,1,n) {
		printf("%c","rb"[v[i]-1]);
        // 只需要考虑前n个横坐标点的连边情况
	}
	return 0;
}

```

## 拓扑排序

随便放点题。

### luogu3243 [HNOI2015] 菜肴制作

在满足限制的情况下，字典序小的数尽可能靠前。

用小根堆去贪显然是错的。

考虑较大的数在合法的范围内尽可能靠后是优秀的，所以建反图，用大根堆贪心求出反图的拓扑序，它的逆序就是答案。

### CF gym104053C Customs Controls 2

设 $d(x)$ 为 $1$ 到 $x$ 的最长路。那么对于 $n$ 和它的入点集合 $\{y\}$，应该满足所有 $d(y)$ 都相等。归纳得到对于任意节点的入点集合 $\{y\}$，都有所有 $d(y)$ 相等。

用并查集把所有点的入点缩成一个点，再此基础上连边。如果出现环，那么说明存在某个点的点权要求是 $0$，从而无解。否则对这张图拓扑排序求出到每个节点的最长路。最后用**一个点所在连通块的最长路**减掉**它的入点集合所在连通块**的最长路就是这个点的点权。

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
const int N=2e5+5;
int T, n, m, in[N], f[N];
vector<int> p[N], q[N];
vector<PII > e;
struct DSU {
	int fa[N];
	void init() { rep(i,1,n) fa[i]=i; }
	int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
	void merge(int x,int y) {
		x=get(x), y=get(y);
		if(x!=y) fa[x]=y;
	}
} dsu;
void solve() {
	n=read(), m=read();
	rep(i,1,n) p[i].clear(), q[i].clear(), in[i]=f[i]=0;
	e.clear();
	rep(i,1,m) {
		int x=read(), y=read();
		q[y].pb(x);
		e.pb({x,y});		
	}
	dsu.init();
	rep(x,1,n) {
		for(auto y:q[x]) {
			dsu.merge(y,q[x][0]);
            // 这里是与第一个入点合并了
		}
	}
	for(auto t:e) {
		int x=t.fi, y=t.se;
		x=dsu.get(x), y=dsu.get(y);
		p[x].pb(y), ++in[y];
	}
	int cnt=0;
	queue<int> qu;
	rep(i,1,n) {
		if(i==dsu.get(i)) {
			++cnt;
			if(!in[i]) f[i]=1, qu.push(i);
		}
	}
	while(qu.size()) {
		int x=qu.front(); qu.pop();
		--cnt;
		for(auto y:p[x]) {
			f[y]=max(f[y],f[x]+1);
			if(--in[y]==0) qu.push(y);
		}
	}
	if(cnt) { puts("No"); return; }
	puts("Yes");
	for(int i=1;i<=n;++i) {
		int ans=f[dsu.get(i)];
		if(i!=1) ans-=f[dsu.get(q[i][0])];
		printf("%lld ",ans);
	}
}
signed main() {
	T=read();
	while(T--) solve();
	return 0;
}
```

