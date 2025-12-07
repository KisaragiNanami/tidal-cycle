---
title: 「NOIP Record」#8 搜索剪枝与记忆化搜索
pubDate: 2023-07-14
tags:
  - 搜索
  - 状态压缩
  - DP
categories: Record
description: '少年不怕从头开始'
---

## 搜索剪枝

纯搜索剪枝题很少，早就融入各种搜索之中了。

但是在各种多项式时间的搜索里，剪枝仍然是重要的。

目前只有一道题，以后看情况加。

### luogu1120 小木棍

能注意到长度一定是所有木棍总和的倍数，并且至少是 $\max\{a_i\}$，所以只对这部分搜索就行。

设`dfs(cnt,len,lst)`表示当前还剩下 $cnt$ 根木棍要拼接，当前木棍剩余长度为 $len$ ，使用的上一根木棍长度为 $lst$ 的情况下，能否搜到答案。

枚举每根木棍选不选的复杂度过高，但是也没有其他好办法，所以尝试剪枝。

1. 如果使用长度为 $a_i$ 的木棍搜不到答案，那么直接尝试另一种长度。
2. 长度小的木棍更灵活，产生的状态数必然更多，也更容易在剩余长度小时找到答案，所以改变搜索顺序，优先搜索长度大的。
3. 如果当前使用的木棍长度等于  $len$ 且仍然搜不到答案，那么直接返回无解。

这样就来到了一个玄学复杂度，能够通过。

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
#define psb push_back
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
const int N=70;
int n, len, s, a[N], c[N], pre[N];
bool dfs(int cnt,int le,int st) {
	if(le==0) { return dfs(cnt-1,len,a[n]); }
	if(cnt==0) return 1;
	st=min(st,le);
  	// 长度不能大于le
	while(st&&!c[st]) --st;
	while(st) {
		if(c[st]) {
			--c[st];
			int fg=dfs(cnt,le-st,st);
			++c[st];
			if(((le==st)||(le==len))&&!fg) return 0;
            // 3
			else if(fg) return 1;
			st=pre[st];
            // 1
		} else st=pre[st];
	}
	return 0;
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read(), ++c[a[i]], s+=a[i];
	sort(a+1,a+n+1); // 2
	rep(i,1,n) if(a[i]!=a[i-1]) pre[a[i]]=a[i-1];
	for(len=a[n];2*len<=s;++len) if(s%len==0) {
		if(dfs(s/len,len,a[n])) { printf("%lld\n",len); exit(0); }
	}
	printf("%lld\n",s);
}

```

## 记忆化搜索

重点，适合用来打部分分。

用来转移状压 DP 也是好的，可以剪掉很多废状态。

记忆化搜索分为两种。

1. 用 DP 的思想，记录自底向上某个状态的最优解或方案数。这样做就相当于用搜索实现 DP，具有 DP 的那些性质，遇到一个已经访问过的状态便可以直接返回。
2. 更接近于对一般搜索的优化，记录到从初始状态到达当前状态的搜索树上的边权和，这样只有当再次搜到这个状态时，当前边权和劣于记录的值，才能直接返回，否则就要更新记录的边权和。效率一般低于前者，且对搜索顺序要求较高。

很多时候都是二者皆可用的，那为啥后者还存在呢？

用 DP 的理论，前者要求记录的状态满足最优子结构性质，后者则只是提取出最优子结构一个子集。一般使用前者。

第 2 种看起来挺没用的，不过它放宽了太多条件，根本不必考虑最优性，直接暴搜就行，在某些时候有奇效，比如可以应用搜索顺序优化。

### luogu3609 [USACO17JAN] Hoof, Paper, Scissor G

要把整个序列划分成至多 $k$ 段，考虑到 $k$ 不大，$O(nk)$ 的 DP 是容易做的。

设 $f(i,k,cur)$ 表示当前在 $i$，分了 $k$ 段，手势是 $cur$ 的最大值。

要么接在后面，要么新开一段。

这个满足最优子结构性质，可以使用第 1 种方法。



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
int n, k, ans, s[N];
int f[N][22][3];
int winwin(int x,int y) {
	if(x==0&&y==1) return 1;
	if(x==1&&y==2) return 1;
	if(x==2&&y==0) return 1;
	return 0;
}
int dfs(int i,int k,int cur) {
	if(i==0) return 0;
	if(f[i][k][cur]) return f[i][k][cur];
	int& res=f[i][k][cur];
	res=dfs(i-1,k,cur)+winwin(cur,s[i]);
	if(k) {
		rep(j,0,2) if(cur!=j) res=max(res,dfs(i-1,k-1,j)+winwin(cur,s[i]));
	}
	return res;
}
signed main() {
	n=read(), k=read();
	rep(i,1,n) {
		char c; scanf(" %c",&c);
		if(c=='H') s[i]=0;
		else if(c=='S') s[i]=1;
		else if(c=='P') s[i]=2;
	}
	rep(i,0,k) rep(j,0,2) ans=max(ans,dfs(n,i,j));
	printf("%lld\n",ans);
}

```



### luogu1278 单词游戏

$n$ 很小，考虑状压 $n$。

设 $f(S,pre)$ 为选了集合 $S$ 中的串，上一个选的串是 $pre$ 的最大值。

然后就做完了。

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
#define psb push_back
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
int n, ans, f[(1<<17)+5][N];
string s[N];
int dfs(int S,int pre) {
	if(f[S][pre]) return f[S][pre];
	int& res=f[S][pre];
	rep(i,0,n-1) if((S&(1<<i))==0) {
		int l=s[pre].size()-1;
		if(!pre||s[pre][l]==s[i+1][0]) {
			res=max(res,dfs(S|(1<<i),i+1)+(int)s[i+1].size());
		}
	}
	return res;
}
signed main() {
	n=read();
	s[0]=" ";
	rep(i,1,n) cin>>s[i];
	printf("%lld\n",dfs(0,0));
}
```

### luogu2476 [SCOI2008] 着色方案

注意到颜色只有 $5$ 种，用典题乌龟棋的做法，记录上一个放的什么颜色即可。

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
#define psb push_back
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
const int N=16, mod=1e9+7;
int k, t[N], f[N][N][N][N][N][6];
int dfs(int a,int b,int c,int d,int e,int lst) {
	if(~f[a][b][c][d][e][lst]) return f[a][b][c][d][e][lst];
	int& res=f[a][b][c][d][e][lst];
	res=0;
	if(a+b+c+d+e==0) return res=1;
	if(a) (res+=(a-(lst==2))*dfs(a-1,b,c,d,e,1)%mod)%=mod;
	if(b) (res+=(b-(lst==3))*dfs(a+1,b-1,c,d,e,2)%mod)%=mod;
	if(c) (res+=(c-(lst==4))*dfs(a,b+1,c-1,d,e,3)%mod)%=mod;
	if(d) (res+=(d-(lst==5))*dfs(a,b,c+1,d-1,e,4)%mod)%=mod;
	if(e) (res+=e*dfs(a,b,c,d+1,e-1,5)%mod)%=mod;
	return res;
}
signed main() {
	k=read();
	rep(i,1,k) ++t[read()];
	SET(f,-1);
	printf("%lld\n",dfs(t[1],t[2],t[3],t[4],t[5],0));
}
```



&nbsp;

另外的，本题相当于是 CF840C 的弱化弱化版。

### luogu8565 Sultan Rage

题目乍一看很可怕。

然而能发现 $\text{Fibonacii}$ 序列应该是题目中序列的一个极小情况，但增长已经是指数级了。也就是说给出的序列在超过 $m$ 的部分里，有用的最多六十多项。



考虑记忆化搜索，设 $f(k,x)$ 为用前 $k$ 项凑成 $x$ 的方案数，转移就是背包。

$x$  这一维很大，但 $m$ 位之后能搞一个进位操作，直觉上数量不是很多，所以可以用`std::unordered_map`实现。对于前 $m$ 项直接用背包处理答案，这部分状态数不会太少。

可以做一些优化。

1. 如果 $x> \sum_{i=1}^k a_i$，那么直接返回 $0$。
2. 如果 $x \le \sum_{i=1}^k a_i$ 并且 $x > \sum_{i=1}^{k-1} a_i$，那么 $a_k$ 就必须选择。

复杂度 $\text{proof by AC}$。

可以就此了解一下 $\text{Zeckendorf ’s theorem}$。

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
#define psb push_back
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
const int N=233, mod=998244353;
int T, n, m, q, a[N], s[N], f[N*100];
unordered_map<int,int> g[N];
int dfs(int x,int k) {
	if(x<0||x>s[k]) return 0;
	if(x==0) return 1;
	if(g[k].count(x)) return g[k][x];
	if(k==n) return g[k][x]=f[x];
	if(x>s[k-1]) g[k][x]=dfs(x-a[k],k-1);
	return g[k][x]=(dfs(x-a[k],k-1)+dfs(x,k-1))%mod;
}
void solve() {
	n=read(), q=read();
	rep(i,1,n) a[i]=read(), s[i]=s[i-1]+a[i], g[i].clear();
	memset(f,0,(s[n]+1)<<3);
	f[0]=1;
	rep(i,1,n) per(j,s[i],a[i]) {
		if(j>=a[i]) (f[j]+=f[j-a[i]])%=mod;
	}
	m=n+1;
	for(;;++m) {
		a[m]=0;
		for(int i=1;i<=n;++i) a[m]+=a[m-i];
		if(a[m]>1e18) break;
	}
	--m;
	rep(i,n+1,m) s[i]=s[i-1]+a[i], g[i].clear();
	while(q--) {
		int x=read();
		printf("%lld\n",dfs(x,m));
	}
}
signed main() {
	T=read();
	while(T--) solve();
}
```

### luogu8658 [蓝桥杯 2017 国 A] 填字母游戏

我们用分别用 $1$，$-1$，$0$ 表示胜利、失败、平局。

对于一个状态 $S$，它的胜负状态可以表示为
$$
f(S) = \max_{S \rightarrow S' }\Big\{-f(S')\Big\}
$$
一旦 $f(S)$ 被更新为 $1$，那就直接返回。

然而极限状态数还是 $O(3^{len})$，无法承受，但是这种东西重叠状态数很大，记忆化的效果很好。状态是字符串，可以用`std::unordered_map<string,int>`实现。

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
const int N=22;
int T, n;
string s;
unordered_map<string,int> p;
int dfs(string st) {
	if(p.count(st)) return p[st];
	for(int i=0;i<st.size()-2;++i) {
		if(st[i]=='L'&&st[i+1]=='O'&&st[i+2]=='L') {
			return p[st]=-1;
		}
	}
	p[st]=-1;
	int cnt=0;
	for(int i=0;i<st.size();++i) {
		if(st[i]=='*') {
			string t=st;
			t[i]='O';
			p[st]=max(p[st],-dfs(t));
			if(p[st]==1) return 1;
			t[i]='L';
			p[st]=max(p[st],-dfs(t));
			if(p[st]==1) return 1;
			++cnt;
		}
	}
	if(cnt==0) p[st]=max(p[st],0ll);
	return p[st];
}
void solve() {
	cin>>s;
	if(s.size()<3) { puts("0"); return; }
	for(int i=0;i<s.size()-2;++i) if(s[i]=='L'&&s[i+1]=='O'&&s[i+2]=='L') { puts("1"); return; }
	printf("%lld\n",dfs(s));
	p.clear();
}
signed main() {
	T=read();
	while(T--) solve();
}
```



### luogu3257 [JLOI2014] 天天酷跑

上古老题了，题面有很多叙述不严谨的地方。

首先能发现不管跳不跳，横坐标每次至少增加 $1$，而跳跃过程是容易刻画的。并且 $m$ 和最多连跳数很小，可以直接枚举。

设 $f(x,y,z)$ 表示在 $(x,y)$，已经连跳了 $j$ 次的最大值。

有一些小细节：

1. 初始点是 $(0,1)$。
2. 注意跳跃的最高点的贡献不要算重。

用记忆化搜索相对容易实现。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
#define psb push_back
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
int n, m, cnt, h, ans=-1e9, cost1, cost2, a[N][22];
int f[N][22][7];
int dfs(int x,int y,int z) {
	if(x>n||y>m||y<1) return 0;
	if(a[x][y]==-1) return -1e9;
	if(~f[x][y][z]) return f[x][y][z];
	int& res=f[x][y][z];
	res=-1e9;
	if(y==1) z=0;
	
	if(z<cnt&&y+h<=m) {
		int sum=0, t=0;
		for(int i=1;i<h;++i) {
			if(a[x+i][y+i]==-1) { t=1; break; }
			sum+=a[x+i][y+i]; 
		}
		if(!t) res=max(res,sum+dfs(x+h,y+h,z+1));
        // a[x][y]放到最后算了，所以这里只算前h-1个的贡献
        // 而且在跳跃完成，下落之前，也是可以连跳的
	}
	if(y==1) res=max(res,dfs(x+1,y,z));
	else res=max(res,dfs(x+1,y-1,z));
	return res+=a[x][y];
}
signed main() {
	n=read(), m=read(), cost1=read(), cost2=read();
	rep(j,1,m) rep(i,1,n) a[i][j]=read();
	int ii=0, hh=0;
	for(cnt=1;cnt<=5;++cnt) {
		for(h=1;h*cnt<m;++h) {
			SET(f,-1);
			int res=dfs(0,1,0)-(h-1)*cost1-(cnt-1)*cost2;
			if(res>ans) ans=res, ii=cnt, hh=h;
		}
	}
	if(ans>=0) printf("%d %d %d\n",ans,ii,hh);
	else puts("mission failed");
}

```

### luogu4962 朋也与光玉

$k$ 很小，考虑状压之。

并且在图上走过的路径长度不会超过 $k$，所以直接枚举起点开搜就行。

设 $f(x,S)$ 表示到达节点 $x$，已经收集的元素集合为 $S$ 时的最短路，可以直接通过。

然而本题重叠状态数不多，这时候如果使用上文提到的第二种记忆化方法，那么就能优化搜索顺序，优先搜索权值小的边，这样就能卡进 400ms。

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
const int N=105;
int n, m, k, U, res, ans=1e9, id, a[N], f[N][1<<13];
vector<PII > p[N];
void dfs(int x,int S,int sum,int dep) {
	if((f[x][S]&&f[x][S]<=sum)) return;
	f[x][S]=sum;
	if(sum>=ans) return;
	if(S==U) { ans=sum; return; }
	if(dep==k) return;
	for(auto t:p[x]) {
		int y=t.fi, z=t.se;
		if(S&(1<<a[y])) continue;
		dfs(y,S|(1<<a[y]),sum+z,dep+1);
	}
}
bool cmp(PII a,PII b) {
	if(a.se!=b.se) return a.se<b.se;
	return a.fi<b.fi;
}
signed main() {
	n=read(), m=read(), k=read();
	U=(1<<k)-1;
	rep(i,1,n) a[i]=read();
	rep(i,1,m) {
		int x=read(), y=read(), z=read();
		p[x].pb({y,z});
	}
	rep(x,1,n) sort(p[x].begin(),p[x].end(),cmp);
	rep(i,1,n) dfs(i,1<<a[i],0,1);
	if(ans!=1e9) printf("%d\n",ans);
	else puts("Ushio!");
}
```

### luogu4796 [BalticOI 2018] 路径

差不多一样的套路，$k$ 很小，设 $f(x,S)$ 为到达节点 $x$，颜色集合为 $S$，还能够产生的路径条数。

注意当 $|S|=1$ 时 $f(x,k)$ 初始值为 $0$，否则为 $1$。

然后就直接做了。

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
const int N=3e5+5;
int n, m, k, U, a[N];
ll ans, f[N][1<<5];
vector<int> p[N];
int lowbit(int x) { return x&-x; }
ll dfs(int x,int S) {
	if(f[x][S]) return f[x][S];
	ll& res=f[x][S];
	res=1;
	if(S==lowbit(S)) res=0;
	if(S==U) return res;
	for(auto y:p[x]) {
		if(S&(1<<a[y])) continue;
		res+=dfs(y,S|(1<<a[y]));
	}
	return res;
}
signed main() {
	n=read(), m=read(), k=read();
	U=(1<<k)-1;
	rep(i,1,n) a[i]=read()-1;
	rep(i,1,m) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	rep(i,1,n) ans+=dfs(i,1<<a[i]);
	printf("%lld\n",ans);
}
```

## 部分分

搜索主要的作用是拿部分分。

### luogu7961 [NOIP2021] 数列

前 10 个点 $m$ 比较小，$S$ 的范围也不会很大，考虑直接设 $f(x,S')$ 表示已经确定了 $\{a_i\}$ 的前 $x$ 项，$S=S'$，还能产生的方案数。
$$
f(x,S') = \sum_{i=0}^m v_i \times f(x+1,S'+2^i)
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
const int N=35, M=105, mod=998244353;
int n, m, k, v[M], f[N][1<<18];
int popcount(int x) {
	int cnt=0;
	while(x) cnt+=x&1, x>>=1;
	return cnt;
}
int dfs(int x,int S) {
	if(~f[x][S]) return f[x][S];
	if(x==n) return f[x][S]=popcount(S)<=k;
	int& res=f[x][S];
	res=0;
	for(int i=0;i<=m;++i) {
		(res+=v[i]*dfs(x+1,S+(1<<i)))%=mod;
	}
	return res;
}
signed main() {
	n=read(), m=read(), k=read();
	rep(i,0,m) v[i]=read();
	SET(f,-1);
	printf("%lld\n",dfs(0,0));
}
```

### luogu8817 [CSP-S 2022] 假期计划

这题官方数据过水，以洛谷数据为准。

用 $n$ 次 $\text{BFS}$ 求出多源最短路。

设 $f(x,cnt)$ 为以 $x$ 结尾，选择了 $cnt$ 个点的最大值。这显然是不满足最优子结构性质的：无法知道已经选过了哪些点。使用第一种记忆化方法显然是错的，而第二种做法在选点情况不同时也无法保证到达 $(x,cnt)$ 且当前值小于 $f(x,cnt)$ 最终不会更新答案。

然而这个竟然能通过 $\mathfrak{CCF}$ 的数据。

事实上这个搜索加上乱搞做法然后极致卡时，就能通过所有数据。不过非正解就不细说了。

下面的代码可以通过官方数据，洛谷数据会 WA 一个。

```cpp
void bfs(int s) {
	queue<int> q;
	rep(i,1,n) dis[s][i]=1e9;
	dis[s][s]=0;
	q.push(s);
	while(q.size()) {
		int x=q.front(); q.pop();
		for(auto y:p[x]) {
			if(dis[s][y]!=1e9) continue;
			dis[s][y]=dis[s][x]+1;
			q.push(y);
		}
	}
}
void dfs(int x,int cnt,int sum) {
	if(f[x][cnt]!=0&&f[x][cnt]>=sum) return;
	int& res=f[x][cnt];
	res=sum;
	if(cnt==5) { ans=max(ans,sum); return; }
	if(cnt==4) {
		if(dis[1][x]<=k+1) dfs(1,5,sum);
		return;
	}
	for(int y=2;y<=n;++y) if(x!=y&&!v[y]&&dis[x][y]<=k+1) {
		v[y]=1;
		dfs(y,cnt+1,sum+a[y]);
		v[y]=0;
	}
}
signed main() {
	n=read(), m=read(), k=read();
	rep(i,2,n) a[i]=read();
	rep(i,1,m) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	rep(i,1,n) bfs(i);
	dfs(1,0,0);
	printf("%lld\n",ans);
}
```

### LOJ#539. 「LibreOJ NOIP Round #1」旅游路线

观察那张大表格。

考虑前 12 个点，发现有 $q_i \le 100$ 和 $C,c_i \le 10^3$，而 $d_i$ 范围相对大。

设 $f(x,qt,ct)$ 表示到达节点 $x$，还剩下 $qt$ 的钱，$ct$ 的油，还能走的最大距离。

这个状态是个 $\text{DAG}$，所以用记忆化搜索转移 DP 即可。
$$
f(x,qt,ct) = \max \begin{cases}
f(y,qt,ct-1)+z  &  ct > 0
\\
f (x,qt-p_x,\min\{ c_x,C\}) & qt \ge p_x \text{ and }  ct < c_x
\end{cases}
$$
对于一个询问 $(s_i,q_i,d_i)$，枚举剩下多少钱，判断是否满足 $d_i$ 的条件即可。

显然具有单调性，可以二分答案优化，不过没必要。

官方题解说这个做法能得到 $60 \text{ pts}$，不过可能是因为数据不给力，实际得分 $75 \text{ pts}$。

复杂度 $\mathcal{O} \Big((n+m)C\max\{q_i\} + Tq_i \Big)$。

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
const int N=105, M=1e5+5;
int n, m, C, T, ww[N][N], p[N], c[N];
int f[N][505][1005];
vector<PII > g[N];
int dfs(int x,int qt,int ct) {
	if(~f[x][qt][ct]) return f[x][qt][ct];
	int& res=f[x][qt][ct];
	res=0;
	if(ct<c[x]&&qt>=p[x]) res=max(res,dfs(x,qt-p[x],min(c[x],C)));
	for(auto t:g[x]) {
		int y=t.fi, z=t.se;
		if(ct) res=max(res,z+dfs(y,qt,ct-1));
	}
	return res;
}
signed main() {
	n=read(), m=read(), C=read(), T=read();
	rep(i,1,n) p[i]=read(), c[i]=read();
	rep(i,1,m) {
		int x=read(), y=read(), z=read();
		ww[x][y]=max(ww[x][y],z);
        // 可能有重边，取最大边权。
	}
	rep(i,1,n) rep(j,1,n) if(ww[i][j]) g[i].pb({j,ww[i][j]});
	SET(f,-1);
	while(T--) {
		int s=read(), q=read(), d=read();
		int ans=-1;
		for(int i=q-1;~i;--i) if(q-i>=p[s]) {
			int t=dfs(s,q-i-p[s],min(c[s],C));
			if(t>=d) { ans=i; break; }
		}
		printf("%lld\n",ans);
	}
}
```

### luogu8163 [JOI 2022 Final] 铁路旅行 2

使用单调队列，我们能求出从每个 $i$ 出发能到达的最左点 $tl_i$ 与最右点 $tr_i$。

一个 $\mathtt{Navie}$ 的结论：任何时候能到达的点都是一个区间，并且这个区间单调扩大。

我们把换乘作为边，边权都是 $1$。在图上 BFS时维护当前区间，维护全局左右端点 $l,r$，对于节点 $i$，将 $[\min(l,tl_i),\max(r,tr_i)]$ 中的节点入队，同时更新 $l$ 为 $\min\{tl_i\}$，$r$ 为 $\max\{tr_i\}$。当终点第一次被 $[l,r]$ 包含时，路径长度就是答案。

这样做的复杂度是 $O(n)$ 的，可以得到 $27 \text{ pts}$。

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
int n, k, m, Q, a[N], b[N], tl[N], tr[N], tl1[N], tr1[N];
int q[N];
bool v[N];
int bfs(int s,int t) {
	rep(i,1,n) v[i]=0;
	queue<PII > q;
	q.push(MP(s,1));
	int l=s, r=s;
	while(q.size()) {
		int x=q.front().fi, y=q.front().se; q.pop();
		if(v[x]) continue;
		v[x]=1;
		if(s<t&&tr[x]>=t) return y;
		if(s>t&&tl[x]<=t) return y;
		for(int i=r+1;i<=tr[x];++i) if(!v[i]) {
			q.push(MP(i,y+1));
		}
		r=max(r,tr[x]);
		for(int i=l-1;i>=tl[x];--i)if(!v[i]) {
			q.push(MP(i,y+1));
		}
		l=min(l,tl[x]);
	}
	return -1;
}
signed main() {
	n=read(), k=read(), m=read();
	rep(i,1,n) tr[i]=tl[i]=tl1[i]=tr1[i]=i;
	rep(i,1,m) {
		a[i]=read(), b[i]=read();
		if(a[i]<b[i]) tr[a[i]]=tr1[a[i]]=max(tr1[a[i]],b[i]);
		else tl[a[i]]=tl1[a[i]]=min(tl1[a[i]],b[i]);
	}
	int l=1, r=0;
	rep(i,1,n) {
		while(l<=r&&q[l]<i-k+1) ++l;
		if(l<=r) tr[i]=max(tr[i],tr1[q[l]]);
		while(l<=r&&tr1[q[r]]<tr1[i]) --r;
		q[++r]=i;
	}
	l=1, r=0;
	per(i,n,1) {
		while(l<=r&&q[l]>i+k-1) ++l;
		if(l<=r) tl[i]=min(tl[i],tl1[q[l]]);
		while(l<=r&&tl1[q[r]]>tl1[i]) --r;
		q[++r]=i;
	}
	Q=read();
	while(Q--) {
		int s=read(), t=read();
		printf("%lld\n",bfs(s,t));
	}
}
```

### luogu9375 「DROI」Round 2 划分

对于 $\text{subtask 1}$，只需要枚举每个数是接在前面还是新开一段，然后扫一遍统计答案，复杂度 $O(n2^n)$。

观察 $\text{subtask 2}$，总的段数 $m$ 不超过 $20$，那么直接把它们状压了，把划分区间放置区间，从前往后放，同时预处理任意区间的答案，复杂度可以做到 $O(m2^m)$。

观察 $\text{subtask 3}$，区间长度最多只有 $5$ 种，数量算一下也不会很多，仿照乌龟棋就能做了。

这就有了 $50 \text{ pts}$。

```cpp
// Problem: P9375 「DROI」Round 2 划分
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P9375
// Author: KisaragiQwQ
// Date: 2023-06-25 15:20:38
// Memory Limit: 128 MB
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
const int N=128, M=1e6+5, NN=1<<21;
int n, ans, m, mx, ss, a[N], c[N], bel[N];
int squ[20005], v[N][N];
namespace sub3 {
	int U, g[NN];
	int dfs(int S) {
		if(~g[S]) return g[S];
		g[S]=0;
		int T=U^S, sum=1;
		for(int i=0;i<m;++i) if(S&(1<<i)) sum+=bel[i];
		for(int i=0;i<m;++i) if(T&(1<<i)&&sum+bel[i]-1<=n) {
			g[S]=max(g[S],dfs(S|(1<<i))+v[sum][sum+bel[i]-1]);
		}
		return g[S];
	}
	void solve() {
		U=(1<<m)-1;
		SET(g,-1);
		printf("%lld\n",dfs(0));
	}
};
namespace sub4 {
	int g[55][26][18][15][15];
	int dfs(int c1,int c2,int c3,int c4,int c5) {
		if(~g[c1][c2][c3][c4][c5]) return g[c1][c2][c3][c4][c5];
		int& res=g[c1][c2][c3][c4][c5];
		res=0;
		int sum=c[1]-c1+2*(c[2]-c2)+3*(c[3]-c3)+4*(c[4]-c4)+5*(c[5]-c5)+1;
		if(c1>0) res=max(res,dfs(c1-1,c2,c3,c4,c5)+v[sum][sum]);
		if(c2>0) res=max(res,dfs(c1,c2-1,c3,c4,c5)+v[sum][sum+1]);
		if(c3>0) res=max(res,dfs(c1,c2,c3-1,c4,c5)+v[sum][sum+2]);
		if(c4>0) res=max(res,dfs(c1,c2,c3,c4-1,c5)+v[sum][sum+3]);
		if(c5>0) res=max(res,dfs(c1,c2,c3,c4,c5-1)+v[sum][sum+4]);
		return res;
	}
	void solve() {
		SET(g,-1);
		g[0][0][0][0][0]=0;
		printf("%lld\n",dfs(c[1],c[2],c[3],c[4],c[5]));
	}
};
void prework() {
	for(int i=0;i*i<=mx;++i) squ[i*i]=1;
	for(int i=1;i<=n;++i) for(int j=i;j<=n;++j) {
		int x=0, y=0;
		for(int k=i;k<=j;++k) {
			if(squ[abs(a[k]-a[i])]) ++x;
			if(squ[abs(a[j]-a[k])]) ++y;
		}
		v[i][j]=x*y;
	}
}
signed main() {
	n=read();
	rep(i,1,n) a[i]=read(), mx=max(mx,a[i]);
	int fg=1;
	rep(i,1,n) {
		c[i]=read(), ss+=i*c[i];
		if((i>5&&c[i]!=0)) fg=0;
		int t=c[i];
		while(t--) bel[m++]=i;
	}
	if(ss!=n) puts("-1"), exit(0);
	prework();
	if(fg) sub4::solve(); else sub3::solve();
	// sub3::solve();
	return 0;
}
```

然而正解就比较人类智慧了。

注意到所有 $c_i$ 构成的一个集合，其中元素的总和是不断变小的，然后放置区间是一个很能 $\text{DP}$ 的过程。假定我们有一种哈希方法能唯一表示一个集合的状态，状态的数量却不是很容易计算，如果数量过多，那么这种做法也就没有意义了。

教练用搜索剪枝和一些奇技淫巧，用时 5 min 跑出了 $n=120$ 的状态总数，我记得好像也就 $10^6$？

貌似用 GF 算一下也行，但是手算有点逆天。

由于每个 $c_i$ 单调不增，所以我们这样进行一个进制哈希。

```cpp
pre[0]=1;
for(int i=1;i<=n;++i) pre[i]=pre[i-1]*(q.c[i]+1);

struct node { int c[N]; } q;

int vary(node x) {
	int id=0;
	for(int i=1;i<=n;++i) id+=x.c[i]*pre[i-1];
	return id;
}
```

记忆化搜索即可。

```cpp
namespace sub2 {
	int dfs(node x) {
		int S=vary(x);
		if(~f[S]) return f[S];
		f[S]=0;
		int sum=0;
		for(int i=1;i<=n;++i) sum+=i*x.c[i];
		if(sum==0) return 0;
		for(int i=1;i<=n;++i) if(x.c[i]>0) {
			node y=x;
			--y.c[i];
			f[S]=max(f[S],dfs(y)+v[sum-i+1][sum]);
		}
		return f[S];
	}
	void solve() {
		printf("%lld\n",dfs(q));
	}
};
```



这部分未完待续。
