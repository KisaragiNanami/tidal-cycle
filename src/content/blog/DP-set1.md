---
title: 一些简单 DP 题
tags:
  - DP
  - 树形DP
  - 概率论
  - 线段树
  - 树状数组
categories: 题解
pubDate: 2022-08-17
description: '做题记录'
---

## luogu2606 排列计数

这个条件相当于，$[1,n]$ 有多少排列满足小根堆性质。

设 $sz_i$ 为以 $i$ 为根的子树大小。



那么 $1$ 必定填 $1$，而其他节点只需要考虑相对大小，所以对于 $i$，只要规定了它的子节点内部到底用哪些数字，就一定存在合法方案。

设 $f_i$ 为以 $i$ 为根的子树的方案数，那么

$$
f_i = \binom{sz_i - 1}{sz_{2i}} f_{2i}  f_{2i + 1}
$$



对于 $i > n$，规定 $f_i = 1$。

数据很弱，貌似不必使用 lucas 定理。

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
#define ll long long
const int N=1e6+6;
ll n, p, sz[N<<1], fac[N], f[N];
ll fp(ll x,ll y) {
    ll z=1;
    for(;y;x=x*x%p,y>>=1ll) if(y&1ll) z=z*x%p;
    return z;
}
ll C(ll n,ll m) {
    return fac[n]*fp(fac[m],p-2)%p*fp(fac[n-m],p-2)%p;
}
ll lucas(ll n,ll m) {
    return m? lucas(n/p,m/p)*C(n%p,m%p)%p:1;
}
signed main() {
    scanf("%lld%lld",&n,&p);
    fac[0]=fac[1]=1;
    for(int i=2;i<=n;++i) fac[i]=fac[i-1]*i%p;
    for(int i=n;i;--i) sz[i]=sz[i*2]+sz[i*2+1]+1;
    for(int i=n;i;--i) {
        f[i]=lucas(sz[i]-1,sz[i*2]);
        f[i]=f[i]*(i*2<=n? f[i*2]:1)%p*(i*2+1<=n? f[i*2+1]:1)%p;
    }
    printf("%lld\n",f[1]);
}
```

## luogu2467 地精部落

山脉高度亮亮不同，而且只关心相对大小，所以问题可以转化为 $[1,n]$ 的排列中，满足波浪形分布的排列的个数。

考虑“谷”必须要接在”峰“的后面，设 $f_{i,j}$ 表示考虑 $[1,i]$ 的排列中，满足最后一个数为 $j$ 且是一个”谷“的方案数。可以这样设的原因是只关心相对大小。

枚举一个 $k \in [1,j-1]$，那么贡献为 $f_{i-1,(i-1)-k+1} = f_{i-1,i-k}$。这样做的原因是，对于一个以峰结尾的合法排列，对于其中每个元素 $p_j$ 都变成 $(i-1)-p_j+1$，就能满足以谷结尾，且仍然合法。

如果 $(i-1)-k+1 > k$，那么将 $k$ 接在结尾后，交换 $(i-1)-k+1$ 和 $k$，此时一定满足结尾的元素是峰，而倒数第二个元素是谷，整个序列合法。使用上述做法之后依然是合法的。否则，直接将 $k$ 接在结尾就是合法的，直接使用上述做法即可。

举点例子。假如 $k=2$，$i=5$。那么 $i-k = 3$，把 $i-k$ 接在后面，假设此时排列为 $4,3,2$，交换 $3,2$ 后的 $4,2,3$ 使用上述方法变成 $1,3,2$，满足条件。如果 $k=3$，其他条件不变，那么排列为 $4,2,3$，此时使用上述方法转化成 $1,3,2$，也满足条件。

那么

$$
f_{i,j} = \sum_{k=1}^{j-1} f_{i-1,i-k}
$$



复杂度为 $O(n^3)$。这个式子肉眼可见很多冗余。

发现

$$
\sum_{k=1}^{j-1} f_{i-1,i-k} = f_{i-1,i-j+1} + \sum_{k=1}^{j-2} f_{i-1,i-k} = f_{i-1,i-j+1} + f_{i,j-1}
$$



于是优化到 $O(n^2)$。

最后乘 $2$ 才是总方案数，通过上述做法不难证明。

答案

$$
\sum_{i=1}^n f_{n,i}
$$



```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
using namespace std;
const int N=4205;
int n, p, k=1, ans, f[2][N];
int main() {
    scanf("%d%d",&n,&p);
    f[0][1]=1;
    for(int i=2;i<=n;++i,k^=1) for(int j=1;j<=i;++j)
        f[k][j]=(f[k][j-1]+f[k^1][i-j])%p;
    // 按理说j不能取i，但是当j=i时正好让第二项为0，第一项就相当于求了前缀和
    // 所以f[k^1][n]就是答案
    printf("%d\n",(f[k^1][n]*2)%p);
}
```

## luogu4644 Cleaning Shifts

将区间右端点排序。设 $f_i$ 为打扫 $[1,i]$ 时间段的最小花费，$k$ 为当前考虑到了第 $k$ 个区间。由于每个区间必须全部打扫完，所以每头奶牛只能更新一个位置，$f_{r(k)}$

$$
f_{r(k)} = \min_{j \in [l(k)-1,r(k)]} \{ f_j+ c_k \}
$$

左右区间并不同时具有单调性，可以用线段树维护 $f$。

```cpp
#include<cstdio>
#include<cstring>
#include<iostream>
#include<algorithm>
using namespace std;
const int N=1e5+6, inf=0x3f3f3f3f;
int n, l, r, f[N];
struct E { int l, r, z; } a[N];
bool operator<(E a,E b) { return a.r!=b.r? a.r<b.r:a.l<b.l; }
struct Seg {
    int l, r, z;
    #define l(x) t[x].l
    #define r(x) t[x].r
    #define z(x) t[x].z
} t[N<<2];
void pushup(int p) { z(p)=min(z(p<<1),z(p<<1|1)); }
void build(int p,int l,int r) {
    l(p)=l, r(p)=r;
    if(l==r) { z(p)=f[l]; return; }
    int mid=l+r>>1;
    build(p<<1,l,mid), build(p<<1|1,mid+1,r);
    pushup(p);
}
void modify(int p,int x,int y) {
    if(l(p)==r(p)) {  z(p)=y; return; }
    int mid=l(p)+r(p)>>1;
    if(x<=mid) modify(p<<1,x,y); else modify(p<<1|1,x,y);
    pushup(p);
}
int query(int p,int l,int r) {
    if(l<=l(p)&&r>=r(p)) return z(p);
    int mid=l(p)+r(p)>>1, ans=inf;
    if(l<=mid) ans=min(ans,query(p<<1,l,r));
    if(r>mid) ans=min(ans,query(p<<1|1,l,r));
    return ans;
}
int main() {
    int i;
    scanf("%d%d%d",&n,&l,&r);
    for(i=1;i<=n;++i) {
        scanf("%d%d%d",&a[i].l,&a[i].r,&a[i].z);
        a[i].l=max(l,a[i].l), a[i].r=min(r,a[i].r);
    }
    sort(a+1,a+n+1);
    memset(f,0x3f,sizeof(f)), f[l-1]=0;
    build(1,l-1,r);
    for(i=1;i<=n;++i) {
        if(a[i].l>a[i].r) continue;
        f[a[i].r]=min(f[a[i].r],query(1,a[i].l-1,a[i].r)+a[i].z);
        modify(1,a[i].r,f[a[i].r]);
    }
    printf("%d\n",f[r]!=inf? f[r]:-1);
}
```

## luogu2018 消息传递

一个小贪心：对于 $x$ 的子节点集合 $\{y\}$，首先传达的一定是最费时间的 $y_i$，其次是次费时间的 $y_i$，否则通过邻项交换一定能证明不优。

但是传达完毕的时间并不一定是最费时间的 $y_i$ 所花费的时间 $+1$。

$$
f_x = \max_{(x,y)} \{ f(y) + ord_y \}
$$





其中 $ord_y$ 表示 $y$ 是第几个被 $x$ 传达的点。

这样做复杂度是 $O(n^2)$ 的。

可以记忆化搜索。

还有一个优化空间的 Trick 就是，不是记忆化 $f(x,fa_x)$，而是记忆化 $(fa_x \rightarrow x)$ 的这条边，空间复杂度降为 $O(n)$。

## luogu1385 密令

注意到字典序总和不变。

设 $f_{i,k}$ 为长度为 $i$，字典序总和为 $k$ 的字符串数量。

小把戏。

## CF106C Buns

设 $f_{i,j}$ 为考虑前 $i$ 种馅料，剩下 $j$ 克面粉的最大收益。

做多重背包即可。

统计答案时，枚举 $i$，取 $f_{n,i} + \frac{n-i}{c_0} \cdot d_0$ 的最大值即可。

## luogu2059 卡牌游戏

设 $f_{i,j}$ 为剩下 $i$ 个人，其中编号相对大小排第 $j$ 的玩家坐庄的胜率。

$f_{1,1}= 1$，推就行了。

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
const int N=60;
int n, m, c[N];
double f[N][N];
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=m;++i) scanf("%d",&c[i]);
    f[1][1]=1.0;
    for(int i=2;i<=n;++i) for(int j=1;j<=i;++j) {
        for(int k=1;k<=m;++k) {
            int p=c[k]%i? c[k]%i:i;
            if(p<j) f[i][j]+=f[i-1][j-p]/m;
            else if(p>j) f[i][j]+=f[i-1][i-p+j]/m;
            // p=j时他自己就死了，贡献为0
        }
    }
    for(int i=1;i<=n;++i) printf("%.2lf%% ",f[n][i]*100);
    puts("");
}
```

## luogu3287 方伯伯的玉米田

每次拔高的一定是一段后缀，否则一定不优。这句话也变相说明了，对于一次拔高操作 $[i,n]$，能对答案产生影响的只有 $i$ 能否接在之前的某处。

如果拔高的是 $[i,n]$，那么最终最长不下降子序列中必然包含 $i$，否则这个操作无用。

设 $f_{i,j}$ 为中 $i$ 已经被拔高了 $j$ 次，以 $i$ 结尾的最长不下降子序列长度。

$$
f_{i,j} = \max_{k \in [1,i-1], l \in[0,j]} \{ f_{k,l} \} + 1
$$



其中必须满足 $h_i + j \ge h_k + l$。

可以用二维树状数组维护前缀最大值，一维是 $h_i + j$，另一维是 $j$。

```cpp
#include<cstdio>
#include<iostream>
using namespace std;
const int N=1e4+5, M=505;
int n, m, mx, ans, a[N], f[N][M];
void modify(int x,int y,int z) {
    for(int i=x;i<=mx+m;i+=(i&-i)) for(int j=y;j<=m+1;j+=(j&-j))
        f[i][j]=max(f[i][j],z);
}
int query(int x,int y) {
    int ans=0;
    for(int i=x;i;i-=(i&-i)) for(int j=y;j;j-=(j&-j)) ans=max(ans,f[i][j]);
    return ans;
}
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=n;++i) scanf("%d",&a[i]), mx=max(mx,a[i]);
    for(int i=1;i<=n;++i) for(int j=m;j>=0;--j) {
        // 没有储存阶段的信息，滚动数组
        int k=query(a[i]+j,j+1)+1;
        // j+1防止0下标
        ans=max(ans,k);
        modify(a[i]+j,j+1,k);
    }
    printf("%d\n",ans);
}
```
