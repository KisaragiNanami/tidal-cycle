---
title: 「KDOI」Round 6 题解
pubDate: 2023-10-30
tags:
  - DP
  - 计数
  - 贪心
  - 树形DP
  - 区间DP
  - 构造
  - 记忆化搜索
  - 决策单调性
categories:
  - 题解
  - 比赛
description: '个人题解'
---

> 暂时只有 S 组

## A

容易发现答案是前缀置 $0$ 后单点改 $1$ 和后缀单点改 $0$。

但前缀置 $0$ 用 1 操作不一定更优秀，也有可能多次使用 2 操作。

如何实现才能使求解过程只和关键点有关呢？单点改 $1$ 可以提出来，后缀单点改  $0$ 可以维护关于关键点的 $\Delta$。

求出 $f_i$ 表示把前缀 $[1,i]$ 置为 $0$，后缀 $[i+1,n]$ 改成全 $0$ 的最小代价。
$$
f_i = \min(f_{i-1},a_i + \sum_{j=1}^n b_i)
$$
对于一个点集 $P$，我们直接从左往右扫两种操作的分界点。维护 $\Delta$ 表示把当前扫到的关键点单点改 $1$ 的代价、没扫到的关键点单点改 $0$ 的代价的相反数之和，在 $P_i$ 时的答案就是 $f_{P_{i-1}}+\Delta$。

注意不要漏掉全区置 $0$ 后单点改 $1$。

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
const int N=5e5+5;
int n, q, a[N], b[N], c[N], d[N], f[N];
int p[N]; 
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    rep(i,1,n) b[i]=read();
    rep(i,1,n) c[i]=read();
    q=read();
    per(i,n,1) d[i]=d[i+1]+b[i];
    f[0]=d[1];
    for(int i=1;i<=n;++i) f[i]=min(f[i-1],a[i]+d[i+1]);
    while(q--) {
        int m=read(), t=0;
        rep(i,1,m) p[i]=read(), t-=b[p[i]];
        int ans=5e18;
        rep(i,1,m) ans=min(ans,f[p[i]-1]+t), t+=c[p[i]]+b[p[i]];
        ans=min(ans,f[n]+t);
        printf("%lld\n",ans);
    }
    return 0;
}
```

## B

注意到每一位是相对独立的，所以拆掉。

对于每一位，有用的信息是连通块中这个位上出现 $1$ 的数量的奇偶性。

设 $f(x,i,0/1)$ 为以 $x$ 为根的子树，在包含 $x$ 的连通块中，第 $i$ 位上的 $1$ 出现了偶数/奇数次的总贡献和。

转移考虑子树合并，讨论加入还是断开。

加入是平凡的。
$$
f'(x,i,j \oplus j') \leftarrow f(x,i,j) \times f(y,i,j')
$$

断开则需要统计所有位的贡献。
$$
f'(x,i,j) \leftarrow f(x,i,j) \times 2^k \times f(y,k,1)
$$
这样复杂度就是 $O(n \log^2 V)$ 的，无法通过。

瓶颈在于断开的转移。我们可以做这样一个等价转换：断开等价于接上一个所有位都是 $0$ 的连通块。

于是我们对 $x$ 先只做加入的转移，然后令 $h(x) = \sum_{i=1}^{\lfloor \log V \rfloor} f(x,i,1) \times 2^{i}$，做
$$
f(x,i,0) \leftarrow  h(x)
$$
即可。

注意最后还要闭合最后一个连通块，所以答案就是 $h(1)$。

复杂度 $O(n \log V)$。

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
const int N=5e5+5, mod=998244353;
int n, a[N], f[N][61][2], g[61][2], h[N];
int pw[60];
vector<int> p[N];
void dfs(int x,int fa) {
    for(int i=0;i<60;++i) f[x][i][(a[x]>>i)&1]=1;
    for(auto y:p[x]) if(y!=fa) {
        dfs(y,x);
        for(int i=0;i<60;++i) g[i][0]=g[i][1]=0;
        for(int i=0;i<60;++i) {
            (g[i][0]+=(f[x][i][0]*f[y][i][0]%mod+f[x][i][1]*f[y][i][1]%mod)%mod)%=mod;
            (g[i][1]+=(f[x][i][0]*f[y][i][1]%mod+f[x][i][1]*f[y][i][0]%mod)%mod)%=mod;
        }
        for(int i=0;i<60;++i) f[x][i][0]=g[i][0], f[x][i][1]=g[i][1];
    }
    for(int i=0;i<60;++i) (h[x]+=f[x][i][1]*pw[i]%mod)%=mod;
    for(int i=0;i<60;++i) (f[x][i][0]+=h[x])%=mod;
}
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    rep(i,2,n) {
        int x=read();
        p[x].pb(i), p[i].pb(x);
    }
    pw[0]=1;
    for(int i=1;i<60;++i) pw[i]=pw[i-1]*2%mod;
    dfs(1,0);
    printf("%lld\n",h[1]);
    return 0;
}
```

## C

不会正解。

输出方案放到最后说。

注意到合并不会改变异或和，那么任何时候合并的三个数都可以看作原序列的三个区间。

设 $f(i,j)$ 为 $[i,j]$ 能否完成合并。转移枚举 $l_1,l_2,l_3,l_4$，如果 $[i,l_1],[l_2,l_3],[l_4,j]$ 能够合并，那么 $f(i,j)=1$。

复杂度 $O(n^6)$，常数大约为 $\frac{1}{720}$，可以得到 $35 \text{ pts}$。

考虑求出 $S_x$ 表示异或和为 $x$ 的区间集合。转移时枚举 $l_1,l_4$，然后我们我们只要取出 $S_x$ 中被区间 $[l_1+1,l_4-1]$ 完全包含的区间即可，其中 $x$ 为 $[i,l_1]$ 与 $[l_4,j]$ 的异或和再取异或。

一个区间最多可能被取出 $O(n^2)$ 次，姑且认为复杂度是 $O(n^4 + n^2V)$，常数大约是 $\frac{1}{24}$。

由于输出方案不需要考虑最优，所以可以加入可行性剪枝。使用记忆化搜索实现，可以得到 $100 \text{pts}$，但是有一组不计入分数的 Hack 数据。

&nbsp;

下面讨论如何输出方案。

我们先在 DP 的过程中记录使得 $f(i,j)$ 成为 $1$ 的三个区间。

从 $[1,n]$ 开始考虑，注意到状态间选出的区间无交，并且任意状态的三个区间中间夹着的位置都不会被操作。

所以如果我们在递归输出方案时优先递归靠右的区间，那么可以保证每个 $f(l,r)$ 第一个决策区间的左端点以及其左边的任何位置都没有操作，从而选出的三个下标中第一个数是 $l$。由于三个区间中间的位置不会被操作，记三个区间为 $[l,k_1],[k_2,k_3],[k_4,r]$，那么第二个下标就是 $l+k_2-k_1$，第三个下标就是 $l+k_2-k_1+k_4-k_3$。

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
const int N=555;
int T, n, a[N], s[N], f[N][N];
vector<PII > v[N];
PII tmp;
struct node {
    PII i, j, k;
    node() {
        i=j=k=tmp;
    }
    node(PII a,PII b,PII c) {
        i=a, j=b, k=c;
    }
} pre[N][N];
int get(int l,int r) {
    return s[r]^s[l-1];
}
void print(int l,int r) {
    if(l==r) return;
    print(pre[l][r].k.fi,pre[l][r].k.se);
    print(pre[l][r].j.fi,pre[l][r].j.se);
    print(pre[l][r].i.fi,pre[l][r].i.se);
    printf("%d %d %d\n",l,l+pre[l][r].j.fi-pre[l][r].i.se,l+pre[l][r].j.fi-pre[l][r].i.se+pre[l][r].k.fi-pre[l][r].j.se);
}
int dfs(int l,int r) {
    if(f[l][r]!=-114514) return f[l][r];
    if(l==r) return f[l][r]=0;
    if(l+1==r) return f[l][r]=-1;
    for(int i=l;i<r-1;++i) {
        int v1=dfs(l,i);
        if(v1<0) continue;
        for(int j=r;j>i+1;--j) {
            int v2=dfs(j,r);
            if(v2<0) continue;
            int x=get(l,i)^get(j,r);
            for(auto t:v[x]) {
                if(t.fi<=i||t.se>=j) continue;
                int v3=dfs(t.fi,t.se);
                if(v3<0) continue;
                pre[l][r]=node(MP(l,i),t,MP(j,r));
                return f[l][r]=v1+v2+v3+1;
            } 
        }
    }
    return f[l][r]=-1;
}
void solve() {
    n=read();
    rep(i,1,n) a[i]=read(), s[i]=s[i-1]^a[i];
    if(n==1) {
        printf("Huoyu\n0\n");
        return;
    }
    rep(i,0,512) v[i].clear();
    rep(i,1,n) rep(j,i,n) {
        f[i][j]=-114514;
        int x=get(i,j);
        v[x].pb(MP(i,j));
    }
    int x=dfs(1,n);
    if(~x) {
        puts("Huoyu");
        printf("%d\n",x);
        print(1,n);
    } else puts("Shuiniao");
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```



## D

不会正解。

$\texttt{Observation}$

1. 无法创造新数。
2. 序列 $\text{or}$ 和不变，同时无法消去任何一个二进制位。

所以，最终留下的一定是序列 $\text{or}$ 和，同时要求最大值等于序列 $\text{or}$ 和。

设序列 $\text{or}$ 和为 $s$，当 $s$ 多于两个时，我们总能通过一次操作使得两个 $s$ 相邻，从而不断扩展到全为 $s$。所以此时一定合法。

当 $s$ 只出现一次时，如果同时包含 $s$，那么就不能创造新的 $s$，所以只能从 $s$ 左边或右边找到一个 $\text{or}$ 和为 $s$ 的区间。更进一步的，只需要看 $s$ 左边或右边的 $\text{or}$ 和即可。

> 综上所述，一个序列满足条件，当且仅当序列 $\text{or}$ 和等于序列最大值，并且最大值出现超过一次，或最大值左边或右边的 $\text{or}$ 和等于最大值。

用 ST 表维护区间 $\text{or}$ 和区间最大值的下标，即可 $O(1)$ 判断一个区间是否合法。

用区间 DP 处理区间最长合法区间即可 $O(1)$ 回答询问，复杂度 $O(n^2)$，可以得到 $38 \text{pts}$。



对于 $\sum q \le 10$ 的测试点，我们直接暴力枚举 $[l,r]$ 中的每一个点当作最大值，二分找出对应的区间左右端点，然后在由于 $\text{or}$ 有单调性，二分找临界点即可。

有一些细节，比如某一边取到临界点后另一边就可以取到端点。有点麻烦就不写了，以后再说。

结合上述暴力可以得到 $48 \text{pts}$。

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
const int N=6005;
int T, id, n, q, a[N], lg[N], g[N][N];
bool valid[N][N];
int f[N][15], mx[N][15];
int cmax(int x,int y) {
    if(a[x]>=a[y]) return x;
    return y;
}
int qor(int l,int r) {
    if(l>r) return 0;
    int k=lg[r-l+1];
    return (f[l][k]|f[r-(1<<k)+1][k]);
}
int qmx(int l,int r) {
    int k=lg[r-l+1];
    return cmax(mx[l][k],mx[r-(1<<k)+1][k]);
}
void solve() {
    n=read(), q=read(); 
    rep(i,1,n) a[i]=read(), f[i][0]=a[i], mx[i][0]=i;
    for(int j=1;(1<<j)<=n;++j)
        for(int i=1;i+(1<<j)-1<=n;++i) {
            f[i][j]=(f[i][j-1]|f[i+(1<<(j-1))][j-1]);
            mx[i][j]=cmax(mx[i][j-1],mx[i+(1<<(j-1))][j-1]);
        }
    rep(i,1,n) rep(j,i,n) {
        if(i==j) {
            valid[i][j]=1;
            continue;
        }
        int sor=qor(i,j), pos=qmx(i,j);
        if(a[pos]!=sor) valid[i][j]=0;
        else {
            int ls=qor(i,pos-1), rs=qor(pos+1,j);
            if(ls==a[pos]||rs==a[pos]) valid[i][j]=1;
            else valid[i][j]=0; 
        }
    }
    rep(i,1,n) g[i][i]=1;
    rep(len,2,n) for(int i=1;i+len-1<=n;++i) {
        int j=i+len-1;
        g[i][j]=max(g[i+1][j],g[i][j-1]);
        if(valid[i][j]) g[i][j]=max(g[i][j],len);
    }
    while(q--) {
        int l=read(), r=read();
        printf("%d\n",g[l][r]);
    }
}
signed main() {
    T=read(), id=read();
    if(id>24) exit(0);
    rep(i,2,6000) lg[i]=lg[i>>1]+1;
    while(T--) solve();
    return 0;
}
```
