---
title: 「NOIP Record」#23 贪心（2）
pubDate: 2023-11-12
tags:
  - 贪心
  - 并查集
  - 线段树
categories: Record
description: '少年忽略了自身的渺小'
---

### ABC137D Summer Vacation

错解：扫时间，维护当前可以做的事件集合，贪心选取收益最大的。

正解：把事件以收益为第一关键字，时长为第二关键字递增排序，每次选取收益最大的，找到能使其产生收益的最晚的那天安排这个事件。用并查集维护。

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
const int N=1e5+5;
int n, m;
struct node {
    int a, b;
    bool operator<(const node& r) const {
        if(b!=r.b) return b>r.b;
        return a>r.a;
    }
} a[N];
int fa[N];
int get(int x) { return x==fa[x]? x:fa[x]=get(fa[x]); }
void merge(int x,int y) {
    x=get(x), y=get(y);
    if(x!=y) fa[x]=y;
}
signed main() {
    n=read(), m=read();
    rep(i,1,n) a[i].a=read(), a[i].b=read();
    sort(a+1,a+n+1);
    int ans=0;
    rep(i,1,m) fa[i]=i;
    rep(i,1,n) if(m-a[i].a+1>0) {
        int p=get(m-a[i].a+1);
        if(!p) continue;
        merge(p,p-1);
        ans+=a[i].b;
    }
    printf("%lld\n",ans);
    return 0;
}
```

## UVA1316 Supermarket

上面那题为啥不能扫事件呢？

仔细想想就能发现，这个是有后效性的。

但是这一题就可以扫时间。具体的，我们把所有物品按照过期时间递增排序，然后按顺序枚举每个物品，用堆维护当前选择卖出的物品集合。如果当前物品的 DDL $d_i$ 大于集合大小，那么可以直接将其加入，否则尝试把集合中价值最小的那个物品换出来即可。

这个就是没有后效性的，因为每个物品的影响只有它被安放的那一天，并且过了 DDL 后这些物品都不能产生贡献。然后因为每个元素在尽可能靠近 DDL 的时刻被卖出去一定是不劣的，我们扫的其实是 DDL，同时两个元素的决策集合最多相差一个元素，所以我们可以用这种类似反悔贪心的做法。

本题也可以使用并查集的做法。由于每个问题在尽可能靠近 DDL 处卖出去最合适，所以我们可以把所有物品按照价值递增排序后用并查集维护这个过程。其正确性就在于，如果一个物品因此放置失败，那么把换掉任何一个之前放过的物品都不优秀。

代码就不写了。

## luogu3619 魔法

我们一定收先做 $b_i \ge 0$ 的任务，再做 $b_i < 0$ 的任务，这个显然。

对于 $b_i \ge 0$ 的任务，我们肯定是优先做 $t_i$ 更小的，这个也显然。

对于 $b_i < 0$ 的任务，则没有那么显然。 

对于两个任务 $i,j$，满足 $b_i,b_j <0$。

- 先做 $i$，那么失败的条件是 $T+b_i < t_j$，即 $T < t_j - b_i$。
- 先做 $j$，那么失败的条件是 $T+b_j < t_i$，即 $T < t_i - b_j$。

由于我们要尽可能做完所有任务，所以应该先完成更紧的条件。考虑
$$
t_j - b_i < t_i - b_j
$$
如果满足这个条件，那么 $i$ 应该先做，因为做完一个后 $T$ 必然减小。

此时 $b_i + t_i > b_j+t_j$，按照这个排序即可。

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
const int N=1e5+5;
int T, n, m, t[N], b[N], a[N];
bool cmp(int x,int y) {
    if(b[x]>=0&&b[y]>=0) return t[x]<t[x];
    else if(b[x]>=0||b[y]>=0) return b[x]>=0;
    else return t[x]+b[x]>t[y]+b[y];
}
void solve() {
    n=read(), m=read();
    rep(i,1,n) t[i]=read(), b[i]=read(), a[i]=i;
    sort(a+1,a+n+1,cmp);
    int cur=m;
    rep(i,1,n) {
        if(cur>t[a[i]]) cur+=b[a[i]];
        else { puts("-1s"); return; }
        if(cur<=0) { puts("-1s"); return; }
    }
    puts("+1s");
}
signed main() {
    T=read();
    while(T--) solve();
    return 0;
}
```

## luogu1986 元旦晚会

带权区间选点。

所有区间按照右端点递增排序，对区间开扫，线段树维护区间有多少个人没有话筒。如果一个区间不满足条件，那么二分出一个后缀，区间修改即可。

偷懒没写线段树上二分。

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
const int N=30005, M=5005;
int n, m;
struct node {
    int l, r, c;
    bool operator<(const node& b) const {
        if(r!=b.r) return r<b.r;
        return l<b.l;
    }
} a[M];
int t[N<<2], tag[N<<2];
void pushup(int x) { t[x]=t[x<<1]+t[x<<1|1]; }
void maketag(int x) {
    t[x]=0;
    tag[x]=0;
}
void pushdown(int x) {
    if(!tag[x]) {
        maketag(x<<1);
        maketag(x<<1|1);
        tag[x]=1;
    }
}
void build(int x=1,int l=1,int r=n) {
    tag[x]=1;
    if(l==r) { t[x]=1; return; }
    int mid=(l+r)>>1;
    build(x<<1,l,mid);
    build(x<<1|1,mid+1,r);
    pushup(x);
}
void upd(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) { maketag(x); return; }
    int mid=(l+r)>>1;
    pushdown(x);
    if(L<=mid) upd(L,R,x<<1,l,mid);
    if(R>mid) upd(L,R,x<<1|1,mid+1,r);
    pushup(x);
}
int query(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) return t[x];
    int mid=(l+r)>>1, res=0;
    pushdown(x);
    if(L<=mid) res+=query(L,R,x<<1,l,mid);
    if(R>mid) res+=query(L,R,x<<1|1,mid+1,r);
    return res;
}
signed main() {
    n=read(), m=read();
    rep(i,1,m) {
        a[i].l=read(), a[i].r=read(), a[i].c=read();
    }
    sort(a+1,a+m+1);
    build();
    int l=a[1].r-a[1].c+1, r=a[1].r;
    int ans=a[1].c;
    upd(l,r);
    rep(i,2,m) {
        int cnt=a[i].r-a[i].l+1-query(a[i].l,a[i].r);
        if(cnt>=a[i].c) continue;
        a[i].c-=cnt;
        int L=a[i].l, R=a[i].r;
        while(L<R) {
            int mid=(L+R+1)>>1;
            if(query(mid,a[i].r)>=a[i].c) L=mid; else R=mid-1;
        }
        ans+=a[i].c;
        upd(L,a[i].r);
    }
    printf("%lld\n",ans);
    return 0;
}
```

## luogu6155 修改

把 $a_i$ 递减排序，对于每个 $a_i$，让其变成大于 $a_i$ 的最小的没有被占用的数，一定是最优的。感性理解显然。

在值域上用并查集维护，可以求出每个位置被操作的次数。

把 $b_i$ 递增排序，每个位置被操作的次数递减排序，这样匹配也一定最优。

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
const int N=1e6+5;
int n, a[N], b[N];
unordered_map<int,int> fa;
int get(int x) {
     if(!fa[x]) return fa[x]=x+1;
     return fa[x]=get(fa[x]);
}
vector<int> v;
signed main() {
    n=read();
    rep(i,1,n) a[i]=read();
    rep(i,1,n) b[i]=read();
    sort(a+1,a+n+1,greater<int>());
    rep(i,1,n) {
        int x=get(a[i])-(a[i]+1);
        if(x>0) v.pb(x);
    }
    sort(v.begin(),v.end(),greater<int>());
    sort(b+1,b+n+1);
    uint ans=0;
    int pos=1;
    for(auto x:v) {
        ans+=x*b[pos];
        ++pos;
    }
    printf("%llu\n",ans);
    return 0;
}
```

## luogu1607 Fair Shuttle

这种题，猜结论远远比推结论更实用。

策略：把所有区间按照右端点为第一关键字，左端点为第二关键字递增排序。从左往右扫，能上车多少就上多少。

>证明。
>
>考虑排序后的两个区间。
>
>1. 不相交。显然互不影响。
>2. 相交但不包含。由于靠前的区间更早结尾，所以对于它们重叠的那一块，选择前面的区间必然不劣。
>3. 存在包含关系。此时我们先处理较小的区间。同理，重叠的那一块，选择较小的区间必然不劣。

如何维护呢？

我们开一棵线段树维护在每个站点时车上有多少人，同时维护区间最大值。这样就能求出最多上车多少人，然后区间加法即可。

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
const int N=2e5+5, M=5e5+5;
int n, m, c, ans;
struct node {
    int l, r, x;
    bool operator<(const node& b) const {
        if(r==b.r) return l<b.l;
        return r<b.r;
    }
} a[M];
int t[N<<2], tag[N<<2];
void pushup(int x) { t[x]=max(t[x<<1],t[x<<1|1]); }
void maketag(int x,int d) { t[x]+=d, tag[x]+=d; }
void pushdown(int x) {
    if(tag[x]!=0) {
        maketag(x<<1,tag[x]);
        maketag(x<<1|1,tag[x]);
        tag[x]=0;
    }
}
void upd(int L,int R,int d,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) { maketag(x,d); return; }
    pushdown(x);
    int mid=(l+r)>>1;
    if(L<=mid) upd(L,R,d,x<<1,l,mid);
    if(R>mid) upd(L,R,d,x<<1|1,mid+1,r);
    pushup(x);
}
int query(int L,int R,int x=1,int l=1,int r=n) {
    if(L<=l&&r<=R) return t[x];
    pushdown(x);
    int mid=(l+r)>>1, res=0;
    if(L<=mid) res=max(res,query(L,R,x<<1,l,mid));
    if(R>mid) res=max(res,query(L,R,x<<1|1,mid+1,r));
    return res;
}
signed main() {
    m=read(), n=read(), c=read();
    rep(i,1,m) {
        a[i].l=read(), a[i].r=read()-1, a[i].x=read();
        // 注意右端点-1
    }
    sort(a+1,a+m+1);
    rep(i,1,m) {
        int l=a[i].l, r=a[i].r;
        int cnt=query(l,r);
        if(cnt>=c) continue;
        int d=min(a[i].x,c-cnt);
        ans+=d;
        upd(l,r,d);
    }
    printf("%lld\n",ans);
    return 0;
}
```

