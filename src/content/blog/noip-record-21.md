---
title: 「NOIP Record」#21 序列上的扫描线
pubDate: 2023-09-15
tags:
  - 扫描线
  - DP
  - 状态压缩
  - 容斥原理
  - 计数
  - 组合数学
  - 贪心
categories:
  - Record
description: '少年望见了新大陆'
---


先放题，有时间再整理。

其实也就那回事，理解了思想之后就没啥特殊性了。

### luogu6647 [CCC2019] Tourism

不难发现 $t =\lceil \frac{n}{k} \rceil$，然而并没有什么用，我们只要在转移时对取值区间进行限制即可。

具体地，第 $i$ 天的取值左端点是 $L_i = \max(0,i-k)$，右端点是 $R_i = \lfloor \frac{i-1}{k} \rfloor \times k$。

设 $f(i)$ 为看到第 $i$ 个景点，所能获得的最大收益，显然有
$$
f(i) = \max_{j \in [L_i,R_i]} \Big \{ f(j-1) + \max_{k \in [j,i]} \{a_k\} \Big \}
$$
单调栈有一个很好的性质：容易得到 $a_i$ 作为最值的区间。

我们用线段树维护每个 $f(j-1)+\max_{k \in [j,i]} \{a_k\}$，其中 $i$ 是当前位置。

每加入一个 $a_i$，我们用单调栈找到 $a_i$ 作为最大值的左边界，同时用 $a_i$ 与之前的最值之差作为增量，修改每一段的值。

这样就到达了对最值扫描线的目的。

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
const int N=1e6+5;
int n, k, a[N];
int tp, st[N];
ll t[N<<2], tag[N<<2], f[N];
void pushup(int x) { t[x]=max(t[x<<1],t[x<<1|1]); }
void maketag(int x,ll d) {
	t[x]+=d;
	tag[x]+=d;
}
void pushdown(int x) {
	if(tag[x]!=0) {
		maketag(x<<1,tag[x]);
		maketag(x<<1|1,tag[x]);
		tag[x]=0;
	}
}
void upd(int L,int R,ll d,int x=1,int l=0,int r=n) {
	if(L<=l&&r<=R) { maketag(x,d); return; }
	pushdown(x);
	int mid=(l+r)>>1;
	if(L<=mid) upd(L,R,d,x<<1,l,mid);
	if(R>mid) upd(L,R,d,x<<1|1,mid+1,r);
	pushup(x);
}
ll query(int L,int R,int x=1,int l=0,int r=n) {
	if(L<=l&&r<=R) return t[x];
	pushdown(x);
	int mid=(l+r)>>1;
	ll res=0;
	if(L<=mid) res=max(res,query(L,R,x<<1,l,mid));
	if(R>mid) res=max(res,query(L,R,x<<1|1,mid+1,r));
	return res;
} 
signed main() {
	n=read(), k=read();
	rep(i,1,n) a[i]=read();
	a[0]=1e9+7;
	st[++tp]=0;
    // f[0]+max(a[1,i])
	for(int i=1;i<=n;++i) {
	    upd(i-1,i-1,a[i]);
		int lst=i-1;
        // 注意位置j维护的是f[j]+max(a[j+1,i])
		// 所以lst从i-1开始
		while(tp&&a[st[tp]]<=a[i]) {
			upd(st[tp-1],lst-1,a[i]-a[st[tp]]);
            // 对应的区间是[st[tp-1]+1,lst]
			lst=st[tp-1];
			--tp;
		}
		st[++tp]=i;
		int L=max(0,i-k), R=(i-1)/k*k;
		f[i]=query(L,R);
		upd(i,i,f[i]);
	}
	printf("%lld\n",f[n]);
	return 0;
}
```



### CF1585F Non-equal Neighbours

考虑容斥。

设第 $i$ 个性质表示 $b_i = b_{i+1}$。

然后做一个转化：如果满足 $k$ 个性质，那么序列被分为 $k+1$ 个连续段。我们要求的是恰好被划分成 $n$ 个连续段的方案数。

设 $F(k)$ 表示至多满足 $k$ 个性质的方案数。二项式反演一下，答案就是
$$
ans = \sum_{k=0}^{n} (-1)^{n-k} F(k)
$$


注意 $F(0) = 0$。

考虑用 DP 计算 $F$。

设 $f(i,j)$ 为考虑了前 $i$ 个数，至多成了 $j$ 个连续段的方案数。这样做的正确性是每一段所取的值也可能和前一段相同，满足「至多」。

显然有转移
$$
f(i,j) = \sum_{k=1}^{i} \Big( f(k-1,j-1) \times \min_{l \in [k,i]}\{a_l\} \Big)
$$


考虑优化。

$j$ 本质上就是容斥系数的指数，可以提取奇偶性后压成 $0/1$。于是设 $f(i,0/1)$ 为考虑了前 $i$ 个数，容斥系数为 $0/1$ 的所有状态方案书之和。

- 当 $\min_{l \in [k,i]} \{a_l\}$ 一定时，把 $f$ 对 $k$ 这一维做前缀和后可以 $O(1)$ 求得对应的方案。
- 压了容斥系数后，只需要考虑 $a_i$ 作为最小值的这一段作为新的贡献，然后直接累加 $a_i$ 左边第一个比它小的那个位置的方案。

在单调栈的过程中 DP 即可。

当 $n$ 是偶数时，答案是 $f(n,0) - f(n,1)$；否则是 $f(n,1) - f(n,0)$。





```cpp
// LUOGU_RID: 122131096
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
const int N=2e5+5, mod=998244353;
int n, a[N], f[N][2], g[N][2];
int tp, st[N];
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	f[0][0]=g[0][0]=1;
	for(int i=1;i<=n;++i) {
		while(tp&&a[st[tp]]>=a[i]) --tp;
		f[i][0]=a[i]*(g[i-1][1]-(tp==0? 0:g[st[tp]-1][1])+mod)%mod;
		f[i][1]=a[i]*(g[i-1][0]-(tp==0? 0:g[st[tp]-1][0])+mod)%mod;
		if(tp) {
            // 注意f[0][0/1]不是0
			(f[i][0]+=f[st[tp]][0])%=mod;
			(f[i][1]+=f[st[tp]][1])%=mod;
		}
		st[++tp]=i;
		g[i][0]=(g[i-1][0]+f[i][0])%mod;
		g[i][1]=(g[i-1][1]+f[i][1])%mod;
	}
	int ans=(f[n][0]-f[n][1]+mod)%mod;
	if(n&1) ans=(-ans+mod)%mod;
	printf("%lld\n",ans);
	return 0;
}

```

### 某道题

>定义 $\max(A)$ 为矩形 $A$ 内所有数的最大值，$\min(A)$ 为矩形 $A$ 内所有数的最小值。
>
>定义 $f(A)$ 为 $A$ 的所有子矩形 $B$ 中，满足 $\max(B) \oplus \min(B) = v$ 的子矩形 $B$ 的个数。其中 $\oplus$ 是按位异或运算，$v$ 是给定的常数。
>
>给定 $n$ 个长度为 $m$ 的序列，第 $i$ 个序列为 $a_i$。
>
>对于所有 $1 \sim n$ 的排列 $P$，构造矩形 $A$，满足 $A$ 的第 $i$ 行是序列 $a_{P_i}$。
>
>求所有 $f(A)$ 之和。
>
>$n \le 8$，$m \le 10^5$，$0 \le v,S_{i,j} < 2^{31}$。

考虑计算每个子矩形的贡献，即每个合法子矩形能被多少个更大的矩形包含，同时不会改变其中的最大值与最小值。

$n$ 很小，并且每一列只有只有最大值和最小值有用，考虑状压 $n$。

求出 $mx(S,i)$ 与 $mn(S,i)$，分别表示使用的序列集合 $S$，时第 $i$ 列的最大值与最小值。把值离散化了，记 $rec_x$ 为与 $x$ 异或后为 $v$ 的值。

枚举序列集合 $S$，对最大值和最小值扫描线。为了避免重复，我们只考虑每个值作为最值区间右端点的情况。在单调栈的过程中维护最值对应线段的加入和删除，将一个最值 $x$ 所在线段与最值  $rec_x$ 所在线段取交后就能得到合法的子矩形宽度取值范围。

然后我们就能得到每个 $mx(S,i)$ 与 $mn(S,i)$ 作为最值时的贡献和 $res$，对答案的贡献就是  $res \times (n-|S|+1) \times (|S|)! \times (n-|S|)!$。

```cpp
// Problem: T349092 D
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/T349092
// Author: yozora0908
// Memory Limit: 512 MB
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
const int N=9, M=1e5+5;
int n, m, V, U, a[N][M], rec[N*M], lg[256];
int mx[256][M], mn[256][M], fac[N];
int tot, c[N*M];
unordered_map<int,int> mp;
void lsh() {
	sort(c+1,c+n*m+1);
	rep(i,1,n*m) {
		int x=c[i], y=c[i]^V;
		if(!mp.count(x)) mp[x]=++tot;
		if(mp.count(y)) {
			rec[mp[x]]=mp[y], rec[mp[y]]=mp[x];
		}
	}
	rep(i,1,n) rep(j,1,m) {
		a[i][j]=mp[a[i][j]];
	}
}
int lowbit(int x) { return x&-x; }
int tpa, tpb, sa[M], sb[M];
struct node {
	int l=0, r=0, exist=0;
	node() {}
	node(int _l,int _r) { l=_l, r=_r, exist=1; }
} A[M], B[M];

int dlt, ans;

void opa(int l,int r,int s,int type) {
	int x=mx[s][r], y=rec[x];
	if(type==1) A[x]=node(l,r); else A[x]=node();
	if(B[y].exist) dlt+=type*max(0ll,min(r,B[y].r)-max(l,B[y].l)+1);
}
void opb(int l,int r,int s,int type) {
	int x=mn[s][r], y=rec[x];
	if(type==1) B[x]=node(l,r); else B[x]=node();
	if(A[y].exist) dlt+=type*max(0ll,min(r,A[y].r)-max(l,A[y].l)+1);
}
signed main() {
	n=read(), m=read(), V=read();
	rep(i,1,n) rep(j,1,m) a[i][j]=read(), c[(i-1)*m+j]=a[i][j];
	lsh();
	rep(i,1,m) mn[0][i]=1e12;
	fac[0]=1;
	rep(i,1,8) lg[1<<(i-1)]=i, fac[i]=fac[i-1]*i;
	U=(1<<n)-1;
	
	rep(i,1,U) {
		int k=lowbit(i);
		rep(j,1,m) {
			mx[i][j]=max(mx[i^k][j],a[lg[k]][j]);
			mn[i][j]=min(mn[i^k][j],a[lg[k]][j]);
		}
		
		int res=0;
		tpa=tpb=dlt=0;
		rep(j,1,m) {
			while(tpa&&mx[i][sa[tpa]]<=mx[i][j]) {
				opa(sa[tpa-1]+1,sa[tpa],i,-1);
				--tpa;
			}
			while(tpb&&mn[i][sb[tpb]]>=mn[i][j]) {
				opb(sb[tpb-1]+1,sb[tpb],i,-1);
				--tpb;
			}
			
			sa[++tpa]=j;
			opa(sa[tpa-1]+1,j,i,1);
			sb[++tpb]=j;
			opb(sb[tpb-1]+1,j,i,1);
			res+=dlt;
		}
		
		rep(j,1,tpa) A[mx[i][sa[j]]]=node();
		rep(j,1,tpb) B[mn[i][sb[j]]]=node();
		
		int cnt=__builtin_popcount(i);
		ans+=res*(n-cnt+1)*fac[cnt]*fac[n-cnt];
	}
	printf("%lld\n",ans);
	
	return 0;
}
```



### CF1313D Happy New Year

把一个区间 $[l,r]$ 拆成加入事件 $(l,i)$ 与删除事件 $(r+1,-i)$，对其扫描线，这样夹在两个事件中间的点都是等价的。

由于区间拆掉之后就是左闭右开，所以两个事件的坐标之差就是中间的点的个数。不妨设事件 $i$ 与 $i+1$ 中间的**点集**为 $P(i)$。

由于 $k$ 很小，所以设 $f(i,S)$ 表示考虑到事件 $i$，选择的能覆盖 $P(i,i+1)$ 的线段集合为 $S$ 时，最多有多少个被覆盖次数为奇数的点。

为了方便，我们用一个标记数组动态维护可以覆盖 $i$ 的区间，并对它们进行编号，具体见代码。

设 $\text{cntp}(S)$ 为集合 $S$ 内元素个数的奇偶性。

考虑加入事件，不妨设其为 $j$。

- $j \in S$，那么 $f(i,S) = f(i-1,S \setminus \{j\})+ [\text{cntp}(S)=1] \cdot \Big|P(i)\Big|$。
- $j \notin S$，那么令 $f(i,S) = f(i-1,S) +[\text{cntp}(S)=1] \cdot \Big|P(i)\Big|$。

考虑删除事件，不妨设其为 $j$。

- $j \in S$，令 $f(i,S) = -\infty$。
- $j \notin S$，$f(i,S) = \max\Big( f(i-1,S),f(i-1,S \cup \{j\}) \Big)+[\text{cntp}(S)=1] \cdot \Big|P(i)\Big|$

$i$ 这一维可以滚掉，但是 512MiB 的内存限制是的绰绰有余的。

事件加入和删除时，在标记数组中进行相应操作即可。

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
const int N=1e5+5, inf=0x3f3f3f3f;
int n, m, K, f[1<<8], v[10];
vector<PII > vec;
signed main() {
	n=read(), m=read(), K=read();
	rep(i,1,n) {
		int l=read(), r=read();
		vec.pb({l,i});
		vec.pb({r+1,-i});
	}
	sort(vec.begin(),vec.end());
	SET(f,-0x3f);
	f[0]=0;
    // 由于vector下标从0开始，所以这里使用滚动数组
	for(int i=0;i<vec.size();++i) {
		int id=vec[i].se;
		int len=(i!=vec.size()-1? vec[i+1].fi-vec[i].fi:0);
		if(id>0) {
			int k=-1;
			for(int j=0;j<8;++j) if(!v[j]) { v[j]=id, k=j; break; }
			for(int S=255;~S;--S) {
				if((S>>k)&1) {
					f[S]=f[S^(1<<k)]+len*__builtin_parity(S);
				} else f[S]+=len*__builtin_parity(S);
			}
		} else {
			int k=-1;
			for(int j=0;j<8;++j) if(v[j]==-id) { v[j]=0, k=j; break; }
			for(int S=0;S<=255;++S) {
				if((S>>k)&1) f[S]=-inf;
				else {
					f[S]=max(f[S],f[S^(1<<k)])+len*__builtin_parity(S);
				}
			}
		}
	}
	printf("%d\n",f[0]);
	return 0;
}
```



### Public NOIP Round #4 治病

转化一下题意，先求出总花费 $sum$，然后对于每个医生 $i$ 都求出只按照 $i$ 的药方吃药的花费 $ans_i$，最终答案就是 $sun-ans_i$。

每一种药是相对独立的，所以我们分开考虑。

对于第 $i$ 种药，我们把医生 $j$ 的要求 $(L_j,R_j)$ 看作两个事件：

1. 在 $L_j$ 处，药物 $i$ 的需求加 $1$。
2. 在 $R_j+1$ 处，药物 $i$ 的需求减 $1$。

然后我们对这些事件扫描线，维护当前要求此类药物的医生集合。

- 如果处理完一个事件后集合不为空，那么这个事件与下个事件中间的那一段代价都要贡献给 $sum$。

- 如果处理完一个事件后集合大小为 $1$，那么这个事件与下个事件中间的那一段代价都要贡献给 $ans_i$。

用`std::set`来维护，时间复杂度 $O(m \log_2 n)$。

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
const int N=5e5+5, M=1e6+5;
int n, m, c[M];
int sum, ans[N];
vector<PII > v[M];
signed main() {
    n=read(), m=read();
    rep(i,1,m) c[i]=read();
    rep(i,1,n) {
        int l=read(), r=read(), k=read();
        while(k--) {
            int x=read();
            v[x].pb({l,i}), v[x].pb({r+1,-i});
        }
    }
    rep(x,1,m) {
        set<int> s;
        sort(v[x].begin(),v[x].end());
        for(int i=0;i<v[x].size();++i) {
            PII t=v[x][i];
            if(t.se>0) s.insert(t.se); else s.erase(-t.se);
            if(s.size()&&i<v[x].size()-1) sum+=c[x]*(v[x][i+1].fi-t.fi);
            if(s.size()==1) ans[*s.begin()]+=c[x]*(v[x][i+1].fi-t.fi);
        }
    }
    rep(i,1,n) printf("%lld ",sum-ans[i]);
    return 0;
}
```



### 某道题

>$n$ 件事，第 $i$ 件事只能在 $[s_i,t_i]$ 开始做，需要花费 $x_i$ 的时间，其中 $x_i > t_i-s_i$。完成第 $i$ 件事的收益是 $c_i$，任何时候最多同时做一件事。
>
>求最大收益。
>
>$n \le 3 \times 10^5$，$1 \le s_i \le t_i \le 5000$，$1 \le x_i \le 5000$，$1 \le c_i \le 10^9$。



注意到事件的数量不多，时间的范围也不大，考虑对事件扫描线，得到每个时刻能够去做的所有事件。

设 $f(i)$ 为到达 $i$ 时刻的最大收益。先取前缀 $\max$，再往后刷表，这样一定是正确的。

对每个 $x_i$ 都开一个优先队列，贪心选择收益更大的事件。

时间复杂度 $O(n^2 + n \log_2 n)$。

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
const int N=3e5+5, M=5005;
int n, f[2*M], x[N], c[N];
vector<int> s[M], t[M];
bool v[N];
priority_queue<PII > q[M];
signed main() {
	n=read();
	rep(i,1,n) {
		int l=read(), r=read();
		x[i]=read(), c[i]=read();
		s[l].pb(i), t[r+1].pb(i);
	}
	int ans=0;
	for(int i=1;i<=5000;++i) {
		f[i]=max(f[i],f[i-1]);
		for(auto j:s[i]) q[x[j]].push({c[j],j});
		for(auto j:t[i]) v[j]=1;
		for(int j=1;j<=5000;++j) {
			while(q[j].size()&&v[q[j].top().se]) q[j].pop();
			if(q[j].size()) {
				f[i+j]=max(f[i+j],f[i]+q[j].top().fi);
				ans=max(ans,f[i+j]);
			}
		}
	}
	printf("%lld\n",ans);
	return 0;
}
```

### LOJ2274「JXOI2017」加法

答案显然具有单调性，于是二分答案 $mid$。

对于第一个满足 $a_i < mid$ 的位置 $i$，最优决策一定是选择此时能覆盖到它的，右端点尽可能靠右的若干个区间。

不难发现从左往右这样贪心做是最优的。

对区间端点扫描线，维护一个优先队列表示能覆盖到当前位置的区间集合。选择一个区间时，直接在差分数组上修改即可。

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
int T, n, m, A, k, a[N], c[N], v[N];
vector<PII> p[N];
struct node {
	int l, r;
} s[N];
bool check(int x) {
	int cnt=0;
	priority_queue<PII > q;
	rep(i,1,n) c[i]=v[i]=0;
	
	for(int i=1;i<=n;++i) {
		c[i]+=c[i-1];
		for(auto t:p[i]) {
			int id=t.fi, type=t.se;
			if(type==1) {
				q.push({s[id].r,id});
			}
			else v[id]=1;
		}
		if(a[i]+c[i]>=x) continue;
		if(cnt>=k) return 0;
		while(a[i]+c[i]<x) {
			if(cnt>=k) return 0;
			while(q.size()&&v[q.top().se]) q.pop();
			if(q.empty()) return 0;
			int id=q.top().se; q.pop();
			c[i]+=A, c[s[id].r+1]-=A;
			++cnt;
		}
		
	}
	return 1;
}
void solve() {
	int l=1e9, r=0;
	n=read(), m=read(), k=read(), A=read();
	rep(i,1,n) a[i]=read(), l=min(l,a[i]), p[i].clear();
	rep(i,1,m) {
		s[i].l=read(), s[i].r=read();
		p[s[i].l].pb({i,1}), p[s[i].r+1].pb({i,-1});
	}
	r=l+k*A;
	while(l<r) {
		int mid=(l+r+1)>>1;
		if(check(mid)) l=mid; else r=mid-1;
	}
	printf("%lld\n",l);
}
signed main() {
	T=read();
	while(T--) solve();
	return 0;
}

```



### luogu7503 「HMOI R1」文化课

容易得出一个 $\text{Trivial}$ 的 DP。设 $f(i)$ 为前 $i$ 个人能得到的最大收益，则

$$
f(i) = \max_{j \in [0,i-1]}\Big\{ f(j) + w(j+1,i) \Big\}
$$
其中 $w(j+1,i)$ 为 $[j+1,i]$ 中的人一同作弊能产生的最大贡献。

但是本题不能直接用线段树维护 $f(j) + w(j+1,i)$ 了，因为展开之后大概是下面这个样子的
$$
w(j,i) = \sum_{k=j}^i[l_k \le \max_{p=j}^i \{a_p\} \le r_k]
$$


观察这个式子，我们能发现只要一个区间包含 $i$ 以及一个满足 $a_j \ge l_i$ 的 $j$，那么 $a_i$ 就能产生贡献。同样地，一旦出现了 $a_j \ge r_i$，那么贡献就要消去。也就是说每个 $a_i$ 都在序列上有若干关键点，结合上文提到的扫描线方法，我们尝试对这些关键点扫描线。

首先 $f(j)+w(j+1,i)$ 这个东西最好是不要丢掉的，因为这个后缀形式很适合扫描线。我们还是在线段树上维护 $f(j)+w(j+1,i)$，对于每个 $i$，求出

1. $ll_i$，表示最大的 $j$，满足 $j<i \land a_j \ge l_i$。
2. $lr_i$，表示最大的 $j$，满足 $j<i \land a_j > r_i$。
3. $rl_i$，表示最小的 $j$，满足 $j>i \land a_j \ge l_i$。
4. $rr_i$，表示最小的 $j$，满足 $j>i \land a_j > r_i$。

然后讨论跨越不同关键点的情况。

- 在扫描到 $i$ 时，$a_i$ 能对 $w(k,i), k \in [1,ll_i]$ 产生 $1$ 的贡献，同时对 $w(k,i),k \in [1,lr_i]$ 产生 $-1$ 的贡献。

- 在扫描到 $rl_i$ 时，$a_i$ 能对 $w(k,rl_i),k \in[ll_i+1,i]$ 产生 $1$ 的贡献。
- 在扫描到 $rr_i$ 时，$a_i$ 能对 $w(k,rr_i),k \in [rl_i+1,i]$ 产生 $-1$ 的贡献。

计算 $a_i$ 贡献之前用全局最大值更新 $f(i)$ 即可

```cpp
#include<bits/stdc++.h>
using namespace std;
#define LL long long
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
int n, a[N], l[N], r[N];
int ll[N], lr[N];
vector<int> pl[N], pr[N];
int t[N<<2], tag[N<<2];
void pushup(int x) { t[x]=max(t[x<<1],t[x<<1|1]); }
void maketag(int x,int d) {
	t[x]+=d;
	tag[x]+=d;
}
void pushdown(int x) {
	if(tag[x]!=0) {
		maketag(x<<1,tag[x]);
		maketag(x<<1|1,tag[x]);
		tag[x]=0;
	}
}

void upd(int L,int R,int d,int x=1,int l=1,int r=n) {
	if(L<=l&&r<=R) { maketag(x,d); return; }
	pushdown(x);
	int mid=(l+r)>>1;
	if(L<=mid) upd(L,R,d,x<<1,l,mid);
	if(R>mid) upd(L,R,d,x<<1|1,mid+1,r);
	pushup(x);
}
struct BIT {
	int c[N];
	void clear() { rep(i,0,n) c[i]=0; }
    // 维护后缀信息的BIT
	void upd(int x,int d) { for(;x;x-=x&-x) c[x]=max(c[x],d); }
	int query(int x) {
		int d=0;
		for(;x<=n;x+=x&-x) d=max(d,c[x]);
		return d;
	}
} T;
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	rep(i,1,n) l[i]=read(), r[i]=read();
	rep(i,1,n) {
		T.upd(a[i],i);
		ll[i]=T.query(l[i]), lr[i]=T.query(r[i]+1);
	}
	T.clear();
	per(i,n,1) {
		T.upd(a[i],n-i+1);
		int s=n-T.query(l[i])+1, t=n-T.query(r[i]+1)+1;
		pl[s].pb(i), pr[t].pb(i);
	}
	rep(i,1,n) {
		upd(i,i,t[1]);
		if(ll[i]>0) upd(1,ll[i],1);
		if(lr[i]>0) upd(1,lr[i],-1);
		for(auto j:pl[i]) if(ll[j]<j) upd(ll[j]+1,j,1);
		for(auto j:pr[i]) if(lr[j]<j) upd(lr[j]+1,j,-1);
	}
	printf("%d\n",t[1]);
	return 0;
}
```

### LOJ#2999. 「JOISC 2015 Day2」Keys

[link](https://yozora0908.github.io/2023/loj2999-solution)

### CF483D Interesting Array

套路题。

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
int n, m, ans[N], sum[N][31];
int lim[31];
vector<int> s[N], t[N];
struct limit {
    int l, r, x;
} q[N];
void upd(int x,int d) {
    for(int i=0;i<30;++i) if((x>>i)&1) lim[i]+=d;
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        int l=read(), r=read(), x=read();
        s[l].pb(x), t[r+1].pb(x);
        q[i].l=l, q[i].r=r, q[i].x=x;
    }
    rep(i,1,n) {
        for(auto x:s[i]) upd(x,1);
        for(auto x:t[i]) upd(x,-1);
        int res=0;
        for(int j=0;j<30;++j) {
            sum[i][j]=sum[i-1][j];
            if(lim[j]>0) res|=(1<<j), ++sum[i][j];
        }
        ans[i]=res;
    }
    int fg=0;
    for(int i=1;i<=m;++i) {
        int l=q[i].l, r=q[i].r, x=q[i].x;
        for(int i=0;i<30;++i) if(((x>>i)&1)==0) {
            if(sum[r][i]-sum[l-1][i]==r-l+1) { fg=1; break; }
        }
    }
    if(fg) puts("NO");
    else {
        puts("YES");
        rep(i,1,n) printf("%lld ",ans[i]);
        puts("");
    }
    return 0;
}
```
