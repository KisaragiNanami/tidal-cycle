---
title: SDCPC2023 个人题解
pubDate: 2025-07-20
categories: 
  - 比赛
  - 题解
tags: 
  - 二进制
  - 并查集
  - 数论
  - 贪心
description: '身败名裂了。'
---



## luogu9556 [SDCPC 2023] Orders

货物按天排个序，求个和，找日期分界线，判一下够不够即可。

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
#define pf push_front
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
int T, n, k;
ll s[305];
PII a[305];
void solve() {
    n=read(), k=read();
    rep(i,1,n) a[i].fi=read(), a[i].se=read();
    sort(a+1,a+n+1);
    rep(i,1,n) s[i]=s[i-1]+a[i].se;
    int now=0, t=0;
    int l=1;
    while(l<=n) {
        int r=l;
        while(r<=n&&a[r].fi==a[l].fi) r++;
        if(a[l].fi==a[r-1].fi&&s[r-1]>1ll*k*a[r-1].fi) {
            puts("No");
            return;
        }
        l=r;
    }
    puts("Yes");
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu9558 [SDCPC 2023] Trie

不会

## luogu9562 [SDCPC 2023] Matching

考虑如果有边 $(i , j),(j , k)$。

$$  
\begin{align}  
i-j=a_i - a_j  
\\  
i-k=a_i-a_k  
\end{align}  
$$

联立

$$  
j-k = a_j - a_k  
$$

即存在边 $(j,k)$。

手玩一下不难发现图是由若干个连满对角线的多边形构成的。

移相，然后

$$  
a_i - i = a_j - j  
$$

这样就能得到所有连通块了。

如何选边？

按照 $a_i$ 排个序，从大到小两个两个选即可。

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
#define pf push_front
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
const int N=1e5+5;
int T, n, m, a[N], v[N];
map<int,int> mp;
vector<int> p[N];
void solve() {
    n=read();
    mp.clear();
    ll ans=0;
    m=0;
    rep(i,1,n) a[i]=read(), mp[a[i]-i]=++m, p[i].clear();
    rep(i,1,n) {
        int j=mp[a[i]-i];
        p[j].pb(a[i]);
    }
    rep(i,1,m) {
        sort(p[i].begin(),p[i].end(),greater<int>());
        int lim=p[i].size(); // [0,lim)
        if(lim<2) continue;
        if(lim&1) --lim;
        for(int j=0;j<lim-1;j+=2) ans+=max(p[i][j]+p[i][j+1],0);
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu9567 [SDCPC 2023] Puzzle: Sashigane

没做。

## luogu9568 [SDCPC 2023] Computational Geometry

不会计算几何。

## luogu9557 [SDCPC 2023] Building Company

做不出来。

太失败了。

马上写掉。

## luogu9560 [SDCPC 2023] Math Problem

太失败了。

特殊情况就不讲了。

操作二可以直接抵消掉操作一，也就是操作序列必然若干操作二接上若干操作一。

枚举操作二的次数，然后

$\textbf{Lemma}$

> 设 $f(n)=kn+k-1$，则通过 $t$ 次操作一，能够得到 $[k^{t-1}n,f^{t}(n)]$。

$\textbf{Proof}$

> 数学归纳法。
> 
> 当 $t=1$ 时，显然成立。
> 
> 假设 $t=p$ 时成立，下证当 $t=p+1$ 时也成立。
> 
> 此时我们已经得到了区间 $[k^{t-1}n,f^t(n)]$ 的所有数。
> 
> 对于区间 $x \in [k^{t-1}n,f^t(n)]$，它可以得到 $[kx,kx+k-1]$，然后 $x+1$ 有 $[k(x+1),k(x+1)+k-1]$，可以发现这是连续的。首位一接正好填满。
> 
> 所以得到了区间 $[k^{t}n,f^{t+1}(n)]$。
> 
> 故命题对 $t \in N^{+}$ 都成立。
> 
> 证毕。

好像证了个很显然的东西。

但自己做的时候真的没想到。

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
#define pf push_front
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(b))
#define rep(i,j,k) for(int i=(j);i<=(k);++i)
#define per(i,j,k) for(int i=(j);i>=(k);--i)
ll read() {
   ll a=0, f=1; char c=getchar();
   while(!isdigit(c)) {
       if(c=='-') f=-1;
       c=getchar();
   }
   while(isdigit(c)) a=a*10+c-'0', c=getchar();
   return a*f;
}
int T, k, m, a, b;
ll n;
void solve() {
    n=read(), k=read(), m=read(), a=read(), b=read();
    if(n%m==0) {
        puts("0");
        return;
    }
    if(k==1) {
        // a,bは無駄です
        puts("-1");
        return;
    }
    // bbb...aaa
    ll ans=(1ll<<63)-1, res=0;
    while(n) {
        __int128 l=n, r=n;
        ll t=0;
        while(l%m&&(l/m==r/m)) {
            // l不为m倍数并且可达范围不跨越m倍数
            l*=k;
            r=r*k+k-1;
            t+=a;
        }
        ans=min(ans,res+t);
        n/=k, res+=b;
    }
    printf("%lld\n",min(ans,res));
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu9561 [SDCPC 2023] Colorful Segments

[link](https://nanami7.top/blog/luogu9561/)

## luogu9564 [SDCPC 2023] Three Dice

模拟。

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
#define pf push_front
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
int A, B;
vector<int> a, b;
signed main() {
    A=read();
    B=read();
    if(A>12||B>18) {
        puts("No");
        return 0;
    }
    a.pb(1), a.pb(4);
    b.pb(2), b.pb(3), b.pb(5), b.pb(6);
    rep(i,0,3) {
        // 红色个数
        if((i==0&&A>0)||(i==3&&B>0)) {
            continue;
        }
        if(i==0) {
            for(auto x:b) for(auto y:b) for(auto z:b) {
                if(x+y+z==B) {
                    puts("Yes");
                    return 0;
                }
            }
        } else if(i==1) {
            for(auto x1:a) for(auto x:b) for(auto y:b) {
                if(x1==A&&x+y==B) {
                    puts("Yes");
                    return 0;
                }
            }
        } else if(i==2) {
            for(auto x:a) for(auto y:a) for(auto x1:b) {
                if(x+y==A&&x1==B) {
                    puts("Yes");
                    return 0;
                }
            }
        } else if(i==3) {
            for(auto x:a) for(auto y:a) for(auto z:a) {
                if(x+y+z==A)  {
                    puts("Yes");
                    return 0;
                }
            }
        }
    }
    puts("No");
    return 0;
}
```

## luogu9559 [SDCPC 2023] Fast and Fat

二分答案 $mid$。

展开

$$  
v_i + w_i - w_j  
$$

考虑超过 $v_i \ge mid$ 的 $i$，用大的 $v_i+w_i$ 贪心匹配较大的 $w_j$。

维护两个堆即可。

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
#define pf push_front
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
const int N=1e5+5;
int T, n, v[N], w[N];
bool check(int k) {
    priority_queue<int> q, q2;
    rep(i,1,n) {
        if(v[i]>=k) q.push(v[i]+w[i]);
        else q2.push(w[i]);
    }
    while(q2.size()) {
        if(q.empty()) return false;
        int x=q2.top(); q2.pop();
        int y=q.top();
        if(y-x>=k) q.pop();
        else return false;
    }
    return true;
}
void solve() {
    n=read();
    int l=0, r=0;
    rep(i,1,n) v[i]=read(), w[i]=read(), r=max(r,v[i]);
    while(l<r) {
        int mid=(l+r+1)>>1;
        if(check(mid)) l=mid; else r=mid-1;
    }
    printf("%d\n",l);
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu9563 [SDCPC 2023] Be Careful 2

不会

## luogu9566 [SDCPC 2023] Difficult Constructive Problem

不会，可能会补一下。

## luogu9565 [SDCPC 2023] Not Another Path Query Problem

一条路径合法，当且仅当路径权值与大于等于 $V$。

1. 等于 $V$。

3. 大于 $V$。

等于就不说了。

如果路径与大于 $V$，那么一定存在一位 $k$，满足路径权值与这一位是 $1$，$V$ 这一位是 $0$。同时更高位相同，后面不关心。

位数不多，枚举 $k$ 即可。

用并查集维护合法边的连通块即可回答询问。

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
#define pf push_front
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(b))
#define rep(i,j,k) for(int i=(j);i<=(k);++i)
#define per(i,j,k) for(int i=(j);i>=(k);--i)
ll read() {
   ll a=0, f=1; char c=getchar();
   while(!isdigit(c)) {
       if(c=='-') f=-1;
       c=getchar();
   }
   while(isdigit(c)) a=a*10+c-'0', c=getchar();
   return a*f;
}
const int N=5e5+5;
int n, m, Q, ans[N];
ll V;
struct edge { int x, y; ll z; } e[N];
struct query { int x, y; } q[N];
namespace djs {
    int fa[N];
    void init() { rep(i,1,n) fa[i]=i; }
    int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
    void merge(int x,int y) {
        x=get(x), y=get(y);
        if(fa[x]!=y) fa[x]=y;
    }
};
signed main() {
    n=read(), m=read(), Q=read(), V=read();
    rep(i,1,m) e[i].x=read(), e[i].y=read(), e[i].z=read();
    rep(i,1,Q) q[i].x=read(), q[i].y=read();
    djs::init();
    for(int i=59;~i;i--) if(((V>>i)&1)==0) {
        djs::init();
        // 大于V
        // x当前位1，V当前位0，后面不关心
        ll x=((V>>i)+1)<<i;
        rep(j,1,m) if((e[j].z&x)>=x) djs::merge(e[j].x,e[j].y);
        rep(j,1,Q) if(djs::get(q[j].x)==djs::get(q[j].y)) ans[j]=1; 
    }

    djs::init();
    rep(j,1,m) if((e[j].z&V)>=V) djs::merge(e[j].x,e[j].y);
    rep(j,1,Q) {
        if(djs::get(q[j].x)==djs::get(q[j].y)) ans[j]=1;
        if(ans[j]) puts("Yes");
        else puts("No");
    }
    return 0;
}
```
