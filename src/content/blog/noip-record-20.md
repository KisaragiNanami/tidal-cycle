---
title: 「NOIP Record」#20 树论（1）树上差分与树上倍增
pubDate: 2023-09-07
tags:
  - 树论
  - 线段树
  - 树状数组
  - 树链剖分
  - 树上差分
  - 树上倍增
categories: Record
description: '少年开始建造舒适区'
---



## 树上差分

从抽象代数的角度讲，树上差分可以维护所有群上信息。

换句话说，满足结合律，存在「可减性」。

>通过差分我们能将一个高纬问题以常数代价转化为低维问题，而问题低一维往往会简单非常多
>
>—— lxl



太 $\textit{Trivial}$ 的我们就不提了。

下文成「前缀」为根到节点的路径。

### luogu8201 [yLOI2021] 生活在树上（hard version）

考虑这样一个结论。

>树上路径 $(t,x)$ 与 $(t,y)$，一定是先有一段重合的路径，再与路径 $(x,y)$ 交于一点 $z$，然后分别连向对应的点。

这个有什么用呢？我们可以把 $\text{dis}_{t,a} \oplus \text{dis}_{t,b} = k$ 转化为 $\text{dis}_{a,b} \oplus w_z = k$， 其中 $z$ 是 $t$ 与路径 $(a,b)$ 的交点。

更进一步地，询问 $(a,b,k)$ 等价于查询路径 $(a,b)$ 上是否存在点 $z$，满足 $w_z = k \oplus \text{dis}_{a,b}$。



设 $h(x,k)$ 为根到 $x$ 的路径上，点权为 $k$ 的点的个数，$c=\operatorname{LCA}(a,b)$。

我们把询问拆成前缀，放到 $a,b,c,fa(c)$ 上，在对应点处打上 $k \oplus \text{dis}_{a,b}$ 的标记。开一个全局桶，一个点的贡献只会在其子树中产生，访问时加入，回溯时撤销即可。然后开个`std::unordered_map`数组统计在 $x$ 处统计所有标记对应的值，就能在 $O(n)-O(1)$ 的复杂度内解决问题。

>把对路径的询问差分成对前缀的询问。

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
const int N=5e5+5;
int n, m, w[N], d[N];
int son[N], dep[N], sz[N], top[N], fa[N];
vector<int> p[N];
struct node {
	int x, y, z, k;
} q[N];
vector<int> r[N];
unordered_map<int,int> mp, ans[N];
void dfs1(int x,int fr) {
	fa[x]=fr;
	dep[x]=dep[fr]+1;
	sz[x]=1;
	d[x]=d[fr]^w[x];
	for(auto y:p[x]) if(y!=fr) {
		dfs1(y,x);
		if(sz[y]>sz[son[x]]) son[x]=y;
		sz[x]+=sz[y];
	}
}
void dfs2(int x,int tp) {
	top[x]=tp;
	if(!son[x]) return;
	dfs2(son[x],tp);
	for(auto y:p[x]) if(y!=fa[x]&&y!=son[x]) {
		dfs2(y,y);
	}
}
int lca(int x,int y) {
	while(top[x]!=top[y]) {
		if(dep[top[x]]<dep[top[y]]) swap(x,y);
		x=fa[top[x]];
	}
	if(dep[x]>dep[y]) swap(x,y);
	return x;
}
void dfs3(int x) {
	++mp[w[x]];
	for(auto y:r[x]) ans[x][y]=mp[y];
	for(auto y:p[x]) if(y!=fa[x]) {
		dfs3(y);
	}
	--mp[w[x]];
}
signed main() {
	n=read(), m=read();
	rep(i,1,n) w[i]=read();
	rep(i,2,n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	dfs1(1,0);
	dfs2(1,1);
	rep(i,1,m) {
		q[i].x=read(), q[i].y=read(), q[i].k=read();
		q[i].z=lca(q[i].x,q[i].y);
		q[i].k=q[i].k^d[q[i].x]^d[q[i].y]^w[q[i].z];
		int x=q[i].x, y=q[i].y, z=q[i].z, k=q[i].k;
		r[x].pb(k), r[y].pb(k);
		r[z].pb(k), r[fa[z]].pb(k);
	}
	dfs3(1);
	
	for(int i=1;i<=m;++i) {
		int x=q[i].x, y=q[i].y, z=q[i].z, k=q[i].k;
		int cnt=ans[x][k]+ans[y][k]-ans[z][k]-ans[fa[z]][k];
		if(cnt>0) puts("YeS"); else puts("nO");
	}
	return 0;
}
```



### luogu1600 [NOIP2016 提高组] 天天爱跑步

[link](https://yozora0908.github.io/2021/lg1600-solution)

>把路径的贡献拆成前缀的贡献，维护子树和。

### luogu2680 [NOIP2015 提高组] 运输计划

首先答案是可以二分的。

问题转化为：判定是否能通过把一条边的权值置为 $0$，使得给定的路径中，最长的路径不超过 $mid$，

我们考虑所有长度超过 $mid$ 的路径，设其的数量为 $cnt$。那么 $mid$ 可行当且仅当存在一条被经过 $cnt$ 次，并且其长度大于等于 $\max_{i=1}^m \big\{dis(u_i,v_i) \big\} - mid$。

怎么做？把路径差分了再做子树和，求出每条边被覆盖的次数，检查一遍即可。

但是这题卡常，需要预处理出 $\text{DFS}$ 序再倒着做子树和。

```cpp
// Problem: P2680 [NOIP2015 提高组] 运输计划
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P2680
// Author: yozora0908
// Memory Limit: 292 MB
// Time Limit: 1000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=3e5+5;
int n, m, c[N];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
int sz[N], fa[N], son[N], dep[N], d[N], top[N];
int num,  idf[N];
struct node {
	int x, y, z, d;
} a[N];
void add(int x,int y,int z)  {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
void dfs1(int x,int fr) {
	fa[x]=fr, dep[x]=dep[fr]+1;
	idf[++num]=x;
	sz[x]=1;
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i], z=w[i];
		if(y==fr) continue;
		d[y]=d[x]+z;
		dfs1(y,x);
		if(!son[x]||sz[y]>sz[son[x]]) son[x]=y;
		sz[x]+=sz[y];
	}
}
void dfs2(int x,int tp) {
	top[x]=tp;
	if(!son[x]) return;
	dfs2(son[x],tp);
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i];
		if(y==fa[x]||y==son[x]) continue;
		dfs2(y,y);
	}
}
int lca(int x,int y) {
	while(top[x]!=top[y]) {
		if(dep[top[x]]<dep[top[y]]) swap(x,y);
		x=fa[top[x]];
	}
	return 	dep[x]<dep[y]? x:y;
}
bool check(int x) {
	int mx=0, cnt=0;
	rep(i,1,n) c[i]=0;
	for(int i=1;i<=m;++i) if(a[i].d>x) {
		++c[a[i].x], ++c[a[i].y], c[a[i].z]-=2;
		mx=max(mx,a[i].d-x);
		++cnt;
	}
	per(i,n,1) c[fa[idf[i]]]+=c[idf[i]];
	rep(i,2,n) if(d[i]-d[fa[i]]>=mx&&c[i]==cnt) {
		return 1;
	}
	return 0;
}
signed main() {
	n=read(), m=read();
	rep(i,2,n) {
		int x=read(), y=read(), z=read();
		add(x,y,z), add(y,x,z);
	}
	dfs1(1,0);
	dfs2(1,1);
	int L=0, R=0;
	rep(i,1,m) {
		a[i].x=read(), a[i].y=read();
		a[i].z=lca(a[i].x,a[i].y);
		a[i].d=d[a[i].x]+d[a[i].y]-2*d[a[i].z];
		R=max(R,a[i].d);
	}
	while(L<R) {
		int mid=(L+R)>>1;
		if(check(mid)) R=mid; else L=mid+1;
	}
	printf("%d\n",L);
	return 0;
}
```





### luogu4219 [BJOI2014] 大融合

对于一个询问 $(x,y)$，答案就是两边连通块大小之积。

不过显然不能直接做。

考虑离线，把树定根后建起来。钦定 $\text{dep}(x) \le \text{dep}(y)$，那么答案就是**此时与 $x$ 连通的子树大小**减去**此时以 $y$ 为根且连通的子树大小**，最后再乘上后者。注意这里的子树就是定根后原树中的。

这个怎么维护呢？用并查集维护连通块，每个连通块的根是原树种深度最低的那个点。如果连边 $(x,y)$，那么 $y$ 此时所在连通块一定都会贡献到 $x$ 以及其父亲的子树中去。

也就是说这是个链加，我们直接差分掉。问题转化为链加，单点求子树和，摊到 $\text{DFS}$ 序上即可用树状数组维护。在 $x$ 处产生贡献，同时在 $x$ 所在连通块的根**在原树中的父亲处消去贡献**，这样就能保证只会贡献到当前连通情况下的点上。

任意时刻，与 $x$ 连通的子树大小就是此时 $x$ 所在连通块的大小，以 $y$ 为根且连通的子树大小就是 $y$ 的子树和再加上 $1$。

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
int n, Q, dep[N], tfa[N], tsz[N];
int num, dfn[N];
struct query {
	int op, x, y;
} q[N];
vector<int> p[N];
struct BIT {
	int c[N];
	void upd(int x,int y) {
		if(x==0) return;
		for(;x<=n;x+=x&-x) c[x]+=y;
	}
	int query(int x) {
		
		int res=0;
		if(x==0) return res; 
		for(;x;x-=x&-x) res+=c[x];
		return res;
	}
} T, bit;
void dfs(int x,int fr) {
	dep[x]=dep[fr]+1;
	tfa[x]=fr;
	dfn[x]=++num;
	tsz[x]=1;
	for(auto y:p[x]) if(y!=fr) {
		dfs(y,x);
		tsz[x]+=tsz[y];
	}
}
struct DSU {
	int fa[N], sz[N], siz[N];
	void init() {
		rep(i,1,n) fa[i]=i, siz[i]=1;
	}
	int get(int x) {
		return x==fa[x]? x:fa[x]=get(fa[x]);
	}
	void merge(int x,int y) {
		if(dep[x]>dep[y]) swap(x,y);
		int fx=get(x), fy=get(y);
		if(fx==fy) return;
		fa[y]=fx;
		siz[fx]+=siz[y];
		T.upd(dfn[x],siz[y]);
		T.upd(dfn[tfa[fx]],-siz[y]);
	}
} dsu;
void add(int x,int y) {
	p[x].pb(y), p[y].pb(x);
}
char s[3];
signed main() {
	n=read(), Q=read();
	rep(i,1,Q) {
		scanf("%s",s);
		if(s[0]=='A') q[i].op=1; else q[i].op=2;
		q[i].x=read(), q[i].y=read();
		if(q[i].op==1) add(q[i].x,q[i].y);
	}
	rep(i,1,n) if(!dfn[i]) dfs(i,0);
	dsu.init();
	rep(i,1,Q) {
		int x=q[i].x, y=q[i].y;
		if(q[i].op==1) {
			dsu.merge(x,y);
		} else {
			if(dep[x]>dep[y]) swap(x,y);
			int size=dsu.siz[dsu.get(x)];
			int szy=T.query(dfn[y]+tsz[y]-1)-T.query(dfn[y]-1)+1;
			printf("%lld\n",(size-szy)*szy);
		}
	}
	return 0;
}
```



### luogu4211 [LNOI2014] LCA

首先把询问差分了，考虑求 $\sum_{i=1}^r \text{dep}\Big(\text{LCA}(i,z)\Big) $。

从贡献的角度，$\text{dep}\Big(\text{LCA}(i,z)\Big)$ 可以被具象化为根到 $i$ 与 $z$ 的路径上交点的个数。

把询问离线了，询问挂到 $l-1$ 与 $r$ 上。从 $1$ 到 $n$ 枚举节点 $i$，并且使根到 $i$ 的路径点权都 $+1$。

具体地，对于一个询问 $(z,op,id)$，我们查询此时根到 $z$ 的链和，带上系数 $op$ 累加进 $ans(id)$ 即可。

树剖套线段树即可维护。

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
const int N=5e4+5, mod=201314;
int n, m, ans[N];
vector<int> p[N];
int son[N], top[N], dep[N], sz[N], fa[N];
int num, dfn[N];
void dfs1(int x,int fr) {
	fa[x]=fr;
	sz[x]=1;
	dep[x]=dep[fr]+1;
	for(auto y:p[x]) {
		dfs1(y,x);
		if(sz[y]>sz[son[x]]) son[x]=y;
		sz[x]+=sz[y];
	}
}
void dfs2(int x,int tp) {
	top[x]=tp;
	dfn[x]=++num;
	if(!son[x]) return;
	dfs2(son[x],tp);
	for(auto y:p[x]) {
		if(y!=son[x]) dfs2(y,y);
	} 
}
int t[N<<2], tag[N<<2];
void pushup(int x) { t[x]=t[x<<1]+t[x<<1|1]; }
void maketag(int x,int l,int r,int d) {
	t[x]+=(r-l+1)*d;
	tag[x]+=d;
}
void pushdown(int x,int l,int r) {
	if(tag[x]) {
		int mid=(l+r)>>1;
		maketag(x<<1,l,mid,tag[x]);
		maketag(x<<1|1,mid+1,r,tag[x]);
		tag[x]=0;
	}
}
void Seg_upd(int L,int R,int d,int x=1,int l=1,int r=n) {
	if(L<=l&&r<=R) { maketag(x,l,r,d); return; }
	pushdown(x,l,r);
	int mid=(l+r)>>1;
	if(L<=mid) Seg_upd(L,R,d,x<<1,l,mid);
	if(R>mid) Seg_upd(L,R,d,x<<1|1,mid+1,r);
	pushup(x);
}
int Seg_query(int L,int R,int x=1,int l=1,int r=n) {
	if(L<=l&&r<=R) return t[x];
	pushdown(x,l,r);
	int mid=(l+r)>>1, res=0;
	if(L<=mid) (res+=Seg_query(L,R,x<<1,l,mid))%=mod;
	if(R>mid) (res+=Seg_query(L,R,x<<1|1,mid+1,r))%=mod;
	return res;
}
struct Q {
	int z, op, id;
	Q() {}
	Q(int _z,int _op,int _id) { z=_z, op=_op, id=_id; } 
};
vector<Q> q[N];
void upd(int x,int y,int d) {
	while(top[x]!=top[y]) {
		if(dep[top[x]]<dep[top[y]]) swap(x,y);
		Seg_upd(dfn[top[x]],dfn[x],1);
		x=fa[top[x]];
	}
	if(dep[x]>dep[y]) swap(x,y);
	Seg_upd(dfn[x],dfn[y],1);
}
int query(int x,int y) {
	int res=0;
	while(top[x]!=top[y]) {
		if(dep[top[x]]<dep[top[y]]) swap(x,y);
		(res+=Seg_query(dfn[top[x]],dfn[x]))%=mod;
		x=fa[top[x]];
	}
	if(dep[x]>dep[y]) swap(x,y);
	(res+=Seg_query(dfn[x],dfn[y]));
	return res;
}
void solve() {
	rep(i,1,n) {
		upd(1,i,1);
		for(auto t:q[i]) {
			int z=t.z, op=t.op, id=t.id;
			int res=query(1,z);
			ans[id]+=res*op;
			(ans[id]+=mod)%=mod;
		}
	}
}
signed main() {
	n=read(), m=read();
	rep(i,2,n) {
		int x=read()+1;
		p[x].pb(i);
	}
	dfs1(1,0);
	dfs2(1,1);
	for(int i=1;i<=m;++i) {
		int l=read()+1, r=read()+1, z=read()+1;
		q[r].pb(Q(z,1,i));
		if(l-1>0) q[l-1].pb(Q(z,-1,i));
	}
	solve();
	rep(i,1,m) printf("%lld\n",ans[i]);
	return 0;
}

```

### luogu4216 [SCOI2015]情报传递

发现操作一挺难搞的。

考虑第二种操作。$i$ 时刻点权大于 $c$，等价于开始时间小于 $i-c$。问题转化为求一条链上小于某个数的个数。

lxl 课件上说用树剖 + 树状数组可以做到 $O(m \log_2^2 n)$，但是我不会。

继续观察。如果我们把操作一看成一个点的点权从 $0$ 变成 $1$，问题等价于求 $i-c-1$ 时刻 $(x,y)$ 的链和。

把询问差分成前缀和相减，离线后挂到时间上，单点加转化为子树加，树状数组即可维护。

时间复杂度是 $O(m \log_2 n)$。

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
int n, rt, Q, ans[N];
vector<int> p[N];
struct Query {
	int op, x, y, c;
} q[N];
struct node {
	int x, y, id;
};
vector<node> v[N];
int son[N], top[N], dep[N], sz[N], fa[N];
int num, dfn[N];
struct BIT {
	int c[N];
	void upd(int x,int d) {
		if(x<=0) return;
		for(;x<=n;x+=x&-x) c[x]+=d;
	}
	int query(int x) {
		int res=0;
		if(x<=0) return res;
		for(;x;x-=x&-x) res+=c[x];
		return res;		
	}
} T;
void dfs1(int x,int fr) {
	fa[x]=fr;
	sz[x]=1;
	dep[x]=dep[fr]+1;
	for(auto y:p[x]) {
		dfs1(y,x);
		if(sz[y]>sz[son[x]]) son[x]=y;
		sz[x]+=sz[y];
	}
}
void dfs2(int x,int tp) {
	top[x]=tp;
	dfn[x]=++num;
	if(!son[x]) return;
	dfs2(son[x],tp);
	for(auto y:p[x]) {
		if(y!=son[x]) dfs2(y,y);
	} 
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
	return dep[x]+dep[y]-dep[z]-dep[fa[z]];
}
int calc(int x,int y) {
	int z=lca(x,y);
	return T.query(dfn[x])+T.query(dfn[y])-T.query(dfn[z])-T.query(dfn[fa[z]]);
}
signed main() {
	n=read();
	rep(i,1,n) {
		int x=read();
		if(x!=0) p[x].pb(i); else rt=i;
	}
	Q=read();
	rep(i,1,Q) {
		q[i].op=read();
		if(q[i].op==1) {
			q[i].x=read(), q[i].y=read(), q[i].c=read();
			if(i-q[i].c-1>=0) v[i-q[i].c-1].pb((node){q[i].x,q[i].y,i});
		} else q[i].x=read();
	}
	
	dfs1(rt,0);
	dfs2(rt,rt);
	rep(i,0,Q) {
		if(q[i].op==2) {
			int x=q[i].x;
			T.upd(dfn[x],1);
			T.upd(dfn[x]+sz[x],-1);
		}
		for(auto t:v[i]) {
			ans[t.id]=calc(t.x,t.y);
		}
	}
	rep(i,1,Q) if(q[i].op==1) {
		printf("%lld %lld\n",dis(q[i].x,q[i].y),ans[i]);
	}
	return 0;
}

```

## 树上倍增

没啥技巧，直接上题。

### CF932D Tree

 设 $f(x,i)$ 表示从 $x$ 往上提取一个长度为 $2^i$ 的点权单调不降子序列（不含 $x$），最后一项的节点编号。

发现要是能处理出 $f(x,0)$ 就做完了。

对于一个新加入的 $x$，如果 $f(x,0) \neq fa(x)$，那么就从 $fa(x)$ 向上找到最后一个满足 $w_p < w_x$ 的 $p$，$fa(p)$ 就是 $f(x,0)$。

### CF519E A and B and Lecture Rooms

运用本文第一题的结论。

一个点分别到 $x$ 与 $y$ 的路径，一定是先重合一段，然后路径 $(x,y)$ 的一个点上分开。也就是说，到二者的距离相等的点，一定满足这个交点是路径 $(x,y)$ 的中点。

设中点为 $p$，考虑其与 $z=\text{LCA}(x,y)$ 的关系。

设 $pre_x(y)$ 为 $x$ 的一个祖先，满足其是 $y$ 的子节点。

- $p=z$，答案就是 $n-pre_x(z)-pre_y(z)$。
- $p$ 在靠近 $x$ 的那一侧，答案是 $sz_{p} - pre_x(p)$。
- $p$ 在靠近 $y$ 的那一侧，答案是 $sz_p - pre_y(p)$。



$\text{dep}(p)$ 可以根据 $(x,y,z)$ 的深度关系得到，然后倍增求出 $q$。

$pre_x(y)$ 也可以从 $x$ 往上倍增出来。



### LOJ #2955. 「NOIP2018」保卫王国

[link](https://yozora0908.github.io/2023/loj2955-solution)
