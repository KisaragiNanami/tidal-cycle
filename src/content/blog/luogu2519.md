---
title: luogu2519 problem a 题解
tags:
  - 贪心
  - DP
categories:
  - 题解
description: 'Solution'
pubDate: 2022-04-16
---

## 分析

说假话的人最少，可以转化成求说真话的人最多。

考虑按照成绩递增排序的情况，如果第 $i$ 个人有 $a_i$ 个人分数比他高，$b_i$ 个人分数比他低，那么 $[b_i+1,n-a_i]$ 这个区间表示的就是分数和他相等的人。



令 $l_i = b_i+1$，$r_i=n-a_i$。如果 $l_i > r_i$ 那么这个人一定说假话。同一分数相等的人不能超过 $r_i - l_i +1$ 个。 

所以我们把每个 $l_i$ 与 $r_i$ 看作线段的端点，端点相同（分数相同）的人数看作这天线段的权值，那么问题就转化成了带权区间调度问题。

以上的特判可以用`std::map`来快速实现。

设 $f_i$ 为前 $i$ 条线段能得到的最大值，那么有

$$
f_i = \max_{1 \le j < i}{\{ f_i,f_j + cnt_j \}} \quad r_j < l_i
$$



$f$ 显然是单调增的，二分即可。

复杂度 $O(n \log_2 n)$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define pii pair<int,int>
#define mk make_pair
const int N=1e5+5;
int n, len, d[N], f[N];
struct edge { int l, r, k; } a[N];
inline bool operator<(edge a,edge b) { return a.r<b.r; }
map<pii,int> mp;
int main() {
    scanf("%d",&n);
    for(int i=1,x,y,l,r;i<=n;++i) {
        scanf("%d%d",&x,&y);
        l=y+1, r=n-x;
        if(l>r) continue; // 第一种不合法
        pii e=mk(l,r);
        if(mp[e]==r-l+1) continue; // 第二种不合法
        if(!mp[e]) a[++len].l=l, a[len].r=r;
        ++mp[e];
    }
    for(int i=1;i<=len;++i) {
        int k=mp[mk(a[i].l,a[i].r)];
        a[i]=(edge){a[i].l,a[i].r,k};
    }
    sort(a+1,a+len+1);
    for(int i=1;i<=len;++i) d[i]=a[i].r;
    for(int i=1;i<=len;++i) {
        int k=lower_bound(d+1,d+i,a[i].l)-d-1; //注意-1
        f[i]=max(f[i-1],f[k]+a[i].k);
    }
    printf("%d\n",n-f[len]);
}

```
