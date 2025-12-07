---
title: 「NOIP Record」#13 树形DP（2）
pubDate: 2023-08-09
tags:
  - DP
  - 树形DP
  - 计数
  - 容斥原理
  - 子集反演
  - 组合数学
categories: Record
description: '少年一再呼喊'
---

### [ARC101E] Ribbons on Tree

对于以 $x$ 为根的子树，如果 $(x,fa_x)$ 的边没有被覆盖，那么说明子树内没有任何一个点与子树外的点匹配。

把这些没有被覆盖的边看作特殊边，那么整棵树就被若干特殊边划分成了若干连通块。我们要求的是不含任何特殊边的匹配方案。

考虑容斥。钦定一个边集 $S$，表示 $S$ 内的边一定是特殊边。根据**子集反演**，容斥系数为 $(-1)^{|S|}$。

用树形背包维护连通块，设 $f_{x,i,j}$ 为以 $x$ 为根的子树中，$x$ 所在连通块大小为 $i$，其中特殊边集大小为 $j$ 的方案数，容斥系数就是 $(-1)^j$。转移就是讨论 $(x,y)$ 这条边要不要加入特殊边集。如果加入，那么以 $y$ 为根的连通块闭合，在这里可以计算任意两两匹配的方案数。 

然而这样复杂度过高，瓶颈在于 $j$ 这一维。一种解决方案只记录 $j$ 的奇偶性，不过更好的做法则是把这个容斥系数放进 DP 值里面。具体地，对 $j$ 这一维做前缀和，设 $f_{x,i}$ 为以 $x$ 为根的子树，$x$ 所在连通块大小为 $i$ 的方案数。每有一个连通块闭合，就有一条边没有被覆盖，要多乘一个 $-1$，对应到实现就是这部分的方案做减法。

$2n$ 个点两两匹配的方案是
$$
\frac{\binom{2n}{n}n!}{2^n}
$$

或者说
$$
h_{2n} = h_{2n-2} \times (2n-1)
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
const int N=5005, mod=1e9+7;
int n, f[N][N], g[N], sz[N], h[N];
vector<int> p[N];
void dfs(int x,int fa) {
	f[x][1]=sz[x]=1;
	for(auto y:p[x]) if(y!=fa) {
		dfs(y,x);
		for(int i=1;i<=sz[x];++i) {
			int t=0;
			for(int j=1;j<=sz[y];++j) {
				(g[i+j]+=f[x][i]*f[y][j]%mod)%=mod;
				(g[i]-=f[x][i]*f[y][j]%mod*h[j]%mod-mod)%=mod;
			}
		}
		sz[x]+=sz[y];
		for(int i=1;i<=sz[x];++i) f[x][i]=g[i], g[i]=0;
	}
}
signed main() {
	n=read();
	rep(i,2,n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	h[2]=h[0]=1;
	for(int i=4;i<=n;i+=2) h[i]=h[i-2]*(i-1)%mod;
	dfs(1,0);
	int ans=0;
	for(int i=2;i<=n;i+=2) (ans+=f[1][i]*h[i]%mod)%=mod;
    // 闭合最后一个连通块
	printf("%lld\n",ans);
	return 0;
}
```

### CF Gym104160 E. Graph Completing

最终的图是一张边双连通图，也就是不存在割边。

先把边双缩了，内部点随便连。

剩下的每一条树边都是割边。考虑容斥，设 $f_{x,i,j}$ 为以 $x$ 为根的子树，$x$ 所在连通块大小为 $i$，子树中有 $j$ 条割边的方案。

与上一题相同，转移还是讨论边 $(x,y)$ 的情况。不同的是在连通块闭合时不太容易计算方案数，所以要在 $(x,y)$ 加入以 $x$ 所在连通块时统计。具体地，选取 $(x,y)$ 为基准点，设 $x$ 所在连通块大小为 $j$，$y$ 所在连通块大小为 $k$，那么总共有 $j \times k -1$ 条可以连的边能覆盖 $(x,y)$，方案数 $2^{\max(j \times k -1,0)}$。注意除了钦定的边集之外，并不需要保证连通块也是边双。

然后就是把容斥系数塞进 DP 值去。

```cpp
// Problem: E. Graph Completing
// Contest: Codeforces - The 2022 ICPC Asia Shenyang Regional Contest (The 1st Universal Cup, Stage 1: Shenyang)
// URL: https://codeforc.es/gym/104160/problem/E
// Author: KisaragiQwQ
// Date: 2023-06-27 07:14:30
// Memory Limit: 512 MB
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
const int N=5005, M=2e4+5, mod=998244353;
int n, m, num, dfn[N], low[N], sz[N], pw[N*N>>1];
int f[N][N], g[N];
int tp, st[N];
int dcc, bel[N], ecnt[N];
bool v[N][N];
struct G {
	int tot, h[N], to[M], nxt[M];
	void add(int x,int y) { to[++tot]=y, nxt[tot]=h[x], h[x]=tot; }
} G, T;
void tarjan(int x,int lst) {
	dfn[x]=low[x]=++num, st[++tp]=x;
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
		do y=st[tp--], ++sz[dcc], bel[y]=dcc; while(x!=y);
	}
}
void suodian() {
	T.tot=1;
	for(int i=2;i<=G.tot;++i) {
		int x=G.to[i^1], y=G.to[i];
		if(bel[x]==bel[y]) ++ecnt[bel[x]];
		if(bel[x]==bel[y]||v[bel[x]][bel[y]]) continue;
		v[bel[x]][bel[y]]=v[bel[y]][bel[x]]=1;
		T.add(bel[x],bel[y]), T.add(bel[y],bel[x]);
	}
	pw[0]=1;
	for(int i=1;i<=n*(n-1)/2;++i) pw[i]=pw[i-1]*2%mod;
}
void dfs(int x,int fa) {
	f[x][sz[x]]=pw[sz[x]*(sz[x]-1)/2-(ecnt[x]>>1)];
	for(int i=T.h[x];i;i=T.nxt[i]) {
		int y=T.to[i];
		if(y==fa) continue;
		dfs(y,x);
		for(int j=0;j<=sz[x];++j) {
			int t=0;
			for(int k=0;k<=sz[y];++k) {
				(g[j+k]+=f[x][j]*f[y][k]%mod*pw[max(j*k-1,0ll)]%mod)%=mod;
				(g[j]-=f[x][j]*f[y][k]%mod-mod)%=mod;
			}
		}
		sz[x]+=sz[y];
		for(int j=0;j<=sz[x];++j) f[x][j]=g[j], g[j]=0;
	}
}
signed main() {
	n=read(), m=read();
	G.tot=1;
	rep(i,1,m) {
		int x=read(), y=read();
		G.add(x,y), G.add(y,x);
	}
	tarjan(1,0);
	suodian();
	dfs(1,0);
	int ans=0;
	for(int i=1;i<=n;++i) (ans+=f[1][i])%=mod;
	printf("%lld\n",ans);
	return 0;
}
```



### CF Gym103427 L. Perfect Matchings

怎么又是 ICPC shenyang。

转化一下题意，$2n$ 个点完美匹配就是两两匹配，但是有 $2n-1$ 条构成一棵树的边不允许使用。不妨只考虑树边。

和第一题很像，但也有不同，所以先子集反演一下。设 $f(S)$ 为至少使用了边集 $S$ 内的边的完美匹配数量，$g(S)$ 为恰好使用了边集 $S$ 内的边的完美匹配数量。
$$
g(\varnothing) = \sum_{S \in U} (-1)^{|S|} f(S)
$$
类比第一题，前者是求至少让边集 $S$ 内的边没有被经过，从而划分成若干连通块，而后者则是至少让边集 $S$ 的边被经过。对于「不被经过」，可以直接钦定，把匹配操作放到连通块闭合处进行。而对于「经过」操作，则必须通过匹配完成，因此设 $f_{x,i,j,0/1}$ 为以 $x$ 为根的子树，匹配了 $i$ 对点，经过了$j$ 条边，其中 $x$ 有没有匹配的方案数。讨论是否匹配 $(x,y)$ 即可转移。

依然是对 $j$ 这一维做前缀和，在匹配 $(x,y)$ 处带上系数即可。

&nbsp;

有人可能会说，如果设 $f(S)$ 至少为没有经过 $S$ 内的边，$g(S)$ 为恰好没有使用 $S$ 内的树边，那么不就转化成了第一题的形式了吗？不能。因为本题中一条树边 $(x,y)$ 没有被使用的充要条件是 $x$ 没有匹配 $y$，而不是第一题中的子树内没有和外部匹配的点。



```cpp
// Problem: L. Perfect Matchings
// Contest: Codeforces - The 2021 ICPC Asia Shenyang Regional Contest
// URL: https://codeforces.com/gym/103427/problem/L
// Author: KisaragiQwQ
// Date: 2023-06-28 09:17:48
// Memory Limit: 512 MB
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
const int N=4005, mod=998244353;
int n, f[N][N/2][2], g[N/2][2], sz[N], h[N];
vector<int> p[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
void dfs(int x,int fa) {
	f[x][0][0]=sz[x]=1;
	for(auto y:p[x]) if(y!=fa) {
		dfs(y,x);
		for(int i=0;i<=sz[x]/2;++i) for(int j=0;j<=sz[y]/2;++j) {
			(g[i+j][0]+=f[x][i][0]*(f[y][j][0]+f[y][j][1])%mod)%=mod;	
			(g[i+j][1]+=f[x][i][1]*(f[y][j][0]+f[y][j][1])%mod)%=mod;
			(g[i+j+1][1]-=f[x][i][0]*f[y][j][0]%mod-mod)%=mod;
		}
		sz[x]+=sz[y];
		for(int i=0;i<=sz[x]/2;++i) f[x][i][0]=g[i][0], f[x][i][1]=g[i][1], g[i][0]=g[i][1]=0;
	}
}
signed main() {
	n=read();
	rep(i,2,2*n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	h[0]=1;
	for(int i=2;i<=2*n;i+=2) h[i]=h[i-2]*(i-1)%mod;
	dfs(1,0);
	int ans=0;
	for(int i=0;i<=n;++i) (ans+=(f[1][i][0]+f[1][i][1])%mod*h[2*(n-i)]%mod)%=mod;
    // 还要乘上其他点任意匹配的方案数，才是子集反演中的f(S)
	printf("%lld\n",ans);
	return 0;
}
```



### luogu4099 [HEOI2013] SAO

既有外向边，也有内向边，不是很好做。但是只有一种边就很容易了。

考虑容斥。钦定一个内向边集不满足，剩下的是否满足均可。

~~其实钦定内向外向都一样~~。

设 $f_{x,i,j}$ 为以 $x$ 为根的子树，其中 $x$ 所在连通块大小为 $i$，钦定了 $j$ 条内向边不满足的方案数，同样把 $j$ 压了。

在内向边 $(x,y)$ 加入连通块时带上容斥系数，统计这条边作为外向边的贡献即可。

```cpp
// Problem: P4099 [HEOI2013] SAO
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P4099
// Author: KisaragiQwQ
// Date: 2023-06-28 07:50:08
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
const int N=1005, mod=1e9+7;
int n, T, sz[N], C[N][N], f[N][N], g[N];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
int fac[N], inv[N];
void add(int x,int y,int z) {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;	
}
void dfs(int x,int fa) {
	f[x][1]=sz[x]=1;
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i], z=w[i];
		if(y==fa) continue;
		dfs(y,x);
		if(z==0) {
			for(int j=1;j<=sz[x];++j)
				for(int k=1;k<=sz[y];++k) {
					(g[j+k]+=f[x][j]*f[y][k]%mod*C[sz[x]+sz[y]][sz[x]]%mod)%=mod;
				}
		} else {
			for(int j=1;j<=sz[x];++j)
				for(int k=1;k<=sz[y];++k) {
					int d=f[x][j]*f[y][k]%mod*C[sz[x]+sz[y]][sz[x]]%mod;
					(g[j+k]-=d-mod)%=mod;
					(g[j]+=d)%=mod;
				}
		}
		sz[x]+=sz[y];
	    for(int i=1;i<=sz[x];++i) f[x][i]=g[i], g[i]=0;
	}
	for(int i=1;i<=sz[x];++i) (f[x][i]*=fac[i-1]*inv[i]%mod)%=mod;
    // x必须放在最后
}
void solve() {
	n=read();
	tot=0;
	rep(i,1,n) h[i]=sz[i]=0;
	rep(i,1,n) rep(j,1,n) f[i][j]=0;
	rep(i,2,n) {
		int x=read()+1;
		char c=getchar();
		int y=read()+1;
		if(c=='<') add(x,y,0), add(y,x,1);
		else add(x,y,1), add(y,x,0); 
	}
	dfs(1,0);
	int ans=0;
	rep(i,1,n) (ans+=f[1][i])%=mod;
	printf("%lld\n",ans);
}
signed main() {
	T=read();
	C[0][0]=fac[0]=inv[0]=1;
	rep(i,1,1000) {
		fac[i]=fac[i-1]*i%mod;
		C[i][0]=C[i][i]=1;
		rep(j,1,i-1) C[i][j]=(C[i-1][j]+C[i-1][j-1])%mod;
	}
	inv[1000]=fp(fac[1000],mod-2);
	per(i,999,1) inv[i]=inv[i+1]*(i+1)%mod;
	while(T--) solve();
}

```

### LOJ#2117. 「HNOI2015」实验比较

能发现相等关系具有反身性和传递性，并且这些点必然放到质量序列的连续一段，所以可以先用并查集把相等的图片合并了。

然后 $x<y$ 说明 $x$ 必须放到 $y$ 前面，连边 $(x \rightarrow y)$，约等于是内向树拓扑序计数，唯一的区别在于没有祖孙关系的两个节点可以通过相等链接。

为了解决这个问题，我们用状态刻画它。

设 $f(x,i)$ 表示以 $x$ 为根的子树形成的质量序列，其中存在 $i-1$ 个小于号把序列划分成 $i$ 个相等段的方案数。

转移合并子树。
$$
g(i) = \sum_{j \le i \wedge  i \le j+k  } f(x,j) f(y,k) \binom{i-1}{j-1}\binom{j-1}{k-(i-j)}
$$
下面解释上式的含义。$x$ 肯定要放到第一个位置单独一段，所以其实是 $j-1$ 段和 $k$ 段要放到 $i-1$ 段中。第一个二项式系数是给 $f(x,j)$ 重标号，然后 $f(y,k)$ 中的 $k$ 段去补剩下的 $(i-j)$ 段，最后剩下的 $k-(i-j)$ 段则合并进 $j-1$ 段中。每个段只合并一次，防止重复计数。

本题还有 $O(n^2)$ 做法，先鸽着。

```cpp
// Problem: P3240 [HNOI2015]实验比较
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3240
// Author: KisaragiQwQ
// Date: 2023-06-26 19:56:23
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
const int N=105, mod=1e9+7;
int n, m, in[N], sz[N], f[N][N], c[N][N], g[N];
vector<int> p[N];
vector<PII > v;
char ch[3];
struct DSU {
	int f[N];
	int get(int x) { return x==f[x]? x:f[x]=get(f[x]); }
	void merge(int x,int y) {
		x=get(x), y=get(y);
		if(x!=y) f[y]=x;
	}
} dsu;
void prework() {
	c[0][0]=1;
	rep(i,1,n) {
		c[i][0]=c[i][i]=1;
		for(int j=1;j<i;++j) c[i][j]=(c[i-1][j]+c[i-1][j-1])%mod;
		
	}
}
void dfs(int x) {
	// printf("x=%lld\n",x);
	f[x][1]=sz[x]=1;
	for(auto y:p[x]) {
		dfs(y);
		for(int i=1;i<=sz[x]+sz[y];++i) {
			for(int j=1;j<=sz[x];++j) for(int k=1;k<=sz[y];++k) {
				if(k+j<i||j>i) continue;
				(g[i]+=f[x][j]*f[y][k]%mod*c[i-1][j-1]%mod*c[j-1][k-(i-j)]%mod)%=mod;
			}
		}
		sz[x]+=sz[y];
		for(int i=1;i<=sz[x];++i) f[x][i]=g[i], g[i]=0;
	}
}
signed main() {
	n=read(), m=read();
	rep(i,1,n) dsu.f[i]=i;
	rep(i,1,m) {
		int x, y;
		scanf("%lld%s%lld",&x,ch,&y);
		if(ch[0]=='=') dsu.merge(x,y);
		else v.pb({x,y});
	}
	for(auto t:v) {
		int x=dsu.get(t.fi), y=dsu.get(t.se);
		if(x==y) continue;
		++in[y];
		p[x].pb(y);
	}
	++n;
	int fg=0;
	for(int i=1;i<n;++i) if(dsu.f[i]==i&&!in[i]) p[n].pb(i), fg=1;
	prework();
	if(!fg) puts("0"), exit(0);
	dfs(n);
	int ans=0;
	rep(i,1,n) (ans+=f[n][i])%=mod;
	printf("%lld\n",ans);
	return 0;
}
```

