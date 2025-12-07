---
title: 「NOIP Record」#5 倍增
pubDate: 2023-05-26
tags:
  - 倍增
  - DP
  - 贪心
categories:
  - Record
description: '少年想挑战更多'
---

## 满足「结合律」的静态信息

### CF1175E Minimal Segment Cover

预处理 $rt_x$ 表示点 $x$ 经过一条线段能到达的最右边的点。

跳区间显然是满足结合律的，可以倍增之，复杂度 $O(n \log_2 n)$。

这类题目有一个重要的小技巧：为了满足最优性，倍增时跳到不能到达 $y$ 的最远的点 $p$，然后判断能一次跳过 $y$。如果不能则无解，否则这就是最优解。

证明是平凡的。如果能到达 $r$，那么一定能到达位置 $p$，否则一定找不到。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
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
int n, m, L=1e15, R, f[N][22];
int calc(int l,int r) {
	int t=0;
	for(int i=21;~i;--i) {
		if(f[l][i]&&f[l][i]<r) l=f[l][i], t|=1<<i;
        // f[l][i]!=0，特判跳出去的情况
	}
	if(f[l][0]>=r) return t+1;
	else return -1;
}
signed main() {
	n=read(), m=read();
	rep(i,1,n) {
		int l=read(), r=read();
		f[l][0]=max(f[l][0],r);
		L=min(L,l), R=max(R,r);
	}
	rep(i,L,R) f[i][0]=max(f[i][0],f[i-1][0]);
    // 预处理：先处理每个左端点的情况，再求前缀max
	rep(j,1,21) rep(i,L,R) f[i][j]=f[f[i][j-1]][j-1];
	while(m--) {
		int l=read(), r=read();
		printf("%lld\n",calc(l,r));
	}
}
```

### luogu4155 [SCOI2015]国旗计划

[link](https://nanami7.top/blog/luogu4155)

### luogu3509 [POI2010]ZAB-Frog

处理出距离每个点第 $k$ 近的点后，就可以倍增了。

如何处理？发现 $h_i$ 单调增，那么对于一个 $i$，距离它最近的点一定是它前后一共 $k$ 个其他元素中的一个。

观察性质，显然对于这个长度为 $k+1$ 的滑动窗口 $[l,r]$，$[l,i)$ 与 $(i,r]$ 的内部分别是单调减与单调增的，因此第 $k$ 近的点必然是左端点或者右端点。

但问题在于如何维护正确的滑动窗口。如果 $[l,r]$ 在 $i$ 处求得错误答案，那么一定有 $dis(l,i) > dis(i,r+1)$，即往右移动更能逼近 $i$（滑动窗口的移动具有滞后性），不断这样往右移动 $l$ 与 $r$ 直到收敛一定是不劣的。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long 
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
const int N=1e6+5;
int n, k, m, a[N], f[N][62];
int calc(int x) {
	int t=0;
	for(int i=60;~i;--i) {
		if(t+(1ll<<i)<=m) x=f[x][i], t+=(1ll<<i);
	}
    // 使用1ll
	return x;
}
signed main() {
	n=read(), k=read(), m=read();
	rep(i,1,n) a[i]=read();
	int l=1, r=k+1;
	rep(i,1,n) {
	    while(i!=1&&r<n&&a[i]-a[l]>a[r+1]-a[i]) ++l, ++r;
		if(a[i]-a[l]>=a[r]-a[i]) f[i][0]=l; else f[i][0]=r;
	}
	rep(j,1,60) rep(i,1,n)  f[i][j]=f[f[i][j-1]][j-1];
	rep(i,1,n) printf("%lld ",calc(i));
}
```

### Nowcoder51190 Count the Repetitions

首先可以把 $s_2$ 重复 $n_2 \times m$ 次的条件干掉，求最大的 $n$ 使能满足条件即可。

$s_2$ 重复 $n$ 次依然是 $s_1$ 重复 $n_1$ 次的子序列，那么就可以套路地进行匹配了。

设 $f(i)$ 表示从 $s_1[i]$ 开始匹配完一遍 $s_2$ 需要从 $s_1$ 中走多少步。这里认为 $s_1$ 是一个环形字符串。

发现这玩意满足结合律，倍增优化。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long 
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
const int N=1e6+5, M=105;
int n1, n2, l1, l2, f[M][50];
char s1[M], s2[M];
void solve() {
	l1=strlen(s1), l2=strlen(s2);
	for(int i=0;i<l1;++i) {
		int pos=i;
		f[i][0]=0;
		for(int j=0;j<l2;++j) {
			int cnt=0;
			while(s1[pos]!=s2[j]) {
				(++pos)%=l1, ++cnt;
				if(s1[pos]!=s2[j]&&cnt>=l1) { puts("0"); return; }
			}
			(++pos)%=l1;
			f[i][0]+=cnt+1;
		}
	}
	for(int j=1;j<=30;++j) for(int i=0;i<l1;++i) {
		f[i][j]=f[i][j-1]+f[(i+f[i][j-1])%l1][j-1];
	}
	int ans=0, pos=0;
	for(int i=30;~i;--i) {
		if(pos+f[pos%l1][i]<=l1*n1)  pos+=f[pos%l1][i], ans+=1<<i;
	}
	printf("%lld\n",ans/n2);
}
signed main() {
	while(cin>>s2>>n2>>s1>>n1) solve();
}

```

### CF1142B Lynyrd Skynyrd

乍一看就能想出 $O(n^2)$ 的倍增做法，但是貌似无法优化了。

$\texttt{Observation}$

把循环移位转化为环形结构。

设 $pre_{i}$ 为 $p$ 中满足 $p_k=j$ 的 $p_{j-1}$ 的值，特别地 $pre_1 = p_n$。

对于一个 $a_i$，它要么自己开一段子序列，要么接到 $a[1,i-1]$ 中满足 $a_j=pre_{a_i}$ 的最靠右的 $j$ 后面。

这样往前找是满足结合律的，可以倍增。

如果能从 $r$ 往前跳 $n-1$ 次到达 $l$，那么说明以 $r$ 为右端点，满足条件的最短的区间是 $[l,r]$。然后对 $ans_r$ 求前缀最大值，就能得到满足条件的最大的 $l$，直接判断即可。

有 $O(n)$ 的内向树做法，但是咕了。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
int n, m, Q, a[N], b[N], pre[N], pos[N];
int f[N][18], ans[N];
int calc(int x) {
	int d=n-1;
	for(int i=17;~i;--i) {
		if(d>=1<<i) d-=1<<i, x=f[x][i];
	}
	return x;
}
signed main() {
	n=read(), m=read(), Q=read();
	rep(i,1,n) a[i]=read(), pre[a[i]]=a[i-1];
	pre[a[1]]=a[n];
	rep(i,1,m) {
		b[i]=read();
		f[i][0]=pos[pre[b[i]]];
		pos[b[i]]=i;
	}
	rep(j,1,17) rep(i,1,m) f[i][j]=f[f[i][j-1]][j-1];
	rep(i,1,m) ans[i]=max(ans[i-1],calc(i));
	while(Q--) {
		int l=read(), r=read();
		if(l<=ans[r]) printf("1"); else printf("0");
	}
}
```



## 能不能干点别的？

### Nowcoder50943 Genius ACM

最优解一定是若干极长段，贪心划分即可。对于一个确定的左边界 $l$，得到右边界 $r$ 后求“校验值”至少是带着 $\log$ 的。如果二分求 $r$，那么要是一直判定失败，那么复杂度就会上天，同时 $r$ 也会很小，效率很低。如果枚举 $r$，上界也是 $O(n^2\log_2 n)$ 的。

这时候可以考虑让右端点倍增前进，这种倍增和本文中其他倍增不太相同。

- 初始化 $p=1$，$r=l$。
- 如果 $[l,r+p]$ 合法，那么令 $r \leftarrow r+p$，$p \leftarrow 2 \times p$。
- 否则 $p \leftarrow p / 2$。

这样做的好处是无论失败多少次，复杂度都是 $O(n \log_2 n)$ 的，但是带着相对大的常数。

还有一个问题——排序。如果每次对 $[l,r+p]$ 排序，那么复杂度就假了。应该将 $[r,r+p]$ 排序，然后与 $[l,r]$ 归并。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long 
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
int T, n, m, k, a[N], b[N], c[N];
void merge(int l,int mid,int r) {
	int i=l, j=mid+1, pos=l;
	while(i<=mid&&j<=r) {
		if(b[i]<=b[j]) c[pos++]=b[i++];
		else c[pos++]=b[j++];
	}
	while(i<=mid) c[pos++]=b[i++];
	while(j<=r) c[pos++]=b[j++];
}
int solve(int L,int mid,int R) {
	if(R>n) return 0;
	for(int i=mid+1;i<=R;++i) b[i]=a[i];
	sort(b+mid+1,b+R+1);
	merge(L,mid,R);
	int p=L, q=R, cnt=0, res=0;
	for(;p<q&&cnt<m;) {
		res+=(c[q]-c[p])*(c[q]-c[p]);
		++p, --q, ++cnt;
		if(res>k) return 0;
	}
	rep(i,L,R) b[i]=c[i];
	return 1; 
}
void solve() {
	n=read(), m=read(), k=read();
	rep(i,1,n) a[i]=read();
	int L=1, ans=0;
	while(L<=n) {
		int d=1, R=L;
		b[L]=a[L];
		while(d) {
			if(solve(L,R,R+d)) {
				R+=d; d<<=1;
			} else d>>=1;
		}
		++ans;
		L=R+1;
	}
	printf("%lld\n",ans);
}
signed main() {
	T=read();
	while(T--) solve();
}
```

 

### luogu1081 [NOIP2012 提高组] 开车旅行

预处理小 A 与小 B 从 $i$ 开始驾驶的时候会到达的点。具体的，对于每个 $i$，找 $j_0,j_1 \neq i$，满足 $h_i$ 与 $h_{j_0},h_{j_1}$ 分别做差取绝对值后，分别是最小、次小值。

由于 $h_i$ 两两不同，所以用`std::set`容易维护，写的比较丑。

然后就是设 $F(i,j,0/1)$ 为小 A/B 先从 $i$ 开车，两人交替行驶 $2^j$ 次能够到达的城市。上面预处理的信息就是边界值。转移有一个细节，当 $j>1$ 时，$2^{j-1}$ 也就是两次行驶的距离是偶数，因此小 A 和小 B 都要合并自己的 $2^{j-1}$ 的信息。当 $j=1$ 时，则是从对方的信息合并而来。

如何求二者分别的路程？笔者一开始设 $G(i,j,0/1)$ 表示轮到小 A/B 开车，两人交替行驶 $2^j$ 次后走过的路程。但这样就假掉了，因为先手不同时，走过的路径不一定相同，且对于 $G(i,j,1)$，行驶的次数就不是 $2^j$ 了。

所以加一维，$G_{0/1}(i,j,0/1)$，下标一维表示最开始谁开车。转移类似。

尽管如此，我们却用不到小 B 先开车的情况，作用在于 $j=1$ 时的转移。

细节较多，见代码。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define uint unsigned long long 
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
int n, m, h[N], to[N][2]; // to[i][0]表示最近，to[i][1]表示第二近
int f[N][20][2];
int x0, ga[N][20][2], gb[N][20][2];
set<pair<int,int> > s;
#define x first
#define y second
#define mp make_pair
void prework() {
	rep(i,1,n-1) {
		
		if(h[i]==s.begin()->x) {
            // 最小值
			auto p=s.upper_bound(mp(h[i],i));
			if(p==s.end()) {
				to[i][0]=0;
				continue;
			} else to[i][0]=p->y;
			
			++p;
			if(p==s.end()) to[i][1]=0; else to[i][1]=p->y;
			s.erase(mp(h[i],i));
			
		} else if(h[i]==s.rbegin()->x) {
			// 最大值
			auto p=s.lower_bound(mp(h[i],i));
			if(p==s.begin()) {
				to[i][0]=0;
				continue;
			} else --p, to[i][0]=p->second;
			if(p==s.begin()) to[i][1]=0; else --p, to[i][1]=p->y;
			s.erase(mp(h[i],i));
			
		} else {
			pair<int,int> pii=mp(h[i],i);
			auto p0=s.upper_bound(pii);
			auto p1=--s.lower_bound(pii);
            
			int h0=p0->x, id0=p0->y;
			int h1=p1->x, id1=p1->y;
			int t0=abs(h0-h[i]), t1=abs(h1-h[i]);	
			if(t0<t1) to[i][0]=id0;
			else if(t0==t1) {
				if(h[id0]<h[id1]) to[i][0]=id0;
				else to[i][0]=id1;
			} else to[i][0]=id1;
			// 做两遍
			s.erase(pii);
			if(to[i][0]==0) continue;
			pii=mp(h[to[i][0]],to[i][0]);
			p0=s.upper_bound(pii);
			p1=s.lower_bound(pii);
			if(p0==s.end()&&p1==s.begin()) to[i][1]=0;
			else if(p0==s.end()) --p1, to[i][1]=p1->y;
			else if(p1==s.begin()) to[i][1]=p0->y;
			else {
				--p1;
				int h0=p0->x, id0=p0->y;
			int h1=p1->x, id1=p1->y;
			int t0=abs(h0-h[i]), t1=abs(h1-h[i]);	
			if(t0<t1) to[i][1]=id0;
			else if(t0==t1) {
				if(h[id0]<h[id1]) to[i][1]=id0;
				else to[i][1]=id1;
			} else to[i][1]=id1;
			}
			
		}
		
		f[i][0][0]=to[i][1], f[i][0][1]=to[i][0];
		ga[i][0][0]=abs(h[to[i][1]]-h[i]);
		gb[i][0][1]=abs(h[to[i][0]]-h[i]);
	}
	for(int j=1;j<=18;++j) for(int i=1;i<=n;++i) rep(k,0,1) {
		if(j==1) {
			f[i][j][k]=f[f[i][j-1][k]][j-1][k^1];
			ga[i][j][k]=ga[i][j-1][k]+ga[f[i][j-1][k]][j-1][k^1];
			gb[i][j][k]=gb[i][j-1][k]+gb[f[i][j-1][k]][j-1][k^1];
		}
		else {
			f[i][j][k]=f[f[i][j-1][k]][j-1][k];
			ga[i][j][k]=ga[i][j-1][k]+ga[f[i][j-1][k]][j-1][k];
			gb[i][j][k]=gb[i][j-1][k]+gb[f[i][j-1][k]][j-1][k];
		}
		
	}
}




pair<int,int> calc(int p,int X) {
	int Ta=0, Tb=0;
	for(int i=18;~i;--i) {
		int t=1<<i;
		if(f[p][i][0]!=0&&(ll)Ta+ga[p][i][0]+Tb+gb[p][i][0]<=X) {
			Ta+=ga[p][i][0], Tb+=gb[p][i][0], p=f[p][i][0];
            // 当i=0时，p=f[p][i][0]后下次就轮到小B了
            // 可惜没有下次了。
		}
	}
	return mp(Ta,Tb);
}
int cmp(int x,int y,int p,int q) {
	if(y==0) return 0;
	if((ll)x*q<(ll)p*y) return 2;
	else if(x*q==p*y) return 1;
	else return 0;
    // 分数比较
}
void solve1() {
	int p=1, q=0, ans1=0;
	for(int i=1;i<=n;++i) {
		pair<int,int> T=calc(i,x0);
		int fg=cmp(T.x,T.y,p,q);
		if(fg==2||(fg==1&&h[i]>h[ans1])) p=T.x, q=T.y, ans1=i;
	}
	printf("%lld\n",ans1);
}
signed main() {
	n=read();
	rep(i,1,n) h[i]=read(), s.insert(make_pair(h[i],i));
	prework();
	x0=read();
	solve1();
	m=read();
	while(m--) {
		int s=read(), x=read();
		pair<int,int> p=calc(s,x);
		printf("%d %d\n",p.x,p.y);
	}
}
```

### luogu9019 [USACO23JAN] Tractor Paths P

预处理每个点经过一条边能到达的最远点，倍增即可解决第一问。

设第一问求出的答案为 $d$，从 $i$ 出发，往右走 $j$ 次能到达的最远点是 $f(i,j)$，往左走 $j$ 次能到达的最远点是 $g(i,j)$。从两端往中间走总和为 $d$ 的步数，二者的交错便是可能在最短路径上的点。

因此答案为
$$
[S_a=1] + [S_b=1] + \sum_{j=1}^{d-1} cnt \Big( g(b,d-j),f(a,j) \Big)
$$
发现和式是个区间和的形式，拆成前缀减后缀，而加法和减法都能单独拿出来。

倍增。设 $fs(i,j)$ 为从 $i$ 往右走 $2^j$ 步到达最远点时，关键区间的数量。$gs(i,j)$ 类似。

复杂度 $O((n+Q) \log n)$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
int n, Q, lt[N], rt[N], ss[N];
int f[N][18], g[N][18], fs[N][18], gs[N][18];
char s[2*N], t[N];
void prework() {
	int p=0, now=1;
	for(int i=1;i<=2*n;++i) {
		if(s[i]=='L') ++p;
		else rt[now]=p, ++now;
	}
	p=n+1, now=n;
	for(int i=2*n;i;--i) {
		if(s[i]=='R') --p;
		else lt[now]=p, --now;
	}
	rep(i,1,n) ss[i]=ss[i-1]+t[i]-'0';
	rep(i,1,n) {
		f[i][0]=rt[i], g[i][0]=lt[i];
		fs[i][0]=ss[rt[i]], gs[i][0]=ss[lt[i]-1];
	}
	rep(j,1,17) for(int i=1;i<=n;++i) {
		f[i][j]=f[f[i][j-1]][j-1];
		fs[i][j]=fs[i][j-1]+fs[f[i][j-1]][j-1];
        g[i][j]=g[g[i][j-1]][j-1];
		gs[i][j]=gs[i][j-1]+gs[g[i][j-1]][j-1];
	}
}
int calc(int l,int r) {
	int res=0;
	for(int i=17;~i;--i) {
		if(f[l][i]&&f[l][i]<r) res|=(1<<i), l=f[l][i];
	}
	return res+1;
}
signed main() {
	n=read(), Q=read();
	scanf("%s%s",s+1,t+1);
	prework();
	while(Q--) {
		int a=read(), b=read();
		int ans1=calc(a,b), ans2=t[a]-'0'+t[b]-'0';
		for(int i=17;~i;--i) if((ans1-1)&(1<<i)) ans2+=fs[a][i], a=f[a][i];
		for(int i=17;~i;--i) if((ans1-1)&(1<<i)) ans2-=gs[b][i], b=g[b][i];
		printf("%lld %lld\n",ans1,ans2);
	}
}
```

### CF1516D Cut

容易发现一个区间合法当且仅当区间的数两两互质。

发现如果预处理完从 $i$ 开始能分组的最右端点，就可以倍增了。

对质因子开一个桶。

如何预处理呢？如果从 $l$ 开始，到了 $r$ 第一次产生重复质因子，那么从 $l$ 开始往后直到不存在重复的质因子，$r-1$ 都是他们的答案。

存在这样的单调性，就可以双指针求解了。

分解质因子可能带着不小的常数（比如说分解一个质数），但值域不大，一个优化的方法是用线性筛得到每个数的最小质因子，这样就可以 $O(1)$ 除去一个因子，因此上界就是 $O(\log_2 \max\{a_i\})$。

为了避免一些边界错误，使用左闭右开。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
int n, Q, mx, a[N], f[N][17];
int cnt, p[N], g[N];
bool v[N];
int c[N];
void ora() {
	for(int i=2;i<=mx;++i) {
		if(!v[i]) p[++cnt]=i, g[i]=i;
		for(int j=1;j<=cnt&&i*p[j]<=mx;++j) {
			v[i*p[j]]=1;
			g[i*p[j]]=p[j];
			if(i%p[j]==0) break;
		}
	}
}
void del(int x) {;
	while(x>1) --c[g[x]], x/=g[x];
}
void prework() {
	ora();
	int l=1, r=1;
	while(r<=n) {
		int x=a[r];
		while(x>1) {
			while(c[g[x]]) f[l][0]=r, del(a[l++]);
			// [) 左闭右开防止一些奇怪的错误
			x/=g[x];
		}
		x=a[r];
		while(x>1) ++c[g[x]], x/=g[x];
		++r;
	}
	while(l<=n) f[l++][0]=n+1;
	rep(j,1,16) rep(i,1,n) f[i][j]=f[f[i][j-1]][j-1];
}
int calc(int l,int r) {
	int res=0;
	for(int i=16;~i;--i) {
		if(f[l][i]&&f[l][i]<=r) res|=(1<<i), l=f[l][i];
	}
	return res+1;
}
signed main() {
	n=read(), Q=read();
	rep(i,1,n) a[i]=read(), mx=max(mx,a[i]);
	prework();
	while(Q--) {
		int l=read(), r=read();
		printf("%lld\n",calc(l,r));
	}
}
```

左闭右闭写法。

```cpp
void prework() {
	ora();
	int l=1, r=1;
	while(r<=n) {
		int x=a[r];
		while(x>1) {
			while(c[g[x]]) f[l][0]=r-1, del(a[l++]);
			x/=g[x];
		}
		x=a[r];
		while(x>1) ++c[g[x]], x/=g[x];
		++r;
	}
	while(l<=n) f[l++][0]=n;
	f[n][0]=n;
	rep(j,1,16) f[n][j]=0;
	rep(j,1,16) rep(i,1,n) f[i][j]=f[min(f[i][j-1]+1,n)][j-1];
}
int calc(int l,int r) {
	int res=0;
	for(int i=16;~i;--i) {
		if(f[l][i]&&f[l][i]+1<=r) res|=(1<<i), l=f[l][i]+1;
	}
	return res+1;
}
```



- “区间覆盖”最好左闭右闭，“区间划分”最好左闭右开。

### luogu9275 [AGM 2023 资格赛] DrahSort

姑且看了一下网络上巨多的冒泡排序文章。不同于它们，冒泡排序还有另外一种理解方式，就是依次干掉以每个数较大数的逆序对。在本题中使用两者分析均可。

对于一个 $a_l$，如果能找到它右边第一个大于等于它的元素 $a_r$，那么 $l$ 的决策区间就是 $[l,r-1]$，它的贡献就是 $a_l \times \max_{i=l+1}^{r-1} \{a_i\}$。后面即使有小于它的数，$a_r$ 都不劣于 $a_l$。

所以就可以对这个倍增了，从 $l$ 往 $r$ 跳即可，途中记录最大值。

如果最终仍满足 $l<r$，那么说明找不到大于等于 $a_l$ 的元素了，取 $a_l \times \max_{i=l+1}^r a_i$ 即可。

这题仍然以使用左闭右开为上策。



### LOJ#3496. 「JOISC 2021」活动参观 2

自己做的时候不会搞这个字典序……

考虑一个暴力，从小到大考虑每个区间是否能加入。由于字典序的贪心性质，编号小的区间一定优于任何编号更大的区间，所以维护一个区间集合，枚举到 $i$ 就判断强制选择区间集合中的区间和 $i$ 后，剩下的区间还能不能选到 $k$ 个。

怎么做？在枚举之前我们可以按照右端点排序然后贪心选择最多无交区间，如果不到 $k$ 个就无解。考虑把区间左右端点离散化了，这样选择一个区间就是干掉两个坐标中间的所有点。暴力把所有这样的点标记出来，整个序列被划分为了若干段，我们只要知道这些段总共能被塞进多少区间即可。

但这样还是不够优。我们能发现 $i$ 阶段与上一个阶段相比，仅仅多了 $i$ 这个区间。如果 $i$ 与已经选择的区间有冲突，那么直接跳过。否则就不能选择与 $[L_i,R_i]$ 有交的区间。

然后设 $[lt,rt]$ 为已经选择的区间给 $[L_i,R_i]$ 留下的那个段，我们就要在 $[lt,rt]$ 尽可能多放的前提下，最大化 $[lt,L_i]$ 与 $[R_i,rt]$ 能放的区间数量，最小化 $[L_i,R_i]$ 能放的区间数量。由于这些 $[lt,rt]$ 中必然没有选过的区间，所以就是个静态问题。

$O(n)$ 求出 $[lt,rt]$ 的最优解和 $[lt,L_i]$ 与 $[R_i,rt]$ 的最优解就能得到所有信息。这样就能利用上一个阶段得到答案，判断是否不小于 $k$ 即可。

考虑优化。选不相交区间的过程是相当重复的，同时满足结合律，预处理每个右端点往左第一个左端点即可倍增答案，当区间个数一定时能得到放的最近距离，这个比较显然。




```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
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
int n, k, ans, f[2*N][21];
int m, tmp[2*N];
PII a[N], b[N];
bool cmp(PII a,PII b) { return a.se!=b.se? a.se<b.se:a.fi<b.fi; }
void lsh() {
	sort(tmp+1,tmp+m+1);
	m=unique(tmp+1,tmp+m+1)-tmp-1;
	rep(i,1,n) {
		a[i].fi=lower_bound(tmp+1,tmp+m+1,a[i].fi)-tmp;
		a[i].se=lower_bound(tmp+1,tmp+m+1,a[i].se)-tmp;
		b[i]=a[i];
	}
}
void prework() {
	sort(a+1,a+n+1,cmp);
	int p=0;
	rep(i,1,m) {
		f[i][0]=f[i-1][0];
		while(p<n&&a[p+1].se==i) {
			++p;
			f[i][0]=max(f[i][0],a[p].fi);
		}
		for(int j=1;j<=20&&f[i][j-1];++j) f[i][j]=f[f[i][j-1]][j-1];
	}
}
int calc(int l,int r) {
	if(l>r) return 0;
	int res=0;
	for(int i=20;~i;--i) {
		if(f[r][i]>=l) r=f[r][i], res|=1<<i;
	}
	return res;
}
signed main() {
	n=read(), k=read();
	rep(i,1,n) {
		a[i].fi=tmp[++m]=read();
		a[i].se=tmp[++m]=read();
	}
	lsh();
	prework();
	int cnt=calc(1,m);
	if(cnt<k) puts("-1"), exit(0);
	set<PII> s;
	rep(i,1,n) {
		auto p=s.lower_bound(MP(b[i].se,0));
		int tl=0, tr=0;
		if(p==s.end()) tr=m;
		else tr=p->fi;
		if(p==s.begin()) tl=1;
		else --p, tl=b[p->se].se;
		if(tl>b[i].fi) continue;
		int k0=calc(tl,tr), k1=calc(tl,b[i].fi), k2=calc(b[i].se,tr);
		if(cnt-k0+1+k1+k2>=k) {
			cnt=cnt-k0+1+k1+k2;
			s.insert(MP(b[i].fi,i));
			printf("%lld\n",i);
			if(++ans==k) break;
		}
	}
}
```



&nbsp;

## 一些更深的思考

所谓「结合律」究竟是什么？

- 一些数学运算天生满足结合律，可以改变运算顺序。
- 跳到若干“关键点”，从哪里开始跳与跳的过程无关，可以将路径合并。
- 二进制拆分，本质上是求和的结合律。
- 信息的合并，群论的说法叫**半群**。

这些维护的都是「已知」的东西，或者说是显式的倍增结构。

但很多时候并没有这个显式的结构。比如本文第一题，为什么倍增找 $p$ 就是最优的，而倍增 $r$ 则不是呢？

考虑一种新的思想——**倍增答案**。

~~自己起的名字~~。

如果说**二分答案**是利用了答案的单调性然后将最优化问题转化为判定问题，那么**倍增答案**则是利用了答案可以由若干满足结合律的局部答案合并而成，从而将全局最优化问题转化为「答案一定时若干最优局面的并」。

$p$ 并不是显式存在的，但它一定严格小于 $r$ 且满足结合律。这个最优解又因为代价已经确定而容易求得。因此倍增 $p$ 能得到正确答案，而倍增 $r$ 则是难以确定的。

似乎是很 $\texttt{Navie}$ 的东西。

&nbsp;

### LOJ#3665. 「JOI 2022 Final」铁路旅行 2

使用倍增答案的思想，这题其实并不难。

容易处理出从每个点出发能够到达的左右边界，在这个区间之内的任何位置都能到达。

可达性容易处理，最优化不好搞。对于前几个 subtask，可以采用构图然后`BFS`的方式求解，但是一定要搞清楚细节（比如可以反走）。

仍然具有结合律，考虑使用倍增答案，而且能发现依然是那种跳区间的形式。设 $rt(i,j)$ 为从 $i$ 出发走 $2^j$ 步能到达的最右位置，左边 $lt(i,j)$ 类似。
$$
rt(i,j) = \max_{k=lt(i,j-1)}^{rt(i,j-1)}\Big\{rt(k,j-1)\Big\}
$$

$$
lt(i,j) = \min_{k=lt(i,j-1)}^{rt(i,j-1)}\Big\{lt(k,j-1)\Big\}
$$

是个 RMQ 问题。

只有这个还不够，有时候我们中途下车更优，而中途下车一定是某个位置能在代价相同时走得更远，所以不能只看最值，要在倍增过程中维护当前区间的最大最小值。线段树即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
int n, k, m, Q, lt[N][17], rt[N][17];
PII q[N];
struct Segment_Tree {
	int k, t[N<<2][2];
	void pushup(int x) { t[x][0]=min(t[x<<1][0],t[x<<1|1][0]); t[x][1]=max(t[x<<1][1],t[x<<1|1][1]); }
	void build(int x=1,int l=1,int r=n) {
		if(l==r) { t[x][1]=rt[l][k], t[x][0]=lt[l][k]; return; }
		int mid=(l+r)>>1;
		build(x<<1,l,mid), build(x<<1|1,mid+1,r);
		pushup(x);
	}
	int query(int L,int R,int type,int x=1,int l=1,int r=n) {
		if(L<=l&&r<=R) return t[x][type];
		int mid=(l+r)>>1;
		int ans=1;
		if(type==0) ans=n;
		if(L<=mid) {
			if(type==0) ans=min(ans,query(L,R,type,x<<1,l,mid));
			else ans=max(ans,query(L,R,type,x<<1,l,mid));
		}
		if(R>mid) {
			if(type==0) ans=min(ans,query(L,R,type,x<<1|1,mid+1,r));
			else ans=max(ans,query(L,R,type,x<<1|1,mid+1,r));
		}
		return ans;
	}
} T[17];
void init() {
	int l=1, r=0;
	rep(i,1,n) {
		while(l<=r&&q[l].fi<i-k+1) ++l;
		int x=rt[i][0];
		if(l<=r) rt[i][0]=max(rt[i][0],q[l].se);
		while(l<=r&&q[r].se<x) --r;
		q[++r]=MP(i,x);
	}
	l=1, r=0;
	per(i,n,1) {
		while(l<=r&&q[l].fi>i+k-1) ++l;
		int x=lt[i][0];
		if(l<=r) lt[i][0]=min(lt[i][0],q[l].se);
		while(l<=r&&q[r].se>x) --r;
		q[++r]=MP(i,x);
	}
	T[0].k=0;
	T[0].build();
	rep(j,1,16) {
		rep(i,1,n) {
			lt[i][j]=T[j-1].query(lt[i][j-1],rt[i][j-1],0);
			rt[i][j]=T[j-1].query(lt[i][j-1],rt[i][j-1],1);
		}
		T[j].k=j;
		T[j].build();
	}
}
int calc(int s,int t) {
	int l=s, r=s, res=0;
	for(int i=16;~i;--i) {
		int L=T[i].query(l,r,0);
		int R=T[i].query(l,r,1);
		if(L<=t&&t<=R) continue;
		l=L, r=R, res|=(1<<i);
	}
	if(T[0].query(l,r,0)<=t&&t<=T[0].query(l,r,1)) return res+1;
	return -1;
}
signed main() {
	n=read(), k=read(), m=read();
	rep(i,1,n) rt[i][0]=lt[i][0]=i;
	rep(i,1,m) {
		int a=read(), b=read();
		if(a<b) rt[a][0]=max(rt[a][0],b);
		else lt[a][0]=min(lt[a][0],b);
	}
	init();
	Q=read();
	while(Q--) {
		int s=read(), t=read();
		printf("%lld\n",calc(s,t));
	}
}
```

