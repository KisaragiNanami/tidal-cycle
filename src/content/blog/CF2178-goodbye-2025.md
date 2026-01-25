---
title: CF2178 Goodbye 2025 个人题解
pubDate: 2026-01-03
categories: 
  - 比赛
  - 题解
tags: 
  - 构造
  - 贪心
description: '个人题解'
---

再见 2025

## A

限制是不能合并两个相邻的`Y`。

两个`N`合并后还是`N`，但如果是一个`Y`一个`N`，结果就是`Y`。

所以，合并过程中`Y`不会消失，一旦有超过一个`Y`，最后一定无法合并。

```cpp
#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef unsigned long long ull;
typedef pair<int,int> PII;
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
int T;
string s;
void solve() {
    cin >> s;
    int cnt = 0;
    for(auto x : s) if(x == 'Y') cnt++;
    if(cnt > 1) puts("NO");
    else puts("YES");
}
signed main() {
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    cin >> T;
    while(T--) solve();
    return 0;
}
```

## B

显然首尾的`u`必须改掉。

以下是场上胡乱猜的做法：

1. 从左往右扫一遍，维护 $lst$ 表示当前位置左边最近的`s`。
2. 如果当前位置为`s`，更新 $lst$。
3. 否则根据 $lst$ 计算右边对称的位置，如果其为`u`，将其更新为 `s`。

没想到竟然通过了。

怎么证明呢？

首先我们的原则是能不改就不改。

对于一个`u`，令其满足条件（更新右边的对称位置）代价为 1，改掉它代价也是 1。

因为我们提前改掉了首尾，所以每个`u`都会面临这样的抉择。

选择前者，以后扫到改的那个点时可以一定不必额外花费代价，后者则可能还有代价。

好像证出来了？

```cpp
#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef unsigned long long ull;
typedef pair<int,int> PII;
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
const int N = 2e5 + 5;
int T, n, pos[N];
string s;
void solve() {
    cin >> s;
    n = s.size();
    s = " " + s;
    int ans = 0;
    if(s[1] == 'u') s[1] = 's', ans++;
    if(s[n] == 'u') s[n] = 's', ans++;
    int lst = 0; 
    for(int i = 1;i <= n;i++) {
        if(s[i] == 'u') {
            if(lst) {
                if(s[i + i - lst] != 's') {
                    ans++;
                    s[i + i - lst] = 's';
                }
            }
        } else lst = i;
    }
    cout << ans << endl;
}
signed main() {
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    cin >> T;
    while(T--) solve();
    return 0;
}
```

## C

观察一下先。

1. $a_1$ 的贡献只能是 $a_1$。
2. 无论怎么操作，一定存在一个 $i \in [2, n]$，满足 $a_{i + 1}$ 到 $a_n$ 的贡献是 $- \sum_{j = i + 1}^n a_j$。因为最后肯定是先留着一个元素，然后用若干 $2$ 操作（可以是 $0$ 个）干掉那个元素后面的，最后 $1$ 操作干掉它。
3. 关键在于中间的情况。我们考虑对于第二个元素，如果它是正数，可以跟着 $a_1$ 用 $1$ 操作干掉，如果是负数，则可以先用 $2$ 操作干掉它。这两个过程中，第三个数会到第二个位置，第一个位置上可能是 $a_1$ 或 $a_2$，但 $a_2$ 最终一定能贡献出其绝对值。归纳一下，我们断定，中间的一段肯定可以贡献出每个元素的绝对值。

所以我们枚举贡献绝对值的间断点，其最后一个元素就可以作为 2 里提到的留着的那个元素，答案就是

$$
\max_{i = 2} \Big\{ a_1 + \sum_{j = 2}^i |a_j|- \sum_{j = i + 1}^{n} a_j \Big \}
$$


```cpp
#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef unsigned long long ull;
typedef pair<int,int> PII;
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
const int N = 2e5 + 5;
int T, n, a[N];
ll s[N], sa[N];
void solve() {
    cin >> n;
    for(int i = 1;i <= n;i++) {
        cin >> a[i];
        s[i] = s[i - 1] + a[i];
        sa[i] = sa[i - 1] + abs(a[i]);
    }
    ll ans = s[1] - s[n];
    for(int i = 2;i <= n;i++) {
        ll res = a[1] + sa[i - 1] - sa[1] + s[i] - s[n];
        ans = max(ans, res);
    }
    cout << ans << endl;
}
signed main() {
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    cin >> T;
    while(T--) solve();
    return 0;
}
```

## D

构造题，我们尝试去找到一些普遍的方法。

先给 $\{a\}$ 递增排个序。

考虑一个长度为 $n$ 并且攻击力递增的序列，第 $i$ 次操作让 $i + 1$ 攻击 $i$，这样就能用 $n - 1$ 次操作留下 $1$ 个元素且合法。

然后，再写这篇题解的时候，我突然想到可以在序列里 $k$ 个位置都进行这样的操作，这样肯定就能留下 $k$ 个了，有 $2k \le n$。但当时不知道为什么，我想到的是枚举一个点，这个点一边进行这种操作留下 $1$ 个，然后另一边不断让相邻两个里较大的干掉较小的，然后也能算出干掉的个数，范围和上面其实是一样的。

每进行一次操作，会且仅会干掉一个，次数容易计算且合法。

问题在于，当 $m = 0$ 时该怎么做。这也是场上卡我巨多时间的点。

其实就是最大的那个数怎么办的问题。

如果其他所有数的和还小于最大的数，那么肯定做不到。否则还是有希望的，然后我们就要寻找一个 $k$，先让最大值被一堆炮灰送死 + 消耗，然后在 $[1, k]$ 里面进行只存活一人的自相残杀，最后让 $k$ 干死大魔王，同时自己也受到反作用力而死。

那么这个 $k$ 就要满足 $a_k \le a_n - \sum_{i = k + 1}^{n - 1} a_i$ 并且 $a_n > \sum_{i = k + 1}^{n - 1} a_i$。

如果找不到这样的 $k$，那么无解。这个是否充要我不好说（雾

否则输出操作序列即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
typedef long long ll;
typedef unsigned long long ull;
typedef pair<int,int> PII;
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
const int N = 2e5 + 5;
int T, n, m, d, td;
ll s[N];
PII a[N];
void print(int x) {
    for(int i = 1;i < x;i++) {
        cout << a[i + 1].se << " " << a[i].se << endl;
    }
    for(int i = n;i > x;i -= 2) {
        cout << a[i].se << " " << a[i - 1].se << endl;
    }
}
void solve() {
    cin >> n >> m;
    d = n - m;
    td = 0;
    for(int i = 1;i <= n;i++) {
        int x = 0;
        cin >> x;
        a[i] = {x, i};
    }
    if(n == m) {
        cout << -1 << endl;
        return;
    }
    sort(a + 1, a + n + 1);
    if(m == 0) {
        if(n == 2) {
            cout << -1 << endl;
            return;
        }
        for(int i = 1;i <= n;i++) {
            s[i] = s[i - 1] + a[i].fi;
        }
        if(s[n - 1] < a[n].fi) {
            cout << -1 << endl;
            return;
        }
        int p = 0;
        for(int i = 1;i < n;i++) {
            if(a[i].fi >= a[n].fi - (s[n - 1] - s[i]) && a[n].fi - (s[n - 1] - s[i]) > 0) {
                p = i;
                break;
            }
        }
        if(!p) {
            cout << -1 << endl;
            return;
        }
        cout << n - 1 << endl;
        for(int i = 1;i < p;i++) {
            cout << a[i + 1].se << " " << a[i].se << endl;
        }
        for(int i = p + 1;i < n;i++) {
            cout << a[i].se << " " << a[n].se << endl;
        }
        cout << a[n].se << " " << a[p].se << endl;
        return;
    }
    if(n % 2 == 0) {
        if(d == n / 2) {
            cout << d << endl;
            for(int i = 1;i < n;i += 2) {
                cout << a[i + 1].se << " " << a[i].se << endl;
            }
            return;
        }
    }
    for(int i = 2;i <= n;i++) {
        int t = i - 1 + (n - i + 1) / 2;
        if(t == d) {
            cout << t << endl;
            print(i);
            return;
        }
    }
    cout << "-1" << endl;
}
signed main() {
    ios::sync_with_stdio(0);
    cin >> T;
    while(T--) solve();
    return 0;
}
```

## E

待补