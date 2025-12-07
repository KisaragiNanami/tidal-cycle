---
title: 关于拓扑序的一类题
pubDate: 2023-11-15
tags:
  - 图论
  - 拓扑排序
  - 二分答案
categories: 题解
description: '综合一下'
---

## LOJ#3997. 「CSP-S 2023」种树

答案显然有单调性，考虑二分答案 $mid$。

考虑种树的过程，实际上是把每条树边由父亲向儿子定向后的得到的 DAG 的一个拓扑序。

然后我们能够求出 $lim_i$ 表示每个点的最晚种树时间，容易二分得到。同时 DAG 本身也对 $lim$ 限制，按照逆拓扑序，在 $\text{DFS}$ 的过程中更新 $lim_x \leftarrow \min_{y \in son(x)} \{lim_y - 1\}$ 即可。如果存在 $lim_x < 1$，那么可以直接判掉。

考虑什么时候会冲突。不难发现此时我们贪心选择 $lim$ 小的点先种树一定是最优的，因此有冲突当且仅当存在 $i$ 满足 $\sum_{x=1}^n [h_x \le i] > i$。开个桶统计即可做到 $O(n)$。

复杂度 $O(n \log n \log V)$。

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
ll read() {
    ll a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
#define int128 __int128_t
const int N=1e5+5;
int n;
ll a[N], qwq[N];
int b[N], c[N];
int lim[N], h[N];
vector<int> p[N];
bool valid(int st,int ed,int i) {
	if(st==0) return false;
	int128 e=1;
	if(c[i]<0) {
		if(st>qwq[i]) {
			return ed-st+1>=a[i];
		} else if(st<=qwq[i]&&ed<=qwq[i]) {
			int128 tmp=e*b[i]*(ed-st+1)+e*c[i]*((e*st+ed)*(ed-st+1)/2);
			return tmp>=e*a[i];
		} else {
			int k=qwq[i];
			int128 tmp=e*b[i]*(k-st+1)+e*c[i]*((e*st+k)*(k-st+1)/2);
			tmp+=ed-k;
			return tmp>=e*a[i];
		}
	} else {
		int128 tmp=e*b[i]*(ed-st+1)+e*c[i]*((e*st+ed)*(ed-st+1)/2);
		return tmp>=e*a[i];
	} 
}
void dfs(int x,int fa) {
	for(auto y:p[x]) if(y!=fa) {
		dfs(y,x);
		lim[x]=min(lim[x],lim[y]-1);
	}
	if(lim[x]>=0) ++h[lim[x]];
}
int check(int mid) {
	h[0]=0;
	rep(i,1,n) {
		h[i]=0;
		int l=0, r=n;
		while(l<r) {
			int md=(l+r+1)>>1;
			if(valid(md,mid,i)) l=md;
			else r=md-1;
		}
		lim[i]=l;
	}
	dfs(1,0);
	rep(i,1,n) if(lim[i]<1) return 0;
	int s=0;
	rep(i,0,n) {
		s+=h[i];
		if(s>i) return 0;
	}
	return 1;
}
signed main() {
 	freopen("tree.in","r",stdin);
 	freopen("tree.out","w",stdout);
	n=read();
	rep(i,1,n) {
		a[i]=read(), b[i]=read(), c[i]=read();
		if(c[i]>=0) qwq[i]=-1;
		else {
			qwq[i]=(1-b[i])/c[i];
		}
	}
	rep(i,2,n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	int l=n, r=1e9;
	while(l<r) {
		int mid=(l+r)>>1;
		if(check(mid)) r=mid;
		else l=mid+1;
	}
	printf("%lld\n",l);
    return 0;
}
```

## ABC304Ex Constrained Topological Sort

首先可以拓扑排序判掉不是 DAG 的情况。

上题的做法也适用于一般的 DAG。

我们用正反两遍拓扑排序更新 $l_x$ 与 $r_x$，此时的 $l_x,r_x$ 一定是考虑了所有限制后的值。

贪心策略是让在每个点的拓扑序尽可能小，我们在每个 $r_x$ 处记录 $x$，枚举拓扑序 $i$，让满足 $r_x=i$ 的点选择大于等于 $l_x$ 的最小的拓扑序。

用`std::set`即可维护。

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
int n, m, l[N], r[N], in[N], ans[N];
vector<int> topo, p[N], v[N];
void toposort() {
	queue<int> q;
	rep(i,1,n) if(!in[i]) q.push(i);
	while(q.size()) {
		int x=q.front(); q.pop();
		topo.pb(x);
		for(auto y:p[x]) {
			l[y]=max(l[y],l[x]+1);
			if(--in[y]==0) q.push(y);
		}
	}
	if(topo.size()!=n) {
		puts("No");
		exit(0);
	}
	reverse(topo.begin(),topo.end());
	for(auto x:topo) {
		for(auto y:p[x]) {
			r[x]=min(r[x],r[y]-1);
		}
		v[r[x]].pb(x);
	}
}
signed main() {
	n=read(), m=read();
	rep(i,1,m) {
		int x=read(), y=read();
		p[x].pb(y);
		++in[y];
	}
	rep(i,1,n) {
		l[i]=read(), r[i]=read();
	}
	toposort();
	set<int> s;
	rep(i,1,n) {
		s.insert(i);
		for(auto x:v[i]) {
			auto it=s.lower_bound(l[x]);
			if(it==s.end()) {
				puts("No");
				exit(0);
			}
			ans[x]=*it;
			s.erase(it);
		}
	}
	puts("Yes");
	rep(i,1,n) printf("%lld ",ans[i]);
	puts("");
    return 0;
}
```



## luogu1954 [NOI2010] 航空管制

咕咕咕

## luogu3243 [HNOI2015] 菜肴制作

做法是建反图，贪心放置字典序大的。

证明？等放寒假再说吧。

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
int T, n, m, in[N];
vector<int> p[N], ans;
void toposort() {
	priority_queue<int> q;
	ans.clear();
	rep(i,1,n) if(!in[i]) q.push(i);
	while(q.size()) {
		int x=q.top(); q.pop();
		ans.pb(x);
		for(auto y:p[x]) {
			if(--in[y]==0) q.push(y);
		}
	}
	if(ans.size()!=n) puts("Impossible! ");
	else {
		reverse(ans.begin(),ans.end());
		for(auto x:ans) printf("%lld ",x);
		puts("");
	}
}
void solve() {
	n=read(), m=read();
	rep(i,1,n) p[i].clear(), in[i]=0;
	rep(i,1,m) {
		int x=read(), y=read();
		p[y].pb(x), ++in[x];
	}
	toposort();
}
signed main() {
	T=read();
	while(T--) solve();
	return 0;
}
```



