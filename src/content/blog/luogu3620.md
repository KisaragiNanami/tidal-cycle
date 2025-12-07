---
title: luogu3620 数据备份 题解
tags: 贪心
categories: 题解
description: 'Solution'
pubDate: 2022-05-14
---

## 分析

很容易发现选择不相邻的两个办公楼是不划算的。

所以记 $d_i$ 为第 $i$ 与第 $i+1$ 个办公楼之间的距离。



由于任一个办公楼都属于唯一的配对组，所以一旦选择了 $d_i$，$d_{i-1}$ 与 $d_{i+1}$ 也就不能再选择。

考虑特殊情况，当 $k=1$ 的时候，答案是就 $\min{\{ d_i \}}$。

当 $k=2$ 的时候，设最小的是 $d_a$，那么答案一定是

1. $d_a$ 加上除了 $d_a$，$d_{a-1}$，$d_{a+1}$ 之外的最小值，
2. $d_{a-1}$ 与 $d_{a+1}$。

两种决策其中一个。

为什么会出现这种情况呢？因为选择 $a$，$a-1$ 与 $a+1$ 便不能再选。可是如果 $d_a$ 加上除了上述三者之外的最小值后还不如 $d_{a-1}$ 加上 $d_{a+1}$ 小，那么就是另一种答案了。

那么就有一个结论，$a-1$ 与 $a+1$，在 $a$ 不被选择时同时不选，在 $a$ 不选时一定同时被选择。

感性理解一下，对于任何 $k \ge 2$，这个都是成立的。

单纯地贪心不能保证当前最优就是全局最优，可是能够修改某一个决策的方式维护全局最优，这其实是一个反悔贪心。

所以维护 $d_i$ 的集合 $S$，贪心地将最小值 $d_a$ 加入答案，同时删去 $d_a$，$d_{a-1}$，$d_{a+1}$。加入一个新的元素 $a'$，其中 $d_{a'}=d_{a-1}+d_{a+1}-d_a$。

这样当取出的最小值为 $d_{a'}$ 时，实际上表明第 2 种决策优于第 1 种决策，加入 $d_{a'}$ 后也相当于一步反悔，把加入的 $d_a$ 消去了。

既然要快速查找相邻元素，可以用链表维护，用优先队列实现贪心。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+6, inf=1<<30;
int n, k, pre[N], nxt[N], a[N], d[N], v[N];
// v[x]代表x是否被删去了
long long ans;
struct node { int x, val; };
bool operator<(node a,node b) { return a.val>b.val; } 
priority_queue<node> q;
void updata(node t) {
    int l=pre[t.x], r=nxt[t.x];
    v[l]=v[r]=1;
    pre[t.x]=pre[l], nxt[pre[l]]=t.x;
    nxt[t.x]=nxt[r], pre[nxt[r]]=t.x;
    t.val=d[t.x]=(l&&r)? min(d[l]+d[r]-d[t.x],inf):inf;
    q.push({t.x,t.val});
}
int main() {
    scanf("%d%d",&n,&k);
    for(int i=1;i<=n;++i) scanf("%d",&a[i]);
    for(int i=1;i<n;++i) d[i]=a[i+1]-a[i], pre[i]=i-1, nxt[i]=i+1;
    nxt[n-1]=0;
    for(int i=1;i<n;++i) q.push({i,d[i]});
    for(int i=1;i<=k;++i) {
        while(v[q.top().x]) q.pop(); 
        // 优先队列不方便删除元素，可以额外标记已经被删除的
        node t=q.top(); q.pop();     
        ans+=t.val;
        updata(t); // 更新链表
    }
    printf("%lld\n",ans);
}
```
