---
title: luogu7715 Shape 题解
tags: DP
categories: 题解
pubDate: 2022-11-12
description: 'Solution'
---



枚举极长横杠。

设 $f(x,y)$ 为从 $(x,y)$ 最多同时向上向下延伸多少个白色格子。

对于每一行 $x$，直接处理两个黑色格子中间的部分，设为 $[l,r]$，那么贡献为

$$

$$





考虑如果将 $f(x,y)$ 递增排序，那么对于排名为 $k$ 的 $f(x,y_0)$ 会贡献出 $r-k$ 次。

于是乎这部分的复杂度为 $O(nm \log_2 m)$，可以通过。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
const int N=2005;
int n, m, ans, a[N][N], f[N][N], t[N];
int calc(int i,int l,int r) {
    if(l>r) return 0;
    int cnt=0, res=0;
    rep(j,l,r) t[++cnt]=f[i][j];
    sort(t+1,t+cnt+1);
    rep(j,1,cnt) res+=t[j]*(cnt-j);
    return res;
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) rep(j,1,m) a[i][j]=read();
    rep(j,1,m) {
        int p=-1;
        rep(i,1,n) {
            if(!a[i][j]) ++p; else p=-1;
            f[i][j]=p;
        }
        p=-1;
        per(i,n,1) {
            if(!a[i][j]) ++p; else p=-1;
            f[i][j]=min(f[i][j],p);
        }
    }
    rep(i,1,n) {
        int lst=1;
        rep(j,1,m) if(a[i][j]) ans+=calc(i,lst,j-1), lst=j+1;
        ans+=calc(i,lst,m);
    }
    printf("%lld\n",ans);
}
```
