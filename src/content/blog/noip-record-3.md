---
title: 「NOIP Record」#3 Trie
pubDate: 2023-05-08
tags:
  - Trie
  - 字符串
  - DP
  - 树论
  - 计数
categories:
  - Record
description: '少年找到了节奏'
---

## Trie

### luogu2922 [USACO08DEC]Secret Message G

> 给定两个字符串序列 $a$ 与 $b$，对于 $b$ 中每个字符串 $t$，求 $a$ 中有多少个字符串 $s$，满足以下两个条件之一
> 
> 1. $s$ 是 $t$ 的前缀。
> 2. $t$ 是 $s$ 的前缀。
> 
> 两个字符串序列中所有字符串长度之和不超过 $500000$。

把 $a$ 中所有字符串插入 Trie，记录每个节点处结尾的字符串数量 $end_x$。对于第 1 种，答案就是 $t$ 路径上的 $end_x$ 之和。

对于第 2 种，在 Trie 上 $\text{DFS}$ 求出以 $x$ 为根的子树内有多少字符串的结尾位置 $sz_x$，然后顺着 $t$ 走，如果走不完 $t$ 就是 $0$，否则就是 $t$ 结尾那个节点的 $sz_x$。

注意算第一种要忽略 $t$ 结尾那个节点的 $end_x$，否则会重复。

### UVA1401 Remember the Word

> 给定一个由 $s$ 个不同单词组成的字典 $D$ 和一个长度为 $n$ 的字符串 $S$，求把这个字符串按照字典划分为若干单词有多少种方法。
> 
> $s \le 4000$，$n \le 300000$。
> 
> 单个字典中的单词长度不超过 $100$。

朴素 DP，设 $f_i$ 为 $[1,i]$ 的划分方案数，则

$$
f_i = \sum_{j=0}^i f_j \big[S[j+1,i] \in D\big]
$$



或者

$$
f_i = \sum_{s \in D \texttt{ and } s \text{ is a suffix of } S[1,i]} f_{i-|s|-1}
$$


不太能优化。

尝试另外一种状态，设 $f_{i}$ 为后缀 $[i,n]$ 的划分方案数


$$
f_i = \sum_{s \in D \texttt{ and } s \text{ is a prefix of } S[i,n] } f_{i+|s|+1}
$$




注意到字典中单词长度不超过 $100$，所以可以从 $i$ 暴力枚举，通过 hash 快速判断是否可以转移。

但是这篇文章写 Trie，考虑一些 Trie 做法。

将 $D$ 中字符串插入 Trie，搜一下 $S[i,n]$，找一下路径上的结束节点即可。

### luogu7537. [COCI2016-2017#4] Rima

> 设字符串 $A$ 与 $B$ 的最长公共后缀的长度为 $\operatorname{LCS}(A,B)$。
> 
> 称两个字符串 $A,B$ 合法，当且仅当 $\operatorname{LCS}(A,B) \ge \max(|A|,|B|)-1$。
> 
> 给定 $n$ 个字符串，要求组合出一个长度最长的字符串序列，满足相邻两个字符串合法。输出序列长度。
> 
> $n \le 5 \cdot 10^5$，字符串总长度不超过 $3 \cdot 10^6$。

后缀不好做，可以转化成前缀插入 Trie，记录在每个节点结束的串的个数。

这样就转化成了 $A,B$ 合法，当且仅当在 Trie 树上，二者结束节点的 LCA，距离深度较大的那个结束节点不超过一条边。

还能继续发现性质。合法的字符串序列，相邻两个串的 $\operatorname{LCS}$ 可以是先递减后递增的。这样一定最优。

因此在 Trie 上 DFS，枚举中间这个最小的 $\operatorname{LCS}$。

设 $f_x$ 为最长公共后缀长度单调不增，最后两个串的最长公共后缀是 $x$ 对应的字符串的最长序列。相当于时求了最优序列的一半。

节点 $x$ 是所有子节点的 $\operatorname{LCS}$，所以它的所有子节点都能加入序列，以 $x$ 为结尾的串放到中间。而序列两边还能接上以 $x$ 的某两个子节点的 $f$ 值，取最大和次大即可。

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
const int N=3e6+5;
int n;
int tot, ans, trie[N][26], cnt[N], f[N];
char s[N];
struct Trie {
    void insert(char* s) {
        int x=0, len=strlen(s);
        per(i,len-1,0) {
            int a=s[i]-'a';
            if(!trie[x][a]) trie[x][a]=++tot;
            x=trie[x][a];
        }
        ++cnt[x];
    }
    void dfs(int x) {
        f[x]=cnt[x];
        int sz=0, fr=0, sc=0;
        rep(i,0,25) if(trie[x][i]) {
            int y=trie[x][i];
            dfs(y);
            if(cnt[y]) {
                ++sz;
                if(f[y]>fr) sc=fr, fr=f[y];
                else if(f[y]>sc) sc=f[y];
            }
        }
        f[x]+=fr+max(0ll,sz-1);
        ans=max(ans,fr+sc+cnt[x]+max(0ll,sz-2));
    }
} tr;
signed main() {
    n=read();
    rep(i,1,n) {
        scanf("%s",s);
        tr.insert(s);
    }
    tr.dfs(0);
    printf("%lld\n",ans);
}
```

### luogu9218 「TAOI-1」Apollo

如果 $a$ 与 $b$ 的整数部分不同，那么一定能找到一个整数 $c$ 使得 $f(c) = 0$，从而 $g(a,b)=0$。

如果 $a$ 与 $b$ 的整数部分相同，小数部分不同，那么能找到一个 $c$ 是的 $f(c)$ 是它们小数部分 $\operatorname{LCP}$ 的长度 $len+1$，这也是 $g(a,b)$ 的最小值。

比如

```cpp
a=11.4514
b=11.4523
c=11.452, g(a,b)=3
```

而当 $a=b$ 时，$g(a,b)$ 是 $a$ 小数部分 $\operatorname{LCP}$ 的长度，这个显然。

考虑用 Trie 维护前缀信息，把 $\operatorname{LCP}$ 长度拆成每个节点被经过的次数。

问题在于对于每一个 $i$ 求 $\sum_{j=1}^n g(a_i,a_j)$。

由上述分析知道 $g(a_i,a_j)$ 有贡献的必要条件是 $a_i$ 与 $b_i$ 整数部分相同。我们可以将所有 $a_i$ 按照整数部分排序，一次处理整数部分相同的一块 $[l,r]$，这些数肯定共用一棵 Trie。然后用每个 $a_i$ 的小数部分去匹配这棵 Trie，将这些贡献加入 $ans_i$。

匹配的过程中到达了节点 $x$，无论子节点是什么都会产生贡献，所以在记录每个点被经过的次数时，直接加到它的父亲节点即可。这样同时避免了 $a_i$ 匹配 $a_i$ 时特判最后一位。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=1e5+5, M=3e6+5;
int n, ans[N];
int tot, trie[M][10], cnt[M];
struct qwq {
    int it, id;
    string s;
} e[N];
bool operator<(qwq a,qwq b) {
    return a.it<b.it;
}
void insert(string S,int d) {
    int x=0, len=S.size();
    for(int i=0;i<len;++i) {
        cnt[x]+=d;
        // 在父节点处修改
        int a=S[i]-'0';
        if(!trie[x][a]) trie[x][a]=++tot;
        x=trie[x][a];
    }
}
int query(string S) {
    int x=0, res=0, len=S.size();
    for(int i=0;i<len;++i) {
        res+=cnt[x];
        // 在父节点处统计
        int a=S[i]-'0';
        if(!trie[x][a]) break;
        x=trie[x][a];
    }
    return res;
}
void solve(int l,int r) {
    for(int i=l;i<=r;++i) insert(e[i].s,1);
    for(int i=l;i<=r;++i) ans[e[i].id]+=query(e[i].s);
    for(int i=l;i<=r;++i) insert(e[i].s,-1);
}
signed main() {
    n=read();
    rep(i,1,n) {
        scanf("%lld.",&e[i].it);
        cin>>e[i].s;
        e[i].id=i;
    }
    sort(e+1,e+n+1);
    int lst=1;
    for(int i=1;i<n;++i) {
        if(e[i].it!=e[i+1].it) solve(lst,i), lst=i+1;
    }
    if(lst!=n) solve(lst,n);
    rep(i,1,n) printf("%lld\n",ans[i]);
}

```

### 某模拟赛题

> 小 F 正在写一个磁盘搜索系统。磁盘中共有 $n$ 个文件，它们的文件名 $s_i$ 由小写字母组成，两两不同。小 F 想快速知道 $m$ 个问题的答案：第 $i$ 次给定 $t_i$，求以 $t_i$ 为文件名的文件是否存在。
> 
> 这个问题很快被小 F 解决了。但是小 F 遇到了一个新的问题：他记不清 $t_i$ 具体是什么，只记得它的开头一部分和结尾一部分，中间部分用一个`*`代替。小 F 想知道满足这个条件的文件有多少个。
> 
> 对于 $20\%$ 的数据，$\sum |S_i|,\sum |T_i|\le 100$。
> 
> 对于另外 $40\%$ 的数据，`*`出现在开头或结尾。
> 
> 对于 $100\%$ 的数据，$1\le |S_i|$，$1\le \sum |S_i|,\sum |T_i|\le 10^6$。



正反建两棵 Trie。

设 $t_{i,0}$ 为 $t_i$ 中`*`之前的部分最后一个字符在 Trie 上对应的节点，$t_{i,1}$ 为后面的部分的。

如果匹配 $t_i$ 时在正 Trie 匹配到 $x_0$，在反 Trie 匹配到 $x_1$，$t_{i,0}$ 必须在 $x_0$ 子树内，$t_{i,1}$ 必须在 $x_1$ 子树内。

暴力做法：对于每个 $t_i$，在正 Trie 上 DFS。匹配完 $t_{i,0}$ 之后，对其子树内所有点都加上 $1$ 的权值，然后是反 Trie 上的 $t_{i,1}$，其子树权值和即为答案。子树内 $dfn$ 连续，只涉及区间加区间查，可以用树状数组维护。

正解：把询问离线了。在 DFS 到 $t_{i,0}$ 时，求出此时 $t_{i,1}$ 的子树权值和；DFS 结束后再统计一次，做差即可。

可以只保存 Trie 上的 $t_{i,0/1}$ 节点，重新建图。

给出 std。

```cpp
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<algorithm>
#define IO(x) freopen(x".in","r",stdin),freopen(x".out","w",stdout)
using std::reverse;
const int N=1e6+5;
int n,m;
char s[N];
int ans[N];
int trieTotal,linkTotal,dfsCount;
struct BIT {
    int d[N];
    inline void update(int p) {
        for(; p<=dfsCount; p+=p&-p)++d[p];
    }
    inline int query(int p) {
        static int r;
        for(r=0; p; p-=p&-p)r+=d[p];
        return r;
    }
    inline int querySum(int l,int r) {
        return query(r)-query(l-1);
    }
} b;
struct queryNode {
    int to,nt;
    inline void set(int t,int n) {
        to=t,nt=n;
    }
} q[N];
struct linkNode {
    int to,nt,lp,rp;
    inline void set(int t,int n,int l,int r) {
        to=t,nt=n,lp=l,rp=r;
    }
} l[N<<1];
struct trieNode {
    int h,v1,v2;
#define siz v1
#define dfn v2
#define lnk v1
#define fir v2
    inline void addQuery(int i,int t) {
        q[i].set(t,fir),fir=i;
    }
} a[N<<1];
inline void update(int pos,int flg=1) {
    static int tmp;
    for(int i=a[pos].fir; i; i=q[i].nt) {
        tmp=q[i].to;
        ans[i]+=flg*b.querySum(a[tmp].dfn,a[tmp].dfn+a[tmp].siz-1);
    }
}
inline int newTrieNode() {
    return ++trieTotal;
}
inline int newLinkNode() {
    return ++linkTotal;
}
struct trie {
    int root,cur;
    char buf[N];
    inline trie():root(newTrieNode()) {};
    inline int addLink(int src,int dst,char*&s) {
        int tmp=newLinkNode(),old=cur;
        while(*s)buf[cur++]=*(s++);
        l[tmp].set(dst,a[src].h,old,cur),a[src].h=tmp;
        return dst;
    }
    inline int findLink(int pos,char*&s) {
        for(int i=a[pos].h,p; i; i=l[i].nt){
            for(p=l[i].lp;p<l[i].rp&&buf[p]==*s;++p)++s;
            if(p==l[i].lp)continue;
            if(p==l[i].rp)return l[i].to;
            pos=newTrieNode();
            int tmp=newLinkNode();
            l[tmp].set(l[i].to,0,p,l[i].rp),a[pos].h=tmp;
            l[i].to=pos,l[i].rp=p;
            break;
        }
        return addLink(pos,newTrieNode(),s);
    }
    inline int getLink(int pos,char*&s) {
        for(int i=a[pos].h,p; i; i=l[i].nt){
            for(p=l[i].lp;p<l[i].rp&&buf[p]==*s;++p)++s;
            if(p==l[i].lp)continue;
            if(p==l[i].rp||*s=='*')return l[i].to;
            break;
        }
        return 0;
    }    
    inline int insert(char* s) {
        int pos=root;
        while(*s)pos=findLink(pos,s);
        return pos;
    }
    inline int travel(char* s) {
        int pos=root;
        while(pos&&*s!='*')pos=getLink(pos,s);
        return pos;
    }
} t[2];
inline int dfs1(int pos) {
    a[pos].siz=1,a[pos].dfn=++dfsCount;
    for(int i=a[pos].h; i; i=l[i].nt)a[pos].siz+=dfs1(l[i].to);
    return a[pos].siz;
}
inline void dfs2(int pos) {
    update(pos,-1);
    if(a[pos].lnk)b.update(a[a[pos].lnk].dfn);
    for(int i=a[pos].h; i; i=l[i].nt)dfs2(l[i].to);
    update(pos,1);
}
int len,t0,t1;
inline void funcS() {
    scanf("%s",s);
    len=strlen(s),t0=t[0].insert(s);
    reverse(s,s+len),t1=t[1].insert(s);
    a[t0].lnk=t1;
}
inline void funcT(int i) {
    scanf("%s",s);
    len=strlen(s),t0=t[0].travel(s);
    reverse(s,s+len),t1=t[1].travel(s);
    if(t0&&t1)a[t0].addQuery(i,t1);
}
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1; i<=n; ++i)funcS();
    dfs1(t[1].root);
    for(int i=1; i<=m; ++i)funcT(i);
    dfs2(t[0].root);
    for(int i=1; i<=m; ++i)printf("%d\n",ans[i]);
}
```



## 0-1 Trie

在 0-1 Trie 上实现 $\operatorname{kth xor}$ 很容易。

### luogu5283 [十二省联考 2019] 异或粽子

求前缀异或和 $s$，问题转化为求 $k$ 个点对 $(i,j)$，满足 $s_j \oplus s_i$ 是前 $k$ 大的。

考虑用 Trie。由于 Trie 是无序的而点对有序，所以一个点对会被找到两次，这样求出答案再除以 $2$ 即可。

暴力插入显然是不行的。但是对于 $(i,j_0)$ 与 $(i,j_1)$，若 $s_i \oplus s_{j_0} > s_i \oplus s_{j_1}$，那么 $j_0$ 一定优先于 $j_1$。所以开一个大根堆，维护三元组 $(x,id,rk)$ 表示与 $s_{id}$ 异或结果从大到小排名为 $rk$ 的异或值 $x$，贪心选择，然后再加入 $(x',id,rk+1)$。

虽然 $(i,i)$ 不合法且能被选到，但 $s_i \oplus s_i =0$，所以没有影响。

复杂度 $O(n \log_2 n)$。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
int n, k, ans, s[N];
struct node {
    int x, id, rk;
};
bool operator<(node a,node b) {
    return a.x<b.x;
}
priority_queue<node> q;
struct Trie {
    int tot, trie[N*31][2], cnt[N*31];
    void insert(int s) {
        int x=0;
        for(int i=31;~i;--i) {
            int a=(s>>i)&1;
            if(!trie[x][a]) trie[x][a]=++tot;
            x=trie[x][a];
            ++cnt[x];
        }
    }
    int query(int s,int k) {
        int x=0, ans=0;
        for(int i=31;~i;--i) {
            int a=(s>>i)&1;
            if(cnt[trie[x][a^1]]>=k) {
                ans|=1ll<<i;
                // 注意用1ll
                x=trie[x][a^1];
            } else {
                k-=cnt[trie[x][a^1]];
                x=trie[x][a];
            }
        }
        return ans;
    }
} T;
signed main() {
    n=read(), k=read();
    rep(i,1,n) s[i]=s[i-1]^read(), T.insert(s[i]);
    T.insert(s[0]);
    // 插入s[0]
    rep(i,0,n) {
        int x=T.query(s[i],1);
        q.push({x,i,1});
    }
    k<<=1;
    while(k--) {
        node t=q.top(); q.pop();
        ans+=t.x;
        int x=T.query(s[t.id],t.rk+1);
        q.push({x,t.id,t.rk+1});
    }
    printf("%lld\n",ans>>1);
}

```

### luogu6824 「EZEC-4」可乐

把 $a_i$ 插入 Trie，记录结束节点。

设 $f_y$ 为以 $y$ 为根的子树所能得到的最大值。

但是这样会有两个问题。

1. 不是所有情况下都能知道 $a_i \oplus x$ 与 $k$ 的大小关系。
2. 只有叶子节点能产生贡献，且只能贡献 $1$ 次。

进一步地，只有 $a_i$ 与 $x$ 这一位同号且 $k$ 这一位为 $1$ 时才能让以 $y$ 为根的子树中所有叶子节点的贡献转移到 $f_y$。

因此当 $k$ 这一位是 $1$ 时，有

$$
f_y = \max(f_{son_0(y)}+cnt_{son_1(y)}, f_{son_1(y)}+cnt_{son_0(y)})
$$



否则只继承状态

$$
f_y = \max(f_{son_0(y)},f_{rson_1(y)})
$$



其中 $cnt_y$ 表示以 $y$ 为根的子树中叶子节点的数量。这样就能解决上述两个问题。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
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
const int N=1e6+5;
int n, k, f[N*20], cnt[N*20];
int tot=1, trie[N*20][2];
void insert(int S) {
    int x=1;
    for(int i=20;~i;--i) {
        int a=(S>>i)&1;
        if(!trie[x][a]) trie[x][a]=++tot;
        x=trie[x][a];
    }
    ++cnt[x];
}
void ddfs(int x,int d) {
    if(!trie[x][0]&&!trie[x][1]) return;
    rep(i,0,1) {
        if(trie[x][i]) ddfs(trie[x][i],d-1), cnt[x]+=cnt[trie[x][i]];

    }
}
void dfs(int x,int d) {
    if(!trie[x][0]&&!trie[x][1]) { f[x]=cnt[x]; return; }
    rep(i,0,1) {
        if(trie[x][i]) dfs(trie[x][i],d-1);
    }
    int x0=trie[x][0], x1=trie[x][1];
    if((k>>d)&1) f[x]=max(cnt[trie[x][0]]+f[trie[x][1]],cnt[trie[x][1]]+f[trie[x][0]]);
    else f[x]=max(f[trie[x][0]],f[trie[x][1]]);
}
signed main() {
    n=read(), k=read();
    rep(i,1,n) insert(read());
    ddfs(1,20);
    dfs(1,20);
    printf("%lld\n",f[1]);
}
```

### CF Gym102331B Bitwise Xor

[link](https://nanami7.top/blog/cfgym102331b)

### luogu7717 「EZEC-10」序列

[link](https://nanami7.top/blog/luogu7717)
