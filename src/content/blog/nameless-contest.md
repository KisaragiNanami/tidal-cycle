---
title: Nameless Contest（1）
pubDate: 2023-06-26
tags:
  - 搜索
  - 图论
  - 线段树
  - DP
  - 容斥原理
  - 子集反演
categories:
  - 比赛
description: '神秘模拟赛'
---

22 年某模拟赛。

本人也没有参加，为了造福大众就公开题面了。

~~反正也没什么人看这个博客~~。

会选择性略去一些部分分条件。

## 简单题

$\text{Time Limit: 2 s}$

$\text{Memory Limit: 256 MB}$

> 给定 $n,x,y$ 和 $a,b,c,d$，求有多少个长度为 $n$ 的正整数序列 $\{s\}$，满足 $\forall i \in [1,n] \cap \mathbb{Z}$，$s_i \in [x,y]$，且 $\sum_{i=1}^n s_i \in [a,b]$，$\sum_{i=1}^n s_i^2 \in [c,d]$，对 $\mathbf{998244353}$ 取模。
> 
> 对于 $40 \%$ 的数据，$n \le 5$。
> 
> 对于 $100\%$ 的数据，$n \le 28$，$1 \le x \le y < 1000$，$y-x \le 9$，$a,b,c,d \in [1,10^9]$。



部分分就是直接暴搜 $n$ 个数填什么。

注意到值域非常小，考虑搜索每个数用了多少次，方案数用多重集全排列算。

复杂度？

不限制物品个数的多重集组合数，方案数 $\binom{n+m-1}{m-1}$，其中 $m=y-x+1$。

是 $10^7$ 级别的。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define num s-'0'
int read(){
    int x;
    char s;
    x=0;
    bool flag=0;
    while(!isdigit(s=getchar()))
        (s=='-')&&(flag=true);
    for(x=num;isdigit(s=getchar());x=x*10+num);
    (flag)&&(x=-x);
    return x;
}
const int maxn = 2333;
const int mod = 998244353;
int n;
int a,b,c,d,x,y;
int jc[maxn];
int ni[maxn];
int ak[maxn],ans;
int ksm(int x,int y){
    int ans = 1;
    while(y){
        if(y&1) ans *= x,ans %= mod;
        x *= x,x %= mod,y>>=1;
    }
    return ans;
}
void dfs(int q,int w,int e,int z,int fn)
{
    if(q == y){
        ak[y] = n - w;
        e += y * ak[y];
        z += y * y * ak[y];
        if(a <= e && e <= b && c <= z && z <= d){
            ans += fn * ni[ak[y]] % mod;
        }
        return;
    }
    for(int i=0;w+i<=n;++i){
        dfs(q+1,w+i,e+i*q,z+i*q*q,fn * ni[i] % mod);
    }
}
signed main()
{
    n = read();
    x = read(),y = read();
    a = read(),b = read(),c = read(),d = read();
    jc[0] = 1;
    for(int i=1;i<=n;++i) jc[i] = jc[i-1] * i % mod;
    for(int i=1;i<=n;++i) ni[i] = ksm(jc[i],mod-2);
    ni[0] = 1;
    dfs(x,0,0,0,jc[n]);
    printf("%lld\n",ans % mod);
}
```



## 套路题

$\text{Time Limit: 2 s}$

$\text{Memory Limit: 512 MB}$

> 给出一个拓扑序为 $1 \sim n$ 的 DAG，对于任意 $(i,j)$  且 $i<j$，满足存在一条从 $i$ 到 $j$ 的边，长度为 $a_i \times (n-i) + b_j \times j + c \times \lfloor \frac{j}{i} \rfloor$。另外还有 $m$ 条特殊有向边，第 $i$ 条长度为 $d_i$。
> 
> 求 $1$ 到 $n$ 的最短路。
> 
> 对于 $100 \%$ 的数据，$0 \le a_i,b_i,c_i \le 10^4$，$1 \le d_i \le 10^9$。
> 
> 对于 $\frac{1}{6}$ 的数据，$n,m \le 300$，$c \le 1000$。
> 
> 对于 $\frac{1}{3}$ 的数据，$n,m \le 6000$，$c \le 1000$。
> 
> 对于另外 $\frac{1}{3}$ 的数据，$c=0$.
> 
> 对于 $100\%$ 的数据，$n,m \le 2 \times 10^5$，$0 \le c \le 10000$。

拓扑序为 $1 \sim n$，那么设 $f_i$ 为从 $1$ 到 $i$ 的最短路，之后用 $f_i$ 沿着从 $i$ 连出的特殊有向边更新其他点即可。

对于前两个 subtask 就直接暴力做。

对于 $c=0$ 的情况，$j$ 到任何点的代价都不会改变，维护 $g_j = f_j + b_j \times (n-j)$ 的前缀最小值即可。

考虑扩展上述做法，当 $i-1 \rightarrow i$ 时，什么样的 $j$ 的代价会改变呢？

当且仅当 $\lfloor \frac{i-1}{j} \rfloor \neq \lfloor \frac{i}{j} \rfloor$，这样的 $j$ 一定是 $i$ 的约数。因此只需要枚举 $i$ 的约数，暴力修改。再用线段树维护最小值。

枚举约数的过程是 $O(\sqrt n)$ 的，使用倍数法可以在 $O(n \log n)$ 的复杂度内求出 $1 \sim n$ 所有数的倍数，所以复杂度大概是 $O( n \log n + n \sigma_0 (n) \log_2 n + m)$。

常数挺小的，应该能卡过。但是 std 采用的是枚举约数。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
const int maxn = 200005;
struct stu{
    int to,nxt,w;
}se[maxn];
int f[maxn],hd[maxn],cnt;
int a[maxn],b[maxn],c,m,n;
#define num s-'0'
void read(int &x){
    char s;
    x=0;
    bool flag=0;
    while(!isdigit(s=getchar()))
        (s=='-')&&(flag=true);
    for(x=num;isdigit(s=getchar());x=x*10+num);
    (flag)&&(x=-x);
}
void jia(int x,int y,int z){
    se[++cnt].to = y,se[cnt].nxt = hd[x],hd[x] = cnt,se[cnt].w = z;
}
int minn[maxn * 4 + 1];
void pu(int p)
{
    minn[p] = min(minn[p<<1],minn[p<<1|1]);
}
void build(int l,int r,int p)
{
    if(l == r){
        minn[p] = f[l] + a[l] * (n-l);
        return;
    }
    int mid = (l+r)>>1;
    build(l,mid,p<<1),build(mid+1,r,p<<1|1),pu(p);
}
void gai(int l,int r,int p,int pos,int v)
{
    if(l == r){
        minn[p] = v;
        return;
    }
    int mid = (l+r)>>1;
    if(pos <= mid) gai(l,mid,p<<1,pos,v);
    else gai(mid+1,r,p<<1|1,pos,v);
    pu(p);
}
signed main()
{
    read(n); read(m); read(c);
    for(int i=1;i<=n;++i) read(a[i]),read(b[i]);
    for(int i=1;i<=m;++i) {int x,y,z; read(x),read(y),read(z); jia(x,y,z);}
    for(int i=2;i<=n;++i) f[i] = 1e18;
    build(1,n,1);
    for(int i=1;i<=n;++i){
        if(i != 1){
            for(int j=1;j*j<=i;++j){
                if(i % j == 0){
                    gai(1,n,1,j,f[j] + a[j]*(n-j) + c * (i/j));
                    if(j*j != i && j!=1)
                    gai(1,n,1,i/j,f[i/j] + a[i/j]*(n-i/j) + c * j);
                }
            }
        }
        f[i] = min(f[i],minn[1] + b[i] * i);
        for(int j=hd[i];j;j=se[j].nxt){
            int v = se[j].to;
            f[v] = min(f[v],f[i] + se[j].w);
        }
        gai(1,n,1,i,f[i] + a[i] * (n-i) + c);
    }
    printf("%lld\n",f[n]);
}
```

## 基础题

$\text{Time Limit: 1 s}$

$\text{Memory Limit: 256 MB}$

> 小曹和他的妹子玩取石子游戏，轮流取，小曹先手。
> 第一轮只能取 $1$ 个石子，若第 $i-1$ 轮取了 $x$ 个石子，则第 轮只能取 $2x$ 个或者 $2x+1$ 个石子，谁没法再取谁就输了。
> 由于小曹非常调皮，想欺负他的妹子，于是他快速的计算出了假设初始有 个石子，他有多少种方案(奇数轮取上一轮的两倍还是两倍多一个），使得他的妹子无论怎么取，他都能获得胜利。
> 他想考考你，对于所有的  $n \in [l,r]$，让他获得胜利的方案数的和。
> 两种方案不同，当且仅当存在某一轮，小曹在一种方案中取了上一轮的两倍，而在另一种方案中取了上一轮的两倍多一个，与曹队的妹子怎么取无关。

不会做。

看题解感觉还是比较人类智慧的。

咕咕咕。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
int read()
{
    char c; int x = 0;
    int f = 1;
    c = getchar();
    while(c<'0'||c>'9'){
        if(c == '-') f = -1;
        c = getchar();
    }
    while(c >= '0' && c <= '9'){
        x = x * 10 + c - '0';
        c = getchar();
    }
    return x * f;
}
const int maxn = 200005;
int a[maxn];
//1 2 4 8
//1 3 6 12
//1 + 2 + 4 = 7
//1 3 7 15...
int gai[maxn];
int jisuan(int x,int qwq)
{
    int ans = 0;
    if(qwq == 1)
    {
        gai[1] = 1;
        for(int i=2;i<=18;++i) gai[i] = (1ll<<(2*i-1)) - 1;
    }
    else
    {
        gai[1] = 3;
        for(int i=2;i<=18;++i) gai[i] = (1ll<<(2*i)) - 1;
    }
    for(int j=0;j<(1<<18);++j){
        int aa = 0;
        for(int k=0;k<18;++k){
            if((j>>k)&1){
                aa += gai[k+1];
            }
        }
        if(x >= aa)
        ans += x - aa + 1;
    }
    return ans;
}
int solve(int x)
{
    if(x <= 2) return x;
    if(x <= 3) return 2;
    int ans = 2;
    for(int i=1;i<=38;++i){
        if(a[i] > x) return ans;
        int y = 1,z = 1,qwq;
        if(i % 2 == 0)
        {
            for(int j=1;j<=i;++j){
                if(j%2 == 1) z = z * 2 + 1;
                else z *= 2;
                y += z;
            }
            qwq = min(a[i+1] - 1,x) - y + 1;
            qwq --;
            if(qwq < 0) continue;
            ans += jisuan(qwq,1);
        }
        else
        {
            for(int j=1;j<=i;++j){
                if(j%2 == 1) z *= 2;
                else z *= 2,z +=1;
                y += z;
            }
            y --;
            qwq = y - a[i] + 1;
            if(x < y){
                ans -= jisuan(y-x-1,2);
            }
            qwq --;
            if(qwq < 0) continue;
            ans += jisuan(qwq,2);
        }
    }
}
signed main()
{
    int l = read(),r = read();
    int x = 1;
    a[0] = 1;
    for(int i=1;i<=38;++i){
        x *= 2; a[i] = a[i-1] + x;
    }
    int ans = solve(r) - solve(l - 1);
    printf("%lld\n",ans);
    return 0;
}
```

## 不配压轴的题

$\text{Time Limit: 1.5 s}$

$\text{Memory Limit: 1 GB}$

> 给定一棵有 $n$ 节点的树，满足 $2 \mid n$。定义两个点配对时，它们路径上的点都会被覆盖 $1$ 次。求将 $n$ 个点两两配对，且每条边都至少被覆盖过 $1$ 次的方案数。对 $P$ 取模。
> 
> 对于 $25\%$ 的数据，$n \le 16$。
> 
> 对于 $50\%$ 的数据，$n \le 300$。
> 
> 对于 $75\%$ 的数据，$n \le 5000$。
> 
> 对于 $100\%$ 的数据，$n \le 10000$。
> 
> 对于 $100\%$ 的数据，$P \le 1.1 \times 10^9$。

原题是 [ARC101E](https://atcoder.jp/contests/arc101/tasks/arc101_c)。

对于 subtask 1，直接暴搜即可，总匹配方案数是 $10^6$ 级别的。



$\texttt{Observation}$

一条边 $\Big(x,fa(x) \Big)$ 没有被覆盖的充要条件是以  $x$ 为根的子树中，没有点和外面的点匹配。

考虑一个暴力，设 $f(x,i)$  为以 $x$ 为根的子树中，有 $i$ 个点要和外面的点匹配的方案数。
$$
f(x,i) f(y,j) \binom{i}{k} \binom{j}{k} k! \rightarrow g_{i+j-2k}
$$
复杂度 $O(n^3)$。

&nbsp;

考虑正解。

把这些没有被覆盖的边看作特殊边，那么整棵树就被若干特殊边划分成了若干连通块。我们要求的是不含任何特殊边的匹配方案。

考虑容斥。钦定一个边集 $S$，表示 $S$ 内的边一定是特殊边。根据**子集反演**，容斥系数为 $(-1)^{|S|}$。

用树形背包维护连通块，设 $f_{x,i,j}$ 为以 $x$ 为根的子树中，$x$ 所在连通块大小为 $i$，其中特殊边集大小为 $j$ 的方案数，容斥系数就是 $(-1)^j$。转移就是讨论 $(x,y)$ 这条边要不要加入特殊边集。如果加入，那么以 $y$ 为根的连通块闭合，在这里可以计算任意两两匹配的方案数。 

然而这样复杂度过高，瓶颈在于 $j$ 这一维。一种解决方案只记录 $j$ 的奇偶性，不过更好的做法则是把这个容斥系数放进 DP 值里面。具体地，对 $j$ 这一维做前缀和，设 $f_{x,i}$ 为以 $x$ 为根的子树，$x$ 所在连通块大小为 $i$ 的方案数。每有一个连通块闭合，就有一条边没有被覆盖，要多乘一个 $-1$，对应到实现就是这部分的方案做减法。

$2n$ 个点两两匹配的方案是
$$
\frac{\binom{2n}{n}n!}{2^n}
$$

或者说
$$
h_{2n} = h_{2n-2} \times (2n-1)
$$



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
const int N=5005, mod=1e9+7;
int n, f[N][N], g[N], sz[N], h[N];
vector<int> p[N];
void dfs(int x,int fa) {
    f[x][1]=sz[x]=1;
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        for(int i=1;i<=sz[x];++i) {
            int t=0;
            for(int j=1;j<=sz[y];++j) {
                (g[i+j]+=f[x][i]*f[y][j]%mod)%=mod;
                (g[i]-=f[x][i]*f[y][j]%mod*h[j]%mod-mod)%=mod;
            }
        }
        sz[x]+=sz[y];
        for(int i=1;i<=sz[x];++i) f[x][i]=g[i], g[i]=0;
    }
}
signed main() {
    n=read();
    rep(i,2,n) {
        int x=read(), y=read();
        p[x].pb(y), p[y].pb(x);
    }
    h[2]=h[0]=1;
    for(int i=4;i<=n;i+=2) h[i]=h[i-2]*(i-1)%mod;
    dfs(1,0);
    int ans=0;
    for(int i=2;i<=n;i+=2) (ans+=f[1][i]*h[i]%mod)%=mod;
    // 闭合最后一个连通块
    printf("%lld\n",ans);
    return 0;
}
```

### 
