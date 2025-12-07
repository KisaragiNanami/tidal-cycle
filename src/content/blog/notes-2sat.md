---
title: 「图论学习笔记」#2 2-SAT 问题
tags:
  - 图论
  - 2-SAT
categories:
 - 学习笔记
pubDate: 2022-02-13
description: '2-SAT问题的概念与基本解法'
---

## 2-SAT

2-SAT 属于 k-SAT 问题的一种。不幸的是，对于 $k > 2$，都是 NPC 问题。



给定 $n$ 个变量，每个变量 $A_i \in \{0,1\}$。接着给定 $m$ 个条件，每个条件形如 



$$
A_i=0/1 \text{ or } A_j=0/1
$$



求 $n$ 个变量的合法赋值，满足全部 $m$ 个条件。

## 求解

将条件转化为：若 $A_i=p$，则 $A_j=q$，其中 $p,q \in \{0,1\}$。

举个例子，条件是 $A_1 = 1$ 或者 $A_3 = 0$。

1. 如果 $A_1 = 0$，则 $A_3$ 必定为 0。
2. 如果 $A_3 = 1$，那么 $A_1$ 一定为 1。

所以把 $n$ 个节点拆成 $2n$ 个节点，使 $A_i$ 对应节点为 $i$ 与 $i+n$，分别对应以上两种限制条件。

具体做法是，从 $i+p \cdot n$ 向 $j + q \cdot n$ 连一条有向边，从 $j + (1-p) \cdot n$ 向 $i+(1-q) \cdot n$ 连一条有向边。注意 $p,q$ 都是把**条件中的值取反**。

前者是原命题，后者是它的逆否命题。

### DFS

这个 DFS 的算法，代码短的同时还容易构造字典序最小解，但是复杂度为 $O(n \cdot (n+m))$，过高。

~~所以为什么在洛谷模板题，DFS比Tarjan还快~~

具体流程

1. 对于每个当前不确定的变量 $A_i$，令 $A_i=0$，然后 DFS 访问相连的点。
2. 检查如果会导致一个 $j$ 与 $j'$ 都被选，那么撤销操作，执行过程 3。否则令 $A_i=0$。
3. 令 $A_i=1$，重复过程 2，如果还不行，就无解。
4. 继续考虑下一个不确定的变量      

代码略。

### Tarjan

用 Tarjan 算法求出图中所有 SCC。如果存在 $i \in [1,n]$，满足 $i$ 与 $i+n$ 在同一个 SCC 里面，那么表明 $A_i$ 必须赋值为 $p$ 与 $1-p$，这显然是矛盾的，无解。

还可以构造出解。对于一个 $i$，选择拓扑序较大的状态更优。

由于 SCC 编号的顺序就是逆拓扑序，所以我们判断 SCC 编号 $c_i$ 与 $c_{i+n}$ 的大小。令 $f(i) = c_i > c_{i+n}$。如果 $f(i)=1$，那么说明 $i+n$ 的状态更优，对应到上面讨论的连边方法，就是令 $A_i$ 为条件中的值。否则说明 $i$ 状态更优，就是令 $\ \neg A_i$，与条件状态取反。

然后 $f(i)$ 就是解中 $A_i$ 的取值了。

复杂度 $O(n+m)$

```cpp
int n, m, scc, top, num, c[N], dfn[N], low[N], stk[N];
int cnt, h[N], ver[N], nxt[N];
inline void add(int x,int y) { ver[++cnt]=y, nxt[cnt]=h[x], h[x]=cnt; }
inline void addedge(int x,int xv,int y,int yv) {
    // xv,yv是条件中x,y的值
    add(x+!xv*n,y+yv*n), add(y+!yv*n,x+xv*n);
}
inline void tarjan(int x) {
    dfn[x]=low[x]=++num, stk[++top]=x;
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(!dfn[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
        } else if(!c[y]) low[x]=min(low[x],dfn[y]);
    }
    if(dfn[x]==low[x]) {
        ++scc;
        int y;
        do y=stk[top--], c[y]=scc; while(x!=y);
    }
}
bool solve() {
    for(int i=1;i<=n*2;++i) if(!dfn[i]) tarjan(i);
    for(int i=1;i<=n;++i) if(c[i]==c[i+n]) return 0;
    return 1;
}
void output() {
    for(int i=1;i<=n;++i) printf("%d ",c[i]>c[i+n]);
}
```

## 题目

[满汉全席](https://www.luogu.com.cn/problem/P4171)

板子。

汉式看作取值为 1，满式看作取值为 0。判断 2-SAT 是否有解。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define SET(x,y) memset(x,y,sizeof(x))
const int N=205, M=2005;
int T, n, m, num, top, scc, stk[N], dfn[N], low[N], c[N];
int cnt, h[N], ver[M], nxt[M];
inline void add(int x,int y) { ver[++cnt]=y, nxt[cnt]=h[x], h[x]=cnt; }
inline void addedge(int x,int xv,int y,int yv) {
    add(x+!xv*n,y+yv*n), add(y+!yv*n,x+xv*n); 
}
inline void tarjan(int x) {
    dfn[x]=low[x]=++num, stk[++top]=x;
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(!dfn[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
        } else if(!c[y]) low[x]=min(low[x],dfn[y]);
    }
    if(dfn[x]==low[x]) {
        int y;
        ++scc;
        do y=stk[top--], c[y]=scc; while(x!=y);
    }
}
inline void init() {
    cnt=top=scc=num=0;
    SET(h,0), SET(dfn,0), SET(low,0), SET(c,0);
}
inline void get(int& a,int& b) {
    char c=getchar();
    while(c!='h'&&c!='m') c=getchar();
    b=(c=='h');
    scanf("%d",&a);
}
inline bool check() {
    for(int i=1;i<=n;++i) if(c[i]==c[i+n]) return 0;
    return 1;
}
inline void solve() {
    init();
    scanf("%d%d",&n,&m);
    for(int i=1;i<=m;++i) {
        int x, xv, y, yv;
        get(x,xv), get(y,yv);
        addedge(x,xv,y,yv);
    }
    for(int i=1;i<=n*2;++i) if(!dfn[i]) tarjan(i);
    puts(check()? "GOOD":"BAD");
}
int main() { for(scanf("%d",&T);T--;solve()); }
```

&nbsp;

[Wedding](https://www.luogu.com.cn/problem/UVA11294)

翻译（复制的）

> 有N-1对夫妻参加一个婚宴，所有人都坐在一个长长的餐桌左侧或者右侧，新郎和新娘面做面坐在桌子的两侧。
> 
> 由于新娘的头饰很复杂，她无法看到和她坐在同一侧餐桌的人，只能看到对面餐桌的人。
> 
> 任意一对夫妻不能坐在桌子的同侧，另外有m对人有通奸关系，而新娘不希望看到两个有通奸关系人坐在他的对面，问如何安排这些座位

假设所有妻子和新娘坐在一侧，所有丈夫和新郎坐在一侧，如果没有通奸关系的限制，显然是合法的。

如果两人 $(A,B)$ 有通奸关系，那么令 w 为 1，表示和新娘同侧，h 为 2，表示和新郎同侧。$i \in [1,n]$ 为妻子，$i' \in [n+1,2n]$ 为丈夫。

如果 $A$ 在新娘一侧，那么 $B$ 一定在新郎一侧，从而 $B$ 的配偶一定在新娘一侧，反之亦然。这样通奸关系就转化成了条件，可以直接根据这个连边，表示一定在同侧的人。然后跑 2-SAT。

一开始本人也想不太明白，最好举几个例子。

最后要注意编号从 0 开始。新娘要和新郎连边。

```cpp
#include<bits/stdc++.h>
using namespace std;
#define SET(x,y) memset(x,y,sizeof(x))
const int N=8e5+5; 
int n, m, top, scc, num, c[N], dfn[N], low[N], stk[N];
int cnt, h[N], ver[N], nxt[N];
void add(int x,int y) { ver[++cnt]=y, nxt[cnt]=h[x], h[x]=cnt; }
void addedge(int x,int xv,int y,int yv) {
    add(x+!xv*n,y+yv*n), add(y+!yv*n,x+xv*n);
}
void tarjan(int x) {
    dfn[x]=low[x]=++num, stk[++top]=x;
    for(int i=h[x];i;i=nxt[i]) {
        int y=ver[i];
        if(!dfn[y]) {
            tarjan(y);
            low[x]=min(low[x],low[y]);
        } else if(!c[y]) low[x]=min(low[x],dfn[y]); 
    }
    if(dfn[x]==low[x]) {
        int y;
        ++scc;
        do y=stk[top--], c[y]=scc; while(x!=y);
    }
}
void get(int& a,int& b) {
    char c;
    scanf("%d%c",&a,&c), ++a;
    b=(c=='w');
}
void init() {
    cnt=scc=num=top=0;
    SET(h,0), SET(c,0), SET(dfn,0), SET(low,0);
}
void sol() {
    init();
    for(int i=1;i<=m;++i) {
        int x, y, xv, yv;
        get(x,xv), get(y,yv);
        addedge(x,xv,y,yv);
    }
    add(1,1+n);
    for(int i=1;i<=n*2;++i) if(!dfn[i]) tarjan(i);
    for(int i=1;i<=n;++i) if(c[i]==c[i+n]) {
        puts("bad luck");
        return;
    }
    for(int i=2;i<=n;++i) if(c[i]>c[i+n]) printf("%dw ",i-1); else printf("%dh ",i-1);
    puts("");
}
int main() { while(scanf("%d%d",&n,&m)&&n&&m) sol(); }
```



## To Be Continued
