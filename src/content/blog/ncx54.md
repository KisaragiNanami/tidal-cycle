---
title: 「NowCoder Round X」#54 题解
tags:
  - 贪心
  - 最短路
  - DP
categories:
  - NowCoder
  - 比赛
description: '个人题解'
pubDate: 2022-08-14
---

**NowCoderX54**.



## A. Sum

引理：在最优解中，每次操作的 $k=2$。

> 证明：反证法。假设最优解中，存在一次操作 $k \neq 2$。那么 $k \ge 3$，当 $k=3$ 时，设选择的数为 $a$，$b$，$c$，那么会得到 $a+b+c$，收益为 $a+b+c$。如果先选择 $a$ 与 $b$ 得到 $a+b$，再选择 $a+b$ 与 $c$，那么会得到 $a+b+c$，收益为 $(a+b)+(a+b+c)$。这与最优解矛盾。由于操作次数没有限制，所以引理显然成立。

引理：在最优解中，一定先选择较大的数，再选择较小的数。

> 证明：感性理解。如果选择了最大的数和一个正数，那么它被删去之后会在另一个更大数之内，此后只要选这个更大的数，原先最大的数就会不断产生贡献。如果一开始选的数不是最大的数，显然不优。

将数列递减排序，维护前缀和 $pre$，对于 $i > 1$，先令 $pre + a_i$，如果此时 $pre > 0$，那么累加答案即可。

$pre$ 其实是此时数列里最大的数。

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
const int N=2e5+5, mod=1e7+7;
int t, n, a[N];
bool cmp(int x,int y) { return x>y; }
void solve() {
    n=read();
    for(int i=1;i<=n;++i) a[i]=read();
    sort(a+1,a+n+1,cmp);
    int pre=a[1], ans=0;
    for(int i=2;i<=n;++i) {
        pre+=a[i];
        if(pre>0) (ans+=pre)%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    t=read();
    while(t--) solve();
}
```

## B. Gaming

将 $(l_i,r_i,s_i)$ 看作是让 $[l_i,r_i]$ 都加上 $s_i$，那么对于每一个位置 $i$，表示的就是必须带着第 $i$ 个 debuff 才能拿到的总分数，设为 $c_i$。

设总分数为 $S$，那么没有带着所有 debuff 获得的最大的分，相当于带着 $m-1$ 个 debuff 的最大得分。

于是乎答案为 $\max_{i=1}^m \{ S - c_i \}$。

差分维护即可。

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
int n, m, ans, sum, c[N];
signed main() {
    n=read(), m=read();
    for(int i=1;i<=n;++i) {
        int l=read(), r=read(), s=read();
        c[l]+=s, c[r+1]-=s;
        sum+=s;
    }
    for(int i=1;i<=m;++i) {
        c[i]+=c[i-1];
        ans=max(ans,sum-c[i]);
    }
    printf("%lld\n",ans);
}
```

## C. School

这个也可以差分，可是值域很大，一种方法是离散化。

将几时几分转化为分钟，对于每一个禁止通话的时间段 $[l_i,r_i]$，在 $l_i$ 处 $+1$，在 $r_i+1$ 处 $-1$。某个时间能够通话，那么这个时间的位置必须是 $0$，否则一定被某个区间包含。

直接查 $x$ 的位置是否为 $0$，这是差分做法。

但是还有一个更简单的方法。

不被任何区间包含，也就是说，$x$ 经过起点 $l_i$ 的个数必须等于经过终点 $r_i$ 的个数。

将起点和终点分别排序，二分查找 $x$ 严格大于的起点个数和严格大于的终点个数，判断是否相等即可。

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
int n, h, m, q;
vector<int> st, ed;
signed main() {
    n=read(), h=read(), m=read(), q=read();
    for(int i=1;i<=n;++i) {
        int a=read(), b=read(), c=read(), d=read();
        int x=a*m+b, y=c*m+d;
        st.push_back(x), ed.push_back(y);
    }
    sort(st.begin(),st.end());
    sort(ed.begin(),ed.end());
    while(q--) {
        int x=read(), y=read();
        x=x*m+y;
        auto d1=lower_bound(st.begin(),st.end(),x)-st.begin();
        auto d2=lower_bound(ed.begin(),ed.end(),x)-ed.begin();
        if(d1!=d2) puts("No"); else puts("Yes");
    }
}
```

## D. Word

将差异小于等于 $1$ 的字符串互相连边。设 $s$ 为 $0$，$t$ 为 $n+1$，等价于求出 $0 \sim n+1$ 的最短路。

BFS 即可，过程中记录方案。

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
const int N=20005;
int n, m, d[N], pre[N];
int tot, h[N], to[N<<1], nxt[N<<1];
char s[N][30];
void add(int x,int y) {
    to[++tot]=y, nxt[tot]=h[x], h[x]=tot;
}
void addedge(int x,int y) {
    add(x,y), add(y,x);
}
int diff(char* s1,char* s2) {
    int cnt=0;
    for(int i=1;i<=m;++i) cnt+=(s1[i]!=s2[i]);
    return cnt;
}
void bfs() {
    queue<int> q;
    memset(d,-1,sizeof(d));
    d[0]=0, q.push(0);
    while(q.size()) {
        int x=q.front(); q.pop();
        for(int i=h[x];i;i=nxt[i]) {
            int y=to[i];
            if(~d[y]) continue;
            d[y]=d[x]+1;
            pre[y]=x;
            q.push(y);
        }
    }
}
void print(int x) {
    if(!x) { puts(s[x]+1); return; }
    print(pre[x]);
    puts(s[x]+1);
}
signed main() {
    n=read(), m=read();
    for(int i=1;i<=n;++i) scanf("%s",s[i]+1);
    scanf("%s%s",s[0]+1,s[n+1]+1);
    for(int i=0;i<=n+1;++i) for(int j=0;j<i;++j) {
        if(diff(s[i],s[j])<=1) addedge(i,j);
    }
    bfs();
    if(!d[n+1]) puts("0");
    else if(~d[n+1]) printf("%lld\n",d[n+1]-1);
    else { puts("-1"); goto end; }
    print(n+1);
    end:;
}
```

## D. Slash

设 $f(i,j,k)$ 为当前在矩阵的 $(i,j)$，匹配到了 $s_k$，这个字符串含有 $s$ 的最大值。

当 $a_{i,j} = s_k$ 时

$$
f(i,j,k) = \max_{k \in [1,|s|]}{\{ f(i-1,j,k-1),f(i,j-1,k) \}}
$$



如果 $a_{i,j}$ 匹配到了 $s$ 的最后一位，那么下一步就要从 $0$ 开始匹配

$$
f(i,j,0) = f(i,j,|s|) + 1
$$



之前状态的任何局面都有可能从 $0$ 重新开始匹配，所以

$$

$$



初始值乱搞就行了。

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
const int N=105;
int n, m, l, f[N][N][N];
char s[N], a[N][N];
signed main() {
    n=read(), m=read();
    scanf("%s",s+1), l=strlen(s+1);
    for(int i=1;i<=n;++i) scanf("%s",a[i]+1);
    memset(f,-0x3f,sizeof(f));
    f[0][0][0]=f[1][0][0]=f[0][1][0]=0;
    for(int i=1;i<=n;++i) for(int j=1;j<=m;++j) {
        for(int k=1;k<=l;++k) {
            if(a[i][j]==s[k])
                f[i][j][k]=max(f[i-1][j][k-1],f[i][j-1][k-1]);
        }
        f[i][j][0]=f[i][j][l]+1;
        for(int k=0;k<=l;++k)
            f[i][j][0]=max(f[i][j][0],max(f[i-1][j][k],f[i][j-1][k]));
    }
    int ans=0;
    for(int i=0;i<=l;++i) ans=max(ans,f[n][m][i]);
    printf("%lld\n",ans);
}
```

## F. Traveling

单独写了[题解](https://nanami7.top/blog/ncx54)。
