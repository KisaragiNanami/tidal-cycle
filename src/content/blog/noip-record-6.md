---
title: 「NOIP Record」#6 计数杂题 (1)
tags:
  - DP
  - 计数
  - 组合数学
  - 容斥原理
  - 二项式反演
  - Trie
  - 博弈论
  - 树形DP
  - 矩阵
  - 并查集
categories:
  - Record
description: '少年总结下经验'
pubDate: 2023-06-20
---


计数杂题。

## CF840C On the Bench

先进行一些基本的观察。

$\texttt{Observation}$

$\{a_i\}$ 中乘积为完全平方数的数集，一定是相对封闭的。因此我们可以将 $\{a_i\}$ 划分成若干个集合，满足其中两两乘积为完全平方数。

$\texttt{proof}$

>考虑和 $a_i$ 相乘为完全平方数的数集 $\{a_j\}$。由于一个数是完全平方数的充要条件是所有质因子的次幂都是 $2$ 的倍数，因此 $\{a_j\}$ 中任意数的质因子次数都和 $a_i$ 同奇偶，进而它们两两同奇偶。不在 $\{a_j\}$ 中的数则与集合内任何数相乘都不是完全平方数。

有了这个性质，那么相邻两个元素乘积不为完全平方数的条件，等价于同一个集合的元素不能相邻。

考虑每个集合中编号最小的那个元素作为代表元素，排序，处理这个东西的所有排列。显然是个双射。

设 $f_{i,j,k}$ 为考虑 $[1,i]$ 的排列，当前集合有 $k$ 对相邻，其他集合有 $j$ 对同集合且相邻的方案数。

设 $b_i$ 为 $i$ 位置上的代表元素，同时维护 $cnt$ 为当前集合放好了多少个元素。

如果 $b_i = b_{i-1}$，枚举 $j$ 和 $k$

- 放到本集合元素旁边。除了靠在一起的 $k-1$ 个位置，其他每个 $b_i$ 集合元素的位置都有两种方案。
  $$
  f_{i-1,j,k-1} \cdot (2cnt - k+1) \rightarrow f_{i,j,k}
  $$



- 放到其他集合元素旁边，干掉相邻同集合的。显然只能减少一个
  $$
  f_{i-1,j+1,k} \cdot (j+1) \rightarrow f_{i,j,k}
  $$

- 放到其他集合元素旁边，不干掉相邻同集合的。本集合元素两边都不能放，但是还要减去被相邻元素干掉的 $k$ 与 $j$ 个位置。方案数 $i-(2cnt-k) - j$

  $$
  f_{i-1,j,k} \cdot \Big(i-(2cnt-k)-j \Big) \rightarrow f_{i,j,k}
  $$

否则  $b_i \neq b_{i-1}$，说明换了下一个集合，令 $cnt \leftarrow 0$。枚举 $j$ 和上一个集合的 $k$

- 不干掉相邻同集合的
  $$
  f_{i-1,k,j-k} \cdot (i-j) \rightarrow f_{i,j,0}
  $$

- 干掉相邻同集合的
  $$
  f_{i-1,k,j-k+1} \cdot (j+1) \rightarrow f_{i,j,0}
  $$



答案是 $f_{n,0,0}$

复杂度 $O(n^3)$，而且过程相当复杂啊。

```cpp
const int N=305, mod=1e9+7;
int n, a[N], b[N], f[N][N][N];
int squ(int x,int y) {
	int t=sqrt(x*y);
	if(t*t==x*y) return 1;
	return 0;
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	rep(i,1,n) {
		b[i]=i;
		for(int j=1;j<i;++j) if(squ(a[i],a[j])) {
			b[i]=j; break;
		}
	}
	sort(b+1,b+n+1);
	f[0][0][0]=1;
	int cnt=0;
	rep(i,1,n) {
		if(b[i]==b[i-1]) {
			rep(j,0,i-1) rep(k,0,cnt) {
				if(k) (f[i][j][k]+=f[i-1][j][k-1]*(2*cnt-k+1)%mod)%=mod;
				(f[i][j][k]+=f[i-1][j+1][k]*(j+1)%mod)%=mod;
				(f[i][j][k]+=f[i-1][j][k]*(i-2*cnt+k-j)%mod)%=mod;
			}
		} else {
			cnt=0;
			rep(j,0,i-1) rep(k,0,j+1) {
				if(k<=j) (f[i][j][0]+=f[i-1][k][j-k]*(i-j)%mod)%=mod;
				(f[i][j][0]+=f[i-1][k][j-k+1]*(j+1)%mod)%=mod;
			}
		}
		++cnt;
	}
	printf("%lld\n",f[n][0][0]);
}
```


&nbsp;
&nbsp;

有更优秀的容斥做法。

设一共有 $m$ 个集合，第 $i$ 个集合的大小是 $s_i$，每个集合内部元素带标号。

先不考虑限制，设第 $i$ 个集合分成 $b_i$ 段，$B=\sum_{i=1}^m b_i$，那么所有集合全排列的方案是
$$
\frac{B!}{\prod_{i=1}^m (b_i !)} \prod_{i=1}^m s_i! \binom{s_i-1}{b_i-1}
$$

$$
 \prod_{i=1}^m (s_i !) B!\prod_{i=1}^m \frac{1}{b_i!} \binom{s_i-1}{b_i-1}
$$

$B$ 可以枚举，但 $\sum_{i=1}^m b_i = B$ 是卷积。

$\texttt{Obervation}$

考虑这样一个事情。

我们要求的是「对于每一个集合，其元素两两不相邻」的方案数。如果 $B=n$，那么相当于至少有 $0$ 个和自己集合元素相邻的元素，$B=n-1$ 时则是至少有 $1$ 个。于是可以就此容斥。

枚举 $B \in [m,n]$，如何处理 $\prod_{i=1}^m\frac{1}{b_i!} \binom{s_i-1}{b_i -1}$ 呢？

设 $f_{i,j}$ 为 $[1,i]$ 中的集合，划分的总段数不超过 $j$ 时候，上面式子的值。
$$
f_{i,j} = \sum_{k \in [1,\min(s_i,j)]} \binom{s_i-1}{k-1} f_{i-1,j-k} \cdot \frac{1}{k!}
$$
限制了 $j \in [1,\sum_{i=1}^i s_i]$ 与 $k \in [1,\min(s_i,j)]$，复杂度是 $O(n^2)$ 的。

然后上面式子带上个 $(-1)^{n-i}$ 的系数即可。

```cpp
const int N=305, mod=1e9+7;
int n, m, ans, a[N], t[N], s[N], fac[N], inv[N], f[N][N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
void init() {
	fac[0]=inv[0]=1;
	rep(i,1,300) fac[i]=fac[i-1]*i%mod;
	inv[300]=fp(fac[300],mod-2);
	per(i,299,1) inv[i]=inv[i+1]*(i+1)%mod;
}
int C(int n,int m) {
	if(n<m) return 0;
	if(n==m) return 1;
	return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
int squ(int x,int y) {
	int t=sqrt(x*y);
	if(t*t==x*y) return 1;
	return 0;
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	rep(i,1,n) {
		int fg=0;
		rep(j,1,m) {
			if(squ(a[i],t[j])) { ++s[j], fg=1; break; }
		}
		if(!fg) t[++m]=a[i], s[m]=1;
	}
    // 预处理
	init();
	f[0][0]=1;
	int S=0;
	rep(i,1,m) {
		S+=s[i];
		rep(j,1,S) for(int k=1;k<=s[i]&&k<=j;++k) (f[i][j]+=f[i-1][j-k]*C(s[i]-1,k-1)%mod*inv[k]%mod)%=mod;
	}
	rep(i,m,n) {
		if((n-i)&1) (ans-=f[m][i]*fac[i]%mod-mod)%=mod; else (ans+=f[m][i]*fac[i]%mod)%=mod;
	}
	rep(i,1,m) (ans*=fac[s[i]])%=mod;
	printf("%lld\n",ans);
}
```

&nbsp;

&nbsp;

另一种容斥。

设 $f(i)$ 为至少有 $i$ 个 $k$ 满足 $a_k$ 与 $a_{k-1}$ 在同一个等价类中，$g(i)$ 为恰好 $i$ 个，那么

$$
f(k) = \sum_{i=k}^n \binom{i}{k} g(i)
$$

$$
g(k) = \sum_{i=k}^n (-1)^{i-k} \binom{i}{k} f(i)
$$

答案是

$$
g(0) = \sum_{i=0}^n (-1)^i f(i)
$$

大力搞一下可以发现

$$
f(k) = \sum_{k_1+k_2+ \cdots + k_m = k} \frac{(n-\sum_{i=1}^m k_i)!}{\prod_{i=1}^m \Big((s_i-k_i)!\Big)} \prod_{i=1}^m \binom{s_i - 1}{k_i}
$$


这是个卷积形式的式子，考虑到范围不大，可以暴力求，用类似背包的方法合并 $k_i$ 即可。

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
const int N=305, mod=1e9+7;
int n, m, ans, a[N], t[N], s[N], fac[N], inv[N], f[2][N], g[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
void init() {
	fac[0]=inv[0]=1;
	rep(i,1,300) fac[i]=fac[i-1]*i%mod;
	inv[300]=fp(fac[300],mod-2);
	per(i,299,1) inv[i]=inv[i+1]*(i+1)%mod;
}
int C(int n,int m) {
	if(n<m) return 0;
	if(n==m) return 1;
	return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
int squ(int x,int y) {
	int t=sqrt(x*y);
	if(t*t==x*y) return 1;
	return 0;
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	rep(i,1,n) {
		int fg=0;
		rep(j,1,m) {
			if(squ(a[i],t[j])) { ++s[j], fg=1; break; }
		}
		if(!fg) t[++m]=a[i], s[m]=1;
	}
	init();
	f[0][0]=1;
	int S=0;
	rep(i,1,m) {
		rep(j,0,S) f[1][j]=f[0][j], f[0][j]=0;
		rep(j,0,s[i]-1) {
			g[j]=C(s[i]-1,j)*inv[s[i]-j]%mod;
			rep(k,0,S) (f[0][j+k]+=g[j]*f[1][k]%mod)%=mod;
		}
		S+=s[i]-1;
	}
	rep(i,0,n) {
		if(i&1) (ans-=f[0][i]*fac[n-i]%mod-mod)%=mod;
		else (ans+=f[0][i]*fac[n-i]%mod)%=mod;
	}
	rep(i,1,m) (ans*=fac[s[i]])%=mod;
	printf("%lld\n",ans);
}
```



- 有些映射还是可以大胆用的。
- DP 外面也可以维护某些信息的，其实还是取决于 DP 的顺序。计数 DP 可以选择映射到相对容易维护信息的顺序。


## CF1400G Mercenaries

注意到 $m$ 很小，套路性地按照敌对关系容斥。

枚举集合 $S$ 表示至少满足存在 $S$ 集合内所有敌对关系的方案数。

然后对于敌对关系内的每个人，能够求出他们条件区间的交。只要集合大小在这个交区间 $[l,r]$ 内就能满足条件。

注意到所谓条件区间，覆盖的其实是集合大小。

考虑差分求出所有条件区间的覆盖情况，设 $d_j$ 为大小为 $j$ 的集合能满足其条件区间的人数。

设 $g_{i,j}$ 表示选出钦定的 $i$ 个人后，至多选择 $j$ 个人的方案数。
$$
g_{i,j} = g_{i,j-1} + \binom{d_j-i}{j-i}
$$
然后设 $c$ 表示 $S$ 涉及的人的数量，的贡献是 $(g_{c,R}- g_{c,L-1})$，带上一个 $(-1)^{|S|}$ 的容斥系数。

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
const int N=3e5+5, M=(1<<20)+5, mod=998244353;
int n, m, U, ans, l[N], r[N], d[N], g[45][N];
int fac[N], inv[N];
#define PII pair<int,int>
#define x first
#define y second
PII p[25]; 
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
int C(int n,int m) {
	if(n<m||n<0||m<0) return 0;
	return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
void init() {
	fac[0]=inv[0]=1;
	rep(i,1,n) fac[i]=fac[i-1]*i%mod;
	inv[n]=fp(fac[n],mod-2);
	per(i,n-1,1) inv[i]=inv[i+1]*(i+1)%mod;
	rep(i,0,2*m) {
		rep(j,1,n) g[i][j]=(g[i][j-1]+C(d[j]-i,j-i)%mod);
	}
}

int cc(int x) {
	int cnt=0;
	while(x) cnt+=x&1, x>>=1;
	return cnt;
}
signed main() {
	n=read(), m=read();
	rep(i,1,n) {
		l[i]=read(), r[i]=read();
		++d[l[i]], --d[r[i]+1];
	}
	rep(i,1,m) p[i].x=read(), p[i].y=read();
	rep(i,1,n) d[i]+=d[i-1];
	init();
	U=(1<<m)-1;
	rep(S,0,U) {
		set<int> s;
		int L=1, R=n, dlt=0;
		rep(i,0,m-1) if(S&(1<<i)) {
			int x=p[i+1].x, y=p[i+1].y;
			L=max(L,max(l[x],l[y])), R=min(R,min(r[x],r[y]));
			s.insert(x), s.insert(y);
		}
		int cnt=s.size();
		if(L<=R) dlt=(g[cnt][R]-g[cnt][L-1]+mod)%mod;
		int pc=cc(S);
		if(pc&1) (ans-=dlt-mod)%=mod; else (ans+=dlt)%=mod;
	}
	printf("%lld\n",ans);
}
```



## CF1542D Priority Queue

首先将所谓 $A$ 的子序列转化为每个操作可选可不选。

$f(B)$ 不能直接计算，可以对每个 $x$ 求贡献。具体地，计算每个 $x$ 存活到最后的方案数。

设 $f_{i,j}$ 为考虑了 $[1,i]$ 的操作，$T$ 中有 $j$ 个比 $x$ 小的数的方案数。

如果 $i$ 是`-`操作，那么

- 不选，方案数 $f_{i-1,j}$。

- 选择此操作，删掉一个小于 $x$ 的数，方案 $f_{i-1,j+1}$。
- 一个问题：如果 $x \notin T$，排名的问题如何解决？钦定当 $j=0$ 时，$f_{i,0}$ 可以由 $f_{i-1,0}$ 转移而来。

如果 $i$ 是`+ x`操作，那么

- 不选，方案数 $f_{i-1,j}$。
- 选择且 $a_i < x$，那么方案数 $f_{i-1,j-1}$。
- 选择且 $a_i > x$，方案 $f_{i-1,j}$。

- 一个问题：如果 $a_i = x$ 怎么办呢？如果 $x \in T$，那么加入 $a_i$ 之后不会使 $j$ 增加，按照 $a_i > x$ 的方法做显然是对的。否则呢？$x \notin T$ 时 $T$ 中等于 $x$ 的值，我们当然要让它们在 $x$ 之前被删掉，因此按照 $a_i < x$ 的方法做。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int N=505, mod=998244353;
int n, a[N];
char s[N];
ll f[N][N], ans;
int main() {
	scanf("%d",&n);
	for(int i=1;i<=n;++i) {
		scanf(" %c",&s[i]);
		if(s[i]=='-') a[i]=-1; else scanf("%d",&a[i]);
	}
	for(int p=1;p<=n;++p) {
		int x=a[p];
		if(!~x) continue;
		memset(f,0,sizeof(f));
		f[0][0]=1;
		for(int i=1;i<=n;++i) {
			if(p==i) { memcpy(f[i],f[i-1],sizeof(f[i])); continue; }
			for(int j=0;j<=i;++j) {
				if(a[i]==-1) {
					f[i][j]=(f[i-1][j]+f[i-1][j+1])%mod;
					if(i<p&&!j) (f[i][j]+=f[i-1][j])%=mod;
				} else if(a[i]<x||(a[i]==x&&i<p)) {
					f[i][j]=f[i-1][j];
					if(j) (f[i][j]+=f[i-1][j-1])%=mod;
				} else f[i][j]=2*f[i-1][j]%mod;
			}
		}
		ll sum=0;
		for(int i=0;i<=n;++i) (sum+=f[n][i])%=mod;
		(ans+=sum*x%mod)%=mod;
	}
	printf("%lld\n",ans);
}
```



## luogu [USACO20JAN]Cave Paintings P

难点在于如何合并两块空格子的信息。

不妨把连成一片的空格子称为一个连通块。对于一个连通块，初始贡献肯定是 $1$。

考虑对于一行的连通块，必然是先向左右下合并，合并后的方案数为两个连通块方案数之积。事实上，由于这一行的初始值是 $1$，所以相当于是把下面那一行中，能通过这一行互相到达的连通块合并了起来，由于它们是相对独立的，所以方案要做乘法。

然后呢？对于上面那一行，这一行的每个连通块必然是可选可不选，因此每一块的方案都加上 $1$。

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
const int N=1005, mod=1e9+7;
const int dx[4]={1,0,0}, dy[4]={0,1,-1};
int n, m, ans=1, f[N*N], g[N*N];
char s[N][N];
int id(int i,int j) { return (i-1)*m+j; }
namespace dsu {
	void init() { for(int i=1;i<=n*m;++i) f[i]=i, g[i]=1; }
	int get(int x) { return x==f[x]? x:f[x]=get(f[x]); }
	void merge(int x,int y) {
		x=get(x), y=get(y);
		if(x!=y) {
			(g[x]*=g[y])%=mod;
			f[y]=x;
		}
	}
};
signed main() {
	n=read(), m=read();
	rep(i,1,n) scanf("%s",s[i]+1);
	dsu::init();
	for(int i=n-1;i>=2;--i) {
		map<int,int> v;
		for(int j=2;j<=m-1;++j) if(s[i][j]!='#') {
			rep(k,0,2) {
				int ii=i+dx[k], jj=j+dy[k];
				if(s[ii][jj]=='#') continue;
				dsu::merge(id(i,j),id(ii,jj));
			}
		}
		for(int j=2;j<=m-1;++j) if(s[i][j]!='#') {
			int k=dsu::get(id(i,j));
			if(!v[k]) ++g[k], v[k]=1;
		}
	}
	rep(i,2,n-1) rep(j,2,m-1) if(f[id(i,j)]==id(i,j)) (ans*=g[id(i,j)])%=mod;
	printf("%lld\n",ans);
}
```

- 计算顺序对于一个计数题来说，是相当重要，且是需要着重考虑的。
- 虽然是有关于连通块的计数，却忽略了最关键的合并环节，同时，没有搞清楚题目中水流这个条件所具备的相对独立性与相邻两行之间的关系，思路糊成一团，反复去琢磨“样例是怎么算出来的”而非主动寻找计数的方法。



## luogu8974 『GROI-R1』 古朴而优雅

容易看出题面中的伪代码就是生成欧拉序的方法。

那么对于每个点 $x$，其子节点可以任意排列，因此一棵树的答案为
$$
\prod_{x} |son(x)|!
$$
加上边后就可能成环。手动模拟不难发现，成环之后仅仅只会让一条边访问不到，这条边就是它们 $LCA$ 分别到达它们的路径上的第一条边。

设加入的边是 $(x,y)$，$z=LCA(x,y)$，$z$ 到 $x$ 路径上第一个节点为 $u$，另一个为 $v$。

如果没走 $(z,u)$，那么相当于 $z$ 少了一个子节点，$u$ 少了一个子节点，$x$ 与 $y$ 都增加了一个子节点。另一种情况同理。分别统计两种情况，加起来即可。

如何找到 $u$ 与 $v$？树上倍增即可。

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
const int N=2e5+5, mod=1e9+7;
int n, q, ans=1, ss[N], dep[N], f[N][20], fac[N], inv[N];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
void dfs(int x,int fa) {
	dep[x]=dep[fa]+1, f[x][0]=fa;
	ss[x]=0;
	rep(i,1,18) f[x][i]=f[f[x][i-1]][i-1];
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i];
		if(y==fa) continue;
		++ss[x];
		dfs(y,x); 
	}
	(ans*=fac[ss[x]])%=mod;
}
int lca(int x,int y) {
	if(dep[x]<dep[y]) swap(x,y);
	for(int i=18;~i;--i) if(dep[f[x][i]]>=dep[y])  x=f[x][i];
	if(x==y) return x;
	for(int i=18;~i;--i) {
		if(f[x][i]!=f[y][i]) x=f[x][i], y=f[y][i];
	}
	return f[x][0];
}
void init() {
	fac[0]=inv[0]=1;
	rep(i,1,n) fac[i]=fac[i-1]*i%mod;
	inv[n]=fp(fac[n],mod-2);
	per(i,n-1,1) inv[i]=inv[i+1]*(i+1)%mod; 
}
int gett(int x,int y) {
	for(int i=18;~i;--i) if(dep[f[x][i]]>=dep[y]+1) x=f[x][i];
	return x;
}
pair<int,int> get(int z,int x,int y) {
	if(dep[x]>dep[y]) swap(x,y);
	if(x==z) return {y,gett(y,x)};
	else return {gett(x,z),gett(y,z)};
}
int getans(int z,int u,int x,int y) {
	int d=ans*inv[ss[z]]%mod*inv[ss[u]]%mod*inv[ss[x]]%mod*inv[ss[y]]%mod;
	--ss[z], --ss[u], ++ss[x], ++ss[y];
	(d*=fac[ss[z]]*fac[ss[u]]%mod*fac[ss[x]]%mod*fac[ss[y]]%mod)%=mod;
	++ss[z], ++ss[u], --ss[x], --ss[y];
	return d;
}
void solve() {
	int x=read(), y=read();
	int z=lca(x,y);
	if(dep[x]+dep[y]-2*dep[z]==1) {
		printf("%lld\n",ans);
		return;
	}
	pair<int,int> p=get(z,x,y);
	int u=p.first, v=p.second;
	int d1=getans(z,u,x,y), d2=getans(z,v,x,y);
	printf("%lld\n",(d1+d2)%mod);
	
}
signed main() {
	n=read(), q=read();
	rep(i,1,n-1) {
		int x=read(), y=read();
		add(x,y), add(y,x);
	}
	init();
	dfs(1,0);
	while(q--) solve();
}
```





## luogu6803 [CEOI2020] 星际迷航

相当精妙的题目啊。

考虑到这 $D+1$ 棵树是相同的，我们先把一棵树的必胜必败态求出来。

设白点为先手必胜，黑点为先手必败。

加上 rt- 的前缀表明是以它为根的树中它的颜色。

$\texttt{Observation}$

如果一个点连接一个 rt-白点，那么这个点的胜负情况不会改变。

如果一个点连接一个 rt-黑点，那么这个点的颜色可能改变（其实取决于对方能不能不让你走这条边）。



这个的证明是显然的。有了这个结论，$D=1$ 的情况就能做了。

>笔者自己在思考本题的时候，想法是对于先考虑一个点的颜色，再考虑连到什么样的点才必胜。这样做也不是不可以，但是有如下坏处
>
>- 分类讨论过细，一直在思考着必胜策略，导致做法根本无法推广到更大的 $D$ 上。
>- 将博弈的局面分的过细。比如很多时间花在了考虑什么样的黑点连 2-黑点能够改变自己的胜负情况。
>- 浪费了过多时间，结果也只能解决部分分。
>
>应该考虑连边的本质是换到另一个根上面，然后分连 rt-白点与 rt-黑点讨论。而犯这样的错误很大程度上是因为一开始就把自己限制在了 $D=1$ 的部分分上，导致思路受到局限。
>
>要注意从特殊到一般，整个过程的推广并不都是可以直接套用特殊做法的。



设 $st_i(x)$ 为以 $i$ 为根的树中，$x$ 的颜色。

称「改变颜色」为连边后的胜负情况改变，相当于这个点的颜色改变。

下面来解决改变颜色的问题。

设 $f_i(x)$ 表示以 $i$ 为根的树，在以 $x$ 为根的子树中，有多少个点满足它们连接 rt-黑点后，$x$ 的颜色改变。

先考虑以 $1$ 为根。

1. $x$ 的子节点全都是白点，那么 $x$ 为黑点，此时如果 $x$ 连到 2-黑点，那么 $x$ 就相当于改变成白点。否则如果任意子节点能改变为黑点，也能使 $x$ 变为白点，因此
   $$
   f_1(x) = 1 + \sum_{y \in son(x) \text{ and } st_1(y)=1} f_1(y)
   $$

2. 如果 $x$ 的子节点存在不止一个黑点，那么 $x$ 为白点，从而从 $x$ 连没有用。就算某个黑子节点变为白点，先手也总有其他选择，故不可能变成黑点，$f_1(x)=0$

3. 如果 $x$ 的子节点恰好有一个黑点，那么 $x$ 为白点，从而从 $x$ 连没有用。如果那个黑点变为白点，此时 $x$ 就变成了黑点
   $$
   f_1(x) = f_1(y) \quad y \in son(x) \text{ and } st_1(y) = 0
   $$

维护每个颜色子节点 $f$ 的和即可。


>犯过严重错误：没有设 $f$，从整棵子树的角度考虑，导致得到正确的结论花了巨多时间，且不成体系。
>
>而且有过逆天想法：万一 $x$ 连了子树外的节点怎么办呢？
>
>实际上，如果这个点能满足 $f$ 的条件，那么连什么样的 2-黑点都相同且方案数是定值。而连接 rt-黑点后颜色能否改变，取决于这棵子树能不能使得这条边一定被经过。
>
>没有想到求这个东西，本质上是对题目还未理解清楚。
>
>这种逆天的担心是拖慢我做题速度的重要因素之一。
>
>真的是太降智了啊！



$st$ 与 $f$ 均可换根 DP 在 $O(n)$ 复杂度内求出。

下面考虑 $D=1$ 时的答案。

设原树中存在 $m$ 个 $st_x(x)=0$ 的点。如果 $st_1(1)=1$，那么答案是 $n \times (n-m) + \Big(n-f_1(1)\Big) \times m$，否则就是 $f_1(1) \times m$。



当 $D=2$ 时，由于第 $1$ 棵树的结点颜色可以通过第 $2$ 棵树转化，设 $F_0$ 为 $st_x(x)=0$ 的 $x$ 的答案之和，$F_1$ 类似。那么如果 $st_1(1)=1$，答案是 $n \times F_1 + \Big(n-f_1(1)\Big) \times F_0$，否则就是 $f_1(1) \times F_0$。



对于 $D > 2$，是完全一样的问题。

考虑 $F_0$ 与 $F_1$ 的求法。前者要么是白点转化而来，要么是黑点不变，后者类似，因此

$$
F_0 = \sum_{st_x(x)=0} \Big(n-f_x(x)\Big)m + \sum_{st_x(x)=1} f_x(x)m + \sum_{st_x(x)=0} n(n-m)
$$

$$
F_1 = \sum_{st_x(x)=1} \Big(n-f_x(x)\Big)m + \sum_{st_x(x)=0} f_x(x)m + \sum_{st_x(x)=1} n(n-m)
$$

发现是一个矩阵去变换 $\begin{bmatrix} m \\ n-m\end{bmatrix}$ 这个向量 $D-1$ 次。矩阵快速幂优化即可。



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
int n, m, D, st[N], s0[N], f[N], sf[N][2];
int st2[N], g[N];
vector<int> p[N];
#define pb emplace_back
void dfs(int x,int fa) {
	for(auto y:p[x]) {
		if(y==fa) continue;
		dfs(y,x);
		s0[x]+=!st[y];
		sf[x][st[y]]+=f[y];
	}
	st[x]=(s0[x]>0);
	if(s0[x]==1) f[x]=sf[x][0];
	else if(s0[x]==0) f[x]=sf[x][1]+1;
}
void dfs2(int x,int fa) {
    // 换根
	if(!st[x]) ++m;
	st2[x]=st[x], g[x]=f[x];
	int s0x=s0[x], stx=st[x], fx=f[x], sfx0=sf[x][0], sfx1=sf[x][1];
	for(auto y:p[x]) {
		if(y==fa) continue;
		int s0y=s0[y], sty=st[y], fy=f[y], sfy0=sf[y][0], sfy1=sf[y][1];
		
		
		
		s0[x]-=!st[y];
		st[x]=(s0[x]>0);
		sf[x][st[y]]-=f[y];
		if(s0[x]==1) f[x]=sf[x][0];
		else if(s0[x]==0) f[x]=sf[x][1]+1;
		else f[x]=0;
		if(!st[x]) st[y]=1, ++s0[y];
		sf[y][st[x]]+=f[x];
		if(s0[y]==1) f[y]=sf[y][0];
		else if(s0[y]==0) f[y]=sf[y][1]+1;
		else f[y]=0;
		dfs2(y,x);
		
		
		s0[x]=s0x, st[x]=stx, f[x]=fx, sf[x][0]=sfx0, sf[x][1]=sfx1;
		s0[y]=s0y, st[y]=sty, f[y]=fy, sf[y][0]=sfy0, sf[y][1]=sfy1;
	}
}

struct Mat {
	int m[2][2];
	void clear() { SET(m,0); }
	void init() { m[0][0]=m[1][1]=1; } 
} base, ans;
Mat operator*(Mat a,Mat b) {
	Mat c; c.clear();
	for(int i=0;i<2;++i)
		for(int k=0;k<2;++k)
			for(int j=0;j<2;++j)
				(c.m[i][j]+=a.m[i][k]*b.m[k][j]%mod)%=mod;
	return c;
}
Mat fp(Mat a,int b) {
	Mat c; c.clear(), c.init();
	for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
	return c;
}

signed main() {
	n=read(), D=read();
	rep(i,2,n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	dfs(1,0);
	dfs2(1,0);
	for(int x=1;x<=n;++x) {
		if(!st2[x]) {
			(base.m[0][0]+=n-g[x])%=mod;
			(base.m[0][1]+=n)%=mod;
			(base.m[1][0]+=g[x])%=mod;
		} else {
			(base.m[0][0]+=g[x])%=mod;
			(base.m[1][0]+=n-g[x])%=mod;
			(base.m[1][1]+=n)%=mod;
		}
	}
	ans.m[0][0]=m, ans.m[1][0]=n-m;
	ans=fp(base,D-1)*ans;
	int f0=ans.m[0][0], f1=ans.m[1][0];
    
	if(st[1]) printf("%lld\n",((n-g[1]+mod)*f0%mod+n*f1%mod)%mod);
	else printf("%lld\n",g[1]*f0%mod);
}
```





## luogu8971 『GROI-R1』 虹色的彼岸花

对于题目中没有点权的那些边，显然是没有用的，删掉。

一条边 $(x,y,z)$ 实际上是 $a_x + a_y =z$ 这样的一个限制。由于原图是一棵树，又删掉了若干边，得到的一定是一个森林。不难发现对于一棵树，钦定一个点为根，其他所有节点的值都能通过它来表示出来。这样就只需要考虑 $a_{root}$ 的取值了。

由于每棵树之间没有关系，所以分别求方案即可。设 $root$ 为当前树的根，节点 $x$ 的值为 $a_x = a_{root} + \Delta$，根据 $\Delta$ 的正负取值能得到一个区间，然后与 $[l,r]$ 取交即可。

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
const int N=2e5+5, mod=1e9+7;
int T, n, l, r, cnt, v[N], dep[N], c[N];
int tot, h[N], to[N<<1], nxt[N<<1], w[N<<1];
vector<int> zh[N], fu[N];
void add(int x,int y,int z) {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
void dfs(int x,int fa,int root,int d) {
	v[x]=1;
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i], z=w[i];
		if(y==fa) continue;
		dep[y]=dep[x]+1; 
		if(dep[y]%2==0) fu[cnt].push_back(z-d);
		else zh[cnt].push_back(z-d);
		dfs(y,x,root,z-d);
	}
}
void solve() {
	n=read(), l=read(), r=read();
	tot=cnt=0;
	rep(i,1,n) h[i]=c[i]=dep[i]=v[i]=0, zh[i].clear(), fu[i].clear();
	rep(i,1,n-1) {
		int op=read();
		if(!op) int x=read(), y=read();
		else {
			int x=read(), y=read(), z=read();
			add(x,y,z), add(y,x,z);
		}
	}
	rep(i,1,n) if(!v[i]) {
		++cnt;
		dep[i]=1;
		dfs(i,0,i,0);
	}
	rep(i,1,cnt) {
		if(fu[i].size()==0) {
			c[i]=r-l+1;
			continue;
		}
		int mx1=-1e18, mx2=-1e18, mn1=1e18, mn2=1e18;
		for(auto x:zh[i]) mx1=max(mx1,x), mn1=min(mn1,x);
		for(auto x:fu[i]) mx2=max(mx2,x), mn2=min(mn2,x);
		if(!zh[i].size()) mx1=mn1=0;
		int L=max(mx2-r,l-mn1), R=min(mn2-l,r-mx1);
		if(R<L||R<l||L>r) c[i]=0;
		else if(l<=L&&R<=r) c[i]=(R-L+1);
		else if(L<l&&R<=r) c[i]=(R-l+1);
		else if(R>r&&l<=L) c[i]=(r-L+1);
	}
	int ans=1;
	rep(i,1,cnt) (ans*=c[i])%=mod;
	printf("%lld\n",ans);
}
signed main() {
	T=read();
	while(T--) solve();
}

```



## luogu7717 「EZEC-10」序列

[link](https://yozora0908.top/2023/lg7717-solution)

## luogu4063 [JXOI2017]数列

设 $L_i$ 为第 $i+1$ 个数的左边界，$R_i$ 为第 $i+1$ 个数的右边界。

$\texttt{Observation}$

假定 $L_{i-1} \neq -\infty \texttt{ and } R_{i-1} \neq \infty$。

如果 $A_i \in [L_{i-1},A_{i-1}]$，那么将有 $R_i = A_{i-1}$；如果 $A_i \in [A_{i-1},R_{i-1}]$，那么将有 $L_i = A_i$。

总之，合法取值区间必然是不断减小的。

并且取值区间的大小变化只能是边界或者上一个填的数，非常有限，但是需要分类讨论。



$\texttt{Solution}$

用 $rr_i$ 代替题目中的 $r_i$。

考虑到 $n$ 和 $rr_i$ 都很小，设 $f(i,l,r,k)$ 为考虑到了第 $i$ 个数，$L_i = l$，$R_i = r$ 且 $A_i = k$ 的方案数。

首先要解决取值区间边界为正无穷或负无穷的问题。令 $-\infty \rightarrow 0$，$\infty \rightarrow \max_{i=1}^n\{rr_i\} + 1$。这两种情况，会随着取值区间缩小而消亡。

状态很多，选择使用刷表法。

对于一个 $f(i-1,l,r,k)$，分如下几种情况讨论

- 取值区间缩减到 $[l,l]$，那么 $A_i \in [\max(1,l),\min(l,rr_i)]$。
- 取值区间缩减到 $[l,k]$，那么 $A_i \in [l+1,\min(k-1,rr_i)]$。
- 取值区间缩减到 $[k,k]$，那么要求 $A_i = A_{i-1}$，即 $k>l$，此时 $A_i \in [k,\min(k,rr_i)]$。
- 取值区间缩减到 $[k,r]$，那么 $A_i \in [k+1,\min(r-1,rr_i)]$。
- 取值区间缩减到 $[r,r]$，那么 $k<r$，此时 $A_i \in [r,\min(r,rr_i)]$。

以上转移在满足 $A_i$ 区间合法时，对于每个取值都加上 $f(i-1,l,r,k)$。区间加法，差分即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=155, mod=998244353;
int n, ans, inf, rr[N], f[2][N][N][N];
signed main() {
	n=read();
	rep(i,1,n) rr[i]=read(), inf=max(inf,rr[i]);
	++inf;
	int p=0;
	f[p][0][inf][1]=1, f[p][0][inf][rr[1]+1]=-1+mod;
    // 初始值
	rep(i,2,n) {
		memset(f[p^1],0,sizeof(f[p^1]));
		rep(l,0,inf) rep(r,l,inf) rep(k,l,r) if(k-1>=0) (f[p][l][r][k]+=f[p][l][r][k-1])%=mod;
		
		
		rep(l,0,inf) rep(r,l,inf) rep(k,l,r) if(f[p][l][r][k]) {
			
			
			int L=max(1ll,l), R=min(l,rr[i]);
			int d=f[p][l][r][k];
			if(L<=R)(f[p^1][l][l][L]+=d)%=mod, (f[p^1][l][l][R+1]-=d-mod)%=mod;
			
			
			// [l,l]
			L=l+1, R=min(k-1,rr[i]);
			if(L<=R) (f[p^1][l][k][L]+=d)%=mod, (f[p^1][l][k][R+1]-=d-mod)%=mod;
			// [l+1,k-1]
			
			if(k>l) {
				L=max(k,1ll), R=min(k,rr[i]);
				if(L<=R) (f[p^1][k][k][L]+=d)%=mod, (f[p^1][k][k][R+1]-=d-mod)%=mod;
			}
			// a[i]=a[i-1] [k,k];
			
			
			L=k+1, R=min(r-1,rr[i]);
			if(L<=R) (f[p^1][k][r][L]+=d)%=mod, (f[p^1][k][r][R+1]-=d-mod)%=mod;
			// [k+1,r-1]
			
			if(k<r) {
				L=max(r,1ll), R=min(r,rr[i]);
				if(L<=R) (f[p^1][r][r][L]+=d)%=mod, (f[p^1][r][r][R+1]-=d-mod)%=mod;
			}
			// [r,r]
		}
		p^=1;
	}
	rep(l,0,inf) rep(r,l,inf) rep(k,l,r) {
		(f[p][l][r][k]+=f[p][l][r][k-1])%=mod;
		(ans+=f[p][l][r][k])%=mod;
		// printf("%lld\n",f[n][l][r][k]);
	}
	printf("%lld\n",ans);
}
```