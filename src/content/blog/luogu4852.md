---
title: luogu4852 yyf hates choukapai 题解
tags:
  - DP
  - 单调队列
categories: 题解
pubDate: 2022-07-03
description: 'Solution'
---

## 分析

不是那么显然的 DP。

对于每一次连抽，只会累计开始连抽的那张卡的欧气值，损失之后 $c-1$ 张卡的欧气值。而单抽则不会损失欧气值。题目要求最大化欧气值，那么就是要尽量减小连抽损失的欧气值。

形式化地，对于一次在 $i$ 位置开始的连抽，得到 $a_i$，损失 $\sum_{j=i+1}^{i+c-1} a_i$ 的欧气。对于 $j$ 位置的单抽，只会得到 $a_j$ 的欧气值。设 $b_i = \sum_{j=i+1}^{i+c-1} a_i$，那么目标为最小化选出的 $n$ 个 $b_i$。可以用前缀和预处理。

设 $f(i,j)$ 为进行了 $j$ 次连抽，其中第 $j$ 次连抽从 $i$ 开始，且 $[1,i-1]$ 已经抽完了，所能选出 $j$ 个 $\{b\}$ 中元素的最小值。

思路是枚举上一次连抽的位置，由于两次连抽中间必然全是单抽且不成超过 $d$ 次，而连抽必须抽 $c$ 个，那么对于 $f(i,j)$，上一次连抽的位置 $i' \in [i-c-d,i-c]$。确定位置之后，直接加上 $b_i$ 就行。

$$
f(i,j) = \min_{i' \in [i-c-d,i-c]} \{ f(i',j-1)  + b_i \}
$$

设 $len = n \times c + m$，则复杂度为 $O(n \cdot  len^2)$。

对于 $i > i_0$，$i$ 的合法决策区间的左右端点必然严格大于 $i_0$ 的合法决策区间的左右端点，直接单调队列优化。

对于能够成为答案的 $f(i,n)$，必须满足$i \in [1,len-c+1]$ 且 $len-(i+c-1) \le d$，即最后一次连抽后单抽不能超过 $d$ 次。

最终答案 $\sum_{i=1}^n a_i - \max\{f(i,n)\}$。

复杂度 $O(n \cdot len)$ 。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int N=200005;
int n, m, c, d, a[N], q[N], pre[N][45];
ll s[N], b[N], f[N][45];
int read() {
    int a=0; char c=getchar();
    while(!isdigit(c)) c=getchar();
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a;
}
void print(int i,int t) {
    if(!i) return;
    print(pre[i][t],t-1);
    printf("%d ",i);
}
int main() {
    n=read(), m=read(), c=read(), d=read();
    int len=c*n+m;
    for(int i=1;i<=len;++i) s[i]=s[i-1]+read();
    for(int i=1;i<=len-c+1;++i) b[i]=s[i+c-1]-s[i];
    memset(f,0x3f,sizeof(f));
    for(int i=1;i<=d+1;++i) f[i][1]=b[i];
    // 注意第一次连抽的位置区间是[1,d+1]
    for(int j=2;j<=n;++j) {
        int l=1, r=0;
        for(int i=1;i<=len-c+1;++i) {
            while(l<=r&&q[l]<i-c-d) ++l;
            while(l<=r&&i-c>0&&f[i-c][j-1]<f[q[r]][j-1]) --r;
            if(i-c>0) q[++r]=i-c;
            if(l<=r&&q[l]>=i-c-d&&q[l]<=i-c) f[i][j]=f[q[l]][j-1]+b[i], pre[i][j]=q[l];
        }
    }
    int p=0;
    ll ans=1e15;
    for(int i=1;i<=len-c+1;++i) {
        int j=i+c-1;
        if(len-j<=d&&ans>f[i][n]) ans=f[i][n], p=i;
    }
    printf("%lld\n",s[len]-ans);
    print(p,n);
    puts("");
}
```
