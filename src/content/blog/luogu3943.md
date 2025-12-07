---
title: luogu3943 星空 题解
pubDate: 2023-07-15
tags:
  - 差分
  - 状态压缩
  - 搜索
  - DP
categories:
  - 题解
description: 'Solution'
---



注意到区间异或可以差分成端点异或，所以把序列差分了，并且能发现差分之后最多有 $2k$ 个需要修改的位置。

又因为当一个序列的首项与差分序列确定时，这个序列也被唯一确定了，所以我们可以提取出那些需要修改的位置，压成一个整数 $S$，并且处理它们之间的距离。

反转长度为 $b$ 的区间提供了 3 种在差分序列上的操作：

1. 干掉 $S$ 中距离为 $b+1$ 的两个 $1$。
2. 干掉 $S$ 中距离 $n+1$ 不超过 $b+1$ 的一个 $1$。
3. 让一个 $1$ 向左或向右移动 $b+1$ 位。



多次使用三种操作，求出 $g(i)$ 表示消去距离为 $i$ 的两个 $1$ 的最小代价。这个可以用  $\text{BFS}$ 处理。注意由于操作有重叠，所以只有第一次使用操作时距离才是 $b+1$，否则都是 $b$。

这样就可以 DP 了。设 $f(S)$ 为从初始状态到达 $S$ 的最小代价。

按秩转移，钦定 $\operatorname{lowbit}(S)$ 是最后一个被干掉的。枚举与它一起被干掉的 $1$ 或者直接扔到 $n+1$ 去，取最小值即可。



```cpp
// Problem: P3943 星空
// Contest: Luogu
// URL: https://www.luogu.com.cn/problem/P3943
// Author: KisaragiQwQ
// Date: 2023-06-18 07:33:28
// Memory Limit: 250 MB
// Time Limit: 1000 ms
// 
// Let's Daze
// 
// Powered by CP Editor (https://cpeditor.org)

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
const int N=4e4+5, inf=0x3f3f3f3f;
int n, k, m, st, p[N], c[N], a[20], b[70], d[20];
int cnt, g[N], f[1<<16], lg[1<<16];
void bfs() {
	SET(g,0x3f);
	queue<int> q;
	rep(i,1,m) q.push(b[i]), g[b[i]]=1;
	while(q.size()) {
		int x=q.front(); q.pop();
		rep(i,1,m) {
			if(x+b[i]-1<=n+1&&g[x+b[i]-1]==inf) g[x+b[i]-1]=g[x]+1, q.push(x+b[i]-1);
			if(x-b[i]+1>0&&g[x-b[i]+1]==inf) g[x-b[i]+1]=g[x]+1, q.push(x+b[i]-1);
		}
	}
}
void init() {
	if(p[1]) st=1, ++cnt, d[0]=1;
	rep(i,2,n) {
		int x=p[i-1]^p[i];
		if(x) {
			d[cnt]=i;
			st|=(1<<cnt);
			++cnt;
		}
	}
}
int lowbit(int x) { return x&-x; }
signed main() {
	n=read(), k=read(), m=read();
	rep(i,1,k) {
		int x=read();
		p[x]=1;
	}
	rep(i,1,m) b[i]=read()+1; // 注意这里+1了
	bfs();
	init();
	
	SET(f,0x3f);
	f[st]=0;
	for(int i=0;i<2*k;++i) lg[1<<i]=i;
	for(int S=st;S;S=(S-1)&st) {
		int i=lg[lowbit(S)];
		for(int S0=S-lowbit(S);S0;S0-=lowbit(S0)) {
			int j=lg[lowbit(S0)];
			if(g[d[j]-d[i]+1]!=inf) f[S^(1<<i)^(1<<j)]=min(f[S^(1<<i)^(1<<j)],f[S]+g[d[j]-d[i]+1]);
		}
		if(g[n+1-d[i]+1]!=inf) f[S^(1<<i)]=min(f[S^(1<<i)],f[S]+g[n+1-d[i]+1]);
	}
	printf("%d\n",f[0]);
	return 0;
}
```

