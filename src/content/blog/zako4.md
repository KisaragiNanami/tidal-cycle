---
title: 杂题选讲4
tags:
  - 贪心
  - 二分答案
  - 双指针
  - 组合数学
  - DP
  - 并查集
categories:
  - 题解
description: '4444'
pubDate: 2022-10-22
---

**杂题选讲** 4.

## luogu8110 矩阵

### 分析

萌萌题。
$$
A^2_{i,j} = \sum_{i=k}^n A_{i,k} \cdot A_{k,j} = \sum_{k=1}^n a_ib_ka_kb_j = a_ib_j\Big( (\sum_{k=1}^n a_ib_i)  = d\Big)
$$

$$
\sum_{i=1}^n \sum_{j=1}^n A^2_{i,j} = \sum_{i=1}^n \sum_{j=1}^n a_ib_jd = \Big( \sum_{i=1}^n a_i \cdot \sum_{i=1}^n b_i \Big) d
$$

归纳一下得到答案。

### CODE

```cpp
int n, k, sa, sb, a[N], b[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
signed main() {
	n=read(), k=read();
	for(int i=1;i<=n;++i) {
		a[i]=(read()%mod+mod)%mod;
		(sa+=a[i])%=mod;
	}
	for(int i=1;i<=n;++i) {
		b[i]=(read()%mod+mod)%mod;
		(sb+=b[i])%=mod;
	}
	if(!k) { printf("%lld\n",n); return 0; }
	int d=0;
	for(int i=1;i<=n;++i) (d+=a[i]*b[i]%mod)%=mod;
	printf("%lld\n",sa*sb%mod*fp(d,k-1)%mod);
}
```

## luogu6599 异或

### 分析

按位贪心。

若答案的第 $k$ 位为 $1$，设 $x$ 为序列中第 $k$ 位为 $1$ 的个数。不难发现它会与所有第 $k$ 位不是 $1$ 的数产生 $2^k$ 的贡献。

那么总贡献为 $2^k \cdot x \times (l-x)$，当 $x = \lfloor \frac{l}{2} \rfloor$ 时有最大值。

## CODE

```cpp
int t, n, l;
const int mod=1e9+7;
void solve() {
	n=read(), l=read();
	if(n==1) { puts("0"); return; }
	int base=1ll<<40, x=l>>1, ans=0;
	while(base) {
		base>>=1;
		if(n<base) continue;
		(ans+=base*x%mod*(l-x))%=mod;
	}
	printf("%lld\n",ans);
}
signed main() {
	t=read();
	while(t--) solve();
}
```

## luogu7714 排列排序

### 分析

容易想到，一定存在一种排序方法，使得每个数之多被操作 $1$ 次（因为代价的上界为 $n$）。

考虑这样的区间是什么样的。

设其为 $[l,r]$。其中 $[1,l-1]$ 中的数要严格小于 $[l,r]$ 中的最小值，$[r+1,n]$ 中的数要严格大于 $[l,r]$ 中的最大值。

双指针找即可。

### CODE

```cpp
const int N=1e6+5;
int t, n, p[N];
void solve() {
	n=read();
	for(int i=1;i<=n;++i) p[i]=read();
	int l=1, ans=0;
	while(l<=n) {
		if(p[l]==l) ++l;
        // 跳过已经有序的部分
		else {
			int r=l+1, mx=max(p[l],p[r]);
			while(mx>r) {
                // 直到最大值和右端点相等
				++r;
				mx=max(mx,p[r]);
			}
			ans+=r-l+1;
			l=r+1;
		}
	}
	printf("%lld\n",ans);
}
signed main() {
	t=read();
	while(t--) solve();
}

```

## luogu8432 ぽかぽかの星

### 分析

发现直接做比较困难。

考虑从值域下手。把相加为 $k+1$ 的数两两分组，$(1,k)$，$(2,k-1)$，$\cdots$。

对于任意一组，至少有一个数出现的次数为 $0$。

设 $m$ 为组数。

当 $2 \mid k$ 时，有正好偶数组。

枚举非全 $0$ 的组数 $i$，方案数 $\binom{m}{i}$，将 $n$ 个 $1$ 分配到 $i$ 组中，每一组不能为 $0$，方案数 $\binom{n-1}{i-1}$，每一组有 $2$ 种方法，方案数为 $2^i$。

答案为
$$
\sum_{i=1}^{\min(n,m)} \binom{m}{i} \binom{n-1}{i-1} 2^i
$$
当 $2 \nmid k$ 时，存在一个孤立的数字。

那么一次统计去掉它的方案数，一次强制选择它，累加即可。

答案
$$
\sum_{i=1}^{\min(n,m)} \binom{m}{i} \binom{n-1}{i-1} 2^i + \sum_{i=1}^{\min(n-1,m)} \binom{m}{i} \binom{n-2}{i-1} 2^i
$$

### CODE

```cpp
const int N=5e6+5, mod=1e9+7;
int t, n, k, fac[N], inv[N], p2[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
void init() {
	fac[1]=inv[0]=p2[0]=1;
	p2[1]=2;
	for(int i=2;i<=5e6;++i) fac[i]=fac[i-1]*i%mod, p2[i]=p2[i-1]*2%mod;
	inv[N-5]=fp(fac[N-5],mod-2);
	for(int i=N-6;i;--i) inv[i]=inv[i+1]*(i+1)%mod;
}
int C(int n,int m) { return n<=m? 1:fac[n]*inv[m]%mod*inv[n-m]%mod; }
void solve() {
	n=read(), k=read();
	if(n==1) {
		printf("%lld\n",k);
		return;
	}
	int ans=0;
	if(k%2==0) {
		int m=k/2;
		for(int i=1;i<=min(n,m);++i) (ans+=C(m,i)*C(n-1,i-1)%mod*p2[i]%mod)%=mod;
	} else {
		int m=(k-1)/2;
		for(int i=1;i<=min(n,m);++i) (ans+=C(m,i)*C(n-1,i-1)%mod*p2[i]%mod)%=mod;
		for(int i=1;i<=min(n-1,m);++i) (ans+=C(m,i)*C(n-2,i-1)%mod*p2[i]%mod)%=mod;
	}
	printf("%lld\n",ans);
}
signed main() {
	init();
	t=read();
	while(t--) solve();
}
```

## luogu5689 多叉堆

### 分析

套路题。

设 $f_x$ 为以 $x$ 为根的树的方案数。

对于 $x$ 合并到 $y$，只需要钦定 $y$ 的根为 $0$，随便选出 $sz_x$ 个数放到 $x$ 里面，都有 $f_x$ 种方法，其他的节点的方案数为 $f_y$，所以得到
$$
f_y = \binom{sz_y + sz_x -1}{sz_x} f_x f_y
$$
 用并查集维护合并操作即可。

## CODE

```cpp
const int N=3e5+5, mod=1e9+7;
int n, q, fa[N], sz[N], fac[N], inv[N], f[N];
int tot, h[N], to[2*N], nxt[2*N];
void add(int x,int y) {
	to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
	add(x,y), add(y,x);
}
int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
int C(int n,int m) { return fac[n]*inv[m]%mod*inv[n-m]%mod; }
void merge(int x,int y) {
	x=get(x), y=get(y);
	sz[y]+=sz[x];
	fa[x]=y;
	f[y]=(f[y]*f[x]%mod*C(sz[y]-1,sz[x])%mod)%mod;
	// do DP
}
signed main() {
	n=read(), q=read();
	for(int i=0;i<n;++i) fa[i]=i, f[i]=1, sz[i]=1;
	fac[0]=fac[1]=1, inv[0]=1;
	for(int i=1;i<=n;++i) fac[i]=fac[i-1]*i%mod;
	inv[n]=fp(fac[n],mod-2);
	for(int i=n-1;i;--i) inv[i]=inv[i+1]*(i+1)%mod;
	int lst=0;
	while(q--) {
		int op=read();
		if(op&1) {
			int x=(read()+lst)%n, y=(read()+lst)%n;
			merge(x,y);
		} else {
			int x=(read()+lst)%n;
			printf("%lld\n",lst=f[get(x)]);
		}
	}
}
```
