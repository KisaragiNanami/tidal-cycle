---
title: luogu7482 不条理狂诗曲 题解
pubDate: 2023-11-10
tags:
  - 分治
  - DP
  - 决策单调性
  - 双指针
categories: 题解
description: 'Solution'
---

## Solution

对所有区间求和，考虑分治。

由于我们要处理的区间一定跨越 $mid$，我们可以把所有的半个区间根据是否选择 $mid$ 与 $mid+1$ 分成四类。

具体的，我们求出 $f_{i,0/1}$ 表示后缀 $[i,mid]$ 在**强制不选**或**任意选取** $mid$ 的情况下能够取到的最大值，$g_{i,0/1}$ 表示前缀 $[mid+1,i]$ 在**强制不选**或**任意选取** $mid+1$ 的情况下能够取到的最大值。答案就可以表示为

$$
\sum_{i \in [l,mid]} \sum_{j \in [mid+1,r]} \max(f_{i,0}+g_{j,1},f_{i,1}+g_{j,0})
$$



直接求显然不能接受，套路性的把 $\max$ 拆掉。考虑 $f_{i,0} + g_{j,1} \le f_{i,1} + g_{j,0}$，容易得到一个很好的形式 $g_{j,1} - g_{j,0} \le f_{i,1} - f_{i,0}$，也就是说只要满足这个式子，我们就可以把 $f_{i,0}$ 换成 $f_{i,1}$ 同时把 $g_{j,1}$ 换成 $g_{j,0}$，$\max$ 取到另一边的情况是对称的。

一种方法是将 $f_{i,1} - f_{i,0}$ 与 $g_{i,1} - g_{i,0}$ 分别排序，然后扫一个，另一个求前缀和后指针维护。细节较多。

有更好的做法。注意到 $f$ 与 $g$ 相对独立，我们可以先钦定全部选择 $f_{i,0}$ 与 $g_{j,0}$，然后把 $f_{i,1} - f_{i,0}$ 与 $g_{i,1} - g_{i,0}$ 放到一起排序，但要记录二者的类别。从大到小扫，维护每种类别还有多少个比当前的小。举个例子，设当前扫到了 $f_{k,1} - f_{k,0}$，还有 $c$ 个 $g$ 没被扫到，那么就会有 $c$ 个 $f_{k,1}$ 被换出来。

至于 $f$ 和 $g$，可以用一个很平凡的 DP 得到。

复杂度 $O(n \log^2 n)$。

代码中的数组名字与上文有所不同。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=1e5+5, mod=1e9+7, inf=0x0f0f0f0f0f0f0f0f;
int n, a[N];
int ans, f[N][2][2], g[N][2];
void solve(int l,int r) {
    if(l==r) { (ans+=a[l])%=mod; return; }
    int mid=(l+r)>>1;
    solve(l,mid);
    solve(mid+1,r);

    int cntl=mid-l+1, cntr=r-mid;
    vector<PII > v;
    rep(i,l,r) rep(j,0,1) rep(k,0,1) f[i][j][k]=-inf;
    f[mid][0][0]=f[mid][0][1]=f[mid][1][0]=0, f[mid][1][1]=a[mid];
    for(int i=mid-1;i>=l;--i) rep(j,0,1) {
        f[i][j][0]=max(f[i+1][j][0],f[i+1][j][1]);
        f[i][j][1]=f[i+1][j][0]+a[i];
    }
    for(int i=mid;i>=l;--i) {
        g[i][0]=max(f[i][0][0],f[i][0][1]);
        g[i][1]=max(f[i][1][0],f[i][1][1]);
        (ans+=g[i][0]*cntr%mod)%=mod;
        v.pb({g[i][1]-g[i][0],0});
    }
    f[mid+1][0][0]=f[mid+1][1][0]=f[mid+1][0][1]=0, f[mid+1][1][1]=a[mid+1];
    for(int i=mid+2;i<=r;++i) rep(j,0,1) {
        f[i][j][0]=max(f[i-1][j][0],f[i-1][j][1]);
        f[i][j][1]=f[i-1][j][0]+a[i];
    }
    for(int i=mid+1;i<=r;++i) {
        g[i][0]=max(f[i][0][0],f[i][0][1]);
        g[i][1]=max(f[i][1][0],f[i][1][1]);
        (ans+=g[i][0]*cntl%mod)%=mod;
        v.pb({g[i][1]-g[i][0],1});
    }
    sort(v.begin(),v.end(),greater<PII >());
    for(auto t:v) {
        int x=(t.fi+mod)%mod, type=t.se;
        if(!type) (ans+=x*cntr%mod)%=mod, --cntl;
        else (ans+=x*cntl%mod)%=mod, --cntr;
    }


}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    solve(1,n);
    printf("%lld\n",ans);
    return 0;
}
```
