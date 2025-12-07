---
title: luogu6406 [COCI2014-2015#2] Norma 题解
pubDate: 2023-11-11
tags:
  - 分治
  - 决策单调性
categories:
  - 题解
description: 'Solution'
---

## Solution

考虑分治。

对于当前处理的区间 $[L,R]$，枚举左端点 $l$，维护 $mn = \min_{i=l}^{mid} \{a_i\}$，$mx = \max_{i=l}^{mid} \{a_i\}$。

同时用 $pos_0$ 表示最靠右的 $p$，满足 $mn \le \min_{i=mid+1}^{p} \{a_i \}$，$pos_1$ 表示最靠右的 $p$，满足 $mx \ge \max_{i=mid+1}^{p} \{a_i \}$。

有了这些信息，我们就能将以 $l$ 为左端点的区间根据右端点 $r$ 的取值分为如下几类。

下面钦定 $pos_0 \le pos_1$。

1. $[mid+1,pos_0]$。此时贡献的最值系数相等，提出来之后就是一个等差数列求和，写出来就是
   
   $$
   \frac{\Big( (mid-l+1+1)+(pos_0-l+1) \Big) \times (pos_0-mid)}{2}
   $$

2. $(pos_0,pos_1]$。这些区间的 $\min$ 不满足条件，但 $\max$ 满足条件，所以贡献是
   
   $$
   mx \sum_{i=pos_0+1}^{pos_1} \Big((i-l+1) \min_{j=mid+1}^{i} \{a_j\}\Big)
   $$
   
   考虑如何计算这个和式。首先我们可以把 $[l,i]$ 拆成 $[l,mid]$ 与 $[mid+1,i]$，前者仅仅是作为贡献的一个系数，后者则可以用差分快速求出。具体地，维护 $\sum_{i=mid+1}^{R} (i-mid) \times pre_i$ 与 $\sum_{i=mid+1}^{R} pre_i$，其中 $pre$ 是前缀 $\min$。

3. $(pos_1,R]$。此时与 $mn$ 和 $mx$ 均无关。
   
   $$
   \sum_{i=pos_1+1}^{R} (i-l+1) \min_{j=pos_1+1}^{i} \{a_j\} \max_{j=pos_1+1}^{i} \{a_j\}
   $$
   
   用类似的办法处理即可。

对于 $pos_0 > pos_1$ 的情况，仅仅会对第二种贡献产生影响，对称着维护一个关于前缀 $\max$ 的东西就行。

代码中的变量名与上文有所不同。

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
const int N=5e5+5, mod=1e9;
int n, ans, a[N];
int s1[N], s2[N], s3[N], s4[N], s5[N], s6[N];
int calc(int i,int mid,int lim) {
    int l=mid+1-i+1, r=lim-i+1;
    return (l+r)*(lim-mid)/2%mod;
}
void solve(int l,int r) {
    if(l==r) { (ans+=a[l]*a[l]%mod)%=mod; return; }
    int mid=(l+r)>>1;

    int pmn=a[mid+1], pmx=a[mid+1];
    s1[mid]=s2[mid]=s3[mid]=s4[mid]=s5[mid]=s6[mid]=0;
    for(int i=mid+1;i<=r;++i) {
        pmn=min(pmn,a[i]), pmx=max(pmx,a[i]);
        s1[i]=(s1[i-1]+(i-mid)*pmn%mod)%mod;
        s2[i]=(s2[i-1]+pmn)%mod;
        s3[i]=(s3[i-1]+(i-mid)*pmx%mod)%mod;
        s4[i]=(s4[i-1]+pmx%mod)%mod;
        s5[i]=(s5[i-1]+(i-mid)*pmx%mod*pmn%mod)%mod;
        s6[i]=(s6[i-1]+pmx*pmn%mod)%mod;
    }
    int mn=a[mid], mx=a[mid], j=mid, k=mid;
    for(int i=mid;i>=l;--i) {
        mn=min(mn,a[i]), mx=max(mx,a[i]);
        while(j<r&&a[j+1]>mn) ++j;
        while(k<r&&a[k+1]<mx) ++k;
        int lim1=min(j,k), lim2=max(j,k);
        if(lim1>mid) (ans+=(mn*mx%mod*calc(i,mid,lim1)%mod)%mod)%=mod;
        if(j>lim1) (ans+=mn*((s3[j]-s3[lim1]+mod)%mod+(mid-i+1)*(s4[j]-s4[lim1]+mod)%mod)%mod)%=mod;
        if(k>lim1) (ans+=mx*((s1[k]-s1[lim1]+mod)%mod+(mid-i+1)*(s2[k]-s2[lim1]+mod)%mod)%mod)%=mod;
        (ans+=(s5[r]-s5[lim2]+mod)%mod+(mid-i+1)*(s6[r]-s6[lim2]+mod)%mod)%=mod;
    }
    solve(l,mid);
    solve(mid+1,r);
}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    solve(1,n);
    printf("%lld\n",ans);
    return 0;
}
```
