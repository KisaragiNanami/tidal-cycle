---
title: AGC012E Camel and Oases 题解
pubDate: 2023-11-16
tags:
  - DP
  - 状态压缩
categories:
  - 题解
description: 'Solution'
---

## Solution

任意位置任意时刻，能到达的绿洲一定是一段区间。

注意到只会跳跃 $O(\log V)$ 次。

设 $L(i,j)$ 为跳跃了 $i$ 次，在 $j$ 向左出发能走到的最远点，$R(i,j)$ 类似。对于一个 $i,j$，区间 $[L(i,j),R(i,j)]$ 中的点都可以无伤互相到达，并且这些区间都是极长的，不妨称每层本质不同的区间为线段。如果我们把按照 $i$ 递增，从上到下把每个状态的线段分层，可以发现一个很强的性质：不存在低层线段跨越或包含高层线段的情况。

我们考虑对 $i=0$ 时的每一个线段求解。问题可以转化为，对 $i>0$ 的层，每一层选择一条线段，一部分向左覆盖到 $1$，一部分向右覆盖到 $n$，使得这两块与那条线段拼起来能覆盖 $1 \sim n$。由于上面那条很强的性质，所以不会有一个区间既能向左贡献又能向右贡献。

如何求解呢？注意到层数是 $O(\log V)$ 级别的，设 $f(S)$ 为在 $i>0$ 的层选择了 $S$ 中的层贡献右端点，从 $1$ 开始最远覆盖到的位置，$g(S)$ 类似。转移时从高层循环到低层，这样能保证是一个拓扑序，原因还是上面那条很强的性质。

设当前求解的线段为 $[l,r]$，只要存在 $S$，使得 $f(S) \ge l-1$ 并且 $g(U \setminus S) \le r+1$，就能使 $[l,r]$ 中的每一个点满足条件。

但这样做的复杂度是 $O(kV)$ 的，其中 $k$ 是 $i=0$ 层的极长线段长度。

还是上面那条很强的性质，我们最多选择 $O(\log V)$ 条线段，并且低层的线段一定全方位小于高层线段，所以如果第一层的线段数量超过层数 $+1$，那么所有点都不满足条件。因此复杂度是 $O(V \log V)$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
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
const int N=2e5+5, LGN=19;
int n, v, cnt, U, x[N], L[LGN][N], R[LGN][N];
int f[1<<LGN], g[1<<LGN], ans[N];
vector<int> h;
signed main() {
    n=read(), v=read();
    rep(i,1,n) x[i]=read();
    int t=v;
    do {
        t>>=1;
        h.pb(t);
    } while(t);
    U=(1<<h.size())-1;
    cnt=h.size();
    h.pb(v);
    // 注意vector的下标，h[cnt]是最高层，h[0]是次高层
    rep(i,0,cnt) {
        rep(j,1,n) {
            if(j==1||x[j]-x[j-1]>h[i]) L[i][j]=j;
            else L[i][j]=L[i][j-1];
        }
        per(j,n,1) {
            if(j==n||x[j+1]-x[j]>h[i]) R[i][j]=j;
            else R[i][j]=R[i][j+1];
        }
    }
    rep(S,0,U) {
        g[S]=n+1;
        rep(i,0,cnt-1) if((S>>i)&1) {
            f[S]=max(f[S],R[i][f[S^(1<<i)]+1]);
            g[S]=min(g[S],L[i][g[S^(1<<i)]-1]);
        }
    }
    vector<PII > seg;
    rep(i,1,n) if(L[cnt][i]==i) {
        // 无法再扩展，说明这是线段的端点
        seg.pb({L[cnt][i],R[cnt][i]});
    }
    if(seg.size()>cnt+1) {
        rep(i,1,n) puts("Impossible");
        exit(0); 
    }
    for(auto t:seg) {
        rep(S,0,U) {
            int T=U^S;
            if(f[S]>=t.fi-1&&g[T]<=t.se+1) {
                rep(i,t.fi,t.se) ans[i]=1;
                break;
            }
        }
    }
    rep(i,1,n) if(ans[i]) puts("Possible"); else puts("Impossible");
    return 0;
}
```


