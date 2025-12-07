---
title: luogu9221 「TAOI-1」Pentiment 题解
pubDate: 2023-08-30
tags:
  - DP
  - 计数
  - 区间合并
categories: 题解
description: 'Solution'
---

先考虑部分分怎么打。

根据个人习惯，规定下文中「直角蛇」是从最上面一行到达最下面一行。

### subtask 2

不妨这样考虑：到达每一行后，都可以通过左右移动，到达下一行的任意一个位置。到达第一行的位置可以任选；从任意位置到达最后一行后，可以再通过左右移动，在任意位置结束。所以答案就是

$$
m^{n+1}
$$



### subtask 1 and 3

这两个子任务都可以用 $O(nm)$ 的做法解决。

结合 subtask 2，我们对每一行考虑。发现第 $i-1$ 行和第 $i$ 行本质上是「输送与接收」的关系。

不妨称不能走的节点为关键点，我们能发现如下性质。

- 关键点把第 $i-1$ 行和第 $i$ 行划分成了若干个连续段，只有当两行的连续段有交时，才能完成方案的传递。

- 到达同一个连续段内任意节点的方案数是相等的。这个容易理解，我们到达这一段后可以左右任意走。

这两个性质启发我们这样做：

设 $f(i,j)$ 为直角蛇到达 $(i,j)$ 的方案数。对于第 $i$ 行，如果 $(i,j)$ 不是关键点，我们就把 $f(i-1,j)$ 的方案下传到 $f(i,j)$。然后对 $j$ 这一维做前缀和，最后扫一遍，每个点的方案就是其所在连续段的总和。

使用滚动数组，时间和空间都可以接受。

```cpp
const int mod=998244353;
int n, m, q;
bitset<10002> v[10002];
bitset<1000002> v1[3];
int f[2][10002], r[10002], s[10002];
namespace sub3 {
    // 这是subtask3的代码。
    // 如果要求解subtask1，那么就交换行和列，用v1做标记即可。
    void solve() {
        rep(i,1,n) {
            int lst=m;
            per(j,m,1) {
                if(v[i][j]) r[j]=j, lst=j-1;
                else r[j]=lst;
            }
            rep(j,1,m) {
                f[i&1][j]=0;
                if(!v[i][j]) {
                    if(i==1) s[j]=1; else s[j]=f[(i-1)&1][j];
                    s[j]=(1ll*s[j]+s[j-1])%mod;
                }
            }
            int L=0, R=0;
            rep(j,1,m) {
                R=r[j];
                if(!v[i][j]) f[i&1][j]=(s[R]-s[L]+mod)%mod;
                else L=j, f[i&1][j]=0;
            }
        }
        int L=0, R=0, ans=0;
        rep(i,1,m) ans=(1ll*ans+f[n&1][i])%mod;
        printf("%d\n",ans);
    }
};
```

### subtask 6

我们发现方案的下传像是在做类似于区间合并的东西。由于本人太菜，不会使用数据结构，所以就对着题解中的离线做法写了，就此学习一下此类问题的处理方法。

对于连续的不存在关键点的行，其方案数是容易求出的，所以有用的只有不同行的关键点。对此我们可以将所有关键点按照横坐标排序。

先不考虑连续空行的情况。我们应该先找到一个临界点 $i$，满足 $i$ 与 $i+1$ 在不同行，再维护一个上一行的末尾位置 $k$。这样我们就能得到这一整行的信息了，同时要维护上一行的区间以及区间内每个位置的方案数（每个位置的方案数都相等）。

```cpp
struct node {
    int l, r; ll x;
    // 区间[l,r]，每个点的方案数都是x
    node() {};
    node(int _l,int _r,ll _x) { l=_l, r=_r, x=_x; }
} f[N];
```



考虑如何区间合并。对于当前行的区间，只要上一行的某个区间与其有交，方案就能下传，看起来不很好做。但反过来想，如果当前行被上一行两个区间下传方案了，那么说明一定有关键点把上面那两个区间隔开。也就是说，如果我们把上一行的关键点当作当前行的关键点，这样得到的区间一定会被上一行唯一确定的一个区间下传方案。

我们先把两行的关键点都存下来，排序后去重。

对于两个关键点确定的一个区间 $[L,R]$，我们找到之前合并完的第一个与这个区间有交的区间，$[L,R]$ 的方案数就是 $R-L+1$ 乘那个区间的方案。注意要把边界 $0$ 与 $m+1$ 都加入。

```cpp
p.clear();
int tot=0;
if(a[k].fi+1==a[i].fi) {
    for(int j=k;j&&a[j].fi==a[k].fi;--j) b[++tot]=a[j].se;
}
for(int j=k+1;j<=i;++j) b[++tot]=a[j].se, p[a[j].se]=1;
b[++tot]=0, b[++tot]=m+1;
uniq(b,tot);

vector<node> v;
for(int j=1,pos=1;j<tot;++j) {
    if(b[j]&&!p.count(b[j])) v.pb(node(b[j],b[j],0ll));
    int L=b[j]+1, R=b[j+1]-1;
    if(L>R) continue;
    while(pos<=cnt&&f[pos].r<L) ++pos;
    ll sum=f[pos].x*(R-L+1)%mod;
    v.pb(node(L,R,sum));
}
```



对于合并，只需要将上一行的关键点当作连接区间的桥梁。具体地，我们将通过上述做法得到的区间都存下来，然后把上一行的关键点当作长度为 $1$ 的区间加进去。合并时，只需要扫一边所有区间，根据端点判断是否可以合并即可，方案数就直接累加。

```cpp
cnt=0;
for(auto xx:v) {
    if(!cnt||f[cnt].r!=xx.l-1) f[++cnt]=xx;
    else f[cnt].r=xx.r, (f[cnt].x+=xx.x)%=mod;
}
```



对于连续的没有关键点的行，我们只需要先将方案下放并累加，然后乘 $m$ 的对应次幂，最后只留下 $[1,m]$。

```cpp
if(a[k].fi+1!=a[i].fi) {
    int dx=a[i].fi-a[k].fi-2;
    ll sum=0;
    rep(j,1,cnt) (sum+=f[j].x*(f[j].r-f[j].l+1)%mod)%=mod;
    (sum*=fp(m,dx))%=mod;
    f[1]=node(1,m,sum);
    cnt=1;
}
```



做完之后，最后一定还剩下若干没有关键点的行，照做即可。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
#define uint unsigned long long
#define PII pair<int,int>
#define MP make_pair
#define fi first
#define se second
#define pb emplace_back
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
const int N=1e5+5, mod=998244353;
int n, m, q, cnt, ans, b[N], t[N];
PII a[N];
map<int,bool> p;
struct node {
    int l, r; ll x;
    node() {};
    node(int _l,int _r,ll _x) { l=_l, r=_r, x=_x; }
} f[N];
ll fp(int a,int b) {
    ll c=1;
    for(;b;a=1ll*a*a%mod,b>>=1) if(b&1) c=c*a%mod;
    return c;
}
void uniq(int* b,int& tot) {
    sort(b+1,b+tot+1);
    tot=unique(b+1,b+tot+1)-b-1;
}

signed main() {
    n=read(), m=read(), q=read();
    rep(i,1,q) a[i].fi=read(), a[i].se=read();
    int k=0;
    f[++cnt]=node(1,m,1);
    rep(i,1,q) if(i==q||a[i].fi!=a[i+1].fi) {
        if(a[k].fi+1!=a[i].fi) {

            int dx=a[i].fi-a[k].fi-2; ll sum=0;
            rep(j,1,cnt) (sum+=f[j].x*(f[j].r-f[j].l+1)%mod)%=mod;
            (sum*=fp(m,dx))%=mod;
            f[1]=node(1,m,sum);
            cnt=1;
        }

        p.clear();

        int tot=0;
        if(a[k].fi+1==a[i].fi) for(int j=k;j&&a[j].fi==a[k].fi;--j) b[++tot]=a[j].se;

        for(int j=k+1;j<=i;++j) b[++tot]=a[j].se, p[a[j].se]=1;

        b[++tot]=0, b[++tot]=m+1;
        uniq(b,tot);


        vector<node> v;
        for(int j=1,pos=1;j<tot;++j) {
            if(b[j]&&!p.count(b[j])) v.pb(node(b[j],b[j],0ll));

            int L=b[j]+1, R=b[j+1]-1;

            if(L>R) continue;
            while(pos<=cnt&&f[pos].r<L) ++pos;

            ll sum=f[pos].x*(R-L+1)%mod;
            v.pb(node(L,R,sum));
        }

        cnt=0;
        for(auto xx:v) {
            if(!cnt||f[cnt].r!=xx.l-1) f[++cnt]=xx;
            else f[cnt].r=xx.r, (f[cnt].x+=xx.x)%=mod;

        }
        k=i;
    }
    int dx=n-a[k].fi;
    ll sum=0;
    rep(i,1,cnt) (sum+=f[i].x*(f[i].r-f[i].l+1)%mod)%=mod;
    printf("%lld\n",sum*fp(m,dx)%mod);
}
```

计数部分不难，难在对区间的处理。

怎么说，在考场上，除非时间很充足并且有很大把握，否则是不会去写这种题的。

但过一遍这道题也有所收获。

初看这道题，很容易与某组合典题联系起来，从而想到利用关键点去容斥。尽管正解不是这样做，但最终也需要在关键点上下功夫，算是完善一下科技树并锻炼代码能力了。
