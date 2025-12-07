---
title: luogu7915 回文 题解
tags:
  - 贪心
  - 搜索
categories: 题解
description: 'Solution'
pubDate: 2022-06-20
---



由于操作和回文串的性质，尝试 meet-in-the-middle。

注意到任何时候剩下的数都是一段区间，然后我们根据前面放了啥倒着扣掉一些数，不难发现想要成功构造那么这些数也必然构成一个区间。

大胆猜测，只要扣掉的区间一直是剩下的区间的子区间，那么就合法。

在选数的过程中容易得到操作序列，所以只要贪心选择字典序小的即可。

开头的数只能是 $a_1$ 或 $a_{2n}$，可以枚举，然后找另一个相同的值，它就是第一个被扣掉的数。

于是我们搞一个`DFS(p,l,r,L,R)`表示当前放完了 $p$ 个数，剩下的区间是 $[l,r]$，扣掉的区间是 $[L,R]$，能得到的最优解。往下递归就是说尝试缩小 $[l,r]$，扩大 $[L,R]$，不难发现这玩意一次最多往下 $\text{DFS}$ 一次，最多 $n$ 层，所以复杂度是 $O(n)$ 的。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define LL long long
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
const int N=1e6+5;
int T, n, fg, a[N], ans[N];
bool valid(int l,int r,int L,int R) {
    return l<=r&&L<=R&&l<=L&&R<=r;
}
void dfs(int p,int l,int r,int L,int R) {
    if(p>n/2) return;
    if(!fg) return;
    if(valid(l+1,r,L-1,R)&&a[l]==a[L-1]) {
        ans[p]=1, ans[n-p+1]=1;
        dfs(p+1,l+1,r,L-1,R);
    } else if(valid(l+1,r,L,R+1)&&a[l]==a[R+1]) {
        ans[p]=1, ans[n-p+1]=2;
        dfs(p+1,l+1,r,L,R+1);
    } else if(valid(l,r-1,L-1,R)&&a[r]==a[L-1]) {
        ans[p]=2, ans[n-p+1]=1;
        dfs(p+1,l,r-1,L-1,R);
    } else if(valid(l,r-1,L,R+1)&&a[r]==a[R+1]) {
        ans[p]=2, ans[n-p+1]=2;
        dfs(p+1,l,r-1,L,R+1);
    } else fg=0;
}
void solve() {
    n=read()*2;
    rep(i,1,n) a[i]=read();
    ans[n]=1;
    int ll=0;
    for(int i=2;i<=n;++i) if(a[i]==a[1]) { ll=i; break; }
    fg=1;
    ans[1]=1;
    dfs(2,2,n,ll,ll);
    if(fg) {
        for(int i=1;i<=n;++i) printf("%c",(ans[i]&1? 'L':'R'));
        puts("");
        return;
    }
    fg=1;
    int rr=0;
    for(int i=1;i<n;++i) if(a[i]==a[n]) { rr=i; break; }
    ans[1]='R';
    dfs(2,1,n-1,rr,rr);
    if(fg) {
        for(int i=1;i<=n;++i) printf("%c",(ans[i]&1? 'L':'R'));
        puts("");
        return;
    }
    puts("-1");
}
signed main() {
    freopen("palin.in","r",stdin);
    freopen("palin.out","w",stdout);
    T=read();
    while(T--) solve();
    return 0;
}
```
