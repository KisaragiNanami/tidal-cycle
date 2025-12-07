---
title: 「NOIP Record」#10 单调性优化与双指针
pubDate: 2023-07-16
tags:
  - 双指针
  - 区间DP
  - 树状数组
categories:
  - Record
description: '少年主动去试错'
---

### luogu8551 Bassline

题目的限制翻译过来就是 $[x,y]$ 中任意位置都被覆盖了相同次数。

用差分求出每个点被覆盖的次数，双指针求极长的满足条件的位置即可。

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
const int N=3e5+5;
int n, ans, c[N], isl[N];
signed main() {
	n=read();
	int L=1e15, R=0;
	rep(i,1,n) {
		int l=read(), r=read();
		L=min(L,l), R=max(R,r);
		++c[l], --c[r+1];
		isl[l]=1;
	}
	rep(i,L,R) c[i]+=c[i-1];
	int l=L, r=L;
	while(r<=R) {
		while(r<R&&c[r+1]==c[r]&&!isl[r+1]) ++r;
		ans=max(ans,c[l]*(r-l));
		l=r=r+1;
	}
	printf("%lld\n",ans);
}
```

### luogu8587 新的家乡

注意到值域不大，直接枚举柱子的高度，然后在值域上双指针匹配即可。

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
const int N=1e6+5, M=6e3+5;
int n, mx, mn=1e5, cnt, h[N], c[M];
bool v[N];
int hh[M], d[M];
int solve(int x) {
	int l=mn-1, r=x-mn, res=0;
	while(l<=r) {
		++l;
		while(l<=r&&!c[l]) ++l;
		while(l<=r&&!c[r]) --r;
		while(l<=r&&l+r>x) --r;
		if(l<=r&&c[l]&&c[r]&&l+r==x) {
			if(l<r) res+=min(c[l],c[r]);
			else if(l==r) res+=c[l]/2;
		}
	}
	return res;
}
signed main() {
	n=read();
	rep(i,1,n) h[i]=read(), ++c[h[i]], mx=max(mx,h[i]), mn=min(mn,h[i]);
	rep(i,1,mx) if(c[i]) {
		rep(j,1,mx) if(c[j]) {
			if(!v[i+j]) v[i+j]=1, hh[++cnt]=i+j;
		}
	}
	int res=0, ans=0;
	rep(i,1,cnt) {
		d[i]=solve(hh[i]);
		res=max(res,d[i]);
	}
	rep(i,1,cnt) if(d[i]==res) ++ans;
	printf("%lld %lld\n",res,ans);
}
```

### luogu8590 『JROI-8』这是新历的朝阳，也是旧历的残阳

最优方案一定是让负数尽可能小，正数尽可能大。因此所有正数必然都被划分进最后一个段，而负数则要在最后一段与第一段中取最大值。

设最后一个负数的位置是 $p$，不难想到一定存在一个这样的临界位置 $p$，使得 $[1,p-1]$ 在第 $1$ 段（序列单调不降），$[p,n]$ 在最后一段。设当前分 $m$ 段，那就是 $i$ 是满足 $(a_p+1)^2 \le (a_p+m)^2$ 的第一个元素，并且随着 $m$ 的增长，$p$ 单调不增。

考虑如何快速统计答案。设划分了 $m$ 段，那么答案就是
$$
\sum_{i=1}^{p-1} (a_i+1)^2 + \sum_{i=p}^n (a_i+m)^2
$$

$$
\sum_{i=1}^{p-1} (a_i^2 + 2a_i+1) + \sum_{i=p}^n (a_i^2 + 2ma_i + m^2)
$$

$$
\sum_{i=1}^n a_i^2 + 2 \sum_{i=1}^{p-1} a_i + 2m \sum_{i=p}^n a_i + (n-p+1) \times m + p-1
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
const int N=1e6+5, M=1e7+5, mod=998244353;
int n, k, a[N], s[N], s2[N];
int squ(int x) { return x*x; }
int bs(int x) {
	int l=1, r=n;
	while(l<r) {
		int mid=(l+r)>>1;
		if(squ(a[mid]+1)<squ(a[mid]+x)) r=mid; else l=mid+1;
	}
	return l!=n? l:n+1;
}
signed main() {
	n=read(), k=read();
	int ans=0;
	rep(i,1,n) {
		a[i]=read();
		s[i]=(s[i-1]+a[i])%mod, s2[i]=(s2[i-1]+a[i]*a[i])%mod;
		(ans+=(a[i]+1)*(a[i]+1)%mod)%=mod;
	}
	int l=n+1;
	
	rep(x,2,k) {
		while(l>1&&squ(a[l-1]+1)<=squ(a[l-1]+x)) --l;
		(ans+=(s2[l-1]+2*s[l-1]%mod+(l-1))%mod)%=mod;
		(ans+=(s2[n]-s2[l-1]+mod)%mod)%=mod;
		(ans+=2*(s[n]-s[l-1]+mod)%mod*x%mod)%=mod;
		(ans+=(n-l+1)*x%mod*x%mod)%=mod;
	}
	printf("%lld\n",ans);
}

```



### luogu8858 折线

手玩几下，发现答案只能是 $2,3,4$ 其中之一。

答案是 $2$ 的充要条件是把所有点按照 $x$ 或 $y$ 排序后，第 $\frac{n}{2}$ 和第 $\frac{n}{2}+1$ 个点对应的坐标不同。

而答案是 $4$ 的情况不太好直接刻画，考虑从答案为 $3$ 下手。

不难发现如果答案是  $3$，那么一定存在一个这样的结构

![](https://i.imgtg.com/2023/07/15/Ozs731.png)

![](https://i.imgtg.com/2023/07/15/OzsA2F.png)

如何求这个东西？

它最大的特征就是形成了一个横坐标或纵坐标反着的二维偏序。

对于第一张图的情况，考虑横坐标递减的过程，维护一个纵坐标 $j$，表示能使这条折线下面的点数不小于 $\frac{n}{2}$ 的折点纵坐标，这玩意也是单调减的。如果在递减的过程中找到了使得下面的点数为 $\frac{n}{2}$ 的折点，那么答案就是 $3$。

对于第二张图的情况，按纵坐标递减，维护横坐标即可。

需要离散化，然后用树状数组维护点数。

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
const int N=5e5+5;
int T, n, m, ans, t[2*N];
struct node {
	int x, y;
} a[N];
bool cmp1(node a,node b) {
	return a.x==b.x? a.y<b.y:a.x<b.x;
    // 按照横坐标排序
}
bool cmp2(node a,node b) {
	return a.y==b.y? a.x<b.x:a.y<b.y;
    // 按照纵坐标排序
}
void lsh() {
	sort(t+1,t+m+1);
	m=unique(t+1,t+m+1)-t-1;
	rep(i,1,n) {
		a[i].x=lower_bound(t+1,t+m+1,a[i].x)-t;
		a[i].y=lower_bound(t+1,t+m+1,a[i].y)-t;
	}
}
struct BIT {
	int c[N];
	void modify(int x,int y) {
		for(;x<=n;x+=x&-x) c[x]+=y;
	}
	int query(int x) {
		int y=0;
		for(;x;x-=x&-x) y+=c[x];
		return y;
	}
} Tr;
void solve() {
	n=read();
	ans=4, m=0;
	rep(i,1,n) {
		a[i].x=t[++m]=read();
		a[i].y=t[++m]=read();
	}
	lsh();
	sort(a+1,a+n+1,cmp1);
	int i=n, j=n+1;
	if(a[n/2].x!=a[n/2+1].x) { ans=min(ans,2ll); goto out; }
	while(i>0) {
		while(a[i].x==a[i-1].x) Tr.modify(a[i].y,1), --i;
        // 坐标相同的点就直接插进去
		Tr.modify(a[i].y,1), --i;
		for(;j>1&&Tr.query(j-1)>=n/2;) --j;
		while(j>1&&Tr.query(j-1)>=n/2) --j;
		if(Tr.query(j)==n/2) ans=min(ans,3ll);
	}
	rep(i,1,n) Tr.modify(a[i].y,-1);
	sort(a+1,a+n+1,cmp2);
	if(a[n/2].y!=a[n/2+1].y) { ans=min(ans,2ll); goto out; }
	i=n, j=n+1;
	while(i>0) {
		while(a[i].y==a[i-1].y) Tr.modify(a[i].x,1), --i;
		Tr.modify(a[i].x,1), --i;
		for(;j>1&&Tr.query(j-1)>=n/2;) --j;
		if(Tr.query(j)==n/2) ans=min(ans,3ll);
	}
	rep(i,1,n) Tr.modify(a[i].x,-1);
	out: printf("%lld\n",ans);
}
signed main() {
	T=read();
	while(T--) solve();
}

```

### luogu7514 [省选联考 2021 A/B 卷] 卡牌游戏

把正反卡牌都放到一起排序，那么一种方案的极差就是一个区间的左右端点之差。一个区间 $[l,r]$ 是合法的，意味着区间内不存在相同的卡牌编号，以及出现反面不超过 $m$ 次，等价于 $[1,l-1]$ 与 $[r+1,n]$ 不出现相同的卡牌编号，并且出现正面不超过 $m$ 次。

考虑右端点递增的过程，不难发现对应的 $l$ 单调不降。因此只需要在一个初始区间上双指针维护即可。

如何找这个初始区间呢？我们考虑的是 $r$ 递增的过程，所以只要在最小化 $r$ 的基础上，找到最大的 $l$ 即可。

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
const int N=1e6+5;
int n, m, ans=1e15;
bool v[N];
struct cd {
	int x, id, st;
} a[2*N];
bool operator<(cd a,cd b) {
	return a.x<b.x;
}
signed main() {
	n=read(), m=read();
	rep(i,1,n) a[i].x=read(), a[i].id=i, a[i].st=1;
	rep(i,1,n) a[i+n].x=read(), a[i+n].id=i, a[i+n].st=0;
	sort(a+1,a+2*n+1);
	int l=1, r=2*n, cnt=0;
	while(cnt+a[r].st<=m&&!v[a[r].id]) v[a[r].id]=1, cnt+=a[r].st, --r;
	while(cnt+a[l].st<=m&&!v[a[l].id]) v[a[l].id]=1, cnt+=a[l].st, ++l;
	ans=min(ans,a[r].x-a[l].x);
	while(r<2*n) {
		v[a[r+1].id]=0, cnt-=a[r+1].st, ++r;
		while(cnt+a[l].st<=m&&!v[a[l].id]) v[a[l].id]=1, cnt+=a[l].st, ++l;
		ans=min(ans,a[r].x-a[l].x);
	}
	printf("%lld\n",ans);
}
```

### luogu4805 [CCC2016] 合并饭团

先转化一下题意。虽然不像石子合并一样需要把所有饭团合并成一个，但是直接当要求合并成一个来做就行，因为任何饭团都是由一个区间内所有饭团合并而来的。

设 $f(i,j)$ 表示 $[i,j]$ 能合并成一个多大的饭团，那么只有第一种合并方式的情况就做完了。仔细想想合并满足结合律，如果一个区间能合并成一个，那么所有合并方式得到的结果都相同。

考虑第二种操作。一种直接做的方法是，对于每个 $f(k,j)$，把它扔进值域桶里面，并记录对应的 $k$。然后枚举 $f(i,k')$，找到桶里 $f(i,k')$ 这个值对应的 $k$，并判断 $f(k'+1,k-1)$ 能否合并成一个，最后取最大值即可。这样做需要用到`std::unordered_map`，效率较低。

考虑直接维护中间那个饭团对应的区间 $[l,r]$，由于长度更大的区间能合并成的饭团更大，所以是有单调性的，用双指针匹配即可。

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
const int N=405;
int n, ans, f[N][N];
signed main() {
	n=read();
	rep(i,1,n) f[i][i]=read(), ans=max(ans,f[i][i]);
	for(int l=2;l<=n;++l) for(int i=1;i+l-1<=n;++i) {
		int j=i+l-1;
		for(int k=i;k<j;++k) if(f[i][k]&&f[k+1][j]&&f[i][k]==f[k+1][j]) {
			f[i][j]=f[i][k]+f[k+1][j];
			break;
		}
		int L=i, R=j;
		while(L<=R-2) {
			while(L<=R-2&&!f[i][L]) ++L;
			while(L<=R-2&&!f[R][j]) --R;
			if(f[i][L]<f[R][j]) ++L;
			else if(f[i][L]>f[R][j]) --R;
			else if(!f[L+1][R-1]) ++L, --R;
			if(L<=R-2&&f[i][L]&&f[L+1][R-1]&&f[R][j]&&f[i][L]==f[R][j]) {
				f[i][j]=max(f[i][j],f[i][L]+f[L+1][R-1]+f[R][j]);
				break;
			}
		}
		ans=max(ans,f[i][j]);
	}
	printf("%lld\n",ans);
}
```



### luogu3724 [AHOI2017/HNOI2017] 大佬

[link](https://yozora0908.github.io/2023/lg3724-solution)

### luogu6563 [SBCOI2020] 一直在你身旁

[link](https://yozora0908.github.io/2023/lg6563-solution)
