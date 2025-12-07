---
title: luogu7960 报数 题解
tags:
  - 数论
categories:
  - 题解
description: 'Solution'
pubDate: 2022-06-21
---



## 分析

首先判断某个数十进制中是否含有 7 这个很简单。

然后用筛子把它的倍数筛掉就行了。

瓶颈在于，如何快速回答下一个要报出的数。枚举的话只有 70pts。

考虑一个数 $x$，满足 $p(x)=0$ 且不存在 $y$，满足 $p(y)=1$ 且 $y \mid x$，它一定是某个数“下一个要报出的数”。

而每一个数“下一个要报出的数”一定是单调增的。

所以设 $r_x$ 为 $x$ 下一个要报出的数，如果它本身不合法，那么就是 -1。

我们可以在筛数的过程中，维护 $lst$。如果 $x$ 满足条件，直接令 $r_{lst}=x$，$lst = x$。因为 $(lst,x)$ 这个区间里的数都是不合法的，否则与 $x$ 为“下一个要报出的数”相矛盾。

注意当 $x=10^7$ 时，答案为 $10^7+1$。

预处理之后就可以直接输出 $r_x$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e7+5;
int t, r[N];
bool v[N];
int read() {
    int a=0; char c=getchar();
    for(;!isdigit(c);c=getchar());
    for(;isdigit(c);a=a*10+(c^48),c=getchar());
    return a;
}
bool pd(int x) {
    if(x%7==0) return 1;
    while(x) {
        if(x%10==7) return 1;
        x/=10;
    }
    return 0;
    // pd(x)=1表示x十进制中有7或者是7的倍数
}
void init() {
    memset(r,-1,sizeof(r));
    int lst=0;
    for(int i=1;i<=1e7+1;++i) {
        if(v[i]) continue;
        // v[i]=1就代表i不合法
        if(pd(i)) {
            for(int j=i;j<=1e7+1;j+=i) v[j]=1;
        } else r[lst]=i, lst=i;
    }
}
int main() {
//     freopen("d:\\number\\number4.in","r",stdin);
//     freopen("d:\\number\\out.out","w",stdout);
    t=read();
    init();
    while(t--) {
        int x=read();
        printf("%d\n",r[x]);
    }
}
```
