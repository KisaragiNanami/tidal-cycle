---
title: CCPC2025 Chongqing Warm up 个人题解
pubDate: 2025-12-08
tags:
  - 贪心
  - 数学
categories:
  - 比赛
  - XCPC
  - CCPC
description: '断断续续做着玩'
---
## A. 找规律

身败名裂 + 1，高数课上推着玩，没想到没看出规律（

搞了一堆东西，三角形数、质数之类的，高阶前缀和，高阶差分，却发现总是缺少条件。

没想到就是质数平方减 1 啊。

$$
3^2 - 1, 5^2 - 1, 7^2 - 1, 11 ^2 - 1, 13^2 - 1 = 168
$$

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
signed main() {
    cout << "168" << endl;
    return 0;
}
```

## B. 动态的果子合并

这是真好题。

我们先考虑，不存在增删操作这题怎么做。

关键就在于集合 $B$。为什么我们直接计算 $A$ 的合并需要 $O(n \log n)$，但是却可以快速计算 $A \cup B$ 的合并呢?

考虑为何普通情况下无法再加速。

两个原因：

1. 只能 $O(\log n)$ 求最小值。
2. 无法统计每个元素对答案的贡献，只能 $O(n)$ 求出每次被合并的数。

那为何在加入集合 $B$ 之后反而能解决这两个问题了呢？

注意到 $2^k + 2^k  = 2^{k+1}$ ，我们充分发扬人类智慧，把集合 $B$ 摊到这样一个数轴上。

为了直观就不要考虑间距了。

然后 $A$ 中的数就是分布在这些区间里的点，每次就是从左往右选两个点再把它们的和放上去。

先不考虑重合的情况，设当前两个最小值是 $2^k$ 和 $x$，且 $2^k < x < 2^{k+1}$，此时一定有 $2^{k+1} < 2^{k} + x < 2^{k + 2}$，也就是说，这两个数往后“跳跃”到了下一个区间，且不可能跳不到或跳过去。

![](https://s2.loli.net/2025/12/08/xUeTjW4BCD6qw3b.png)

然后我们就能构建这样一个过程：最小的两个数不断往右跳一个区间，答案加上它们之和，然后这些区间从左到右依次处理。

这个过程的复杂度是 $O(|B|)$，问题在于如何高效计算一个区间所有点的贡献。

抛开作为端点的 $2^k$，如果区间有奇数个数，和为 $S$，那么对答案的贡献就是 $2^k + S$，同时这些数又会在后面不断产生贡献，称其为 $St$。如果个数为偶数，那么对答案的贡献为 $2^k + S + 2^{k + 1}$，然后这个 $2^{k+1}$ 就不能再当端点考虑了。

考虑这个端点只会让问题复杂化。我们能发现每个 $2^k$ 都得加入 $St$ ，只是时间不同。前者是在当前区间加入 $St$，后者是在前一个区间加入。这样两种情况对后面的贡献其实是一样的。

具体地，我们维护一个变量 $St$ 表示当前的贡献和，$Ct$ 表示当前要合并的数量。由于 $B$ 中不含 $2^0$，所以我们要把 $2^k$ 当成右端点来看。用 $Ct$ 处理当前区间一共有多少需要合并的数（不含右端点）。 奇数个就向答案贡献 $St + S + 2^{k+1}$，偶数个则是 $St + S$。每处理完区间 $[2^k,2^{k+1})$，就让 $St$ 加上 $S + 2^{k+1}$。

注意集合的最大值是 $2^{54}$，是一个右端点，这时候我们再贡献一次 $St$ 即可。

这样就能 $O(|B|)$ 处理一次的贡献了。增删可以 $O(\log x)$ 做到，直接修改对应区间的数字个数与总和。

总复杂度 $O(n \log \max_{i=1}^n\{a_i\} + m|B|)$。

```cpp
#include<bits/stdc++.h>
#include<cmath>
using namespace std;
#define ll long long
typedef unsigned long long ull;
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
const int N = 1e5 + 5, M = 60;
int n, q, cnt[M];
ll a[N], sum[M];
int lg2(ll x) {
    int res = 0;
    while(x > 1) {
        x >>= 1;
        res++;
    }
    return res;
}
signed main() {
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    cin >> n >> q;
    for(int i = 1;i <= n;i++) {
        cin >> a[i];
        cnt[lg2(a[i])]++;
        sum[lg2(a[i])] += a[i];
        // cnt[k] = the count of a[i] in [2^k,2^(k+1))
    }
    while(q--) {
        int op;
        ll x;
        cin >> op >> x;
        int bel = lg2(x);
        if(op == 1) cnt[bel]++, sum[bel] += x;
        else cnt[bel]--, sum[bel] -= x;
        ll ans = 0, st = 0, ct = 0;
        int t = 0;
        for(int i = 0;i < 54;i++) {
            ct += cnt[i];
            if(ct & 1) {
                ans += st + sum[i] + (1ll << (i + 1));
                t = 0;
            }
            else {
                ans += st + sum[i];
                t = 1;
            }
            st += sum[i] + (1ll << (i + 1));
            ct = (ct >> 1) + 1;
        }
        if(ct > 1) ans += st;
        cout << ans << endl;
    }
    return 0;
}
```
