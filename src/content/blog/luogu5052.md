---
title: luogu5052 GO 题解
tags:
  - DP
  - 区间DP
categories:
  - 题解
pubDate: 2022-04-09 description: 'Solution'
---

## 分析

这题评紫确实过了。很容易看出来是套路的区间 DP。

设 $f(i,j,t,0/1)$ 表示抓到了区间 $[i,j]$ 的宝可梦，花费的时间为 $t$，在 $i$ 或 $j$ 的位置，所获得的最大收益。

转移情况比较多，用刷表法比较方便，而且要注意时间限制，否则下面的 $B$  是不能加的。
$$
f(i-1,j,t +\Delta t,0) =
\max \begin{cases}
f(i,j,t,0) + B_{i-1}
\\
f(i,j,t,1) + B_{i-1}
\end{cases}
$$

$$
f(i,j+1,t +\Delta t,1) =
\max \begin{cases}
f(i,j,t,0) + B_{j+1}
\\
f(i,j,t,1) + B_{j+1}
\end{cases}
$$

计算 $\Delta t$ 只需要将对应的编号相减就行了。

注意状态中的 $[i,j]$ 指的是按照编号排序后排名为 $[i,j]$ 的宝可梦，而不是房子编号，不然复杂度不对。这一步就相当于离散化。

边界为

$$
f(i,j,t,0/1) =
\begin{cases}
0 & i=j=k
\\
-\infty & \text{otherwise}
\end{cases}
$$

复杂度 $O(m^2 \max T)$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=105, maxt=2005, inf=0x3f3f3f3f;
int n, m, k, ans, T, f[N][N][maxt][2];
struct qwq { int num, v, t; } a[N];
bool operator<(qwq a,qwq b) { return a.num<b.num; }
int main() {
	scanf("%d%d%d",&n,&k,&m);
	for(int i=1;i<=m;++i) {
		scanf("%d%d%d",&a[i].num,&a[i].v,&a[i].t);
		T=max(T,a[i].t);
	}
	a[++m]=(qwq){k,0,0}; // 原点
	sort(a+1,a+m+1);
	memset(f,-0x3f,sizeof(f));
	int p=0; for(int i=1;i<=m;++i) if(a[i].num==k) { p=i; break; }
	f[p][p][1][1]=f[p][p][1][0]=0;
	for(int t=1;t<=T;++t) for(int len=1;len<=m;++len) for(int i=1;i+len-1<=m;++i) {
		int j=i+len-1;
		if(f[i][j][t][0]!=-inf) {
			if(i!=1) {
				int tt=t+a[i].num-a[i-1].num;
				if(tt<=T) {
					int dlt=0;
					if(tt<=a[i-1].t) dlt=a[i-1].v;
					f[i-1][j][tt][0]=max(f[i-1][j][tt][0],f[i][j][t][0]+dlt);
				}
			}
			if(j!=m) {
				int tt=t+a[j+1].num-a[i].num;
				if(tt<=T) {
					int dlt=0;
					if(tt<=a[j+1].t) dlt=a[j+1].v;
					f[i][j+1][tt][1]=max(f[i][j+1][tt][1],f[i][j][t][0]+dlt);
				}
			}
		}
		if(f[i][j][t][1]!=-inf) {
			if(i!=1) {
				int tt=t+a[j].num-a[i-1].num;
				if(tt<=T) {
					int dlt=0;
					if(tt<=a[i-1].t) dlt=a[i-1].v;
					f[i-1][j][tt][0]=max(f[i-1][j][tt][0],f[i][j][t][1]+dlt);
				}
			}
			if(j!=m) {
				int tt=t+a[j+1].num-a[j].num;
				if(tt<=T) {
					int dlt=0;
					if(tt<=a[j+1].t) dlt=a[j+1].v;
					f[i][j+1][tt][1]=max(f[i][j+1][tt][1],f[i][j][t][1]+dlt);
				}
			}
		}
		ans=max(ans,max(f[i][j][t][0],f[i][j][t][1]));
	}
	printf("%d\n",ans);
}
```

