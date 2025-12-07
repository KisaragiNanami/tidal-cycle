---
title: 「NOIP Record」#19 费用提前计算
pubDate: 2023-09-07
tags:
  - DP
  - 区间DP
  - 费用提前计算
categories: Record
description: '少年长出了野心'
---



未完待续

### CF1107E Vasya and Binary String

设 $f(i,j,t)$ 为删去区间 $[i,j]$，其中区间右边还有 $t$ 个与 $S[j]$ 相同的字符的最大收益。

$$
f(i,j,t) = \max \begin{cases}
f(i,j-1,0) + a_{t+1}
\\
\max _{k=i}^{j-1} \Big\{ f(i,k,t+1) + f(k+1,j-1,0)  \Big\}
\end{cases}
$$

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
int n, a[N], f[N][N][N];
char s[N];
int dfs(int i,int j,int t) {
	if(i>j) return 0;
	if(i==j) return a[t+1];
	if(f[i][j][t]) return f[i][j][t];
	int& res=f[i][j][t];
	res=dfs(i,j-1,0)+a[t+1];
	for(int k=i;k<j;++k) if(s[k]==s[j]) {
		res=max(res,dfs(k+1,j-1,0)+dfs(i,k,t+1));
	}
	return res;
}
signed main() {
	n=read();
	scanf("%s",s+1);
	rep(i,1,n) a[i]=read();
	printf("%lld\n",dfs(1,n,0));
}
```

