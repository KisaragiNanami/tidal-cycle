---
title: luogu3604 美好的每一天 题解
pubDate: 2025-07-20
categories: 
  - 题解
tags: 
  - 状态压缩
  - 莫队
description: 'Solution'
---

## $\\text{Solution}$

在 7 月 20 日写下这篇有纪念意义题解。

初读不知题面意，再读早已成素批。

何时一个区间可以被重排为回文串？

1. 所有字母成对出现。

3. 在上一种情况的基础上添加一个字母。

因为要考虑每一个子区间，所以不能直接计算，必须差分掉。

如何差分？不难发现我们只考虑每个字母出现次数的奇偶性，同时字母只有`26`个，所以可以用一个二进制数来表示。设 $S\_i$ 为区间 $\[1,i\]$ 的字母出现情况。

对于区间 $\[l,r\]$，其答案为

$$  
\\sum\_{j=l}^r \\sum\_{i=l-1}^{j-1} \\left( \[S\_i=S\_j\] + \\sum\_{k=a}^z \[S\_i = S\_j \\oplus {k}\] \\right)  
$$

看上去很恐怖，实际可以维护一个大小为 $2^{26}$ 的桶（差不多`6e7`），保存左端点信息，扫一遍右端点，$O(n)$ 即可回答一个询问。

如何快速得到一个区间的桶？我们发现增加或减少一个元素，只需要在桶里添加或抹除其贡献即可。一个元素的贡献就是与其相同或异或掉一个字母后相同的元素个数，$O(1)$ 即可计算。

使用莫队算法，复杂度 $O(m \\sqrt{n})$。

## $\\text{Code}$

```
#include<bits/stdc++.h>
using namespace std;
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
const int N=60005;
int n, m, block, ans, pos[N], s[N], Ans[N], c[1<<26];
char ss[N];
struct Q {
    int l, r, id;
} q[N];
int cmp(Q a,Q b) {
    if(pos[a.l]!=pos[b.l]) return a.l<b.l;
    if(pos[a.l]&1) return a.r>b.r;
    return a.r<b.r;
}
int w(char c) { return c-'a'; }
void del(int x) {
    --c[x];
    rep(i,0,25) ans-=c[x^(1<<i)];
    ans-=c[x];
}
void add(int x) {
    rep(i,0,25) ans+=c[x^(1<<i)];
    ans+=c[x];
    ++c[x];
}
signed main() {
    n=read(), m=read();
    block=sqrt(n);
    scanf("%s",ss+1);
    rep(i,1,n) {
        pos[i]=(i-1)/block+1;
        s[i]=s[i-1]^(1<<w(ss[i]));
    }
    rep(i,1,m) q[i].l=read()-1, q[i].r=read(), q[i].id=i;
    sort(q+1,q+m+1,cmp);
    int l=1, r=0;
    rep(i,1,m) {
        while(l<q[i].l) del(s[l++]);
        while(l>q[i].l) add(s[--l]);
        while(r<q[i].r) add(s[++r]);
        while(r>q[i].r) del(s[r--]);
        Ans[q[i].id]=ans;
    }
    rep(i,1,m) printf("%d\n",Ans[i]);
}
```
