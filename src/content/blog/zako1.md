---
title: 「杂题选讲」#1
tags:
  - 贪心
  - DP
  - 单调队列
  - 分治
  - 杂题选讲
categories:
  - 题解
pubDate: 2022-07-26
description: '111'
---

杂题选讲。



## CF1548A Web of Lies

### 分析

发现编号为 $i$ 的节点只会对编号大于 $i$ 的节点造成影响。

设 $cnt_x$ 为与 $x$ 相连且编号大于 $x$ 的点的数量。如果 $x$ 是所在连通块编号最小的节点，那么只要 $cnt_x\neq 0$，$x$ 就一定被删除。发现最终剩下的一定是满足 $cnt_x = 0$ 的点。维护即可。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5;
int n, m, cnt[N];
int main() {
    scanf("%d%d",&n,&m);
    int ans=n;
    for(int i=1;i<=m;++i) {
        int x, y; scanf("%d%d",&x,&y);
        if(x>y) swap(x,y);
        if(++cnt[x]==1) --ans;
    }
    int q; scanf("%d",&q);
    while(q--) {
        int op, x, y; scanf("%d%",&op);
        if(op==1) {
            scanf("%d%d",&x,&y);
            if(x>y) swap(x,y);
            if(++cnt[x]==1) --ans;
        } else if(op==2) {
            scanf("%d%d",&x,&y);
            if(x>y) swap(x,y);
            if(--cnt[x]==0) ++ans;
        } else printf("%d\n",ans);
    }
}
```

## luogu3545 HUR-Warehouse Store

### 分析

一个错误的贪心就是，只要能卖出就尽可能卖出。反例是 $b_1 = a_1 = 10^9$，$a_{2 \sim n} = 0$ 且 $b_{2 \sim n} = 1$，其中 $n > 2$。第一天把所有的货物都卖了，可是收益最大为 $1$，显然不对。

尝试修正这个贪心。设第 $i$ 天上午货物量为 $t$，如果 $t < b_i$ 且 $b_i$ 小于已经之前的最大需求量 $b_j$，由于卖给谁收益都是 $1$ 且卖给 $j$ 的一定多于卖给 $i$ 的，所以直接令 $t + (b_j - b_i)$。这样做一定不劣。

否则就遵循能买则买的原则。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=250005;
int n, a[N], b[N];
bool v[N];
priority_queue<pair<int,int> > q;
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a*f;
}
signed main() {
	n=read();
	for(int i=1;i<=n;++i) a[i]=read();
	for(int i=1;i<=n;++i) b[i]=read();
	int t=0, ans=0;
	for(int i=1;i<=n;++i) {
		t+=a[i];
		if(t<b[i]&&q.size()&&q.top().first>b[i]) {
			int d=q.top().first, id=q.top().second;
			q.pop();
			v[id]=0, t+=d, --ans;
            // 反悔贪心
		}
 		if(t>=b[i]) {
            // 如果反悔了，那么一定有t>=b[i]
            // 否则就直接贪心
 			t-=b[i], v[i]=1; q.push(make_pair(b[i],i)), ++ans;
 		}
	}
	printf("%lld\n",ans);
	for(int i=1;i<=n;++i) if(v[i]) printf("%d ",i);
	puts("");
}
```

## luogu2034 选择数字

### 分析

正难则反。~~虽然正着也能做~~。

先认为每个数字都被选择，不能有连续超过 $k$ 个数字被选择说明在一个长度为 $k+1$ 的窗口中，至少有 $2$ 个不被选择的数字。

选出的数字总和最大，说明不被选出的数字总和最小。

设 $f_i$ 表示在 $[1,i]$ 中且满足条件的前提下，不选择 $i$ 的最小和。
$$
f_i = \min_{j \in [i-k-1,i)} {\{ f_j + a_i \}}
$$
单调队列优化即可。答案为 $\max_{i \in [n-k,n]}{\{ S - f_i \}}$，其中 $S=\sum_{i=1}^n a_i$。这是因为如果 $[n-k,n]$ 这个长度为 $k+1$ 区间内，所有数字都没选择，那么显然是不满足条件的。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=100005;
int n, k, sum, a[N], f[N], q[N];
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a*f;
}
signed main() {
	memset(f,0x3f,sizeof(f));
	f[0]=0;
	n=read(), k=read();
	for(int i=1;i<=n;++i) sum+=a[i]=read();
	int l=1, r=1;
	for(int i=1;i<=n;++i) {
		while(l<=r&&i-k-1>q[l]) ++l;
		f[i]=f[q[l]]+a[i];
		while(l<=r&&f[i]<=f[q[r]]) --r;
		q[++r]=i;
	}
	int ans=0;
	for(int i=n-k;i<=n;++i) ans=max(ans,sum-f[i]);
	printf("%lld\n",ans);
}
```

## CF1415E New Game Plus!

### 分析

$k$ 次机会把计数器变为 $0$，相当于 $k+1$ 个初始为 $0$ 的局面。

贪心地将 $\{ a\}$ 递减排序。对于 $i$，找到价值最大的局面 $x$，让 $ans+x$，$x+a_i$。最终 $ans$ 即为答案。

正确性？

假设所有 $a_i$ 都是正数，那么 $k+1$ 个局面都不会减小，那么只要不断累加一个局面即可，这样做是对的。

假设存在负数 $a_i$，使得最大局面 $x$ 会减小，那么由于答案要累加 $x$，所以取出不是最大局面显然不优。由于本题明显存在的一点是“局部最优解可以推得全局最优解”，所以即便 $x$ 减小，如果他还是最大局面，仍然不会产生错误；否则它也不会产生贡献。这种情况下也是对的。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=5e5+5;
int n, k, ans, a[N];
priority_queue<int> q;
bool cmp(int x,int y) { return x>y; }
signed main() {
	scanf("%lld%lld",&n,&k);
	for(int i=1;i<=n;++i) scanf("%lld",&a[i]);
	for(int i=0;i<=k;++i) q.push(0);
	sort(a+1,a+n+1,cmp);
	for(int i=1;i<=n;++i) {
		int x=q.top(); q.pop();
		ans+=x, x+=a[i];
		q.push(x);
	}
	printf("%lld\n",ans);
} 
```

## CF1385D a-Good String

### 分析

$n$ 为 $2$ 的整数次幂，显然是分治啊。

这是我除了归并排序外，第一道分治题。

设 $solve(l,r,c)$ 表示将 $S_{l,r}$ 变成一个 $c$ 好串的最小操作次数。

具体方法是从 $mid=\frac{l+r}{2}$ 作为临界点，考虑两种情况。一种是将 $S_{l,mid}$ 全部改为 $c$，$S_{mid+1,r}$ 改为 $c+1$，另一种是反过来。

这一层的答案即为
$$
\sum_{i=l}^{mid} [S_i \neq c] + solve(mid+1,r,c+1)
$$
和
$$
\sum_{i=mid+1}^r [S_i \neq c] + solve(l,mid,c+1)
$$
取较小值即可。

$T(n) = 2 T(\frac{n}{2}) + O(n)$，带入主定理得到复杂度为 $O(n \log_2 n)$。

### CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
int t, n;
char s[150000];
int solve(int l,int r,char c) {
	if(l==r) return s[l]!=c;
	int mid=(l+r)/2;
	int cl=0, cr=0;
	for(int i=l;i<=mid;++i) cl+=s[i]!=c;
	for(int i=mid+1;i<=r;++i) cr+=s[i]!=c;
	cl+=solve(mid+1,r,c+1), cr+=solve(l,mid,c+1);
	return min(cl,cr);	
}
int main() {
	scanf("%d",&t);
	while(t--) {
		scanf("%d%s",&n,s+1);
		printf("%d\n",solve(1,n,'a'));	
	}
	
} 
```

## CF1545B AquaMoon and Chess

### 分析

$110 \rightarrow 011$。

$011 \rightarrow 110$。

设 $c0$ 为 $0$ 的数量，$c11$ 为两个连续的 $1$ 的数量。注意 $111$ 中 $c11=1$。

那么答案即为 $C_{c0+c11}^{c11}$。

一共 $c_0+c11$ 个位置，填进去 $c11$ 个 $11$ 的方案数。

不难发现，空出来的单个 $1$ 是没有任何影响的，因为只要 $11$ 交换过来，就能用右边的 $1$ 和这个单独的 $1$ 组合成新的 $11$，且 $11$ 的总量不变。所以，$11$ 可以到达任何一个 $0$ 的位置，加上本身的 $c11$ 个位置，就有了这个式子。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e5+5, mod=998244353;
int t, n, m, cnt, ans, fac[N], inv[N];
char s[N];
int read() {
	int a=0, f=1; char c=getchar();
	while(!isdigit(c)) {
		if(c=='-') f=-1;
		c=getchar();
	}
	while(isdigit(c)) a=a*10+c-'0', c=getchar();
	return a*f;
}
int fp(int x,int y) {
	int z=1; x%=mod;
	for(;y;x=x*x%mod,y>>=1) if(y&1) z=z*x%mod;
	return z;
}
int C(int n,int m) {
	return n<=m? 1:fac[n]*inv[m]%mod*inv[n-m]%mod; 
}
void init() {
	fac[1]=1, inv[0]=1;
	for(int i=2;i<=1e5;++i) fac[i]=fac[i-1]*i%mod;
	inv[N-5]=fp(fac[N-5],mod-2);
	for(int i=(1e5)-1;i;--i) inv[i]=inv[i+1]*(i+1)%mod;
}
void solve() {
	n=read();
	scanf("%s",s+1);
	int c0=0, c11=0;
	for(int i=1;i<=n;++i) {
		if(s[i]=='0') ++c0;
		else if(i+1<=n&&s[i+1]=='1') ++c11, ++i;
	}
	printf("%lld\n",C(c0+c11,c11));
}
signed main() {
	init();
    scanf("%d",&t);
    while(t--) solve();
}
```

