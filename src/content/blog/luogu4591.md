---
title: luogu4591 碱基序列 题解
tags:
  - DP
  - KMP算法
categories:
  - 题解
description: 'Solution'
pubDate: 2022-08-12
---

## 分析

设 $f_{i,j}$ 为使用了 $i$ 个串，匹配到了 $S$ 的前 $j$ 位的方案数。

$$
f_{i,j} = \sum_{S[i-m,i] = S_0} f_{i-1,i-m}
$$

其中 $S_0$ 表示一个匹配串，$S[i-m,i]$ 是这个长度为 $m$ 的匹配串的长度。

可以用 KMP 算法快速求出匹配串 $S_0$ 在 $S$ 中出现的所有位置，最终答案为 $\sum_{i=0}^n f_{k,i}$。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e4+5, mod=1e9+7;
int n, m, k, ans, cur, nxt[N], f[105][N];
char s[N], p[N];
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
void kmp(int k) {
    nxt[1]=0;
    for(int i=2,j=0;i<=m;++i) {
        while(j&&p[i]!=p[j+1]) j=nxt[j];
        if(p[i]==p[j+1]) ++j;
        nxt[i]=j;
    }
    for(int i=1,j=0;i<=n;++i) {
        while(j&&s[i]!=p[j+1]) j=nxt[j];
        if(s[i]==p[j+1]) ++j;
        if(j==m) (f[k][i]+=f[k-1][i-m])%=mod, j=nxt[j];
    }
}
signed main() {
    k=read();
    scanf("%s",s+1), n=strlen(s+1);
    for(int i=0;i<=n;++i) f[0][i]=1;
    for(int i=1;i<=k;++i) {
        int q=read();
        while(q--) {
            scanf("%s",p+1);
            m=strlen(p+1);
            kmp(i);
        }
    }
    for(int i=0;i<=n;++i) (ans+=f[k][i])%=mod;
    printf("%lld\n",ans);
}
```
