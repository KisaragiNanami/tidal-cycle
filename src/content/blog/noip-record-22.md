---
title: 「NOIP Record」#22 贪心（1）
pubDate: 2023-11-12
tags:
  - 贪心
  - 二分答案
  - 树论
  - 决策单调性
  - 单调队列
categories:
  - Record
description: '少年要用双脚与一捧沙子渡海'
---

贪心的基本思路是抹除后效性。 

## luogu9378 [THUPC 2023 决赛] 物理实验

尽可能保留编号小的实验一定是最优的。

考虑维护一个集合 $S$ 表示当前已经确定可以保留的实验集合，枚举实验 $i$ 尝试加入，这样原问题就转化为了 $n$ 轮判定问题。

考虑如何 check。由于确定了 $S$ 并且做 $S$ 以外的实验没有意义，所以我们能求出每一轮应该出局的实验，同时求出第 $i$ 个实验最晚被做完的时间 $lim_i$。

接下来问题转化为：是否存在一个 $1 \sim n$ 的排列，满足 $i$ 所在的位置小于等于 $lim_i$。

按照 $lim$ 递增排序后贪心放即可。

时间复杂度 $O(n^2m)$。

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
#define pb push_back
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
const int N=605;
int n, m, a[N], p[N][N], b[N];
int lim[N];
bool s[N], done[N], out[N];
vector<int> ans;
bool cmp(int x,int y) { return lim[x]<lim[y]; }
bool check() {
    rep(i,1,n) done[i]=out[i]=0, lim[i]=n, b[i]=i;
    rep(i,1,m) {
        int k=0;
        rep(j,1,n) if(!s[p[i][j]]&&!out[p[i][j]]) { k=j; break; }
        if(!k) k=n+1;
        else out[p[i][k]]=1;
        rep(j,1,k-1) if(s[p[i][j]]&&!done[p[i][j]]) lim[p[i][j]]=a[i], done[p[i][j]]=1;
    }
    sort(b+1,b+n+1,cmp);
    rep(i,1,n) if(i>lim[b[i]]) return 0;
    ans.clear();
    rep(i,1,n) if(s[b[i]]) ans.pb(b[i]);
    return 1;
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) a[i]=read();
    rep(i,1,m) rep(j,1,n) p[i][j]=read();
    rep(i,1,n) {
        s[i]=1;
        if(!check()) s[i]=0;
    }
    for(auto x:ans) printf("%d ",x);
    puts("");
    return 0;
}
```

## luogu9209 不灭「不死鸟之尾」

我们能发现对于第 $i$ 辆车，其最小代价是 $W_i - \max(L_i,R_i)(n-i)$，只要我们贴着 $\max(L_i,R_i)$ 对应的那边放就一定能取到这个值。

不难发现如果每次都这样做，那么是没有后效性的，所以答案就是 $\sum_{i=1}^{n} W_i - \max(L_i,R_i)(n-i)$。

## CF1661D Progressions Covering

从后往前扫，如果 $a_i$ 不满足条件，那么就做一次以 $i$ 为右端点的操作。

如何维护？区间加等差数列等于在差分序列上单点加再区间加，那么再差分一次就好了。

用树状数组维护二阶差分序列即可。

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
#define pb push_back
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
int n, k, ans, b[N];
struct BIT {
    int c[N], c2[N];
    void add(int x,int d) {
        for(int i=x;i<=n;i+=i&-i) {
            c[i]+=d, c2[i]+=x*d;
        }
    }
    int query(int x) {
        int res=0;
        for(int i=x;i;i-=i&-i) res+=(x+1)*c[i]-c2[i];
        return res;
    }
} T;
int cil(int x,int y) { return (x+y-1)/y; }
signed main() {
    n=read(), k=read();
    rep(i,1,n) {
        b[i]=read();
        T.add(i,b[i]);
        T.add(i+1,-2*b[i]);
        T.add(i+2,b[i]);
    }
    // op b[l,r] = c1[l,r]-1 c1[r+1]+k = c2[l]-1 c2[r+1]+1 c2[r+1]+k, c2[r+2]-k

    for(int i=n;i;--i) {
        int x=T.query(i);
        if(x>0) {
            int d=0, pos=0;
            if(i>=k) d=cil(x,k), pos=i-k+1;
            else d=cil(x,i), pos=1;
            ans+=d, T.add(pos,-d);
        }
    }
    printf("%lld\n",ans);
    return 0;
}
```

## luogu5749 [IOI2019] 排列鞋子

从左往右扫每一只鞋子，我们都把到能与之配对的距离其最近的鞋子交换过来，容易发现此时代价一定取到了下界。

用`std::vector`储存即可，按顺序扫一遍可以保证其内部也是有序的。不过 vector 在头部操作不是很方便，所以我们倒着做，这样所有操作都是尾部操作。

现在我们需要动态维护任意两点距离，这个可以转化成前缀相减。注意到我们现在只会让鞋子从左往右交换，从而把位置 $p$ 的鞋子向右交换只会影响 $p$ 以及后面的前缀，树状数组轻松维护。

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
#define pb push_back
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
int n, d, ans, a[N];
bool v[N];
vector<int> p[N];
struct BIT {
    int c[N];
    void add(int x,int d) {
        for(;x<=n;x+=x&-x) c[x]+=d;
    }
    int query(int x) {
        int res=0;
        for(;x;x-=x&-x) res+=c[x];
        return res;
    }
} T;
signed main() {
    n=read()<<1;
    d=n>>1;
    rep(i,1,n) {
        a[i]=read();
        T.add(i,1);
        p[a[i]+d].pb(i);
    }
    per(i,n,1) if(!v[i]) {
        v[i]=1;
        p[a[i]+d].pop_back();
        int j=p[(-a[i])+d].back();
        p[(-a[i])+d].pop_back();
        v[j]=1;
        ans+=T.query(i)-T.query(j)-(a[i]>0);
        // a[i]>0，说明其需要在右边，少交换一次
        T.add(j,-1);
    }
    printf("%lld\n",ans);
    return 0;
}
```

## ABC254Ex Multiply or Divide by 2

由于对一个 $a_i$ 乘 $2$ 必然对应 $B$ 中的一个偶数，所以可以看作是 $\lfloor b_i/2 \rfloor$，于是问题转化为只有除法操作，并且所有数都不会变大。

考虑全局最大值 $x$。

- 如果 $A$ 与 $B$ 均包含 $x$，那么直接将其删除。
- 否则如果 $A$ 包含之，那么删除 $x$ 并加入 $\lfloor x/2 \rfloor$。
- 否则如果 $B$ 包含之，若 $2 \mid x$，那么删除 $x$ 并加入 $x/2$；否则无解。

使用优先队列实现，复杂度 $O(n \log n \log V)$。

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
#define pb push_back
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
int n, ans, a[N], b[N];
priority_queue<int> p, q;
signed main() {
    n=read();
    rep(i,1,n) a[i]=read(), p.push(a[i]);
    rep(i,1,n) b[i]=read(), q.push(b[i]);
    while(p.size()) {
        if(p.top()==q.top()) p.pop(), q.pop();
        else if(p.top()>q.top()) {
            int x=p.top();
            p.pop();
            p.push(x>>1);
            ++ans;
        } else if(q.top()%2==0) {
            int x=q.top();
            q.pop();
            q.push(x>>1);
            ++ans;
        }
        else { puts("-1"); exit(0); }
    }
    printf("%lld\n",ans);
    return 0;
}
```

## luogu8945 Inferno

我们填 $1$ 的位置一定是连续的一段 $0$，否则一定不优。

更进一步的，我们可以枚举最大子段和对应的区间左端点 $l$，然后最优解一定是从这个点往后把 $k$ 个 $0$ 修改为 $1$。

设 $pos$ 为这 $k$ 个 $0$ 中最后一个所在的位置，那么我们可以对 $r \in [l,pos]$ 和 $r \in [pos+1,n]$ 两种情况进行讨论。

设 $s_{i,1}$ 为把 $[1,i]$ 中所有的 $0$ 都改为 $1$ 的前缀和，$s_{i,2}$ 为把 $[1,i]$ 中所有 $0$ 都改为 $-1$ 的前缀和。

- $r \in [l,pos]$，此时最大子段和即为 $\max_{i=l}^{pos}\{s_{i,1}\}$。我们能发现，如果 $l$ 增加，那么 $pos$ 递增，单调队列即可做到 $O(1)$ 查询。
- $r \in [pos+1,n]$，此时最大子段和为 $\max_{i=pos+1}^{n} \{s_{i,2}\} + k - s_{l,2}+k$，维护 $s_{i,2}$ 的后缀最大值即可 $O(1)$ 查询。

注意如果放不满 $k$ 个 $1$，那么最大子段和是 $\max_{i=l}^{n} \{ s_{i,1} \} - s_{l,1}$。

复杂度 $O(n)$。

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
const int N=1e7+5;
int n, k, a[N];
int m, pos[N], ls[N], s1[N], s2[N];
int suf1[N], suf2[N];
int q[N];
signed main() {
    n=read(), k=read();
    int lst=0;
    rep(i,1,n) {
        a[i]=read();
        ls[i]=lst;
        s1[i]=s1[i-1], s2[i]=s2[i-1];
        if(a[i]==0) {
            pos[++m]=i;
            lst=m;
            ++s1[i], --s2[i];
        } else s1[i]+=a[i], s2[i]+=a[i];
    }
    suf1[n+1]=suf2[n+1]=-1e9;
    suf1[n]=s1[n], suf2[n]=s2[n];
    for(int i=n-1;i;--i) suf1[i]=max(suf1[i+1],s1[i]), suf2[i]=max(suf2[i+1],s2[i]);
    int l=1, r=0, ans=-1e9;
    int p=1;
    rep(i,0,n) {
        while(l<=r&&q[l]<i) ++l;
        int w=ls[i]+k+1;
        if(w>m) {
            ans=max(ans,suf1[i+1]-s1[i]);
            continue;
        }
        int lim=pos[w];
        ans=max(ans,suf2[lim]-s2[i]+2*k);
        while(p<lim) {
            while(l<=r&&s1[q[r]]<s1[p]) --r;
            q[++r]=p;
            ++p;
        }
        ans=max(ans,s1[q[l]]-s1[i]);
    }
    printf("%lld\n",ans);
    return 0;
}
```

## AGC004D Teleporter

连边 $i \rightarrow a_i$，得到一棵内向树。问题转化为修改一些点的出边，使得每个点与 $1$ 存在距离为 $K$ 的路径。

由于保证初始从任何位置出发都能到达 $1$，说明 $1$ 是环上节点。

首先 $1$ 必须指向 $1$，因为如果存在 $1$ 指向 $x$，同时 $x$ 到 $1$ 的路径经过了 $y$，那么 $y$ 一定不满足条件，注意 $y$ 可以等于 $x$。

那么这就是一棵有向树了，考虑以 $1$ 为根拎起来变成一棵树。

这类在树上有关到指定结构（点、环）距离的相关问题，一般都是按照从叶子到根的拓扑序贪心。

在 $\text{DFS}$ 求出 $f_x$ 表示 $x$ 子树内距离 $1$ 的最远距离和 $dep_x$。如果 $f_x - dep_x =k-1$，那么就把 $x$ 的出边指向 $1$，同时 $f_x$ 置为 $0$。

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
const int N=1e5+5;
int n, k, ans, to[N], dep[N], f[N];
vector<int> p[N];
void dfs(int x,int fa) {
    f[x]=dep[x]=dep[fa]+1;
    for(auto y:p[x]) {
        dfs(y,x);
        f[x]=max(f[x],f[y]);
    }
    if(to[x]!=1&&f[x]-dep[x]==k-1) {
        ++ans;
        f[x]=0;
    }
}
signed main() {
    n=read(), k=read();
    rep(i,1,n) {
        to[i]=read();
        if(i!=1) p[to[i]].pb(i);
    }
    if(to[1]!=1) to[1]=1, ans=1;
    dep[0]=-1;
    dfs(1,0);
    printf("%d\n",ans);
    return 0;
}
```



## luogu8314 [COCI2021-2022#4] Parkovi

不放称没有公园的社区为白点，有公园的社区为黑点。

答案显然是有单调性的，直接二分答案，然后问题转化为求使得任意白点到黑点的最短距离不超过给定值 $lim$ 最少需要几个黑点。

然后确定我们的贪心策略：

- 自底向上。
- 一个点尽可能不放。

由于以上两点，我们需要在 $\text{LCA}$ 处理若干子树的信息。

考虑在 $\text{DFS}$ 的过程中求出当前节点与子树内任意黑点的最短距离 $bla$，然后我们贪心地让其对应的那个黑点去覆盖其它子树内白点。具体的，设 $f_{x,0/1}$ 为 $x$ 与子树内任意黑点的最短路径长度/任意白点的最长路径长度，那么 $bla=\min_{y \in son(x)} \{f_{y,0}+z\}$，然后我们拿着 $bla$ 再遍历一边 $son(x)$，如果 $f_{y,1}+z+bla \le lim$，那么就可以覆盖到 $y$。

唯一可能需要 $x$ 处建立公园的情况，就是存在 $f_{y,1} + z + bla > lim$。我们令 $whi$ 表示上述 $y$ 中 $f_{y,1}+z$ 的最大值，注意如果 $bla>lim$，那么 $x$ 也要算在内，距离可以看作 $0$。

由于我们这样做后 $whi$ 不会达到 $2lim$，所以此时在 $x$ 放置公园就能解决所有问题。但如果 $whi$ 加上 $x$ 与 $fa(x)$ 的权值仍然不超过 $lim$，那么我们可以把这些距离丢给 $fa(x)$ 处理，并且一定不会更劣。注意特判 $x=1$ 的情况，此时只要 $whi \ge 0$ 就要在 $x$ 放。

如果没有在 $x$ 放置，那么 $f_{x,0}=bla$，$f_{x,1} = whi$；否则 $f_{x,0}=0$，$f_{x,1}= -\infty$。

输出方案随便记录一下即可，注意不足 $k$ 需要任选然后补齐。

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
#define pb push_back
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
const int N=2e5+5, inf=0x0f0f0f0f0f0f0f0f;
int n, k, lim, f[N][2];
bool v[N];
vector<int> res, ans;
vector<PII > p[N];
void dfs(int x,int fa,int pre) {
	int bla=inf, whi=-inf;
	for(auto t:p[x]) {
		int y=t.fi, z=t.se;
		if(y==fa) continue;
		dfs(y,x,z);
		bla=min(bla,f[y][0]+z);
	}
	if(bla>lim) whi=0;
	for(auto t:p[x]) {
		int y=t.fi, z=t.se;
		if(y==fa) continue;
		if(f[y][1]+z+bla>lim) whi=max(whi,f[y][1]+z);
	}
	if((whi+pre>lim)||(x==1&&whi>=0)) {
		res.pb(x); 
		f[x][0]=0, f[x][1]=-inf;
	} else f[x][0]=bla, f[x][1]=whi;
}
int check(int mid) {
	lim=mid;
	res.clear();
	dfs(1,0,0);
	return res.size()<=k;
}
signed main() {
	n=read(), k=read();
	rep(i,2,n) {
		int x=read(), y=read(), z=read();
		p[x].pb({y,z}), p[y].pb({x,z});
	}
	int l=0, r=2e14;
	while(l<r) {
		int mid=(l+r)>>1;
		if(check(mid)) r=mid, ans=res;
		else l=mid+1;
	}
	printf("%lld\n",l);
	for(auto x:ans) printf("%lld ",x), v[x]=1;
	int x=1, cnt=ans.size();
	while(cnt<k) {
		while(v[x]) ++x;
		printf("%lld ",x);
		++x;
		++cnt;
	}
	puts("");
}

```

## LOJ#3265. 「USACO 2020.2 Platinum」Delegation

答案显然有单调性，直接二分掉。

设二分的答案是 $mid$。

考虑一个树形贪心。我们自底向上扩展每条链，在 $x$ 处对链进行合并。在保证子树内合法的情况下，留下尽可能长的链来接上 $(x,fa_x)$。

一个性质：留下一条链一定比不留下更优秀。所以任何非根节点我们都要尽可能留下。

- 如果子节点集合大小是奇数，那么我们尽可能将当前最短的那条链合并到最短且二者长度之和合法的那条链上，这样留下那条一定是最优的。
- 否则我们考虑把长度大于等于 $k$ 的最短的链单独拿出来，剩下的链再重复上述过程。

对于根节点，由于我们不能留下任何一条长度非法的链，所以我们就对当前最短链贪心匹配。如果子节点集合大小是奇数，那么就拿出来一条合法且长度最短的链。

记录每个点子树内留下的链的长度，使用`std::multiset`实现即可。

注意在贪心的过程中判掉非法情况。

复杂度 $O(n \log^2 n)$。

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
const int N=1e5+5;
int n, fg, f[N];
vector<int> p[N];
void dfs(int x,int fa,int k) {
	multiset<int> s;
	for(auto y:p[x]) if(y!=fa) {
		dfs(y,x,k);
		if(!fg) return;
		s.insert(f[y]+1);
	}
	if(x==1) {
		if(s.size()&1) s.insert(0);
		while(s.size()) {
			auto it=s.begin();
			s.erase(it);
			auto itt=s.lower_bound(k-*it);
			if(itt==s.end()) {
				fg=0;
				return;
			}
			s.erase(itt);
		}
		return;
	}
	if(s.size()%2==0) s.insert(0);
    // 扔进去一个0以找到长度合法且最短的链
    // 如果找不到，那么非法
	int qwq=-1;
	while(s.size()>1) {
		auto it=s.begin();
		s.erase(it);
		auto itt=s.lower_bound(k-*it);
		if(itt==s.end()) {
			if(~qwq) { fg=0; return; }
			else qwq=*it;
            // 非法链最多有一条
		}
		else s.erase(itt);
	}
	if(~qwq) f[x]=qwq;
	else if(s.size()) f[x]=*s.begin();
}
int check(int mid) {
	fg=1;
	dfs(1,0,mid);
	return fg;
}
signed main() {
	n=read();
	rep(i,2,n) {
		int x=read(), y=read();
		p[x].pb(y), p[y].pb(x);
	}
	int l=1, r=n-1;
	while(l<r) {
		int mid=(l+r+1)>>1;
		if(check(mid)) l=mid; else r=mid-1;
	}
	printf("%d\n",l);
	return 0;
}
```

## LOJ#2952. 「NOIP2018」赛道修建

和上面那一题很相似，不同之处在于选出的链可以不覆盖整棵树，但选出的链的数量也有了限制。

仍然可以二分答案，这样我们选链的策略就是只要到达 $mid$ 就行。所以本题中留下一条链一定是在子树内无法合并到 $mid$ 时。

用`std::multiset`维护子节点所在子树内连出的链，贪心匹配即可。

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
const int N=5e4+5;
int n, m, k, f[N];
vector<PII > p[N];
void dfs(int x,int fa,int mid) {
    multiset<int> s;
    for(auto t:p[x]) {
        int y=t.fi, z=t.se;
        if(y==fa) continue;
        dfs(y,x,mid);
        if(f[y]+z<mid) s.insert(f[y]+z);
        else ++k;
    }
    while(s.size()) {
        auto p=s.begin();
        s.erase(p);
        int a=*p, b=mid-a;
        if(!s.size()) {
            f[x]=max(f[x],a);
            continue;
        }
        auto it=s.lower_bound(b);
        if(it==s.end()) f[x]=max(f[x],a);
        else ++k, s.erase(it);
    }
    // printf("f[%lld]=%lld\n",x,f[x]);
}
bool check(int mid) {
    k=0;
    rep(i,1,n) f[i]=0;
    dfs(1,0,mid);
    // printf("mid=%lld m=%lld k=%lld\n",mid,m,k);
    return k>=m;
}
signed main() {
    freopen("track.in","r",stdin);
    freopen("track.out","w",stdout);
    n=read(), m=read();
    int l=1e9, r=0;
    rep(i,2,n) {
        int x=read(), y=read(), z=read();
        p[x].pb({y,z}), p[y].pb({x,z});
        l=min(l,z), r+=z;
    }
    r=(r+m-1)/m;
    while(l<r) {
        int mid=(l+r+1)>>1;
        if(check(mid)) l=mid; else r=mid-1;
    }
    printf("%lld\n",l);
    return 0;
}
```

## LOJ#2333. 「JOI 2017 Final」准高速电车

我们需要对题目给出的信息进行形式化。

先不考虑准快车，我们到达一个站点的最优策略一定是坐快车到那个站点最左边的快车站，然后坐慢车。这样我们能到达的站点一定是每个快车站往后一段，不妨设从第 $i$ 个快车站下车后坐慢车能到达的中站点个数为 $t_i$。

在快车站建造的准快车站，其作用只有当我们坐快车到达这里时换乘准快车，所以可以先忽略。

不难发现我们第一次建造准快车站的位置一定是某个 $S_i+t_i+1$，因为建的更靠前没有意义，更靠后无法到达，没有贡献。然后我们可以计算出从这个站点下车后坐慢车能够到达的位置。同时每个准快车站点一定是在个快车站的中间产生影响。

到这里问题就很明朗了。

我们开一个堆，维护在每个位置建造站点的收益。每次取出收益最大的位置，并算出通过它能够到达的最远位置，只要这个位置没有触及它右边的快车站点，就把这个位置加入堆。

每个时刻堆中元素个数只有 $O(M)$ 个，总共取出 $O(K)$ 个元素，复杂度 $O(k \log M)$。

实现细节较多。

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
const int N=3005;
int n, m, k, A, B, C, T;
int ans;
int s[N], t[N];
bool can[N];
struct node {
    int i, st, val;
    node() {}
    node(int id,int ss) {
        i=id, st=ss;
        int tim=T-(s[i]-1)*B-(st-s[i])*C;
        int lim=s[i+1];
        if(tim>=0) val=1+min(max(lim-st-1,0ll),tim/A);
        else val=0;
    }
    bool operator<(const node& rsh) const {
        return val<rsh.val;
    }
};
signed main() {
    n=read(), m=read(), k=read();
    A=read(), B=read(), C=read();
    T=read();
    rep(i,1,m) s[i]=read();
    k-=m;
    priority_queue<node> q;
    rep(i,1,m-1) {
        if((s[i]-1)*B<=T) {
            int lim=s[i+1];
            t[i]=min((T-(s[i]-1)*B)/A,max(lim-s[i]-1,0ll));
            ans+=1+t[i];
            if(s[i]+t[i]+1<lim) q.push(node(i,s[i]+t[i]+1));
        }
    }
    if((s[m]-1)*B<=T) ++ans;
    while(k--) {
        if(q.empty()) break;
        node t=q.top(); q.pop();
        if(t.val==0) break;
        ans+=t.val;
        if(t.st+t.val<s[t.i+1]) q.push(node(t.i,t.st+t.val));
    }
    printf("%lld\n",ans-1);
    return 0;
}
```

## LOJ#2601. 「NOIP2011」观光公交

$80$ 分做法，可以通过原题数据。

答案可以拆成每个游客的到达时间之和减去每个游客的来到出发地的时刻，后者可以直接得到。

我们每次使用加速，一定是对着效果最好的那个使用，这个是没有后效性的，但是要求每次操作后都重新求出这个最值。

下面重定义 $D_i$ 为从 $i-1$ 到 $i$ 的时间。考虑对一个 $D_i$ 使用加速的效果如何计算。

我们先得到 $lim_i$ 表示在车站 $i$ 出发的人，到达 $i$ 的最晚时间，$ar_i$ 表示公交车到达第 $i$ 个车站的最早时间，显然 $ar_i = \max(d_{i-1},lim_{i-1})+D_i$。

设 $cnt_i$ 为终点在第 $i$ 个车站的人数，$w_i$ 为对 $D_i$ 加速的收益，初始 $w_i = cnt_i$。对 $D_i$ 加速后，如果 $ar_i > lim_i$，那么从站点 $i$ 往后走的人还需要等车，此时令 $w_i \leftarrow w_{i+1}$。这个影响可以叠加，倒着处理即可。

然后找最大的 $w_i$ 对应的 $D_i$ 进行操作。最后终点为 $i$ 的人的到达时间就是 $ar_i$，总贡献是 $\sum_{i=2}^n cnt_i \times ar_i$。

复杂度 $O(nk)$。

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
int n, m, k, ans, d[N], ar[N], w[N];
int lim[N], cnt[N];
namespace bf {
    void solve() {
        rep(i,2,n) ar[i]=max(lim[i-1],ar[i-1])+d[i];
        while(k--) {
            for(int i=n;i>1;--i) {
                w[i]=cnt[i];
                if(i!=n&&ar[i]>lim[i]) w[i]+=w[i+1];
            }
            int x=0;
            rep(i,2,n) if(w[i]>w[x]&&d[i]>0) x=i;
            if(x) --d[x];
            rep(i,2,n) ar[i]=max(lim[i-1],ar[i-1])+d[i];
        }
        rep(i,2,n) ans+=cnt[i]*ar[i];
        printf("%lld\n",ans);
    }
};
signed main() {
    n=read(), m=read(), k=read();
    rep(i,2,n) d[i]=read();
    rep(i,1,m) {
        int t=read(), a=read(), b=read();
        lim[a]=max(lim[a],t);
        ++cnt[b];
        ans-=t;
    }
    bf::solve();
    return 0;
}
```

