---
title: 「NOIP Record」#15 数论题目选讲
pubDate: 2023-08-24
tags:
  - 数论
categories:
  - Record
description: '少年随身带着纸笔'
---

## Hankson的趣味题

从质因子的角度考虑。

把 $a,b,c,d$ 都分解了，对于一个质因子 $p_i$，题目给出的条件等价于
$$
\min \Big( e_{p_i} (x) ,e_{p_i} (a)\Big) =e_{p_i}(c)
$$

$$
\max \Big( e_{p_i}(x),e_{p_i}(b) \Big) = e_{p_i}(d)
$$



讨论一下就能得到 $e_{p_i}(x)$ 的取值范围，或者报告无解。

## CF1114C Trailing Loves (or L'oeufs?)

把 $k$ 分解为 $\prod_{i=1}^m p_i^{e_i}$，设 $E_i$ 为 $p_i$ 在 $N$ 中的幂次。

则 $N$ 在 $k$ 进制下后导 $0$ 的个数就是 $\min\Big(\Big\lfloor \frac{E_i}{e_i} \Big\rfloor\Big)$。

对于每个 $p_i$，$n!$ 中质因子 $p_i$ 的个数为
$$
\sum_{k=1 \wedge p_i^k \le n} \Big\lfloor \frac{n}{p_i^k} \Big\rfloor
$$
解释一下上式。

> $n!$ 中包含质因子 $p_i$ 的指数，等价于 $[1,n]$ 中每个数中 $p_i$ 的指数之和。
> 
> 指数至少为 $1$ 的数有 $\Big\lfloor \frac{n}{p_i} \Big\rfloor$ 个，这里只统计第一个。指数至少为 $2$ 的有 $\Big\lfloor \frac{n}{p_i^2} \Big\rfloor$ 个，这里只统计第二个，以此类推。

## luogu1445 樱花

$$
\begin{aligned}
\frac{1}{x} + \frac{1}{y} &= \frac{1}{n!}
\\
\frac{x+y}{xy} &=\frac{1}{n!}
\\
xn! + yn! &= xy
\\
xy - xn! -yn! + (n!)^2 &=  (n!)^2
\\
(x-n!)(y-n!) &= (n!)^2
\end{aligned}
$$

$x$ 与 $y$ 一一对应。

用上面的办法求出 $(n!)^2$ 的质因子指数，再求 $\sigma_0\Big((n!)^2\Big)$ 即可。

$\texttt{Bonus:}$ 求出所有 $(x+y)$ 的和。

求出 $\sigma_1\Big((n!)^2\Big)$ 即可。



## luogu1069 [NOIP2009 普及组] 细胞分裂

先把 $m_1$ 分解了，对于 $m_1$ 的一个质因数 $p_j$，如果 $s_i$ 中不存在 $p_j$ 则无解。

否则，设 $p_j$ 在 $s_i$ 中的指数为 $E_j$，则 $x$ 至少为 $\Big\lceil \frac{e_j \times m_2}{E_j} \Big\rceil$。

取最大值即可。

## CF1325E Ehab's REAL Number Theory Problem

每个数的约数个数不超过 $7$，也就是每个数最多有 $2$ 个质因数。

首先我们判一下完全平方数。然后我们就可以不考虑次数为偶数的质因子，所以所有数一共可以分成两类。

1. 单个质数 $p$。
2. 两个质数 $p,q$ 的乘积 $pq$。

用这些数的乘积得到完全平方数，那么每一种质数应该都出现偶数次。

考虑经典的图论建模问题。我们把出现过的质数当作点，能表示为 $pq$ 的点，看作 $p$ 与 $q$ 之间连一条无向边。另外还要额外建立一个点 $1$，对于单个质数 $p$，在 $1$ 和 $p$ 之间连一条无向边。

这样，任何合法解都是图中的一个环。问题转化为求这张图的最小环。

由于边权都为 $1$，我们直接使用 $\text{BFS}$ 找环。

$\text{BFS}$ 树上的每一条返祖边都对应着一个环。枚举起点，如果这个点在环里，那么找到的第一条返祖边就是它所在的最小环，并且两个端点到它的距离再加 $1$ 就是环长。

如果一个点不在环里，那么如果有环，以它为起点搜到的环一定比答案更大；否则以它为起点一定不能搜到环。所以这样做不会有问题。

然而复杂度约是 $O\Big(n \frac{n}{\ln n}\Big)$，无法通过。

注意到每条边至少有一个点小于等于 $\sqrt{\max \{a_i\}}$，只枚举这部分点作为起点即可。复杂度 $O\Big(n \sqrt{\max \{a_i\}}\Big)$。

## CF582A GCD Table

一个重要的性质是 $\gcd(a,b) \le \min(a,b)$。

表中最大的数、次大的数一定都是原序列中最大和次大的数，但是其他的就不一定了。

可以这样做。找到表中最大的数 $k$，它一定是序列元素。然后删掉 $k$，在序列中加入 $k$，然后扫一遍序列中的其他元素 $j$，在表中删掉两个 $\gcd(k,j)$。

使用`std::set`可以做到 $O(n^2 \log_2 n^2)$。

## CF1344A Hilbert's Hotel

注意到原本位置距离为 $tn, t \in \mathbb{Z}$ 的点，在移动后仍然会距离 $tn$，所以就可以只考虑 $[0,n-1]$ 的点。

然后 check 每个 $(i+a_i) \bmod n$ 是否唯一即可。

注意要把 $i+a_i$ 可能小于 $0$。

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
const int N=2e5+5;
int T, n, a[N];
unordered_map<int,int> p;
int r(int x) {
    return ((x+a[x])%n+n)%n;
} 
void solve() {

    n=read();
    p.clear();
    rep(i,0,n-1) a[i]=read(), ++p[r(i)];
    int fg=0;
    rep(i,0,n-1) {
        if(p[r(i)]>1) { fg=1; break; }
    }
    if(fg) puts("NO");
    else puts("YES"); 
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## CF1342C Yet Another Counting Problem

容易看出这个是有循环节的，周期为 $\operatorname{lcm}(a,b)$。

然后 $a,b$ 都很小，可以直接暴力处理每个周期内的信息，最后即可 $O(1)$ 回答询问。

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
int T, a, b, q, c, d;
int s[50000];
int calc(int x) {
    int t=x/c;
    return t*s[c]+s[x-t*c];
}
int lcm(int x,int y) { return x/__gcd(x,y)*y; }
void solve() {
    a=read(), b=read(), q=read();
    c=lcm(a,b);
    rep(i,1,c) s[i]=s[i-1]+(i%a%b!=i%b%a);
    while(q--) {
        int l=read(), r=read();
        printf("%lld ",calc(r)-calc(l-1));
    }
    puts("");
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu1477 [NOI2008] 假面舞会

[link](https://yozora0908.github.io/2023/lg1477-solution)

## CF980D Perfect Groups

该上那个经典套路了。。

乘积为完全平方数具有传递性，因此可以轻易划分成若干唯一确定的不相交集合。

题目要求最小化分组的数量，那么就要保证每个集合都是极大的。

枚举起点，每考虑一个数都贪心把它加入它所对应的集合，没有就新开一个。

应该注意的是， $0$ 可以放到任何一个集合中，我们钦定所有 $0$ 都放到第一个集合里。所以，只有以下两种情况才需要新开集合。

1. 序列中没有元素。 
2. $a_i \neq 0$，$a_i$ 所在集合还没有元素并且当前序列中不是全 $0$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=5005;
int n, k, a[N], l[N], ans[N];
int squ(int x,int y) {
    int t=(int)sqrt(x*y);
    return x*y==t*t;
}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    rep(i,1,n) {
        per(j,i-1,1) if(a[i]*a[j]>0&&squ(a[i],a[j])) { l[i]=j; break; }
    }
    rep(i,1,n) {
        int k=0, zero=0;
        rep(j,i,n) {
            if(i==j||(a[j]!=0&&zero&&l[j]<i)) ++k;
            ++ans[k];
            zero|=a[j]!=0;
        }
    }
    rep(i,1,n) printf("%lld ",ans[i]);
    puts("");
}
```

## CF354C Vasya and Beautiful Arrays

考虑直接枚举答案。容易发现一个答案 $d$ 是整个序列的公约数，当且仅当 ${\forall} i \in [1,n], a_i \bmod d \le k$。

然而貌似无法优化了。

注意到答案不会超过 $mn = \min_{i=1}^n \{a_i\}$。

如果 $mn \le k+1$，那么 $a_i \bmod mn \le k$。

如果 $mn> k+1$，那么令答案为 $k+1$，显然都可以满足。因此答案区间为 $[k+1,mn]$。

考虑如果一个 $d$ 能成为答案，每个 $a_i$ 一定都能写成 $tk+r$，其中 $r \in[0,k]$。

注意到值域不大，可以开一个桶，在桶上做前缀和，然后枚举 $t$，对每个区间求和，最后检查是否等于 $n$ 即可。

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
const int N=3e5+5, M=1e6+5, lim=1e6;
int n, k, mx, mn=1e9, a[N], c[M];
signed main() {
    n=read(), k=read();
    rep(i,1,n) {
        a[i]=read();
        mx=max(mx,a[i]);
        mn=min(mn,a[i]);
        ++c[a[i]];
    }
    if(mn<=k+1) { printf("%lld\n",mn); return 0; }
    for(int i=1;i<=min(mx+k,lim);++i) c[i]+=c[i-1];
    per(d,mn,k+1) {
        int cnt=0;
        for(int i=1;i<=mx/d;++i) {
            cnt+=c[min(i*d+k,lim)]-c[i*d-1];
        }
        if(cnt==n) { printf("%lld\n",d); return 0; }
    }    
    return 0;
}

```

## CF1114F Please, another Queries on Array?

不要忘了欧拉函数最原始的式子

$$
\varphi(n) = n \prod_{i=1}^m \left(1-\frac{1}{p_i} \right)
$$




这个式子的优点在于只和 $n$ 以及它的质因子有关，并且是个积式。

也就是说，对于一个区间 $[l,r]$，我们只需要知道区间积以及区间出现过的质因子集合即可。

而值域小得令人发指，并且对于乘法操作，能增加的质因子也不超过 $300$。也就是说可能出现的质因子只有 $62$ 个，正好能用`long long`状压。

用线段树维护区间乘积和区间质因子集合即可。

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
const int N=4e5+5, mod=1e9+7;
int n, q, a[N];
int cnt, v[N];
int p[N], inv[N], rev[N];
int t[N<<2], tag[N<<2], s[N<<2], stag[N<<2];
void init() {
    inv[0]=inv[1]=1;
    for(int i=2;i<=300;++i) {
        inv[i]=(mod-mod/i)*inv[mod%i]%mod;
        if(!v[i]) {
            p[cnt]=i, rev[cnt]=(i-1)*inv[i]%mod, ++cnt;
            for(int j=i*i;j<=300;j+=i) v[j]=1;
        }
    }
}
char ss[14];
int fp(int a,int b) {
    int c=1;
    for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void pushup(int x) {
    t[x]=t[x<<1]*t[x<<1|1]%mod;
    s[x]=s[x<<1]|s[x<<1|1];
}
void maketag(int x,int len,int d,int s0) {
    (t[x]*=fp(d,len))%=mod;
    (tag[x]*=d)%=mod;
    s[x]|=s0;
    stag[x]|=s0;
}
void pushdown(int x,int l,int r) {
    if(tag[x]>1||stag[x]) {
        int mid=(l+r)>>1;
        maketag(x<<1,mid-l+1,tag[x],stag[x]);
        maketag(x<<1|1,r-mid,tag[x],stag[x]);
        tag[x]=1, stag[x]=0;
    }
}
void build(int x=1,int l=1,int r=n) {
    tag[x]=t[x]=1;
    if(l==r)  {
        t[x]=a[l];
        for(int i=0;i<cnt;++i) if(a[l]%p[i]==0) s[x]|=1ll<<i;
        return;
    }
    int mid=(l+r)>>1;
    build(x<<1,l,mid);
    build(x<<1|1,mid+1,r);
    pushup(x);
}
void upd(int L,int R,int d,int s0,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) { maketag(x,r-l+1,d,s0); return; }
    pushdown(x,l,r);
    int mid=(l+r)>>1;
    if(L<=mid) upd(L,R,d,s0,x<<1,l,mid);
    if(R>mid) upd(L,R,d,s0,x<<1|1,mid+1,r);
    pushup(x);
}
PII query(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) {
        return MP(t[x],s[x]);
    }
    pushdown(x,l,r);
    int mid=(l+r)>>1;
    PII res; res.fi=1, res.se=0;
    if(L<=mid) {
        PII tmp=query(L,R,x<<1,l,mid);
        (res.fi*=tmp.fi)%=mod, res.se|=tmp.se;
    }
    if(R>mid) {
        PII tmp=query(L,R,x<<1|1,mid+1,r);
        (res.fi*=tmp.fi)%=mod, res.se|=tmp.se;
    }
    return res;
} 
signed main() {
    n=read(), q=read();
    rep(i,1,n) a[i]=read();
    init();
    build();
    while(q--) {
        scanf("%s",ss);
        if(ss[0]=='M') {
            int l=read(), r=read(), x=read();
            int s0=0;
            for(int i=0;i<cnt;++i) if(x%p[i]==0) s0|=1ll<<i;
            upd(l,r,x,s0);
        } else {
            int l=read(), r=read();
            PII a=query(l,r);
            int ans=a.fi, S=a.se;
            for(int i=0;i<cnt;++i) if((S>>i)&1) (ans*=rev[i])%=mod;
            printf("%lld\n",ans);
        }
    }
    return 0;
}
```



## CF632B Array GCD

首先将「整个序列的 $\gcd$ 大于 $1$」，转化成「整个序列存在公共质因子」。

一个重要的观察：任何一组合法解，整个序列的 $\gcd$ 一定是 $a_1$ 或 $a_n$ 的某个质因子的倍数。

然后 $\omega(a_i)$ 的最大值大概是 $10$ 的样子，所以可以枚举每个质因子。

能发现唯一的影响就是删掉的那一段。

设 $f(i,0/1/2)$ 为考虑前 $i$ 个数，删掉的段在位置 $i$ 还没开始、开始了没结束、结束了的最小代价。

直接做就行了。

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
const int N=1e6+5, inf=2e18;
int n, ans, A, B, a[N][3];
vector<int> tmp, v;
void divide(int x) {
    for(int i=2;i*i<=x;++i) if(x%i==0) {
        tmp.pb(i);
        while(x%i==0) x/=i;
    }
    if(x>1) tmp.pb(x);
}
void prework() {
    rep(i,0,2) divide(a[1][i]), divide(a[n][i]);
    sort(tmp.begin(),tmp.end());
    int p=unique(tmp.begin(),tmp.end())-tmp.begin();
    for(int i=0;i<p;++i) v.pb(tmp[i]);
}
int f[N][3];
int solve(int x) {
    SET(f,0x3f);
    f[0][0]=0;
    rep(i,1,n+1) {
        if(i==n+1) {
            f[i][0]=f[i-1][0];
            f[i][2]=min(f[i-1][1],f[i-1][2]);
            f[i][1]=inf;
            continue;
        }
        if(a[i][1]%x==0) {
            f[i][0]=f[i-1][0];
            f[i][1]=min(f[i-1][0],f[i-1][1])+A;
            f[i][2]=min(f[i-1][1],f[i-1][2]);
        } else if(a[i][0]%x==0||a[i][2]%x==0) {
            f[i][0]=f[i-1][0]+B;
            f[i][1]=min(f[i-1][0],f[i-1][1])+A;
            f[i][2]=min(f[i-1][1],f[i-1][2])+B;
        } else {
            f[i][0]=inf;
            f[i][2]=inf;
            f[i][1]=min(f[i-1][0],f[i-1][1])+A;
        }
    }
    return min(f[n+1][0],f[n+1][2]);
}
signed main() {
    n=read(), A=read(), B=read();
    rep(i,1,n) {
        a[i][1]=read();
        a[i][0]=a[i][1]-1;
        a[i][2]=a[i][1]+1;
    }
    prework();
    ans=inf;
    for(auto x:v) {
        int res=solve(x);
        ans=min(ans,res);
    }
    printf("%lld\n",ans);
    return 0;
}

```





## 求区间中与给定数互质的数的个数

最后我们关注一个小问题。

> 给定 $n,L,R$，求 $[L,R]$ 中与 $n$ 互质的数的个数。

怎么做？

问题等价于求 $[L,R]$ 中有多少个数和 $n$ 含有相同质因子，先差分成 $[1,L-1]$ 和 $[1,R]$。

设当前区间为 $[1,R]$。我们把 $n$ 分解了，暴力搜索所有质因数的组合方式，设其为 $m$，那么就有 $\Big\lfloor \frac{R}{m} \Big\rfloor$ 个数含有这个质因子集合。根据熟悉的集合容斥，容易知道集合 $S$ 的容斥系数就是 $(-1)^{|S|}$。

设质因子个数为 $\omega(n)$，那么复杂度就是 $O(\sqrt{n} + 2^{\omega(n)})$。

通过提前筛质数能做到 $O(\omega(n) + 2^{\omega(n)})$，实际上第一项常数较小，第二项小于 $O(n)$。

### CF1750D Count GCD

有解一定要有 $a_i \mid a_{i-1}$。

考虑 $\gcd_{j=1}^{i-1} \{b_j\} = a_{i-1}$，$\gcd_{j=1}^{i} \{b_j\} = a_{i}$，也就是说 $b_i$ 不能有 $\frac{a_{i-1}}{a_i}$ 的任何质因子。

由于 $a_i \mid b_i$，所以 $\frac{b_i}{a_i} \in [1,\lfloor \frac{m}{a_i} \rfloor]$。

求区间中与 $\frac{a_{i-1}}{a_i}$ 互质的数的个数即可。

单次求解的复杂度已经到了 $O(2^{\omega(m)})$ 了，而 $\omega(m)$ 的上界大概是 $10$。

注意到那个很重要的条件 $a_i \mid a_{i-1}$，也就是这玩意是 $\log$ 级别递减的，所以直接暴力做就行。

```cpp
// LUOGU_RID: 121128333
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
const int N=2e5+5, mod=998244353;
int T, n, m, a[N];
vector<int> p;
map<PII,int> mp;
void divide(int x) {
    p.clear();
    for(int i=2;i*i<=x;++i) if(x%i==0) {
        p.pb(i);
        while(x%i==0) x/=i;
    }
    if(x>1) p.pb(x);
}
int dfs(int i,int j,int k,int lim) {
    if(i==p.size()) {
        if(j>0) {
            if(j&1) return lim/k;
            else return -lim/k;
        } else return 0;
    }
    return dfs(i+1,j,k,lim)+dfs(i+1,j+1,k*p[i],lim);
}
int calc(int lim,int r) {
    PII t={lim,r};
    if(mp.count(t)) return mp[t];
    divide(r);
    return mp[t]=lim-dfs(0,0,1,lim);
}
void solve() {
    n=read(), m=read();
    int fg=0;
    rep(i,1,n) {
        a[i]=read();
        if(i>1&&a[i-1]%a[i]) fg=1;
    }
    if(fg) {
        puts("0");
        return;
    }
    int ans=1;
    rep(i,2,n) {
        (ans*=calc(m/a[i],a[i-1]/a[i]))%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();    
    return 0;
}
```


