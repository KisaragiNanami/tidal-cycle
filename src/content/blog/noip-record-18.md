---
title: 「NOIP Record」#18 区间DP
pubDate: 2023-08-30
tags:
  - DP
  - 区间DP
  - 状态压缩
  - 贪心
  - 双指针
  - 计数
categories:
  - Record
description: '少年对自制的工具驾轻就熟'
---

## 区间形态的扩展

### luogu3205 [HNOI2010] 合唱队

队列的形成方式是不断往左或往右扩展。

考虑区间 DP。发现对于一个区间 $[i,j]$，最后一个元素的来源会对转移产生影响，所以设 $f(i,j,0/1)$ 为考虑区间 $[i,j]$，其中最后一个元素是从左边还是右边加入的方案数。

转移很简单
$$
f(i,j,0) = [a_i < a_{i+1}]f(i+1,j,0) + [a_i < a_j] f(i+1,j,0)
$$

$$
f(i,j,1) = [a_j > a_{i}] f(i,j-1,0) + [a_j > a_{j-1}] f(i,j-1,1)
$$

注意对于 $[i,i]$，钦定从一边转移过来即可。

```cpp
// Problem: P3205 [HNOI2010] 合唱队
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3205
// Author: yozora0908
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
const int N=1005, mod=19650827;
int n, a[N], f[N][N][2];
signed main() {
	n=read();
	rep(i,1,n) a[i]=read(),  f[i][i][0]=1;
	rep(l,2,n) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		if(a[i]<a[i+1]) (f[i][j][0]+=f[i+1][j][0])%=mod;
		if(a[i]<a[j]) (f[i][j][0]+=f[i+1][j][1])%=mod;
		if(a[j]>a[i]) (f[i][j][1]+=f[i][j-1][0])%=mod;
		if(a[j]>a[j-1]) (f[i][j][1]+=f[i][j-1][1])%=mod;
	}
	printf("%lld\n",(f[1][n][0]+f[1][n][1])%mod);
	return 0;
}
```

### 某道题

>你有 $[1,n]$ 中的正整数各 $2$ 个，存在 $k$ 个限制。
>
>要求将这 $2n$ 个数排成一个序列，满足以下两个条件：
>
>- 如果存在一个最大的数所在的的位置 $p$，满足 $p>1$，那么 $[1,p]$ 中的数单调不降。
>- 如果存在一个最大的数所在的的位置 $p$，满足 $p<n$，那么 $[p,n]$ 中的数单调不增。
>
>每个限制条件形如`x op y`。
>
>其中`op`可能为`<`，`<=`，`=`，`>=`，`>`，表示下标为 $x$ 的数与下标为 $y$ 的数必须满足的大小关系。
>
>求方案数，对 $998244353$ 取模。
>
>$n \le 1000$，$0 \le k \le 3 \times 10^4$。
>
>注意：原题没有取模，$n \le 500$。但是复杂度的瓶颈在于高精度，所以这里加上取模，并且增大数据范围。



先不考虑限制。

如何生成这样的序列呢？考虑从大到小放。两个 $n$ 肯定要放到中间，剩下的数要么两边放一个，要么都放在一边。这样就是呈区间形态的扩展方式，考虑区间 DP。

设 $f(i,j,k)$ 为考虑了 $[k,n]$ 中的数，放完了区间 $[i,j]$ 的方案。

仔细思考能发现记录 $k$ 根本没有用，只要区间扩展时每次只扩展 $2$ 的长度，就一定合法。

设 $f(i,j)$ 为放完了区间 $[i,j]$ 的方案数。

如果没有限制的话，能发现答案就是 $3^{n-1}$。

考虑限制。

我们讨论三种方法是否会受限制。

1. 放的两个位置必须都允许相等。
2. 这两个位置都必须严格小于其他位置。

暴力判断就是 $O(n)$ 的。

利用大小关系的对称性。设 $s(i,j)$ 为 $i$ 与 $j$ 的限制，没有就是 $0$，`<`是 $1$，$\le$  是 $2$，`=`是 $3$。对 $j$ 这一维求前缀和，就能 $O(1)$ 判断一个区间对一个位置的限制，加以讨论即可做到 $O(n^2)$。

下面的代码是带着高精的。

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
const int N=1005;
string st;
int n, k, p[N][N], s[N][N];
struct Int {
	short a[245], deg=0;
	void reset() { SET(a,0); deg=0; }
	bool zero() { return !deg||(deg==1&&a[0]==0); }
	void operator=(int x) { deg=1; a[deg-1]=x; }
	void operator+=(Int& x) {
		deg=max(deg,x.deg);
		for(int i=0;i<deg;++i) {
			a[i]+=x.a[i];
			a[i+1]+=a[i]/10;
			a[i]%=10;
		}
		while(a[deg]) ++deg;
	}
	void print() {
		for(int i=deg-1;~i;--i) printf("%d",a[i]);
	}
} f[N][N];

signed main() {
	n=read()*2, k=read();
	rep(i,1,k) {
		int l=read();
		cin>>st;
		int r=read();
		if(st=="<") p[l][r]=1, p[r][l]=5;
		else if(st=="<=") p[l][r]=2, p[r][l]=4;
		else if(st=="=") p[l][r]=p[r][l]=3;
		else if(st==">=") p[l][r]=4, p[r][l]=2;
		else p[l][r]=5, p[r][l]=1;
	}
	rep(i,1,n) rep(j,1,n) s[i][j]=s[i][j-1]+(p[i][j]>2);
	f[1][n]=0;
	for(int i=1;i<n;++i) if(!p[i][i+1]||(p[i][i+1]>=2&&p[i][i+1]<=4)) f[i][i+1]=1;
	for(int l=2;l<=n;l+=2) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		if(!f[i][j].zero()) continue;
		if(p[i][i+1]!=1&&p[i][i+1]!=5&&!f[i+2][j].zero()) {
			if(s[i][j]==s[i][i+1]&&s[i+1][j]==s[i+1][i+1]) f[i][j]+=f[i+2][j];
		}
		if(p[j-1][j]!=1&&p[j-1][j]!=5&&!f[i][j-2].zero()) {
			if(s[j][j-2]==s[j][i-1]&&s[j-1][j-2]==s[j-1][i-1]) f[i][j]+=f[i][j-2];
		}
		if(p[i][j]!=1&&p[i][j]!=5&&!f[i+1][j-1].zero()) {
			if(s[i][j-1]==s[i][i]&&s[j][j-1]==s[j][i]) f[i][j]+=f[i+1][j-1];
		}
	}
	f[1][n].print();
	return 0;
}
```

### luogu6563 [SBCOI2020] 一直在你身旁

[link](https://yozora0908.github.io/2023/lg6563-solution)

## 求出区间信息后贪心划分

### UVA1437 String painter

>我断言一定存在一种最优的方案满足对于任意两次染色：它们的区间要么不交，要么靠后的那次被靠前的那次包含并且不共端点。
>
>By [FZzzz](https://www.luogu.com.cn/user/174045)

先考虑空串怎么做。

设 $f(i,j)$ 为完成区间 $[i,j]$ 的涂色的最小代价。

- 如果 $S[i]=S[j]$，那么 $f(i,j) = f(i,j-1)$。
- 否则一定一个断点，满足左右两边的染色区间不相交。枚举断点即可。

考虑原问题，不难发现最优解一定是若干个不相交区间的 $f$ 拼接成的。

设 $g(i)$ 为完成 $[1,i]$ 的涂色的最小代价。如果 $A[i] = B[i]$，那么直接继承 $g(i-1)$。否则枚举最后一段的划分点，求 $\min_{j=1}^{i-1} \Big\{g(j)+f(j+1,i) \Big\}$



### luogu2470 [SCOI2007] 压缩

和上面那题的套路很像。

先考虑没有`M`的情况。

发现直接做是不行的，比如`aaaabaaaab`，最短的压缩应该是`aRRbR`。也就是说，这里有一个子问题的结构。

设 $g(i,j)$ 为不考虑`M`，区间 $[i,j]$ 的最小压缩长度。

仔细思考，发现这个区间能折半的话就折半，否则就只能拖在后面。
$$
g(i,j) = \min \begin{cases}
g(i,i+mid-1)+1 & \text{if } \; valid(i,j)
\\
g(i,j-1)+1
\end{cases}
$$
其中 $valid(i,j)$ 表示 $[i,j]$ 能否从中间划分成两个相同的串。

然后设 $f(i)$ 为 $[1,i]$ 的最小划分，有
$$
f(i) = \min_{j=0}^{i-1} \Big\{ f(j) + g(j+1,i) \Big\}
$$
如果用哈希求 $valid(i,j)$，那么复杂度就是 $O(n^2)$，优于洛谷题解区所有题解。

但是数据太水，如果用哈希可能因为常数大跑得更慢，所以本人采用了暴力做法，是 $O(n^3)$ 的。

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
const int N=55;
int n, f[N], g[N][N];
string s;
signed main() {
	cin>>s;
	n=s.size();
	s=" "+s;
	rep(i,1,n) g[i][i]=1, g[i][i+1]=2;
	for(int lim=3;lim<=n;++lim) for(int i=1;i+lim-1<=n;++i) {
		int j=i+lim-1;
		int& res=g[i][j];
		res=lim;
		if(lim%2==0&&s.substr(i,lim/2)==s.substr(i+lim/2,lim/2)) res=min(res,g[i][i+lim/2-1]+1);
		res=min(res,g[i][j-1]+1);
	}
	rep(i,1,n) f[i]=g[1][i];
	for(int i=2;i<=n;++i) {
		for(int j=1;j<i;++j) {
			f[i]=min(f[i],f[j]+g[j+1][i]+1);
		}
	}
	printf("%d\n",f[n]);
	return 0;
}
```

类题还有[CF1312E Array Shrinking](https://yozora0908.github.io/2022/cf1312e-solution/)

## 笛卡尔树上DP

说白了就是按照最值划分区间。

### luogu5851 [USACO19DEC] Greedy Pie Eaters

一个合法的顺序，一定若干个区间不断向外扩展。

一次收益只需要保证一个元素的存在，可以就此入手。

区间重叠难以处理，而数据范围较小，可以对区间范围进行限制。

设 $g(k,i,j)$ 为只考虑被 $[i,j]$ 完全包含的区间，所有覆盖过 $k$ 的区间的最大权值。

容易在 $O(n^3)$ 的时间里处理出来。

设 $f(i,j)$ 为只考虑被 $[i,j]$ 完全包含的区间，能够产生的最大收益。

枚举最后一个被干掉的元素 $k$，有转移
$$
f(i,j) = \max_{k=i}^j \Big\{ f(i,k-1) + g(k,i,j) + f(k+1,j)  \Big\}
$$
对于区间 $[i,j]$，一定存在最后一个被干掉的元素。想要这个元素此时依然存在，之前选择的区间就不能包含它，而两边都是子问题。

```cpp
// Problem: P5851 [USACO19DEC] Greedy Pie Eaters P
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P5851
// Author: yozora0908
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
const int N=305;
int n, m, f[N][N], g[N][N][N];
signed main() {
	n=read(), m=read();
	rep(i,1,m) {
		int w=read(), l=read(), r=read();
		rep(k,l,r) g[k][l][r]=max(g[k][l][r],w);
	}
	for(int l=1;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		rep(k,i,j) {
			g[k][i][j]=max({g[k][i][j],g[k][i+1][j],g[k][i][j-1]});
		}
	}
	rep(i,1,n) f[i][i]=max(f[i][i],g[i][i][i]);
	for(int l=2;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		rep(k,i,j) {
			f[i][j]=max(f[i][j],f[i][k-1]+g[k][i][j]+f[k+1][j]);
		}
	}
	printf("%lld\n",f[1][n]);
	return 0;
}
```

### LOJ#2688. 「POI2015」洗车

设 $f(i,j,k)$ 为考虑洗车店区间 $[i,j]$ 和被区间 $[i,j]$ 完全包含的消费者区间，$[i,j]$ 的最小值为 $k$ 时，能得到的最大收益。

先将 $c_i$ 离散化了。

我们把贡献放到点上，求出 $g(p,k)$ 表示在当前区间内，覆盖了 $p$ 且 $c_i \ge k$ 的区间数量。有转移
$$
f(i,j,k) = \max_{p=i}^j \Big\{ f(i,p-1,k) + g(p,k) \times val(k) +  f(p+1,j,k)  \Big\}
$$
正确性就比较显然了。

输出方案只需要记录最优决策点和对应决策值。



```cpp
// Problem: P3592 [POI2015] MYJ
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3592
// Author: yozora0908
// Memory Limit: 250 MB
// Time Limit: 2000 ms
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
const int N=55, M=4005;
int n, m, cnt, a[M], b[M], c[M], t[M];
int f[N][N][M], g[N][M], lst[N][N][M], v[N][N][M], ans[N];
void lsh() {
	sort(t+1,t+m+1);
	cnt=unique(t+1,t+m+1)-(t+1);
	rep(i,1,m) c[i]=lower_bound(t+1,t+cnt+1,c[i])-t;	
}
void print(int i,int j,int k) {
	if(i>j) return;
	ans[lst[i][j][k]]=t[v[i][j][k]];
	print(i,lst[i][j][k]-1,v[i][j][k]);
	print(lst[i][j][k]+1,j,v[i][j][k]);
}
signed main() {
	n=read(), m=read();
	rep(i,1,m) {
		a[i]=read(), b[i]=read(), c[i]=t[i]=read();
	}
	lsh();
	for(int l=1;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		SET(g,0);
		rep(k,1,m) if(i<=a[k]&&b[k]<=j) {
			rep(p,a[k],b[k]) ++g[p][c[k]];
		}
		rep(p,i,j) per(k,cnt,1) g[p][k]+=g[p][k+1];
		lst[i][j][cnt+1]=i, v[i][j][cnt+1]=cnt;
		per(k,cnt,1) {
			f[i][j][k]=f[i][j][k+1];
			lst[i][j][k]=lst[i][j][k+1];
			v[i][j][k]=v[i][j][k+1];
			rep(p,i,j) if(f[i][p-1][k]+f[p+1][j][k]+g[p][k]*t[k]>f[i][j][k]) {
				f[i][j][k]=f[i][p-1][k]+f[p+1][j][k]+g[p][k]*t[k];
				lst[i][j][k]=p, v[i][j][k]=k;
			}
		}
	}
	printf("%lld\n",f[1][n][1]);
	print(1,n,1);
	rep(i,1,n) printf("%lld ",ans[i]);
	return 0;
}
```



另外有类题[luogu4766 Outer space invaders](https://yozora0908.github.io/2022/lg4766-solution/)

## 区间左右取数

这个就相对固定了。

### ABC303G Bags Game

一类在区间左右选物品的博弈问题。

设 $f(i,j)$ 为只考虑区间 $[i,j]$，先手能得到的最大收益。

第一类操作，转移显然。

考虑第二三类操作。

以第二类操作为例，设 $\beta=\min(B,len)$，枚举 $x+y=\beta$，有转移
$$
f(i,j) \leftarrow \max_{x=0}^{\beta} \Big\{ \sum_{k=i}^{i+x-1} a_i + \sum_{j-y+1}^{j} a_i  - f (i+x,j-y) \Big\}
$$
式子变形一下就是
$$
\max_{x=0}^{\beta} \Bigg\{ sum(i,j) - \Big( f (i+x,j-y) + sum(i+x,j-y) \Big) \Bigg\}
$$
考虑优化。

能发现对于一个固定的 $len=j-i+1$，所有决策区间的长度都是 $j-y-(i+x)+1 = len-\beta$。

设 $lb=len-\beta$。

当从 $[i-1,j-1]$ 到 $[i,j]$ 时，我们只会丢掉决策 $f(i-1,i+lb-2)$，增加决策 $f(j-lb+1,j)$ 。

我们只需要用单调队列维护中间那个东西的最小值就行了。

实现细节颇多，具体看代码。

```cpp
// Problem: [ABC303G] Bags Game
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/AT_abc303_g
// Author: yozora0908
// Memory Limit: 1 MB
// Time Limit: 2500 ms
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
const int N=3005;
int n, A, B, C, D, a[N], s[N], f[N][N];
int q1[N], q2[N];
int sum(int i,int j) { return s[j]-s[i-1]; }
signed main() {
	n=read(), A=read(), B=read(), C=read(), D=read();
	
	rep(i,1,n) {
		a[i]=read();
		s[i]=s[i-1]+a[i];
		f[i][i]=a[i];
	}
	for(int len=2;len<=n;++len) {
		int l1=1, r1=0;
		int l2=1, r2=0;
		int lb=len-B, ld=len-D;
		f[1][len]=max(a[1]-f[2][len],a[len]-f[1][len-1]);
		
		if(lb>0) {

			for(int i=1;i+lb-1<=len;++i) {
             	int ll=q1[r1], rr=q1[r1]+lb-1;
             	// 当前加入的区间是[i,i+lb-1]
				while(l1<=r1&&f[ll][rr]+sum(ll,rr)>=f[i][i+lb-1]+sum(i,i+lb-1)) {
					--r1;
					ll=q1[r1], rr=q1[r1]+lb-1;
				}
				q1[++r1]=i;
			}
            // 先把[1,len]中所有决策都扔进，注意边界
			int ll=q1[l1], rr=q1[l1]+lb-1;
			f[1][len]=max(f[1][len],sum(1,len)-A-sum(ll,rr)-f[ll][rr]);
		} else f[1][len]=max(f[1][len],sum(1,len)-A);
		
		if(ld>0) {

			for(int i=1;i+ld-1<=len;++i) {
				int ll=q2[r2], rr=q2[r2]+ld-1;
				while(l2<=r2&&f[ll][rr]+sum(ll,rr)>=f[i][i+ld-1]+sum(i,i+ld-1)) {
					--r2;
					ll=q2[r2], rr=q2[r2]+ld-1;
				}
				q2[++r2]=i;
			}
			
			int ll=q2[l2], rr=q2[l2]+ld-1;
			f[1][len]=max(f[1][len],sum(1,len)-C-sum(ll,rr)-f[ll][rr]);
			
		} else f[1][len]=max(f[1][len],sum(1,len)-C);
		
		
		for(int i=2;i+len-1<=n;++i) {
			int j=i+len-1;
			f[i][j]=max(a[i]-f[i+1][j],a[j]-f[i][j-1]);
			if(lb<=0) f[i][j]=max(f[i][j],sum(i,j)-A);
			else {
				while(l1<=r1&&q1[l1]<i) ++l1;
				int ll=q1[r1], rr=q1[r1]+lb-1;
				while(l1<=r1&&f[ll][rr]+sum(ll,rr)>=f[j-lb+1][j]+sum(j-lb+1,j)) {
					--r1;
					ll=q1[r1], rr=q1[r1]+lb-1;
				}
				q1[++r1]=j-lb+1;
				ll=q1[l1], rr=q1[l1]+lb-1;
                // 注意顺序，我们刚才加入的是当前区间所带来的新决策，所以更新必须放到最后
				f[i][j]=max(f[i][j],sum(i,j)-A-sum(ll,rr)-f[ll][rr]);
				
				
			}
			if(ld<=0) f[i][j]=max(f[i][j],sum(i,j)-C);
			else {
				while(l2<=r2&&q2[l2]<i) ++l2;
				int ll=q2[r2], rr=q2[r2]+ld-1;
				while(l2<=r2&&f[ll][rr]+sum(ll,rr)>=f[j-ld+1][j]+sum(j-ld+1,j)) {
					--r2;
					ll=q2[r2], rr=q2[r2]+ld-1;
				}
				q2[++r2]=j-ld+1;
				ll=q2[l2], rr=q2[l2]+ld-1;
				f[i][j]=max(f[i][j],sum(i,j)-C-sum(ll,rr)-f[ll][rr]);
				
				
			}
		}
	}
	printf("%lld\n",f[1][n]);
	return 0;
}
```



## 杂题

### CF149D Coloring Brackets

先用栈求出点 $i$ 的匹配点 $\text{match}(i)$。

设 $f(i,j,a,b)$ 为考虑区间 $[i,j]$，其中左端点的染色情况和为 $a$，右端点的染色情况为 $b$ 的方案数。

分如下情况讨论。

- $\text{match}(i)=j$。

  如果 $i+1=j$，那么直接讨论就好了。否则枚举颜色，用 $f(i+1,j-1)$ 转移。

- $\text{match}(i) \neq j$。我们考虑把 $[i,\text{match}(i)]$ 拼接到 $[\text{match}(i)+1,j]$ 上。枚举颜色讨论即可。

- 注意由于 $\text{match}(i)$ 不一定在 $i$ 的右边，所以要判断所有 $i>j$ 的情况。

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
const int N=705, mod=1e9+7;
int n, match[N], f[N][N][3][3];
int tp, st[N];
char s[N];
void dfs(int l,int r) {
	if(l>r) return;
	if(l+1==r) {
		f[l][r][0][1]=f[l][r][0][2]=f[l][r][1][0]=f[l][r][2][0]=1;
		return;
	}
	if(match[l]==r) {
		dfs(l+1,r-1);
		rep(i,0,2) rep(j,0,2) {
			if(j!=1) (f[l][r][0][1]+=f[l+1][r-1][i][j])%=mod;
			if(j!=2) (f[l][r][0][2]+=f[l+1][r-1][i][j])%=mod;
			if(i!=1) (f[l][r][1][0]+=f[l+1][r-1][i][j])%=mod;
			if(i!=2) (f[l][r][2][0]+=f[l+1][r-1][i][j])%=mod;
		}		
	} else {
		dfs(l,match[l]);
		dfs(match[l]+1,r);
		rep(i,0,2) rep(j,0,2) rep(p,0,2) rep(q,0,2) {
			if(j==p&&j) continue;
			if(!i||!p) (f[l][r][i][q]+=f[l][match[l]][i][p]*f[match[l]+1][r][j][q]%mod)%=mod;
            // 相邻不能相等，匹配的两边不能都染色
		}
	}
}
signed main() {
	scanf("%s",s+1);
	n=strlen(s+1);
	rep(i,1,n) {
		if(s[i]=='(') st[++tp]=i;
		else {
			match[i]=st[tp];
			match[st[tp]]=i;
			--tp;
		}
	}
	dfs(1,n);
	int ans=0;
	rep(i,0,2) rep(j,0,2)  (ans+=f[1][n][i][j])%=mod;
	printf("%lld\n",ans);
	return 0;
}
```



###  luogu3147 [USACO16OPEN] 262144

先考虑 $O(n^3)$ 怎么做。

这类整个区间合并成一个数的题都有一个套路：只考虑整个区间合并成一个数的情况。

设 $f(i,j)$ 为区间 $[i,j]$ 能合成的数的最大值，转移枚举断点，再判断两边是否相等即可。

然后这题正解就和 DP 没关系了。

设 $f(i,j)$  为从 $j$ 开始合并一串数得到 $i$，这串数的个数。
$$
f(i,j) = f(i-1,j) + f\Big(i-1,j+f(i-1,j)\Big)
$$
类题是 [luogu4805 [CCC2016] 合并饭团](https://www.luogu.com.cn/problem/P4805)，不过那题的主要部分是单调性优化，这里就不展开了。

### luogu2890 [USACO07OPEN] Cheapest Palindrome

设 $f(i,j)$ 为把区间 $[i,j]$ 搞成回文的最小代价。

如果 $S[i]=S[j]$，那么直接继承 $f(i+1,j-1)$。

否则就是 $\min\Big( f(i+1,j)+cost_i,f(i,j-1)+cost_j \Big)$

其中 $cost_i$ 表示增加或删去 $S[i]$ 的较小代价。

对于区间 $[i,j]$，如果 $S[i] \neq S[j]$，那么要想形成回文串，总会拿出 $S[i],S[j]$ 其中之一，删掉或添加一个一样的在另一边，剩下的部分也要形成回文串，这是一个子问题。

```cpp
// Problem: P2890 [USACO07OPEN] Cheapest Palindrome G
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P2890
// Author: yozora0908
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
const int N=2005;
int n, m, f[N][N], c[100][2];
char s[N], o[5];
signed main() {
	n=read(), m=read();
	scanf("%s",s+1);
	
	rep(i,1,n) {
		scanf("%s",o);
		c[o[0]-'a'][0]=read(), c[o[0]-'a'][1]=read();
	}
	SET(f,0x3f);
	rep(i,1,m) f[i][i]=0;
	for(int l=2;l<=m;++l) for(int i=1;i+l-1<=m;++i) {
		int j=i+l-1;
		if(s[i]==s[j]) {
			if(i+1==j) f[i][j]=0;
			else f[i][j]=min(f[i][j],f[i+1][j-1]);
		}
		f[i][j]=min({f[i][j],f[i+1][j]+min(c[s[i]-'a'][0],c[s[i]-'a'][1]),f[i][j-1]+min(c[s[j]-'a'][0],c[s[j]-'a'][1])});
	}
	printf("%lld\n",f[1][m]);
	return 0;
}
```

### LOJ#2063. 「HAOI2016」字符合并

这里用 $m$ 代替题目中的 $k$。

注意到任何区间合并后都一定是一个 $m$ 位二进制数，而 $m$ 很小，可以考虑状压。

设 $f(i,j,S)$ 为区间 $[i,j]$ 合并为 $S$ 的最大收益。

考虑如何转移。先讨论如何得到 $S$，再讨论合并成什么。

可以枚举 $S$ 的最后一位是哪个区间合并而来，复杂度是 $O(\frac{n}{m})$ 的。

合并只能将整个串合并为 $0$ 或 $1$，不难发现这样做的充要条件是 $(m-1) \mid (len-1)$。

枚举 $S$，对于转化成 $0$ 或 $1$ 分别取最大值，最后更新 $f(i,j,0/1)$ 即可。

时间复杂度是 $O(n^2 2^m\frac{n}{m})$，勉强通过。

```cpp
// Problem: #2063. 「HAOI2016」字符合并
// Contest: LibreOJ
// URL: https://loj.ac/p/2063
// author: yozora0908
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
const int N=305, inf=0x3f3f3f3f;
int n, m, U, to[1<<8], w[1<<8], f[N][N][1<<8];
char s[N];
signed main() {
	n=read(), m=read();
	U=(1<<m)-1;
	SET(f,-0x3f);
	scanf("%s",s+1);
	rep(i,1,n) f[i][i][s[i]-'0']=0;
	for(int S=0;S<=U;++S) to[S]=read(), w[S]=read();
	for(int l=2;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		for(int S=0;S<=U;++S) {
			for(int k=j-1;k>=i;k-=m-1) {
				f[i][j][S]=max(f[i][j][S],f[i][k][S>>1]+f[k+1][j][S&1]);
                // 注意枚举顺序
			}
		}
		if((l-1)%(m-1)==0) {
			int res0=0, res1=0;
			for(int S=0;S<=U;++S) {
				if(to[S]==0) res0=max(res0,f[i][j][S]+w[S]);
				else res1=max(res1,f[i][j][S]+w[S]);
			}
			f[i][j][0]=max(f[i][j][0],res0), f[i][j][1]=max(f[i][j][1],res1);
		}
	}
	int ans=0;
	for(int S=0;S<=U;++S) ans=max(ans,f[1][n][S]);
	printf("%lld\n",ans);
	return 0;
}
```

### LOJ#2292. 「THUSC 2016」成绩单

注意到 $n$ 只有 $50$，可以先将 $W_i$ 离散化了。

注意到分发顺序不重要，我们钦定任何区间都是从左往右分发。

设 $g(i,j,mx,mn)$ 表示把 $[i,j]$ 取到还剩下一段值域为 $[mn,mx]$ 的区间的最小代价，$f(i,j)$ 表示取完 $[i,j]$ 的最小代价。

首先我们可以让 $j$ 加入 $g(i,j-1,mx,mn)$，注意 $W_j$ 对 $mx$ 与 $mn$ 的影响。

否则我们枚举和 $j$ 一起消掉的一段。
$$
g(i,j,mx,mn) = \min_{k=i}^{j-1} \Big\{ g(i,k,mx,mn) + f(k+1,j) \Big\}
$$

```cpp
// Problem: P5336 [THUSC2016] 成绩单
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P5336
// Author: yozora0908
// Memory Limit: 500 MB
// Time Limit: 2000 ms
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
const int N=55;
int n, m, a, b, s[N], f[N][N], g[N][N][N][N], t[N];
void lsh() {
	sort(t+1,t+m+1);
	m=unique(t+1,t+m+1)-(t+1);
	rep(i,1,n) s[i]=lower_bound(t+1,t+m+1,s[i])-t;
}
signed main() {
	n=read(), a=read(), b=read();
	rep(i,1,n) s[i]=read(), t[++m]=s[i];
	lsh();
	SET(f,0x3f), SET(g,0x3f);
	rep(i,1,n) {
		f[i][i]=a;
		g[i][i][s[i]][s[i]]=0;
	}
	for(int l=2;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		 rep(mx,1,m) rep(mn,1,mx) {
		 	int& x=g[i][j][max(mx,s[j])][min(mn,s[j])];
		 	x=min(x,g[i][j-1][mx][mn]);
		 	rep(k,i,j-1) g[i][j][mx][mn]=min(g[i][j][mx][mn],g[i][k][mx][mn]+f[k+1][j]);
		 }
		rep(mx,1,m) rep(mn,1,mx) {
			f[i][j]=min(f[i][j],g[i][j][mx][mn]+a+b*(t[mx]-t[mn])*(t[mx]-t[mn]));
		}
	}
	printf("%lld\n",f[1][n]);
	return 0;
}
```



### LOJ#6092. 「Codeforces Round #418」恋爱循环

严格来说算是区间 DP 吗？

对于每个字符，把所有点提取成连续的，保留各自的下标用作距离。我们断言，最终的修改一定指挥让某一个区间的这个字符连成一片。

设 $f_{\pi}(i,j)$ 为考虑字符 $\pi$，把区间 $[i,j]$ 里的 $\pi$，通过修改中间字符的方式搞成连续的所需要的最小代价。

那么每个询问等价于求一个区间 $[l,r]$，满足 $f_c(l,r) \le m$ 并且 $\min\Big(n,r-l+1+m \Big)$ 最大。

不难发现对于不断递增的 $r$，$l$ 是有决策单调性的，直接双指针即可。

然而还是无法通过，考虑预处理答案。

能发现总复杂度是 $O\Big(\sum_{i=1}^{26} cnt_i^2 + q\Big)$，其中 $cnt_i$ 表示第 $i$ 个字符的数量。

后面那个东西在所有字符都相同时有上界，可以通过。

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
const int N=1505;
int n, q, a[N], sum[30][N], ans[30][N];
vector<int> v[30];
vector<vector<int> > f[30];
char s[N], cc[2];
void dp(int x) {
	f[x].resize(v[x].size()+3);
	for(int i=0;i<v[x].size();++i) f[x][i].resize(v[x].size()+3);
	for(int i=0;i<v[x].size();++i) f[x][i][i]=0;
	for(int l=2;l<=v[x].size();++l) for(int i=0;i+l-1<v[x].size();++i) {
		int j=i+l-1;
		f[x][i][j]=f[x][i][j-1]+v[x][j]-v[x][j-1]-1;
	}
}
void solve(int x) {
	for(int i=1;i<=n;++i) {
		int l=0, r=0;
		while(r+1<v[x].size()&&f[x][l][r+1]<=i) ++r;
		ans[x][i]=max(ans[x][i],min(r-l+1+i,n));
		for(;r<v[x].size();++r) {
			while(l<=r&&f[x][l][r]>i) ++l;
			if(l<=r) ans[x][i]=max(ans[x][i],min(r-l+1+i,n));
		}
	}
}
void prework() {
	rep(i,1,26) if(v[i].size()) dp(i);
	rep(i,1,26) if(v[i].size()) solve(i);
}
signed main() {
	n=read();
	scanf("%s",s+1);
	rep(i,1,n) {
		a[i]=s[i]-'a'+1;
		v[a[i]].pb(i);
	}
	prework();
	q=read();
	while(q--) {
		int m=read();
		scanf("%s",cc);
		int c=cc[0]-'a'+1;
		if(v[c].size()) printf("%lld\n",ans[c][m]); else printf("%lld\n",m);
	}
	return 0;
}

```
