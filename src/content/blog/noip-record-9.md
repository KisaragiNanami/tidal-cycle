---
title: 「NOIP Record」#9 状态压缩
pubDate: 2023-07-15
tags:
  - 状态压缩
  - DP
  - 区间DP
  - 数论
  - 计数
categories: Record
description: '少年要建造自己的科技树'
---

聊聊状态压缩。

顾名思义，就是把一个状态压成一个整数，从而使得问题的所有状态可以度量。

一般都是用二进制状态压缩来表示子集与全集的关系，对应着二进制每一位都是 $0$ 或 $1$。更高的进制能表示更多的信息，但状态的数量也会随之增加，并且实现的时候要自己手写位运算，较为复杂，本文不会涉及。

## 信息的表示

### luogu7076 [CSP-S2020] 动物园

题意比较绕。

一个 $(p_i,q_i)$ 相当于对二进制中第 $p_i$ 位进行了限制。把所有 $p_i$ 压成一个整数，如果这个数第 $i$ 位为 $1$ 并且没有 $a_j$ 满足这一位是 $1$，那么所有编号第 $i$ 位是 $1$ 的动物就不能选。

把不能选的位压成一个整数 $t$，那么能选的动物的编号，在所有 $t$ 中为 $1$ 的数位上都是 $0$，答案就是
$$
2^{k-\operatorname{popcount}(t)} - n
$$
注意可能会爆`unsigned long long`。

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
uint read() {
	uint a=0; char c=getchar();
	while(!isdigit(c)) {
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a;
}
const int N=1e6+5;
uint n, m, c, k, a[N], p[N], q[N];
uint h[70];
void add(uint x) {
	for(int i=k-1;~i;--i) if(x&(1ull<<i)) ++h[i];
}
int popcount(uint x) {
	int cnt=0;
	while(x) cnt+=x&1, x>>=1;
	return cnt;
}
signed main() {
	n=read(), m=read(), c=read(), k=read();
	rep(i,1,n) {
		a[i]=read();
		add(a[i]);
	}
	uint cc=0;
	rep(i,1,m) {
		p[i]=read(), q[i]=read();
		cc|=(1ull<<p[i]);
	}
	uint ng=0;
	rep(i,0,k-1) {
		if(h[i]==0&&cc&(1ull<<i)) ng|=(1ull<<i);
	}
	int cnt=popcount(ng);
	if(k==0) puts("1");
	else if(k!=64) printf("%llu\n",(1ull<<(k-cnt))-n);
	else {
		if(cnt!=0) printf("%llu\n",(1ull<<(k-cnt))-n);
		else if(n!=0) {
			printf("%llu\n",0-n);
		} else puts("18446744073709551616");
	}
}
```

### luogu1357 花园

把`P`看作 $0$，`C`看作 $1$，然后把 $m$ 个花圃的状态压成一个整数。

同时值域不大，可以用 $\text{DFS}$ 搜出所有合法状态。

断环为链，则环等价于序列 $[1,n+m]$，同时要求 $[1,n]$ 与 $[n,n+m-1]$ 相同。任意相邻 $m$ 个花圃不同，可以看作是在一个合法状态上删掉前面一位，加上后面一位，这样向前推进 $n$ 次。于是在上一步处理合法状态时，顺便处理状态之间的这样的转移。

这里用到一个 Trick，对于这种环上状态压缩，可以用处理序列的方法做，最后让开头和结尾相同即可。

$n$ 很大，状态数很少且满足结合律，可以使用矩阵加速。

```cpp
// Problem: P1357 花园
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P1357
// Author: KisaragiQwQ
// Date: 2023-06-19 16:15:49
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
const int mod=1e9+7;
int n, m, k, U, ok[1<<5];
struct Mat {
	int m[1<<5][1<<5];
	void clear() { SET(m,0); }
	void id() { rep(i,0,U) m[i][i]=1; }
} a, c;
Mat operator*(Mat a,Mat b) {
	Mat c; c.clear();
	for(int i=0;i<=U;++i)
		for(int k=0;k<=U;++k)
			for(int j=0;j<=U;++j)
				(c.m[i][j]+=a.m[i][k]*b.m[k][j]%mod)%=mod;
	return c;
}
Mat fp(Mat a,int b) {
	Mat c; c.clear(), c.id();
	for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
	return c;
}
void nbuna(int j,int S) {
	ok[S]=1;
	int S0=S>>1;
	a.m[S0][S]=1;
    // S0是去掉第一位，最后一位不放1
	if(j==k&&(S&1)==0) return;
    // 如果已经放满k个1并且去掉的第一位不是1，说明还有k个1
	a.m[S0|(1<<(m-1))][S]=1;
    // 这里是最后一位放1
}
void dfs(int i,int j,int S) {
	if(i==m) { nbuna(j,S); return; }
	dfs(i+1,j,S);
	if(j<k) dfs(i+1,j+1,S|(1<<i));
}
signed main() {
	n=read(), m=read(), k=read();
	U=(1<<m)-1;
	dfs(0,0,0);
	c=fp(a,n);
	int ans=0;
	rep(i,0,U) if(ok[i]) (ans+=c.m[i][i])%=mod;
	printf("%lld\n",ans);
	return 0;
}
```

### ARC058E 和風いろはちゃん

注意到只有和为 $X+Y+Z$ 的那一段才有用，这一段的方案数可以直接插板出来。但是没什么用，因为如果把这一段与其他部分分开做，就会产生重复。

我们考虑 $DP$。

直观上本题的非法方案要比合法方案更好求，这里选择求非法方案数。

&nbsp;
事实上，求出合法方案也并不困难，不过为了去重，需要在第一次满足条件时统计贡献。
&nbsp;

注意到 $X+Y+Z$ 很小，我们希望有一种方式能够让我们知道一个位置总和恰好为 $X+Y+Z$ 若干位置，是否能划分成合法的三段。

考虑把这个看成一个二进制数。二进制数中，每个 $1$ 代表一个元素，这个元素的值就是 $1$ 加上它与下一个 $1$ 之间 $0$ 的个数，也就是说 $x$ 被表示为 $2^{x-1}$。这样任何和为 $X+Y+Z$ 的情况，我们都能用一个二进制数表示，并且它的上界是 $17$ 个 $1$，也就是 $2^{18}-1$。

设 $f(i,S)$ 为考虑了前 $i$ 位，其中 $i$ 前面和为 $X+Y+Z$ 的一段的情况为  $S$ 的方案数。

转移枚举下一个元素填什么，并且更新 $S$ 即可，细节见代码。注意任何时候 $S$ 都不能被分成合法的三段。

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
const int N=42, M=1<<18, mod=1e9+7;
int n, X, Y, Z;
int U, f[N][M];
bool valid(int S) {
	int k1=(S>>(Z-1))&1;
	int k2=(S>>(Y+Z-1))&1;
	int k3=(S>>(X+Y+Z-1))&1;
	if(k1&&k2&&k3) return 0;
    // 当三者均为1时，就能划分出X+Y+Z
	return 1;
}
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
signed main() {
	n=read(), X=read(), Y=read(), Z=read();
	U=(1<<(X+Y+Z))-1;
	f[0][0]=1;
	rep(i,1,n) for(int S=0;S<=U;++S) {
		for(int j=1;j<=10;++j) {
			int T=((S<<j)+(1<<(j-1)))&U;
            //扔掉后面的j位，加上当前值
			if(valid(T)) (f[i][T]+=f[i-1][S])%=mod;
		}
	}
	int ans=fp(10,n);
	for(int S=0;S<=U;++S) (ans-=f[n][S]-mod)%=mod;
	printf("%lld\n",ans);
	return 0;
}

```





## 状压 DP

状态压缩使得状态可以度量，从而便于对复杂状态进行 DP。

有一个 Trick，名叫按秩转移。本质上是根据集合的无序性钦定基准点，从而减少不必要的状态数。基准点一般选取 $\operatorname{lowbit}(S)$。

在下面的题目中会有所涉及。

### luogu3959 [NOIP2017 提高组] 宝藏

太经典了。

打通的一定是一棵生成树，不难想到对生成树树高进行状压。

设 $f(x,S)$ 为当前树高为 $x$，已经打通的节点集合为 $S$ 的最小代价。

$$
f(x,S) = \min_{S_0 \subseteq S }\Big\{ f(x-1,S_0) + x \times d(S \setminus S_0,S_0) \Big\}
$$

其中 $d(S,S_0)$ 表示已经打通 $S$ 中节点后，打通 $S_0$ 中节点的最小代价。

本题的瓶颈在于预处理 $d$。

朴素的做法是枚举集合 $S$ 以及 $U-S$ 的子集 $T$，然后 $O(n^2)$ 算出从 $S$ 中任意节点到达 $T$ 中每个节点的最小代价，它们的和就是 $d(S,T)$。复杂度 $O(n^2 2^n)$。

使用上述技巧按秩转移。在计算 $d(S,T)$ 时，我们已经算完了 $d\Big(S,T-\operatorname{lowbit}(T)\Big)$，所以只需要额外对 $\operatorname{lowbit}(T)$ 求一遍最小值即可。复杂度 $O(n 2^n)$。

然而我们常用的枚举子集的代码，子集是从大到小枚举的。因此可以先存下来再从小到大求。

使用 $\text{DFS}$ 转移这个状态会跑得很快，不再赘述。

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
const int N=15, inf=0x3f3f3f3f;
int n, m, U, ans=inf, dis[N][N], d[1<<12][1<<12];
int f[N][1<<12], nxt[1<<12], lg[1<<12];
int lowbit(int S) { return S&-S; }
void prework() {
	rep(i,0,n-1) lg[1<<i]=i;
	for(int S=1;S<=U;++S) {
		int T=U^S, cnt=0;
		for(int S0=T;S0;S0=(S0-1)&T) nxt[S0]=cnt, cnt=S0;
		for(int S0=cnt;S0;S0=nxt[S0]) {
			int x=lg[lowbit(S0)], t=inf;
			for(int y=0;y<n;++y) if(S&(1<<y)) t=min(t,dis[x][y]);
			int pre=d[S][S0^lowbit(S0)];
			if(t!=inf&&pre!=inf) d[S][S0]=pre+t;
			else d[S][S0]=inf;
		}
	}
}
signed main() {
	n=read(), m=read();
	SET(dis,0x3f);
	rep(i,1,m) {
		int x=read()-1, y=read()-1, z=read();
		dis[x][y]=dis[y][x]=min(dis[x][y],z);
	}
	U=(1<<n)-1;
	prework();
	SET(f,0x3f);
	rep(i,0,n-1) f[0][1<<i]=0;
	for(int i=1;i<n;++i) {
		for(int S=1;S<=U;++S) {
			for(int T=S;T;T=(T-1)&S) if(d[S^T][T]!=inf) f[i][S]=min(f[i][S],f[i-1][S^T]+i*d[S^T][T]);
		}
	}
	rep(i,0,n) ans=min(ans,f[i][U]);
	printf("%d\n",ans);
}
```

### CF11D A Simple Task

典题。

 设 $f(x,y,S)$ 为只经过点集 $S$ 中的点，$x$ 到 $y$ 有多少路径，转移枚举中间点。

然而有很多环被重复统计了多次，而且数组开不下。

按秩转移。考虑让 $y=\operatorname{lowbit}(S)$ 作为基准点，这样状态就成了 $f(x,S)$，规模可以承受。

对于一个 $f(x,S)$，枚举 $(x \rightarrow y)$，当 $y=\operatorname{lowbit}(S)$ 说明找到了环，计入答案。否则只在 $y$ 可能作为 $S$ 后继状态的基准点，也就是 $2^y \ge \operatorname{lowbit}(S)$ 时转移到 $f(x,S \cup \{j\})$。

复杂度 $O(n^2 2^n)$。

```cpp
3092 [USACO13NOV] No Change G#include<bits/stdc++.h>
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
const int N=25;
int n, m, U, ans, a[N][N], f[N][1<<19];
int lowbit(int S) { return S&-S; };
signed main() {
	n=read(), m=read();
	U=(1<<n)-1;
	rep(i,1,m) {
		int x=read()-1, y=read()-1;
		a[x][y]=a[y][x]=1;
	}
	rep(i,0,n-1) f[i][1<<i]=1;
	for(int S=1;S<=U;++S) {
		for(int i=0;i<n;++i) if(S&(1<<i)) {
			if(!f[i][S]) continue;
			for(int j=0;j<n;++j) if(a[i][j]) {
				if((1<<j)<lowbit(S)) continue;
				if((1<<j)==lowbit(S)) ans+=f[i][S];
				else if((S&(1<<j))==0) f[j][S|(1<<j)]+=f[i][S];
			}
		}
	}
	printf("%lld\n",(ans-m)>>1);
}
```

### luogu3092 [USACO13NOV] No Change G

看得出来是一个区间划分类题目。

设 $f(S)$ 为集合 $S$ 内的硬币能够买到的最多物品。这个和顺序有关，转移时枚举最后一个使用的硬币，二分即可。

设 $g(S)$ 为在能买下所有物品的情况下，集合 $S$ 内硬币的总价值。

枚举没有使用的硬币集合 $S$，如果 $f(U \setminus S)=n$，那么就从 $\operatorname{lowbit}$ 处更新 $g(S)$，同时更新答案。

```CPP
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
const int N=20, M=1e5+5;
int k, n, U, ans=-1, c[N], s[M], f[1<<16], g[1<<16], lg[1<<16];
int bs(int L,int x) {
	int l=L, r=n;
	while(l<r) {
		int mid=(l+r+1)>>1;
		if(s[mid]-s[L-1]<=x) l=mid; else r=mid-1;
	}
	return l;
}
int lowbit(int x) { return x&-x; }
signed main() {
	k=read(), n=read();
	U=(1<<k)-1;
	rep(i,0,k-1) c[i]=read(), lg[1<<i]=i;
	rep(i,1,n) s[i]=s[i-1]+read();
	rep(S,1,U) rep(i,0,k-1) if(S&(1<<i)) {
		if(f[S^(1<<i)]==n) { f[S]=n; break; }
		f[S]=max(f[S],bs(f[S^(1<<i)]+1,c[i]));
	}
	if(f[U]==n) ans=max(ans,0ll);
	rep(T,1,U) {
		if(f[U^T]==n) ans=max(ans,g[T]=g[T^lowbit(T)]+c[lg[lowbit(T)]]);
	}
	printf("%lld\n",ans);
}

```

### luogu3694 邦邦的大合唱站队

这题题面写得真的无语。

稍微转化一下，把所有乐队归队就是一个划分区间问题。如果一个乐队归队的区间确定了，那么这个区间里面的偶像就不用动，剩下的就一定要出列。

设 $f(S)$ 为把集合 $S$ 内的的乐队归队，所需要的最小代价。设 $p_i$ 为第 $i$ 个乐队的人数。

枚举最后一个归队的乐队 $i$，算出剩下的乐队一共排到了 $cnt$ ，这样让 $i$ 归队的代价就是 $p_i$ 减去在 $[cnt+1,cnt+p_i]$ 里这个乐队的偶像的数量。

前缀和预处理即可。

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
const int N=25, M=1e5+5;
int n, m, U, a[M], p[N], s[N][M], f[1<<20];
signed main() {
	n=read(), m=read();
	U=(1<<m)-1;
	rep(i,1,n) {
		a[i]=read()-1;
		++p[a[i]], ++s[a[i]][i];
	}
	rep(i,0,m-1) rep(j,1,n) s[i][j]+=s[i][j-1];
	SET(f,0x3f);
	f[0]=0;
	for(int S=0;S<U;++S) {
		int cnt=0;
		for(int i=0;i<m;++i) if(S&(1<<i)) cnt+=p[i];
		for(int i=0;i<m;++i) {
			if(S&(1<<i)) continue;
			f[S|(1<<i)]=min(f[S|(1<<i)],f[S]+p[i]-(s[i][cnt+p[i]]-s[i][cnt]));
		}
	}
	printf("%lld\n",f[U]);
}
```

### luogu2831 [NOIP2016 提高组] 愤怒的小鸟

很无序，很状压。

设 $f(S)$ 表示把集合 $S$ 内的都干掉的最小代价。

转移枚举最后一个被干掉的，看它能不能和某一个一起被干掉，不能的话就自己来一发。

然后这个是 $O(n^2 2^n)$。

还是把 $\operatorname{lowbit}(S)$ 当作最后一个被干掉的，这样就做到  $O(n 2^n)$。

为了方便，预处理 $p(i,j)$ 表示 $i$ 和 $j$ 确定的抛物线能干掉的集合。

需要解方程，式子比较好推，不再赘述。

还有就是注意精度问题。

```cpp
// Problem: P2831 [NOIP2016 提高组] 愤怒的小鸟
// Author: KisaragiQwQ
// Date: 2023-06-17 20:25:53
// URL: https://www.luogu.com.cn/problem/P2831
// Memory Limit: 500 MB
// Time Limit: 2000 ms
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
const int N=20;
const double eps=1e-8;
int T, n, m, U, p[N][N], f[1<<18], lg[1<<18];
double x[N], y[N];
pair<double,double> calc(double x1,double y1,double x2,double y2) {
	double a=(y1*x2-y2*x1)/(x1*x2*(x1-x2));
	double b=y2/x2-x2*a;
	return MP(a,b);
}
double F(double a,double b,double x) { return a*x*x+b*x; }
int lowbit(int x) { return x&-x; }
void solve() {
	n=read(), m=read();
	rep(i,0,n-1) scanf("%lf%lf",&x[i],&y[i]);
	rep(i,0,n-1) rep(j,0,n-1) {
		p[i][j]=0;
		if(i==j||fabs(x[i]-x[j])<eps) continue;
		pair<double,double> gen=calc(x[i],y[i],x[j],y[j]);
		if(gen.fi>-eps) continue;
		rep(k,0,n-1) {
			if(fabs(F(gen.fi,gen.se,x[k])-y[k])<eps) p[i][j]|=(1<<k);
		}
	}
	SET(f,0x3f);
	f[0]=0;
	U=(1<<n)-1;
	for(int S=1;S<=U;++S) {
		int k=lg[lowbit(S)], S0=S^(1<<k);
		f[S]=min(f[S],f[S0]+1);
		for(int i=0;i<n;++i) if(S0&p[k][i]) f[S]=min(f[S],f[S0^(S0&p[k][i])]+1);
	}
	printf("%d\n",f[U]);
}
signed main() {
	T=read();
	rep(i,0,17) lg[1<<i]=i;
	while(T--) solve();
	return 0;
}
```

### luogu7098 [yLOI2020] 凉凉

[link](https://www.luogu.com.cn/blog/yozora0908/solution-p7098)

### luogu4923 [MtOI2018] gcd？人生赢家！

乍一看挺复杂的，读入尤其恶心。

直接设 $f(x,k,S)$ 为当前在宝物 $x$ 所在的节点，还剩下 $k$ 次传送机会，取得了集合 $S$ 内宝物的最小时间。

仔细想想发现还剩下 $k$ 次传送机会不太好弄，可以改为已经传送了 $k$ 次。

先算出当前已经完成了的成就，然后再枚举下一个要到达的宝物所在点，传送或者直接过去，距离用 $\text{Floyd}$ 算法处理。

用 $\text{DFS}$ 转移，跑得很快。

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
const int N=15, inf=0x3f3f3f3f;
int n, m, _k, s, e, U, st;
int ss[N], a[N], p[N], pre[N], d[205][205];
int lg[1<<12], f[N][N][1<<12];
int popcount(int x) {
	int cnt=0;
	while(x) cnt+=x&1, x>>=1;
	return cnt;
}
void input() {
	n=read(), m=read(), _k=read(), s=read();
	U=(1<<m)-1;
	rep(i,1,n) memset(d[i],0x3f,(n+1)<<2), d[i][i]=0;
	rep(i,1,s) {
		int num=read();
		while(num--) {
			int x=read();
			ss[i]|=(1<<(x-1));
		}
	}
	rep(i,1,s) a[i]=read();
	rep(i,0,m-1) p[i]=read(), lg[1<<i]=i;
	e=read();
	rep(i,1,e) {
		int x=read(), y=read(), z=read();
		d[x][y]=d[y][x]=min(d[x][y],z);
	}
	rep(i,0,m-1) {
		int num=read();
		while(num--) {
			int x=read();
			pre[i]|=(1<<(x-1));
		}
	}
	st=read();
}
void floyd() {
	rep(k,1,n) rep(i,1,n) if(d[i][k]!=inf) {
		rep(j,1,n) if(d[k][j]!=inf) d[i][j]=min(d[i][j],d[i][k]+d[k][j]);
	}
}
int lowbit(int x) { return x&-x; }
int dfs(int x,int kk,int S) {
	if(f[x][kk][S]!=inf) return f[x][kk][S];
	int& res=f[x][kk][S];
	if(S==U) return res=0;
	int ayano=0;
	for(int i=1;i<=s;++i) if((S&ss[i])==ss[i]) ayano+=a[i];
	int T=U^S;
	for(int y=0;y<m;++y) if(T&(1<<y)) {
		if((S&pre[y])!=pre[y]) continue;
		if(d[p[x]][p[y]]!=inf) res=min(res,d[p[x]][p[y]]+dfs(y,kk,S|(1<<y)));
		if(kk<_k+ayano) res=min(res,dfs(y,kk+1,S|(1<<y)));
	}
	return res;
}
signed main() {
	input();
	floyd();
	SET(f,0x3f);
	int ans=inf;
	rep(i,0,m-1) if(pre[i]==0) {
        // 起点是任意没有前置要求的宝物处。
		if(d[st][p[i]]!=inf) ans=min(ans,d[st][p[i]]+dfs(i,0,1<<i));
		if(_k) ans=min(ans,dfs(i,1,1<<i));
	} 
	printf("%d\n",ans);
	return 0;
}
```



### luogu3622 [APIO2007] 动物园

有了花园那题的铺垫，这题我们直接状压后面 $5$ 个格子的状态。

可以预处理出每个状态的高兴小朋友数量。

设 $f(i,S)$ 表示考虑前 $i$ 个格子，$[i,i+4]$ 的状态是 $S$ 的最大数量。

枚举初始状态 $S'$，每次往前推一位，后继状态就是最高位放不放 $1$。

警钟敲烂，使用刷表法的时候，一定记得清空整个数组。

```cpp
// Problem: P3622 [APIO2007] 动物园
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3622
// Author: KisaragiQwQ
// Date: 2023-06-19 16:59:37
// Memory Limit: 125 MB
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
const int N=1e4+5, M=5e4+5, U=31;
int n, m, f[N][1<<5], w[N][1<<5];
int popcount(int x) {
    int cnt=0;
    while(x) cnt+=x&1, x>>=1;
    return cnt;
}
signed main() {
	n=read(), m=read();
	rep(i,1,m) {
		int x=read(), c1=read(), c2=read();
		int f=0, l=0;
		while(c1--) {
			int p=read();
			p=(p-x+n)%n;
			f|=(1<<p);
		}
		while(c2--) {
			int p=read();
			p=(p-x+n)%n;
			l|=(1<<p);
		}
		for(int S=0;S<=U;++S) {
			if(S&l||f&(~S)) ++w[x][S];
		}
	}
	int ans=0;
	for(int i=0;i<=U;++i) {
		SET(f,-0x3f);
        // 清空整个数组
		f[0][i]=0;
		for(int j=0;j<n;++j) for(int S=0;S<=U;++S) {
            int S0=S>>1, S1=(S0|16)&31;
            f[j+1][S0]=max(f[j+1][S0],f[j][S]+w[j+1][S0]);
			f[j+1][S1]=max(f[j+1][S1],f[j][S]+w[j+1][S1]);
		}
		ans=max(ans,f[n][i]);
	}
	printf("%d\n",ans);
	return 0;
}
```

填表法代码

```cpp
SET(f[0],-0x3f);
f[0][i]=0;
for(int j=1;j<=n;++j) for(int S=0;S<=U;++S) {
	f[j][S]=max(f[j-1][(S&15)<<1],f[j-1][((S&15)<<1)|1])+w[j][S];
}
```



### luogu2150 [NOI2015] 寿司晚宴

很显然是在质因子上做文章。

30 分怎么做？

$n \le 30$，质因子只有 $10$ 个，可以对其状压。设 $f(x,S_1,S_2)$ 为考虑了前 $i$ 个数，其中第一个人的质因子集合为 $S_1$，另一个人是 $S_2$ 的方案数。预处理每个数的质因子集合，转移的时候讨论每个数的 $3$ 种情况即可。

考虑 50 分做法。设 $f(S)$ 为选出的质因子集合为 $S$ 的方案数，$g(S) = \sum_{T \subseteq S} f(T)$，那么答案就是

$$
\sum_{S \subseteq U} f(S) g(U \setminus S)
$$

然而 $100$ 以内的质数有 $25$ 个。

考虑超过 $50$ 的质因数只能出现 $1$ 次，因此可以只考虑 $\le 50$ 的 $15$ 个质数。超过 $50$ 的质数只有 $3$ 种方案，最后乘上一个 $3$ 的次幂即可。

考虑正解。

$\texttt{Observation}$

超过 $\sqrt n$ 的质数最多选择 $1$ 个。

因此我们就把不超过 $\sqrt  n$ 的最多 $8$ 个质数单拿出来。设超过 $\sqrt n$ 的质数为 $\{bp\}$，不超过 $\sqrt n$ 的为 $\{sp\}$。含相同 $bp$ 的数构成一个等价类，把不含 $bp$ 的数看作大小为 $1$ 的等价类。排序后分段处理。

设 $f(S_1,S_2)$ 为二者的质因数集合分别为 $S_1,S_2$ 的方案数，$g_1(S_1,S_2)$ 和 $g_2(S_1,S_2)$ 是在当前等价类 $i$ 中，$bp_i$ 只能放到 $S_1$ 或 $S_2$ 的方案数。注意最终没有放 $bp_i$ 的方案在二者中都能统计到。

当做完一个等价类后，令 $g_1(S_1,S_2) + g_2(S_1,S_2) - f(S_1,S_2) \rightarrow f(S_1,S_2)$。

复杂度是 $\mathcal{O}(n 2^{16})$。

```cpp
// Problem: P2150 [NOI2015] 寿司晚宴
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P2150
// Author: yozora0908
// Date: 2023-07-15 11:13:46
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
const int N=505, M=1<<8;
const int pr[8]={2,3,5,7,11,13,17,19};
int n, mod;
int f[M][M], g1[M][M], g2[M][M];
struct node {
	int sp, bp;
} a[N];
bool operator<(node a,node b) {
	return a.bp<b.bp;
}
signed main() {
	n=read(), mod=read();
	for(int i=1;i<n;++i) {
		int t=i+1;
		rep(j,0,7) if(t%pr[j]==0) {
			a[i].sp|=1<<j;
			while(t%pr[j]==0) t/=pr[j];
		}
		if(t>1) a[i].bp=t;
	}
	sort(a+1,a+n);
	f[0][0]=1;
	for(int i=1;i<n;++i) {
		if(a[i].bp==0||a[i].bp!=a[i-1].bp) {
            // 新的等价类
			per(S1,255,0) per(S2,255,0) if((S1&S2)==0) {
				 g1[S1][S2]=g2[S1][S2]=f[S1][S2];
			}	
		}
		per(S1,255,0) per(S2,255,0) if((S1&S2)==0) {
			if((S1&a[i].sp)==0) (g2[S1][S2|a[i].sp]+=g2[S1][S2])%=mod;
			if((S2&a[i].sp)==0) (g1[S1|a[i].sp][S2]+=g1[S1][S2])%=mod;
		}
		if(i==n-1||a[i].bp==0||a[i].bp!=a[i+1].bp) {
            // 下一个数是新的等价类
			per(S1,255,0) per(S2,255,0) if((S1&S2)==0) {
				f[S1][S2]=((g1[S1][S2]+g2[S1][S2])%mod-f[S1][S2]+mod)%mod;
			}
		}
	}
	int ans=0;
	rep(S1,0,255) rep(S2,0,255) if((S1&S2)==0) {
		(ans+=f[S1][S2])%=mod;
	}
	printf("%lld\n",ans);
	return 0;
}
```

### luogu6239 [JXOI2012] 奇怪的道路

设 $f(i,j,S)$ 为考虑了 $[1,i]$ 中的点，连了 $j$ 条边，$[i-k,i]$ 中点的奇偶性为 $S$ 的方案数。

貌似可以直接做了。

### luogu3943 星空

Starry Sky.

[link](https://yozora0908.github.io/2023/lg3943-solution)
