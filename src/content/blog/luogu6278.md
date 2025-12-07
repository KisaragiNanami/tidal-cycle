---
title: luogu6278 Haircut 题解
\sum_{ i=1 \text{ and } f_i > k}^n f_i - k \cdot \sum_{i \in [1,n]} [f_i > k]
tags:
  - 树状数组
categories:
  - 题解
pubDate: 2022-08-15
---

一道很有趣，也很有益的题目（雾）。

## 分析

注意到 $a_i \in [0,N]$，这是很关键的一个点，可以从每个 $a_i$ 下手。

当 $j= a_i$ 时，所有大于 $a_i$ 的数都会等于 $a_i$。也就是说，所有 $a_i$ 作为较小数的逆序对，全部寄了。这样看起来很难下手。

可是退一步，当 $j=a_i$ 时，小于 $a_i$ 的数不变，大于 $a_i$ 的数变为 $a_i$，它们的相对大小不变。因此，当 $j=a_i$ 时，由大于 $a_i$ 的数 $a_x$ 和小于 $a_i$ 的数 $a_y$，构成的逆序对 $(x,y)$，其中 $(x<y)$，此时一定仍然成立。而对于由两个小于 $a_i$ 的数构成的逆序对，显然也成立。

所以如果以较小数为基准，设 $S_{a_i}$ 为 $[1,i-1]$ 中大于 $a_i$ 的数的个数，那么当 $j \ge a_i$ 时，这些逆序对仍然成立。

而由上述讨论知道，其他的逆序对绝对不成立。

因此，用树状数组求出 $S_{a_i}$。当 $j=t$ 时，答案为 $\sum_{k=0}^{t-1} S_k$。

由于树状数组下标必须为正整数，所以要平移一位。

## CODE

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
const int N=1e5+5;
int n, ans, a[N], s[N], c[N];
void modify(int x,int y) { for(;x<=1e5;x+=x&(-x)) c[x]+=y; }
int query(int x) {
    int y=0;
    for(;x;x-=x&(-x)) y+=c[x];
    return y;
}
signed main() {
    n=read();
    for(int i=1;i<=n;++i) a[i]=read()+1; // 平移
    puts("0");
    for(int i=1;i<=n;++i) {
        int d=n-(a[i]-1)+1;
        s[a[i]]+=query(d-1);
        modify(d,1);
    }
    for(int i=2;i<=n;++i) printf("%lld\n",ans+=s[i-1]);
    // 由于平移了一位，所以是[2,n]
}
```
