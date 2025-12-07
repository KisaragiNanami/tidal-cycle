---
title: 「NowCoder Round X」#55 个人题解
tags:
  - 贪心
  - 构造
  - DP
  - 组合数学
categories:
  - 题解
  - 比赛
description: '个人题解'
pubDate: 2022-08-21
---

**NowCoderX55**.



## A. 至至子的等差中项

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
int a, b;
signed main() {
    a=read(), b=read();
    printf("%lld\n",2*b-a);
}
```

## B. 至至子的按位与



从高位往低位贪心即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
int a, b;
signed main() {
    a=read(), b=read();
    int c=0;
    for(int i=62;~i;--i) {
        int x=(a>>i)&1, y=(b>>i)&1;
        if(x==y) c|=1ll<<i;
    }
    printf("%lld\n",c);
}
```



## C. 至至子的斐波那契

注意到 $fib_{92}$ 是范围内最大的一项。二分查找即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
int T, R, f[105];
void solve() {
    int x=read();
    if(x==1) { puts("1"); return; }
    int l=1, r=92, k=0;
    while(l<r) {
        int mid=(l+r+1)/2;
        if(f[mid]<=x) l=mid; else r=mid-1;
    }
    k=l;
    int ans=abs(f[k]-x)<=abs(f[k+1]-x)? k:k+1;
    printf("%lld\n",ans);
}
signed main() {
    f[1]=f[2]=1;
    for(int i=3;i<=92;++i) f[i]=f[i-1]+f[i-2];
    T=read();
    while(T--) solve();
}
```

## D. 至至子的鸿门宴

由于双方足够聪明，所以最终的局面一定是 $a_1 = 1,a_2 = 2 , \ldots a_n = n$。

所以判断总操作数 $\sum_{i=1}^n (a_i - i)$ 的奇偶性即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
int n;
signed main() {
    n=read();
    int ans=0;
    for(int i=1;i<=n;++i) ans+=read()-i;
    if(ans&1) puts("ZZZ"); else puts("SSZ");
}
```

## E. 至至子的长链剖分

树根一定是最大值，如果最大值不唯一，那么一定无解。

显然最终值为 $i$ 的节点一定是值为 $i+1$ 的节点的儿子，而儿子节点的数量一定不多于父节点，否则无解。

然后一顿瞎连就行了。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=2e5+5;
int T, n, mx, root, cnt, h[N];
vector<pair<int,int> > p[N], ans;
#define fr first
#define sc second
#define pb push_back
void solve() {
    n=read();
    mx=root=cnt=0;
    for(int i=1;i<=n;++i) {
        h[i]=read(), mx=max(mx,h[i]);
        p[i].clear();
    }
    p[0].clear();
    ans.clear();
    for(int i=1;i<=n;++i) {
        if(h[i]==mx) ++cnt, root=i;
        p[h[i]].pb({h[i],i});
    }
    if(cnt!=1) { puts("-1"); return; }
    for(int i=0;i<mx;++i)
        if(p[i].size()<p[i+1].size())  { puts("-1"); return; }
    for(int i=0;i<mx;++i) {
        int sz=p[i+1].size();
        for(int j=0;j<p[i].size();++j) {
            ans.pb({p[i][j].sc,p[i+1][min(sz-1,j)].sc});
        }
    }
    printf("%lld\n",root);
    for(auto pp:ans) printf("%lld %lld\n",pp.fr,pp.sc);

}
signed main() {
    T=read();
    while(T--) solve();
}
```



## F. 至至子的公司排队

每棵树是互相独立的，因此可以分别考虑，合并答案。

对于一棵树 $i$，设 $f_x$ 为在以 $x$ 为根的子树中，满足条件的排列方法数量。

先不考虑每个子节点子树内的情况，设子节点集合为 $\{y\}$，大小为 $m$。

转移方法有两种。

一，多重集的全排列。。那么对于 $y_i$，相当于存在 $sz_{y_i}$ 个相同元素，总的元素个数为 $sz_x - 1$，最后对于每个 $y_i$，其内部的方案数为 $f_{y_i}$，相乘即可。

$$
f_x = \prod_{i=1} f_{y_i} \frac{(sz_x - 1)!}{\prod_{i=1}^m (sz_{y_i}!)}
$$



二，子树合并。其实我也不太明白这种东西是怎么证明的，但是看起来比较直观一些。

$$
f_x = \prod_{i=1}^m f_{y_i} C_{sz_x' - 1}^{sz_{y_i}}
$$





其中 $sz_x'-1 = \sum_{j=1}^i sz_{y_i}$。

&nbsp;

最后合并不同树的时候，也可以使用上述两种方法。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define pb push_back
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
const int N=1e5+5, mod=1e9+7;
int n, cnt, ans=1, c[N], f[N], fac[N], inv[N], sz[N];
int tot, h[N], to[N<<1], nxt[N<<1];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
    add(x,y), add(y,x);
}
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void init() {
    fac[0]=fac[1]=1;
    const int d=1e5;
    for(int i=2;i<=d;++i) fac[i]=fac[i-1]*i%mod;
    inv[d]=fp(fac[d],mod-2);
    for(int i=d-1;~i;--i) inv[i]=inv[i+1]*(i+1)%mod;
}
int C(int n,int m) {
    if(n<m) return 0;
    return fac[n]*inv[m]%mod*inv[n-m]%mod;
}
void dp(int x,int fa) {
    sz[x]=1, f[x]=1;
    int F=1, g=1;
    for(int i=h[x];i;i=nxt[i]) {
        int y=to[i];
        if(y==fa) continue;
        dp(y,x);
        sz[x]+=sz[y];
        (f[x]*=f[y]*C(sz[x]-1,sz[y])%mod)%=mod;
        // (F*=f[y])%=mod, (g*=inv[sz[y]])%=mod;
    }
    // f[x]=(F*fac[sz[x]-1]%mod*g%mod)%mod;
    // 注释掉的是多重集全排列
}
signed main() {
    init();
    n=read();
    for(int i=1;i<=n;++i) {
        c[i]=read();
        tot=0;
        for(int j=0;j<=c[i];++j) h[j]=0;
        for(int j=2;j<=c[i];++j) {
            int p=read();
            addedge(p,j);
        }
        dp(1,0);
        cnt+=c[i];
        (ans*=f[1]*C(cnt,c[i])%mod)%=mod;
        // 这也是子树合并
    }
    printf("%lld\n",ans);
}
```
