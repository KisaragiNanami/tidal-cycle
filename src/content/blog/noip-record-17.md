---
title: 「NOIP Record」#17 二分图判定
pubDate: 2023-08-26
tags:
  - 图论
  - DP
  - 二分图
  - 贪心
categories:
  - Record
description: '少年一再环顾NOI大纲'
---

## 二分图判定

没啥技巧，最难的是把图论模型建起来。

### luogu1330 封锁阳光大学

相邻两个点只能封锁一个，但是要覆盖所有边。对应到二分图上就是左部右部点的数量取较小值。

图可能不连通，取的是每一张二分图的左右边的较小值。

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
const int N=1e4+5;
int n, m, c[N], deg[N];
vector<int> p[N];
int c1, c2;
void add(int x,int y) {
	p[x].pb(y), p[y].pb(x);
}
bool dfs(int x,int col) {
	c[x]=col;
	if(col==1) ++c1; else ++c2;
	bool res=1;
	for(auto y:p[x]) {
		if(!c[y]) res&=dfs(y,3-col);
		else res&=(c[y]!=col);
	}
	return res;
}
signed main() {
	n=read(), m=read();
	rep(i,1,m) {
		int x=read(), y=read();
		++deg[x], ++deg[y];
		add(x,y);
	}
	int ans=0;
	rep(i,1,n) if(!c[i]) {
		c1=c2=0;
		if(!dfs(i,1)) { puts("Impossible"); return 0; }
		ans+=min(c1,c2);
	}
	printf("%lld\n",ans);
	return 0;
}
```

### luogu1155 [NOIP2008 提高组] 双栈排序

考虑什么情况下，两个元素不能在用一个栈中。注意不一定是同时，先后进栈也算。

不难发现 $i,j$ 不能在同一个栈中，当且仅当存在 $(i,j,k)$，满足 $i<j<k$，$a_k <a_i < a_j$。

考虑在 $i,j$ 之间连边，表示二者不能用同一个栈，那么有解当且仅当这张图是二分图。

考虑如何构造方案。

对图黑白染色，编号小的点贪心染白色，同时规定第一个栈是白色栈。

维护一个全局变量 $now$ 表示下一个应该放哪个元素，从 $1$ 到 $n$ 扫一遍，对于一个将要加入的 $a_i$，维护它所在颜色的栈中元素单调递增，同时判断栈顶是否是 $now$，如果不是就输出另一个栈的栈顶。

由于白色栈的操作优先级都要高于黑色栈，所以在加入 $a_i$ 之前，应该输出白栈的栈顶直到不是 $now$。

最后输出剩下的元素，贪心白色栈即可。

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
int n, now=1, a[N], suf[N], c[N];
vector<int> p[N];
void add(int x,int y) {
	p[x].pb(y), p[y].pb(x);
}
bool dfs(int x,int col) {
	c[x]=col;
	bool res=1;
	for(auto y:p[x]) {
		if(!c[y]) res&=dfs(y,3-col);
		else res&=(c[y]!=col);
		if(!res) return 0;
	}
	return 1;
}
stack<int> s[3];
bool check(int col) {
	return s[col].size()&&s[col].top()==now;
}
void out(int col) {
	s[col].pop();
	++now;
	if(col==1) printf("b ");
	else printf("d ");
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read();
	suf[n]=a[n];
	per(i,n-1,1) suf[i]=min(suf[i+1],a[i]);
	rep(i,1,n) rep(j,i+1,n-1) {
		if(suf[j+1]<a[i]&&a[i]<a[j]) add(i,j);
	}
	rep(i,1,n) if(!c[i]) {
		if(!dfs(i,1)) { puts("0"); return 0; }
	}
	rep(i,1,n) {
		while(s[c[i]].size()&&s[c[i]].top()<=a[i]) {
			if(check(c[i])) out(c[i]);
			else out(3-c[i]);
		}
		while(check(1)) out(1);
		s[c[i]].push(a[i]);
		if(c[i]==1) printf("a "); else printf("c ");
	}
	while(s[1].size()||s[2].size()) {
		if(check(1)) out(1);
		else if(check(2)) out(2);
	}
	return 0;
}
 
```

### luogu1285 队员分组

老题，从其他 OJ 扒来的换皮题，但是质量意外的高啊。

预处理出所有不互相认识的人，他们一定不能在同一组。在他们之间连边，发现如果有解当且仅当连出的图是二分图。

题目要求最小化两组人数之差，但是多个连通块一起考虑显然很难做。这时候可以利用连通块之间相对独立的性质，对每个连通块单独考虑，同时只有单独一个连通块的分组方法是确定的。

这时候我们能发现，每个连通块有两种颜色，每个颜色的所有点都必须一起选择，但是不同连通块的不同颜色却可以分到同一组。因此问题转化为分组背包。

设 $f(i,j)$ 为考虑前 $i$ 个连通块，能否选择 $j$ 个点。转移是平凡的，同时记录到达 $f(i,j)$ 的最后一个决策是选择的哪个颜色。

设连通块个数为 $m$。

分成两组，必然有一组人数不超过 $n / 2$。找到 $f(m,i)$ 中满足 $j \le n/2$ 且 $f(n,j)=1$ 的极大的 $j$，这就是人数较少那组的人数了。

此时我们就可以利用记录的决策输出方案了。

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
const int N=105;
int n, a[N][N], col[N];
int cnt;
vector<int> p[N], con[N][2], ans[2];
int f[N][N], op[N][N];
void add(int x,int y) {
	p[x].pb(y), p[y].pb(x);
}
void input() {
	n=read();
	rep(i,1,n) {
		int j;
		do {
			j=read();
			a[i][j]=1;
		} while(j);
	}
}
void build() {
	rep(i,1,n) rep(j,1,n) if(i!=j) {
		if(!a[i][j]||!a[j][i]) add(i,j);
	}
}
bool dfs(int x,int color) {
	col[x]=color;
	con[cnt][col[x]].pb(x);
	int res=1;
	for(auto y:p[x]) {
		if(~col[y]) res&=(col[y]!=col[x]);
		else res&=dfs(y,col[x]^1);
		if(!res) return 0;
	}
	return 1;
}
void getcol() {
	SET(col,-1);
	rep(i,1,n) if(col[i]<0) {
		++cnt;
		if(!dfs(i,0)) { puts("No solution"); exit(0); }
	}
}
#define sz(x) con[i][x].size()
void getans(int i,int j) {
	if(i<1) return;
	for(auto x:con[i][op[i][j]]) ans[0].pb(x);
	for(auto x:con[i][op[i][j]^1]) ans[1].pb(x);
	getans(i-1,j-sz(op[i][j]));
}
void dp() {
	
	f[0][0]=1;
	rep(i,1,cnt) rep(j,0,n) {
		if(j>=sz(0)&&f[i-1][j-sz(0)]) f[i][j]=1, op[i][j]=0;
		if(j>=sz(1)&&f[i-1][j-sz(1)]) f[i][j]=1, op[i][j]=1;
        // 都可以的话0/1随便取一个
	}
	int j=0;
	for(int i=n/2;i;--i) if(f[cnt][i]) { j=i; break; }
	getans(cnt,j);
	
}
void output() {
	sort(ans[0].begin(),ans[0].end());
	sort(ans[1].begin(),ans[1].end());
    // 注意输出要排序
	printf("%lld ",(int)ans[0].size());
	for(auto x:ans[0]) printf("%lld ",x);
	puts("");
	printf("%lld ",(int)ans[1].size());
	for(auto x:ans[1]) printf("%lld ",x);
}
signed main() {
	input();
	build();
	getcol();
	dp();
	output();
	return 0;
}

```

