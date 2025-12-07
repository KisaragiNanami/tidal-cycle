---
title: 杂题选讲3
tags:
  - 贪心
  - DP
  - 区间DP
  - 并查集
categories: 题解
description: '3333'
pubDate: 2022-10-04
---

## luogu2135 方块消除

### 分析

把同颜色方块区域转化成同色方块相邻，排成一列。

发现是套路区间 DP。

设 $f(i,j,k)$ 为区间 $[i,j]$，其中右侧有 $k$ 个和 $j$ 同色的东西。

设 $c_i$ 为 $i$ 的颜色，$d_i$ 为和 $i$ 颜色相同的方块数量。

一个显然的结论：同色方块会被同时删掉。

证明略。

这个结论可以把我们的状态中的 $[i,j]$ 变成从第 $i$ 中颜色到第 $j$ 种颜色。

直接删去右边这一段
$$
f(i,j,k) = f(i,j-1,0) + (d_j + k) ^ 2
$$
套路性地枚举断点
$$
f(i,j,k) = \max_{l \in [1,r-1]} \{ f(i,l,d_j + k) + f(l+1,j-1,0) \}
$$
其中 $c_l = c_j$。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
int n, c[N], d[N], f[N][N][2*N];
int dp(int l,int r,int p) {
	int rr=d[r]+p;
	if(l==r) return rr*rr;
	if(~f[l][r][rr]) return f[l][r][rr];
	int& x=f[l][r][rr];
	x=dp(l,r-1,0)+rr*rr;
	for(int k=l;k<r;++k) if(c[k]==c[r]) {
		x=max(x,dp(l,k,rr)+dp(k+1,r-1,0));
	}
	return x;
}
signed main() {
	n=read();
	for(int i=1;i<=n;++i) c[i]=read();
	for(int i=1;i<=n;++i) d[i]=read();
	memset(f,-1,sizeof(f));
	printf("%lld\n",dp(1,n,0));
}

```

## luogu6146 Help Yourself

### 分析

看到子集，显然统计贡献。

根据必修一的知识，我们知道对于一个元素 $i$，它在全集的任意一个子集中，只有选和不选两种方案。

设 $f_i$ 为前 $i$ 条线段所产生的贡献。

不选 $i$，那么不会产生任何贡献。

选 $i$，那么如果存在 $j$，满足 $r_j < l_i$，那么 $i$ 与 $j$ 必然不连通。设这样的 $j$ 的数量为 $x$，那么贡献为 $2^x$。

那么
$$
f_i = f_{i-1} + f_{i-1} + 2^x
$$
简单维护线段右端点的信息即可。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
int n, f[N], c[2*N];
#define l first
#define r second
pair<int,int> a[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
signed main() {
	n=read();
	for(int i=1;i<=n;++i) a[i].l=read(), a[i].r=read(), ++c[a[i].r];
	sort(a+1,a+n+1);
	for(int i=1;i<=2*n;++i) c[i]+=c[i-1];
	f[0]=0;
	for(int i=1;i<=n;++i) {
		f[i]=(2*f[i-1]%mod+fp(2,c[a[i].l-1]))%mod;
	}
	printf("%lld\n",f[n]);
}

```

## luogu6733 间歇泉

### 分析

考虑二分第 $k$ 大的温度 $T$。

问题转化为求满足下面式子的 $(i,j)$ 的个数是否大于等于 $k$。
$$
T \le \frac{a_i c_i + a_j c_j}{a_i + a_j}
$$
把式子拆开
$$
a_iT + a_j T \le a_i c_i + a_j c_j
$$

$$
a_i c_i - a_i T \ge a_j T - a_j c_j
$$

发现这些变量的数量是 $O(n)$ 级别的。

求出对于每个 $i$，满足条件的 $j$ 的数量即可。

排序后双指针。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const double eps=1e-5;
int n, k, a[N], c[N];
double p[N], q[N];
bool check(double x) {
	int cnt=0;
	for(int i=1;i<=n;++i) {
		double u=1.0*a[i]*c[i], v=x*a[i];
		p[i]=u-v, q[i]=v-u;
		if(q[i]-p[i]<eps) --cnt;
        // 如果相等了，那么只能算1个
	}
	sort(p+1,p+n+1);
	sort(q+1,q+n+1);
	int j=0;
	for(int i=1;i<=n;++i) {
		while((q[j+1]-p[i])<eps&&j+1<=n) ++j;
		cnt+=j;
	}
	return (cnt/2<k);
    // 数对是无序的，所以要/2
}
signed main() {
	n=read(), k=read();
	for(int i=1;i<=n;++i) a[i]=read(), c[i]=read();
	double l=0, r=1e9;
	while(r-l>eps) {
		double mid=(l+r)/2;
		if(check(mid)) r=mid; else l=mid;
	}
	printf("%.3lf\n",l);
}

```



## luogu8161 自学 (Self Study)

### 分析

二分答案 $x$。

如果某个科目，自学的收益完全大于上课，那么直接全部自学。

否则如果上满 $m$ 节课能够到达 $x$，那么就上课。

否则就自学。

维护一个总共需要的课程数量，如果大于 $nm$，那么无解。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
int n, m, a[N], b[N];
int cil(int x,int y) { return (x+y-1)/y; }
bool check(int x) {
	int nd=0;
	for(int i=1;i<=n;++i) {
		if(a[i]<b[i]) nd+=cil(x,b[i]);
		else {
			if(a[i]*m>=x) nd+=cil(x,a[i]);
			else nd+=m+cil(x-a[i]*m,b[i]);
		}
		if(nd>n*m) return 0;
	}
	return 1;
}
signed main() {
	n=read(), m=read();
	for(int i=1;i<=n;++i) a[i]=read();
	for(int i=1;i<=n;++i) b[i]=read();
	int l=1, r=1000000000000000010;
	while(l<r) {
		int mid=(l+r+1)/2;
		if(check(mid)) l=mid; else r=mid-1;
	}
	printf("%lld\n",l);
}

```

## luogu8359 垃圾回收

删边转化倒序加边，并查集维护连通块。

没啥可说的，实现注意细节。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a;
}
const int N=4e5+5;
int n, m, q, cnt, fa[N], w[N], r[N], alive[N];
unsigned long long ans;
string str;
bool v[N], vis[N];
int tot, h[N], to[N<<1], nxt[N<<1];
struct edge { int x, y; } e[N];
struct pp { int op, x; } p[N];

int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}

void addedge(int x,int y) {
	add(x,y), add(y,x);
	x=get(x),  y=get(y);
	fa[x]=y;
    // 加边也是合并
}
void dfs(int x) {
	if(vis[x]) return;
	vis[x]=1;
	r[++cnt]=x;
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i];
		dfs(y);
	}
}
void find(int x) {
	cnt=0;
	memset(vis,0,sizeof(vis));
	dfs(x);
    // 找出x所在连通块的所有点
}
signed main() {
	n=read(), m=read(), q=read();
	for(int i=1;i<=m;++i) e[i].x=read(), e[i].y=read();
	for(int i=1;i<=q;++i) {
		cin>>str;
		if(str=="GC") p[i].op=2;
		else p[i].op=1, p[i].x=read(), v[p[i].x]=1;
	}
	for(int i=1;i<=n;++i) w[i]=read(), fa[i]=i;
	for(int i=1;i<=m;++i) if(!v[i]) addedge(e[i].x,e[i].y);
    // 没有被删去的边
	find(1);
	for(int i=1;i<=cnt;++i) alive[r[i]]=q+1;
    // q+1时刻被删去的点
	int lst=q+1;
	for(int i=q;i;--i) {
		if(p[i].op==2) lst=i;
        // 维护上一次删点的时刻
		else {
			int x=e[p[i].x].x, y=e[p[i].x].y;
			if(get(1)!=get(x)) swap(x,y);
			if(get(1)==get(x)&&get(1)!=get(y)) {
				find(y);
                // y被合并，y所在连通块要等到(x,y)被删掉之后的lst时间才会被删除
				for(int j=1;j<=cnt;++j) alive[r[j]]=lst;
			}
			addedge(x,y);
		}
	}
	int fg=0;
	for(int i=1;i<=q;++i) if(p[i].op==2) {
		fg=i;
		break;
	}
    // 这些点从始至终和1不连通
	for(int i=1;i<=n;++i) if(get(1)!=get(i)) alive[i]=fg;
	for(int i=1;i<=n;++i) ans+=w[i]*alive[i];
	printf("%llu\n",ans);
}
```



## luogu6394 樱花，还有你



过于套路了。。。

放个代码就完了。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a*f;
}
const int N=5e3+5, mod=10086001;
int n, k, sum, ans, a[N], s[N], f[N];
signed main() {
	n=read(), k=read();
	for(int i=1;i<=k;++i) a[i]=read(), sum+=a[i];
	if(sum<n) {
		puts("impossible");
		return 0;
	}
	for(int i=0;i<=a[1];++i) s[i]=s[i-1]+1;
	for(int i=a[1]+1;i<=n;++i) s[i]=s[i-1];		
	if(a[1]>=n) ++ans;	
	for(int i=2;i<=k;++i) {
		for(int j=0;j<=n;++j) {
			if(j>a[i]) (f[j]=s[j]-s[j-a[i]-1]+mod)%=mod;
			else f[j]=s[j];
		}
		s[0]=f[0];
		for(int j=1;j<=n;++j) s[j]=(s[j-1]+f[j])%mod;
		(ans+=f[n])%=mod;
	}
	printf("%lld\n",ans);
}

```

## luogu8365 吃

### 分析

显然加法在乘法前面。

如果 $a_i = 1$，那么必然选择加上 $b_i$。

注意到除了上述情况，加法最多进行 $1$ 次。

>证明：
>
>我们的目的是最大化体重。
>
>假如第一次加了 $b_i$，第二次加了 $b_j$，钦定 $b_i \le b_j$，那么收益为 $b_i + b_j$。而此时所有的 $a_i \neq 1$，所以选择乘上 $a_j$ 的收益至少是 $2b_i$，显然不劣于 $b_i + b_j$。
>
>证毕。

直接挑最大的加上显然是错的。

考虑从 $j$ 做加法的收益 $d + \frac{\prod_{i=1}^n a_i}{a_j} + b_j$。其中 $d$ 为满足 $a_i = 1$ 的 $b_i$ 之和。

注意到分子会爆，但是又不能取模。考虑我们只关心相对大小，那么直接判断 $\frac{d+b_j}{a_j}$ 的大小即可。

然后就做完了。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a*f;
}
const int N=5e5+5, mod=1e9+7;
int n, d=1;
bool v[N];
#define PII pair<int,int>
#define x first
#define y second
PII a[N];
signed main() {
	n=read();
	for(int i=1;i<=n;++i) a[i].x=read();
	for(int i=1;i<=n;++i) a[i].y=read();
	for(int i=1;i<=n;++i) {
		if(a[i].x==1) d+=a[i].y, v[i]=1;
	}
	double w=d;
	int p=0;
	for(int i=1;i<=n;++i) if(!v[i]) {
		double dlt=1.0*(d+a[i].y)/a[i].x;
		if(dlt>w) w=dlt, p=i;
	}
	(d+=a[p].y)%=mod;
	for(int i=1;i<=n;++i) if(!v[i]&&i!=p) (d*=a[i].x)%=mod;
	printf("%lld\n",d);
}
```

## luogu8552 Rabbit

### 分析

直接没有原则地选点是很盲目的。

注意到如果某个点是全局最大点，那么它与任意两点相连，都能构成一次合法的操作。

考虑这样一个事实：连通块信息是很好维护的。

把上面两点看作两个独立的连通块，从 $1$ 到 $n$ 枚举最大点，用并查集维护即可。

容易证明所有合法操作都能转化成上述形式，且不重不漏。

对于边 $(x,y)$，连边 $\big(\max(x,y),\min(x,y) \big)$。按照节点编号从 $1$ 到 $n$ 加边，用并查集维护上述关系即可。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
int t, n, ans, fa[N], remain[N];
int tot, h[N], to[N], nxt[N];
int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void solve() {
	n=read();
	tot=ans=0;
	for(int i=1;i<=n;++i) h[i]=0, fa[i]=i, remain[i]=1;
	for(int i=1;i<n;++i) {
		int x=read(), y=read();
		add(max(x,y),min(x,y));
	}
	for(int x=1;x<=n;++x) {
		int cnt=0;
		for(int i=h[x];i;i=nxt[i]) {
			int y=get(to[i]);
			if(x==y) continue;
			if(remain[y]) ++cnt;
			remain[x]+=remain[y];
            // remain[x]是x所在连通块内没有被标记的点的数量
			fa[y]=x;
		}
		if(cnt>=2) remain[x]-=3, ++ans;
	}
	printf("%lld\n",ans);
}
signed main() {
	t=read();
	while(t--) solve();
}

```

