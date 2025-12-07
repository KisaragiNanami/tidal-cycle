---
title: luogu5894 robots 题解
tags:
  - 二分答案
  - 贪心
categories:
  - 题解
pubDate: 2022-07-25
description: 'Solution'
---

## 分析

二分答案，设 $check(x)$ 为能否在 $x$ 的时间之内完成。

一个很显然的贪心策略就是，对于每个弱机器人，从 $X_i$ 最小的开始，在不超时的前提下，尽可能拿走重量小于 $X_i$ 且没有被拿走的玩具，优先选择体积最大的。而小机器人则用来收拾烂摊子，从 $Y_i$ 最大的开始，在不超时的前提下，尽可能拿走能够拿走且没有被拿走的玩具，优先选择体积最大的。

简单堆贪心。

正确性？感性理解，弱机器人不考虑体积，那么就在不考虑体积的情况下尽可能多拿，且从 $X_i$ 小的开始保证了“物尽其用”。由于有时间（拿的个数）限制，所以贪心选择体积更大的为小机器人分担压力。而小机器人则不考虑重量，负责收拾烂摊子（时间不够拿不走的，重量太大拿不走的）就好了。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=5e4+5, M=1e6+5;
int T, n, m, a[N], b[N];
struct toy { int w, s; } c[M];
bool operator<(toy a,toy b) { return a.w<b.w; }
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
bool check(int x) {
    int pos=1;
    priority_queue<int> q;
    // 优先队列存放没有被拿走的玩具的体积
    for(int i=1;i<=n;++i) {
        while(pos<=T&&c[pos].w<a[i]) q.push(c[pos++].s);
        // 把能够拿走的玩具入堆
        for(int j=1;j<=x&&q.size();++j) q.pop();
        // x的时间最多拿走x个玩具，贪心选择体积最大的
    }
    while(pos<=T) q.push(c[pos++].s);
    // 这部分就是任何弱机器人都拿不走的
    for(int i=m;i;--i) {
        if(q.empty()) break;
        int cnt=0;
        for(int j=1;j<=x&&q.size()&&q.top()<b[i];++j) q.pop();
        // 在x的时间内，优先选择最大的能够拿走的玩具
    }
    return q.empty(); // 优先队列为空，说明能够完成
}
signed main() {
    n=read(), m=read(), T=read();
    for(int i=1;i<=n;++i) a[i]=read();
    for(int i=1;i<=m;++i) b[i]=read();
    for(int i=1;i<=T;++i) c[i].w=read(), c[i].s=read();
    sort(a+1,a+n+1);
    sort(b+1,b+m+1);
    sort(c+1,c+T+1);
    int l=0, r=T;
    while(l<r) {
        int mid=(l+r)/2;
        if(check(mid)) r=mid; else l=mid+1;
    }
    printf("%lld\n",check(l)? l:-1);
}
```
