---
title: luogu9166 「联合省选 2023」 火车站 题解 
pubDate: 2023-10-23
tags: 差分
categories: 题解
description: 'Solution'
---

## Solution

先只考虑往右边开的情况。

我们先把每个车站被轨道覆盖的次数 $c_i$ 差分出来。注意到达 $r_i$ 时就停下来了，所以实际的覆盖范围是 $[l_i,r_i-1]$。

然后能到达的车站一定是 $x$ 往右连续的一段非 $0$ 位置。

这样有一个问题，只有到达 $r_i$ 才把 $i$ 计入答案，而我们没有覆盖 $r_i$。

仔细思考不难发现，如果 $r_i$ 在非 $0$ 段内，那么就一定能被统计到，会漏掉的仅仅是最后一个，特判即可。

对于往左边，类似处理即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define SET(a,b) memset(a,b,sizeof(a))
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
int n, m, x, l0, r0, l[N], r[N], tag[N], c[N], d[N];
int ans[N];
#define pb push_back
signed main() {
    n=read(), m=read(), x=read();
    rep(i,1,m) {
        l[i]=read(), r[i]=read();
        ++c[l[i]], --c[r[i]], tag[r[i]]=1;
    }
    rep(i,1,n) c[i]+=c[i-1];
    l0=r0=x;
    while(r0<n&&c[r0]) {
        ++r0;
        if(tag[r0]) ans[r0]=1;
    }
    rep(i,1,n) tag[i]=0;
    rep(i,1,m) {
        ++d[r[i]], --d[l[i]], tag[l[i]]=1;
    }
    per(i,n,1) d[i]+=d[i+1];
    while(l0>1&&d[l0]) {
        --l0;
        if(tag[l0]) ans[l0]=1;
    }
    rep(i,1,n) if(ans[i]) printf("%lld ",i);
    puts("");
}
```
