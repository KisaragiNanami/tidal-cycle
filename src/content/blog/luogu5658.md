---
title: luogu5658 括号树 题解
tags:
  - 栈
categories:
  - 题解
pubDate: 2022-04-11
description: 'Solution'
---

## 分析

水一篇题解，明天写 CSP-S2021 T2 括号序列。

考虑序列上的情况，设 $f_i$ 为序列中以 $i$ 结尾的合法序列的数量（注意是以 $i$ 结尾，不是 $[1,i]$ 中的合法序列数量）。那么如果 $s_i$ 是左括号，那么将它入栈，$f_i =0$。如果 $s_i$ 为右括号，则有

$$

$$





其中 $l_i$ 是与 $i$ 配对的左括号位置。

最终答案为 $\sum_{i=1}^n f_i$。

现在考虑树上的情况。由于是一棵树，两点之间有且仅有一条简单路径，所以我们每次都是处理一条链的情况。在链上，$l_i-1$ 就变成了 $l_i$ 的父亲节点，其他都是一样的。

还是一样，遇到左括号就将它入栈。否则就如果栈顶元素是左括号，维护信息；如果是右括号，那就把它入栈。处理完一个节点要回溯时，撤销当前节点的操作，不影响下一条链的信息。

## CODE

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
const int N=5e5+10;
#define R register
#define ll long long
int n, tp, f[N], fr[N], sk[N];
int c, h[N], ver[N<<1], nxt[N<<1];
ll ans;
char s[N];
void add(int x,int y) { ver[++c]=y, nxt[c]=h[x], h[x]=c; }
void dfs(int x,ll res) {
    R int i, y=0;
    if(s[x]=='(') sk[++tp]=x;
    else {
        if(!tp||s[sk[tp]]==')') sk[++tp]=x;
        else y=sk[tp], f[x]=f[fr[sk[tp--]]]+1;
    }
    res+=f[x], ans^=1ll*x*res;
    // 统计答案
    for(i=h[x];i;i=nxt[i]) dfs(ver[i],res);
    if(y) sk[++tp]=y; else --tp;
    // 撤销本次操作

}
int main() {
    scanf("%d%s",&n,s+1);
    for(R int i=2;i<=n;++i) scanf("%d",&fr[i]), add(fr[i],i);
    dfs(1,0);
    printf("%lld\n",ans);
}
```
