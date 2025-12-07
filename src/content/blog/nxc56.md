---
title: 「NowCoder Round X」#56
tags:
  - 贪心
  - 构造
  - 最短路
  - NowCoder
categories:
  - 题解
  - 比赛
description: '个人题解'
pubDate: 2022-08-29
---

**NowCoderX56**.

水。



## A. 阿宁的柠檬


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
int n, a, b;
signed main() {
	a=read(), b=read(), n=read();
	printf("%lld %lld\n",n,(a+b)*n);
}
```

## B. 阿宁与猫咪

注意到全部填 $1$ 时，烦躁值不会超过 $2$。


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
int m;
signed main() {
	m=read();
	printf("%lld\n",m);
	for(int i=1;i<=m;++i) puts("1");
}
```

## C. 阿宁吃粽子

贪心地将最小值放在 $2^0$ 的位置，次小值放在 $2^1$ 的位置。

注意第一个 $2^0$ 的位置是 $a_{10}$。



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
int n, a[N], ans[N];
signed main() {
	n=read();
	for(int i=1;i<=n;++i) a[i]=read();
	sort(a+1,a+n+1);
	if(n<=9) {
		for(int i=1;i<=n;++i) printf("%lld%c",a[i]," \n"[i==n]);
		return 0;
	}
	int pos=1;
	for(int i=10;i<=n;i+=10) ans[i]=a[pos++];
	for(int i=1;i<=9;++i) {
		for(int j=0;i+j<=n;j+=10) ans[i+j]=a[pos++];
	}
	for(int i=1;i<=n;++i) printf("%lld%c",ans[i]," \n"[i==n]);
}
```

## D. 阿宁的质数



做法很显然，但是筛不出值域那么大的一张质数表。

注意到对于 $x = 1,2,3 \ldots$，答案单调不减，且答案一定为质数。也就是最大为第 $2 \times 10^5$ 个质数。不难发现线性筛 $[2,3.5 \times 10^6]$ 这个区间就行了。

然后瞎搞，预处理每个前缀的答案，用`std::unordered_map`实现的话，复杂度是 $O(n)$ 的。



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
const int N=2e5+5, M=3e6+5e5+10;
int n, m, q, a[N], r[N], p[M];
bool v[M];
unordered_map<int,bool> st;
void init() {
	for(int i=2;i<=3e6+5e5;++i) {
		if(!v[i]) p[++m]=i;
		for(int j=1;j<=m&&i*p[j]<=3e6+5e5;++j) {
			v[i*p[j]]=1;
			if(i%p[j]==0) break;
		}
	}
}
signed main() {
	n=read(), q=read();
	for(int i=1;i<=n;++i) a[i]=read();
	init();
	int pos=1;
	for(int i=1;i<=n;++i) {
		if(a[i]==p[pos]) {
			++pos;
			while(st[p[pos]]) ++pos;
			r[i]=p[pos];
		} else r[i]=p[pos];
		st[a[i]]=1;
	}
	while(q--) {
		int x=read();
		printf("%lld\n",r[x]);
	}
}
```

## E. 阿宁睡大觉



只有完全删去夹在两个`Z`中间的`z`才会产生 $4$ 的贡献。

贪心地删去夹在两个`Z`中间的，长度更短的若干个`z`。



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
int n, k, ans;
char s[N];
vector<int> rec;
signed main() {
	n=read(), k=read();
	scanf("%s",s+1);
	int l=1, r=n;
	while(s[l]=='z'&&l<=n) ++l;
	while(s[r]=='z'&&r) --r;
	for(int i=l;i<=r;++i) {
		if(s[i]=='z') continue;
		int j=i;
		while(j+1<=r&&s[j+1]=='Z') ++j;
		ans+=4*(j-i);
        // [i,j]全部为Z
        ++j;
        int d=j;
        if(j>r) break;
		while(j+1<=r&&s[j+1]=='z') ++j;
		rec.push_back(j-d+1);
        // [d,j]全部为z，且删去这部分的代价为j-d+1
		i=j;
	}
	sort(rec.begin(),rec.end());
    // 贪心删去代价小的
	for(auto x:rec) {
		if(k>=x) ans+=4, k-=x;
		if(k<=0) break;
	}
	printf("%lld\n",ans);
}
```

## F. 阿宁去游玩



注意到使用膜法对后续操作完全没有限制，那么对于每对点 $(x,y)$，都能找到一个花费最小的方案。

然后跑最短路即可。



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
int n, m, X, Y, Z, a[N], d[N];
int tot, h[N], to[2*N], nxt[2*N], w[2*N];
bool v[N];
void add(int x,int y,int z) {
	to[++tot]=y, w[tot]=z, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y,int z) {
	add(x,y,z), add(y,x,z);
}
void dijkstra() {
	priority_queue<pair<int,int> > q;
	memset(d,0x3f,sizeof(d));
	d[1]=0;
	q.push({0,1});
	while(q.size()) {
		int x=q.top().second; q.pop();
		if(v[x]) continue;
		v[x]=1;
		for(int i=h[x];i;i=nxt[i]) {
			int y=to[i], z=w[i];
			if(d[y]>d[x]+z) {
				d[y]=d[x]+z;
				q.push({-d[y],y});
			}
		}
	}
}
signed main() {
	n=read(), m=read(), X=read(), Y=read(), Z=read();
	auto f=[&](int x,int y) {
		return a[x]==a[y]? min(X,Y+Z):min(Y,X+Z);
	};
	for(int i=1;i<=n;++i) a[i]=read();
	for(int i=1;i<=m;++i) {
		int x=read(), y=read();
		addedge(x,y,f(x,y));
	}
	dijkstra();
	printf("%lld\n",d[n]);
}
```

