---
title: 「NOIP Record」#4 多项式哈希与异或哈希
pubDate: 2023-05-07
tags:
  - 多项式哈希
  - 异或哈希
  - 树论
  - 树上倍增
  - 分块
categories:
  - Record
description: '少年打磨出了自己的罗盘'
---

## 多项式哈希

把元素看作数字，把哈希对象看作关于 $P$ 的多项式，得到多项式哈希，亦称为进制哈希。

主要用于有序对象的哈希。

一般使用`unsigned long long`自然溢出，相当于对 $2^{64}$ 取模。

关于 $P$ 的选取，尽量避免常用的大质数。下文统一使用`1610612741`，其在 $[2^{30},2^{31}]$ 中。



```cpp
void geth(char* s) {
	n=strlen(s+1);
	for(int i=2;i<=n;++i) h[i]=h[i-1]*P+S[i]-'a'+1;
}
```

### 区间哈希

$h_r$ 为 $[1,r]$ 的哈希值。如何得到 $[l,r]$ 的哈希值？在 $h_r$ 中，$h_{l-1}$ 乘了 $r-l+1$ 个 $P$ 且与 $[l,r]$ 中的元素无关，因此
$$
h_{l,r} = h_r - h_{l-1} \cdot P^{r-l+1}
$$
预处理 $P$ 的幂次即可。

```cpp
uint getlr(int l,int r) {
	return h[r]-h[l-1]*PP[r-l+1];
}
```

### 删除操作

询问 $[l,r]$ 中删去位置 $k$ 上的字符后，$[l,r]$ 的哈希值。

删掉 $k$，那么 $[k+1,r]$ 的字符就会向左移动一位。

考虑两个子串拼凑成的串的哈希值如何由它们二者得到。只要把 $[l,k-1]$ 右移到 $r$ 的位置，做加法即可。移动的距离是 $r-1-(k-1)=r-k$。

```cpp
uint getdel(int l,int r,int k) {
	return getlr(l,k-1)*P[r-k]+getlr(k+1,r);
}
```

### 应用

这个能干啥呢？

可以求 $\texttt{palindrome}$，$\texttt{border}$，$\texttt{LCP}$ 啥的小东西，复杂度一般接近那些算法，也就是一定程度上代替部分字符串算法。

但是不展开讲了。

### luogu7469 [NOI Online 2021 提高组] 积木小赛

>给定两个长度为 $n$ 的字符串 $S,T$，求 $T$ 中一段区间与 $S$ 的任意子序列的匹配数量。两个匹配不同当且仅当字符串本质不同。
>
>$n \le 3000$。

预处理一个东西，$nxt_{i,j}$ 表示 $S[i+1,n]$ 中最靠左的字符 $j$ 的下标。

枚举 $T$ 中的区间左端点 $i$，按照 $nxt_{i,j}$ 扩展右端点即可。如果找不到要匹配的字符，就结束匹配。

对于去重，使用区间哈希即可。

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
const int N=3005, P=1610612741;
int n, nxt[N][30];
uint h[N], PP[N];
char s[N], t[N];
vector<uint> ans;
int id(char c) { return c-'a'+1; }
void geth() {
	PP[0]=1;
	for(int i=1;i<=n;++i) PP[i]=PP[i-1]*P, h[i]=h[i-1]*P+id(t[i]);
}
uint getlr(int l,int r) {
	return h[r]-h[l-1]*PP[r-l+1];
}
signed main() {
	n=read();
	scanf("%s%s",s+1,t+1);
	geth();
	rep(i,1,26) nxt[n][i]=-1;
	nxt[n][id(s[n])]=n;
	for(int i=n-1;i;--i) {
		rep(j,1,26) nxt[i][j]=nxt[i+1][j];
		nxt[i][id(s[i])]=i;
	}
	for(int i=1;i<=n;++i) {
		int pos=1, cnt=0;
		for(int j=i;j<=n;++j) {
			if(nxt[pos][id(t[j])]==-1) break;
			pos=nxt[pos][id(t[j])]+1;
			ans.emplace_back(getlr(i,j));
			++cnt;
			if(pos>n) break;
		}
	}
	int cnt=1;
	sort(ans.begin(),ans.end());
	for(int i=1;i<ans.size();++i) if(ans[i]!=ans[i-1]) ++cnt;
	printf("%lld\n",cnt);
}
```



### luogu7114 [NOIP2020] 字符串匹配

NOIP 多少年来第一道字符串题。~~也希望是最后一道~~。

这里采用哈希做法。

枚举 $i$，表示 $AB = S[1,i]$。然后倍增地找到最大的 $k$，满足 $(AB)^q$ 合法，设 $(AB)^q = S[1,p]$。

那么 $C$ 一定是 $S[p+1,n]$ 前面有奇数个或偶数个 $AB$。不难发现有偶数个 $AB$ 时，其 $F$ 值必然相同，因此只需要多考虑奇数个的情况，取 $S[p-i+1,n]$ 即可。

对于一个 $(p,q)$，放偶数个 $AB$ 的情况有 $c_0=\lceil \frac{q}{2} \rceil$ 种，奇数个有 $c_1=q-c_0$ 种。注意特判 $p=n$ 时，不能放 $0$ 个 $AB$，所以此时 $c_0$ 减去 $1$，后缀需要取 $S[p-2i+1]$。还可能存在 $p-2i+1<i$，这是不合法的。

upd：上面说的过于繁琐，重构后的代码中这部分比较简洁，现在没时间就不改了，以后再说。

设放偶数个 $AB$ 对应的 $F$ 值为 $p_0$，奇数个为 $p_1$。贡献就是
$$
c_0 \times \sum_{j=1}^{i-1} [F(S[1,j])\le p_0] + c_1 \times \sum_{j=1}^{i-1}[F(S[1,j]) \le p_1]
$$
树状数组维护即可。复杂度 $O(n \log_2 n)$。

比 $z$ 函数做法慢很多，但是好想且不容易写错。另外还存在哈希+调和级数枚举做法，但是笔者把这份倍增代码改为上述做法后，在洛谷上 TLE 了。可能是人傻常数大吧。

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
const int N=1048600;
const uint P=1610612741;
int T, n;
int pre[N], suf[N], v[28];
char s[N];
uint pw[N], h[N], f[N][21];
uint getlr(int l,int r) {
    return h[r]-h[l-1]*pw[r-l+1];
}
void prework() {
    SET(v,0);
    rep(i,1,n) {
        int a=s[i]-'a'+1;
        ++v[a];
        if(v[a]&1) pre[i]=pre[i-1]+1;
        else pre[i]=pre[i-1]-1;
        f[i][0]=h[i]=h[i-1]*P+a;
        for(int j=1;j<=20&&i*(1<<j)<=n;++j) f[i][j]=f[i][j-1]*pw[i*(1<<(j-1))]+f[i][j-1];
    }
    suf[n+1]=0;
    SET(v,0);
    per(i,n,1) {
        int a=s[i]-'a'+1;
        ++v[a];
        if(v[a]&1) suf[i]=suf[i+1]+1;
        else suf[i]=suf[i+1]-1;
    }
}
struct BIT {
    int c[N];
    void clear() { rep(i,1,n+1) c[i]=0; }
    void upd(int x,int d) {
        ++x;
        for(;x<=n+1;x+=x&-x) c[x]+=d;
    }
    int query(int x) {
        int res=0;
        ++x;
        for(;x;x-=x&-x) res+=c[x];
        return res;
    }
} bit;
PII calc(int x) {
    int res=0, e=0;
    for(int i=20;~i;--i) if(x+res+x*(1<<i)<=n) {
        if(getlr(x+res+1,x+res+x*(1<<i))==f[x][i]) {
            res+=x*(1<<i);
            e+=1<<i;
        } 
    }
    return MP(res,e);
}
int ceil(int x,int y) { return (x+y-1)/y; }
void solve() {
    scanf("%s",s+1);
    n=strlen(s+1);
    prework();
    int ans=0;
    bit.clear();
    bit.upd(pre[1],1);
    for(int i=2;i<n;++i) {
        PII t=calc(i);
        int lim=i+t.fi, e=t.se+1;
        if(lim==n) lim-=i, --e;
        ans+=ceil(e,2)*bit.query(suf[lim+1]);
        ans+=(e/2)*bit.query(suf[lim-i+1]);
        bit.upd(pre[i],1);
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    pw[0]=1;
    for(int i=1;i<=(1<<20);++i) pw[i]=pw[i-1]*P;
    while(T--) solve();
    return 0;
}
```

### luogu9399 「DBOI」Round 1 人生如树

由于多项式哈希基于多项式，所以它满足多项式运算的性质，且它基于有序结构，能保证元素的顺序。

对于一个询问，如果我们能把路径上的点的哈希值搞出来，那么就能判断 $H(b) - H(a)$ 与 $H(\{1,2,\ldots \})$ 是否相等，进而回答询问。直接都弄出来是做不了的，可以二分长度。

考虑到效率问题，我们要用倍增维护树上哈希值。对于一个 $x$，如果只维护倍增时以它为 $0$ 次项的信息，那么我们很难把到 $\operatorname{LCA}$ 的两条路径接起来，因此要额外维护一个以 $x$ 为最高次项的时候的信息。最高此项可以在倍增合并时往后推。

如果把起点 $x$ 当作 $0$ 次项，那么在从 $y$ 那一条链上倍增时必须让这条链上的次数从下往上递减，这又会造成 $z=\operatorname{LCA}(x,y)$ 下面那个点的次数比 $z$ 的次数大，从而涉及除法。

解决方案是把 $x$ 当作最后一项（一般都是这么做的），这样 $z$ 下面那个点的次数一定是  $1$。

同时正整数序列的哈希值
$$
h_n = \sum_{i=1}^n i \times P^{n-i}
$$
~~这是个卷积~~。

考虑 $h_n$ 的生成函数 $H(z)$， 能发现
$$
H(z) = \frac{1}{(1-z)^2} \frac{z}{1-Pz}
$$
对 $\Big \langle 0,1,P,P^2,P^3 \ldots \Big\rangle$ 做两遍前缀和即可。

注意到修改只会添加叶子，对询问没有影响，直接离线。

注意查询的细节。

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
const uint BASE=1610612741;
int n, m, s, idx, w[N], dep[N], f[N][20];
int x1, y11, x2, y2, z1, z2;
vector<int> p[N];
uint g[2][N][20], pw[N], res[N];
struct Q {
	int x1, y1, x2, y2;
};
vector<Q> q;
void init() {
	pw[0]=res[1]=1, res[0]=0;
	rep(i,1,s) pw[i]=pw[i-1]*BASE;
	rep(i,2,s) res[i]=res[i-1]+pw[i-1];
	rep(i,2,s) res[i]+=res[i-1];
}
void dfs(int x,int fa) {
	f[x][0]=fa, dep[x]=dep[fa]+1;
	g[0][x][0]=g[1][x][0]=w[x];
	for(int i=1;i<=18&&f[x][i-1];++i) {
		f[x][i]=f[f[x][i-1]][i-1];
		g[0][x][i]=g[0][x][i-1]*pw[1<<(i-1)]+g[0][f[x][i-1]][i-1];
        // x在(2^i-1)次项
		g[1][x][i]=g[1][x][i-1]+g[1][f[x][i-1]][i-1]*pw[1<<(i-1)];
        // x在0次项
	}
	for(auto y:p[x]) if(y!=fa) dfs(y,x);
}
int lca(int x,int y) {
	if(dep[x]<dep[y]) swap(x,y);
	for(int i=18;~i;--i) if(dep[f[x][i]]>=dep[y]) x=f[x][i];
	if(x==y) return x;
	for(int i=18;~i;--i) if(f[x][i]!=f[y][i]) x=f[x][i], y=f[y][i];
	return f[x][0];
}
uint get(int x,int y,int z,int d) {
	uint ans=0;
	for(int i=18;~i;--i) if(d>=(1<<i)&&dep[x]-dep[z]+1>=(1<<i)) {
		ans=g[0][x][i]+ans*pw[1<<i];
		d-=(1<<i), x=f[x][i];
	}
	if(d>0) {
		for(int i=18;~i;--i) if(dep[y]-dep[z]>=(1<<i)+d) y=f[y][i];
        // 跳到足够高的位置
		vector<PII> v;
		for(int i=18;~i;--i) if(d>=(1<<i)&&dep[y]-dep[z]>=(1<<i)) {
            // 这条链的开头是z在y这条链的儿子处
		    d-=(1<<i);
			v.pb(MP(g[1][y][i],1<<i)), y=f[y][i];
		}
		reverse(v.begin(),v.end());
		for(auto t:v) ans=t.fi+ans*pw[t.se];
	}
	return ans;
}
bool check(int x) {
	if(get(x2,y2,z2,x)-get(x1,y11,z1,x)!=res[x]) return 0;
	return 1;
}
signed main() {
	n=s=read(), m=read(), idx=read();
	rep(i,1,n) w[i]=read();
	rep(i,1,n-1) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	while(m--) {
		int op=read();
		if(op==1) {
			int x1=read(), y1=read(), x2=read(), y2=read();
			q.pb((Q){x1,y1,x2,y2});
		} else {
			int u=read(), ww=read();
			++s, w[s]=ww, p[u].pb(s), p[s].pb(u);
		}
	}
	init();
	dfs(1,0);
	for(auto t:q) {
		x1=t.x1, y11=t.y1, x2=t.x2, y2=t.y2;
		z1=lca(x1,y11), z2=lca(x2,y2);
		int l=0, r=min(dep[x1]+dep[y11]-2*dep[z1],dep[x2]+dep[y2]-2*dep[z2])+1;
		while(l<r) {
			int mid=(l+r+1)>>1;
			if(check(mid)) l=mid; else r=mid-1;
		}
		printf("%lld\n",l);
	}
}
```



## 异或哈希

异或哈希，一种 Trick。

主要用于无序对象的哈希。

异或哈希一般使用随机权值，同时用异或运算作为链接不同哈希结构之间的桥梁。

相比于按位与、按位或运算，异或运算有着如下优势。

1. 大规模与运算后 $0$ 和 $1$ 的数量比接近 $3 : 1$，或运算反之。而异或运算接近 $1 : 1$。
2. 异或运算的逆运算是异或运算，这意味着容易得到若干子段的信息。

相比于多项式哈希，它更不容易被卡，且其本身的碰撞概率也相当小。

异或本身能做关于奇偶的一些东西以及「截取子段操作」，而异或哈希的主要作用是解决**无序**元素的**存在性问题**。

### ABC250E Prefix Equality

>给定长度为 $n$ 的两个序列 $a,b$，$q$ 个询问。每次询问 $a$ 的前 $x$ 项与 $b$ 的前 $y$ 项，扔进两个不可重集合中后，两个集合是否相同。
>
>$n,q \le 2 \times 10^5$，$a_i,b_i \in [1,10^9]$。

给每个元素 $k$ 一个随机权值 $h_k$。然后对于每个 $[1,i]$，求出 $a$ 与 $b$ 中，只出现了一次的数的权值异或和。这样就能 $O(1)$ 回答询问了。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=2e5+5, BASE=13331;
int n, m, q, cnt, a[N], b[N], t[N<<1];
unsigned aa[N], bb[N];
unordered_map<int,int> p, pa, pb;
mt19937 rd(time(0));
unsigned int fp(int a,int b) {
	unsigned int c=1;
	for(;b;a=a*a,b>>=1) if(b&1) c=c*a;
	return c;
}
signed main() {
	n=read();
	rep(i,1,n) {
		a[i]=read();
		if(p[a[i]]==0) p[a[i]]=rd();
	}
	rep(i,1,n) {
		b[i]=read();
		if(p[b[i]]==0) p[b[i]]=rd();
	}
	unsigned int sa=0, sb=0;
	rep(i,1,n) {
		if(++pa[a[i]]==1) pa[a[i]]=1, sa^=p[a[i]];
		if(++pb[b[i]]==1) pb[b[i]]=1, sb^=p[b[i]];
		aa[i]=sa, bb[i]=sb;
	}
	q=read();
	while(q--) {
		int x=read(), y=read();
		puts(aa[x]==bb[y]? "Yes":"No");
	}
}
```

### 某模拟赛题

>给定一棵 $n$ 个点的树，带边权。对于一个点对 $(u,v)$，可以生成如下游戏：提取二者路径上的所有边权到一个可重集合 $S$，执行两个步骤。
>
>1. 先手第一次取走一个数。
>
>2. 记上一个人取走的数的值为 $x$，当前的人需要从 $S$ 中取走一个不大于 $x$ 的数。不能进行操作的人输。
>
>问有多少无序点对满足先手必胜。
>
>$n \le 5 \times 10^5$。

先手必胜的充要条件是存在一种边权出现了奇数次，容易归纳证明。

给每个边权一个随机权值，求出根到 $x$ 的路径异或和 $d_x$，这样就能把两点之间的路径拆成从根出发的两条路径，如果 $d_x \neq d_y$，那么 $x$ 与 $y$ 路径上一定存在出现奇数次的边权。

直接随机数竟然过不去……

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=5e5+5, BASE=13331;
int T, n, cnt;
int tot, h[N], to[N<<1], nxt[N<<1];
unsigned int w[N<<1], d[N];
unordered_map<int,int> mp, p;
mt19937 rd(time(0));
void add(int x,int y,unsigned int z) {
	to[++tot]=y, nxt[tot]=h[x], w[tot]=z, h[x]=tot;
}
void dfs(int x,int fa,unsigned int v) {
	d[x]=d[fa]^v;
	for(int i=h[x];i;i=nxt[i]) {
		int y=to[i];
		if(y==fa) continue;
		dfs(y,x,w[i]);
	}
}
void solve() {
	n=read();
	tot=cnt=0;
	p.clear(), mp.clear();
	rep(i,1,n) h[i]=0;
	rep(i,1,n-1) {
		int x=read(), y=read();
		unsigned int z=read();
		if(mp.count(z)) z=mp[z];
		else mp[z]=rd()*(z+BASE), z=mp[z];
		add(x,y,z), add(y,x,z);
	}
	dfs(1,0,0);
	rep(i,1,n) ++p[d[i]];
	int ans=0;
	rep(i,1,n) ans+=n-p[d[i]];
	printf("%lld\n",ans/2);
}
signed main() {
	int T=read();
	while(T--) solve();
}
```

### NC51463 Graph Games

给每个点一个随机权值 $w_x$，然后就能得到与点 $x$ 相邻的点的异或和 $v_x$。

区间改不好搞，考虑分块。设 $d(i,x)$ 为第 $i$ 块内关于 $x$ 的异或和，整块对 $d$ 打 tag，散块改 $v$，过程是平凡的。

最终 $x$ 的信息就是 $v_x$ 异或上所有有 tag 的 $d(i,x)$。

正确性显然。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define uint unsigned int
#define SET(a,b) memset(a,b,sizeof(a))
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
const int N=1e5+5, M=2e5+5;
int T, n, m, q, a[M];
int t, block, pos[M], L[450], R[450], tag[450];
uint v[N], w[N], d[450][N];
struct edge {
	int x, y;
} e[M];
mt19937 rd(time(0));
void modify(int l,int r) {
	int p=pos[l], q=pos[r];
	if(p==q) {
		rep(i,l,r) {
			int x=e[i].x, y=e[i].y;
			v[x]^=w[y], v[y]^=w[x];
		}
		return;
	}
	rep(i,p+1,q-1) tag[i]^=1;
	rep(i,l,R[p]) {
		int x=e[i].x, y=e[i].y;
		v[x]^=w[y], v[y]^=w[x];
	}
	rep(i,L[q],r) {
		int x=e[i].x, y=e[i].y;
		v[x]^=w[y], v[y]^=w[x];
	}
}
void solve() {
	n=read(), m=read();
	block=sqrt(m);
	t=m/block;
	rep(i,1,t) L[i]=R[i-1]+1, R[i]=i*block;
	if(R[t]<m) ++t, L[t]=R[t-1]+1, R[t]=m;
	rep(i,1,t) {
		tag[i]=0;
		rep(j,1,n) d[i][j]=0;
	}
	rep(i,1,n) w[i]=rd(), v[i]=0;
	rep(i,1,m) {
		e[i].x=read(), e[i].y=read();
		int x=e[i].x, y=e[i].y;
		v[x]^=w[y];
		v[y]^=w[x];
		pos[i]=(i-1)/block+1;
		d[pos[i]][x]^=w[y];
		d[pos[i]][y]^=w[x];
	} 
	q=read();
	while(q--) {
		int op=read(), l=read(), r=read();
		if(op==1) modify(l,r);
		else {
			int vx=v[l], vy=v[r];
			rep(i,1,t) {
				if(tag[i]) vx^=d[i][l], vy^=d[i][r];
			}
			printf(vx==vy? "1":"0");
		}
	}
	puts("");
}
signed main() {
	T=read();
	while(T--) solve();
}
```



### CF1175F The Number of Subpermutations

>给定一个序列，求这个序列中有多少区间 $[l,r]$ 是 $1 \sim r-l+1$ 的一个排列。
>
>$n \le 3 \times 10^5$。

给每个 $i$ 分配一个随机权值 $h_i$，得到 $base_i = \bigoplus_{j=1}^i h_i$，那么 $base_i$ 就是 $1 \sim i$ 的排列的哈希值。

一个排列中一定包含一个 $1$。设 $j$ 为从上一个 $1$ 的位置到 $i$ 中的最大值，初始或遇到 $a_i=1$ 时，$j=1$。如果 $i \ge j$ 并且 $\bigoplus_{k=i-j+1}^i h_{a_k} = base_j$，那么说明 $[i-j+1,i]$ 是一个排列。

这样只得到了排列的最大值在 $1$ 右边的情况。反过来再枚举一遍即可。

注意如果 $a_i=1$，那么 $[i,i]$ 也是排列。

### CF869E The Untended Antiquity

>给定一个 $n \times m$ 的网格图，有 $q$ 次操作。
>
>1. 在左上角为 $(x_1,y_1)$，右下角为 $(x_2,y_2)$ 的矩形四边上修建围墙。
>2. 删除左上角为 $(x_1,y_1)$，右下角为 $(x_2,y_2)$ 的矩形四边上修建围墙。保证此围墙存在。
>3. 查询从 $(x_1,y_1)$ 出发是否存在路径，满足不跨越任何围墙就能到达 $(x_2,y_2)$。
>
>**保证围墙无重合处。**
>
>$n,m \le 2500$，$q \le 10^5$。

如果能够到达，那么 $(x_1,y_1)$ 与 $(x_2,y_2)$ 一定在同一个围墙内（把整个网格图外围也看做有围墙），否则一定不能。

对于一个围墙，给它一个随机权值，用二维差分的方式做区间异或。只要查询 $(x_1,y_1)$ 与 $(x_2,y_2)$ 的前缀异或值是否相等，就能判断是否有围墙包含了二者其中之一。

### luogu4065 [JXOI2017]颜色

对于一种颜色 $c$，将所有 $a_i=c$ 的位置 $i$ 都随机映射一个权值，特别地，最靠右的 $i$ 的权值是前面的异或和。

这样直接扫一遍，记录当前 $i$ 的异或和 $S$，如果之前也存在异或和为 $S$ 的一个 $j$，那么 $[j+1,i]$ 就是一段异或和为 $0$ 的区间。根据上文的讨论可知，如果异或和为 $0$，那么这一段中的颜色 $c$ 一定满足不存在 $a_k=c$ 使得 $k\le j$ 或 $k > i$，是满足条件的。

维护一个`std::unordered_map`即可。

与上题相同，是利用异或差分与异或前缀和来完成类似区间覆盖的操作。

### luogu8819 [CSP-S 2022] 星战

>给定一个 $n$ 点 $m$ 边的有向图，有 $q$ 次操作。
>
>1. 删掉一条边 $(u,v)$，保证这条边存在。
>2. 删掉 $u$ 所有的入边。
>3. 添加一条边 $(u,v)$，保证这条边是曾经存在且被删掉的。
>4. 添加 $u$ 所有被删掉且此时不存在的入边。
>
>每次操作后，询问这张图是不是一个内向树森林。
>
>$n,m,q \le 5 \times 10^5$。

考虑什么时候一张图是内向树森林。

发现这玩意没啥强力的性质……

1. $n$ 点 $n$ 边。
2. 每个点有且仅有一条出边。
3. 满足上述两个条件的有向图必然是内向树森林，证明是平凡的。也就是说这两个性质同时成立就充要了，可以考虑从这里下手。

第一个条件容易维护，考虑第二个。

直接做会干到 $O(nq)$。

深入思考，我们能发现如果满足第二个条件，那么每个点的入点集合 $in_x$ 之并就是 $1 \sim n$ 所有节点。而由于我们维护了第一个条件，所以这个条件只需要判掉一种情况：$n$ 点 $n$ 边，但是有节点没有出边。没有出边，这个点就一定不在 $in_x$ 的并里面。

如何快速维护这个东西？使用异或哈希即可完成 $O(1)$ 改查。

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
const int N=5e5+5;
int n, m, q;
uint U, S, base[N], in[N], icnt[N], cui[N], ccnt[N];
// base是随机权值，in是入点集合，icnt是入边数量
// cui是被摧毁的入点集合，ccnt是其数量
mt19937 rd(time(0));
signed main() {
	n=read(), m=read();
	rep(i,1,n) base[i]=(uint)rd()*(i+rd()), U^=base[i];
    // U是1~n之并
	rep(i,1,m) {
		int x=read(), y=read();
		in[y]^=base[x], S^=base[x];
		++icnt[y];
	}
	q=read();
	while(q--) {
		int op=read(), u=read();
		if(op==1||op==3) {
			int v=read();
			in[v]^=base[u], cui[v]^=base[u], S^=base[u];
			if(op==1) --icnt[v], ++ccnt[v], --m; else ++icnt[v], --ccnt[v], ++m;
		} else if(op==2) m-=icnt[u], cui[u]^=in[u], ccnt[u]+=icnt[u], S^=in[u], in[u]=0, icnt[u]=0;
		else m+=ccnt[u], icnt[u]+=ccnt[u], in[u]^=cui[u], S^=cui[u], cui[u]=0, ccnt[u]=0;
		if(m==n&&S==U) puts("YES"); else puts("NO");
	}
}
```





