---
title: luogu1973 NOI嘉年华 题解
pubDate: 2023-09-22
tags:
  - DP
  - 决策单调性
categories: 题解
description: 'Solution'
---



两个集合的区间不能有交，这启发我们从区间端点处进行划分。

先把区间端点离散化了。设 $f(i,j)$ 为考虑前 $i$ 个端点，其中第一个集合选择了 $j$ 个区间时，第二集合的最大大小。

转移枚举断点 $k$，讨论放到把 $[k,i]$ 内所有的区间放到哪一个集合即可。

$$
f(i,j) = \max_{k=1}^i \bigg\{ f(k,j)+\text{cnt}(k,i),f\Big(k,j-\text{cnt}(k,i)\Big) \bigg\}
$$



第一问就做完了，答案是

$$
\max_{i=1}^n \bigg\{ \min \Big( f(m,i),i \Big) \bigg\}
$$

其中 $m$ 为离散化后的点数。

类似地求出 $g(i,j)$ 表示考虑后 $i$ 个端点，其中第一个集合选择了 $j$ 个区间时，第二个集合的最大大小。

这样我们就能得到 $h(l,r)$，表示钦定一个集合选择 $[l,r]$ 中的所有区间时，第二个区间的最大大小。转移只需要枚举左右选择的区间个数。

$$
h(l,r) = \max_{x=1}^n \max_{y=1}^n \bigg\{ \min\Big(x+\text{cnt}(l,r)+y,f(l,x)+g(r,y)\Big) \bigg\}
$$



不过 $h(l_i,r_i)$ 并不是强制选择第 $i$ 个区间时的最优解，因为跨越端点 $l_i$ 和 $r_i$ 的区间仍然没有考虑到。一个简单的解决方法是利用状态的简并性，暴力枚举 $\max_{s=1}^{l_i} \max_{t=r_i}^m \{h(s,t)\}$ 作为答案，不过预处理部分是 $O(n^4)$ 的，无法通过。

考虑用单调性优化 $h(l,r)$ 的计算。

设函数 $val(x,y) = \min\Big(x+\text{cnt}(l,r)+y,f(l,x)+g(r,y)\Big)$。它的决策单调性是比较容易发现的：对于递增的 $x$，让决策点 $y$ 右移一定不会让答案更优。

然后就能以 $O(n^3)$ 的复杂度计算 $h(l,r)$ 了。

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
const int N=405;
int n, cnt[N][N], pre[N][N], suf[N][N], f[N][N];
int m, tmp[N];
struct node {
    int l, r;
} a[N];
void lsh() {
    sort(tmp+1,tmp+m+1);
    m=unique(tmp+1,tmp+m+1)-tmp-1;
    rep(i,1,n) {
        a[i].l=lower_bound(tmp+1,tmp+m+1,a[i].l)-tmp;
        a[i].r=lower_bound(tmp+1,tmp+m+1,a[i].r)-tmp;
        rep(l,1,a[i].l) rep(r,a[i].r,m) ++cnt[l][r];
    }
}
int calc(int l,int r,int x,int y) {
    return min(x+cnt[l][r]+y,pre[l][x]+suf[r][y]);
}
signed main() {
    n=read();
    rep(i,1,n) {
        a[i].l=read(), a[i].r=a[i].l+read();
        tmp[++m]=a[i].l, tmp[++m]=a[i].r;
    }
    lsh();
    rep(i,1,m) rep(j,1,n) pre[i][j]=suf[i][j]=-1e9;


    rep(i,1,m) rep(j,0,cnt[1][i]) rep(k,1,i-1) {
        pre[i][j]=max(pre[i][j],pre[k][j]+cnt[k][i]);
        if(j>=cnt[k][i]) pre[i][j]=max(pre[i][j],pre[k][j-cnt[k][i]]);
    }
    per(i,m,1) rep(j,0,cnt[i][m]) rep(k,i+1,m) {
        suf[i][j]=max(suf[i][j],suf[k][j]+cnt[i][k]);
        if(j>=cnt[i][j]) suf[i][j]=max(suf[i][j],suf[k][j-cnt[i][k]]);
    }

    int ans=0;
    rep(i,1,n) ans=max(ans,min(pre[m][i],i));
    printf("%lld\n",ans);

    rep(l,1,m) rep(r,l+1,m) {
        for(int x=0,y=n;x<=n;++x) {
            while(y&&calc(l,r,x,y)<=calc(l,r,x,y-1)) --y;
            // 注意要写<=
            f[l][r]=max(f[l][r],calc(l,r,x,y));
        }
    }
    rep(i,1,n) {
        ans=0;
        rep(l,1,a[i].l) rep(r,a[i].r,m) ans=max(ans,f[l][r]);
        printf("%lld\n",ans);
    }
    return 0;
}
```
