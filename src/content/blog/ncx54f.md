---
title: NowCoderX54F 题解
tags:
  - 图论
  - 构造
categories:
  - 题解
description: 'Solution'
pubDate: 2022-08-14
---

## 分析

先给一组官方题解的数据。



```cpp
10 10
10 19 18 17 16 15 14 13 12 10
```

先考虑特殊情况，对于每个 $i$，要求从 $1$ 到 $i$ 再到 $n$ 的最短路长度为 $d_i$。那么当 $i=1$ 或者 $i=n$ 时，都相当于 $1$ 到 $n$ 的最短路。于是 $d_1$ 必须等于 $d_n$，且二者必须为 $\min_{i=1}^n{\{ d_i\}}$，否则一定无解。

于是乎我们就能搞出第一条边。

![](https://s2.loli.net/2022/08/14/DXKlfk1MjiPTYOa.png)

从 $1$ 到 $i$ 再到 $n$，一种做法是将 $i$ 作为一个中转点，单纯地 $1 \rightarrow i \rightarrow n$，另一种做法是 $1 \rightarrow i \rightarrow 1 \rightarrow n$。后者的好处就是，$(1 \rightarrow i)$ 走了两遍，如果 $d_i - d_1$ 是个偶数，那么这就很好构造了。直接连接 $(1,i)$，权值为 $\frac{d_i-d_1}{2}$。

形成一个大菊花。

![](https://s2.loli.net/2022/08/14/G9xnosaItbSVvk6.png)

那么剩下的只有 $2 \nmid d_i - d_1$ 的情况了，我们可以尝试上述第一种做法，把 $i$ 作为一个中转点，连边 $(1,i)$，$(i,n)$。这时候突然发现，如果 $(1,i)$ 的权值 $\Delta$ 为奇数，剩下的点 $j$ 一定有 $2 \mid d_j - d_1 - \Delta$，于是就能将剩下的点连到 $i$ 上，再用上面的方法了。为了防止负权，这个 $i$ 一定满足 $d_i - d_1$ 最小。

![](https://s2.loli.net/2022/08/14/wOqJLPbCK8ym6tS.png)

那么如何取值最优呢？首先从 $1$ 经过 $i$ 的道路不止一条，就比如图中还有 $1 \rightarrow 8 \rightarrow 1 \rightarrow 10$，$1 \rightarrow 10 \rightarrow 8 \rightarrow 10$。如果 $1 \rightarrow 8 \rightarrow 10$ 不是最优的话，那么这个方法就死掉了。

可是构造题只关注可行性，所以要想办法让 $1 \rightarrow i \rightarrow n$ 最优。注意到其他两种方法，本质上就是走了一遍 $d_1$，走了两遍 $1 \rightarrow i$ 或者 $i \rightarrow n$。

由于 $d_i$ 是个大于等于 $d_1$ 且与 $d_1$ 奇偶性不同的数，所以 $d_i > d_1$，当边权取 $\lfloor \frac{d_i}{2} \rfloor$ 和 $\lfloor \frac{d_i}{2} \rfloor + 1$ 时，走两遍后，最短也是 $d_i - 1$。因此，这种情况下，只要满足 $d_1 + d_i -1 \ge d_i$，就能保证 $1 \rightarrow i \rightarrow n$ 的走法是最优的。上式解得 $d_1 \ge 1$。

![](https://s2.loli.net/2022/08/14/a9Lpl61cZOmbVnK.png)

如果 $d_1 = 0$ 且存在满足 $2 \nmid d_i - d_1$ 的 $i$，这种构造思路就失效了。

设满足 $2 \nmid d_i - i$ 的点为奇点 $odd$，其余为偶点 $even$，这样使用的边数为 $1+even + (1 + odd) = n$，如果不存在奇点，那么就是 $1+even$。

剩下的边权用 $10^9$ 即可，因为这样不会影响到最短路。

## CODE

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
const int N=3e5+5;
int n, m, mn=1e9+7, d[N];
vector<int> odd, even;
set<pair<int,int> > s;
// 用set判断是否存在
bool cmp(int x,int y) { return d[x]<d[y]; }
void add(int x,int y,int z) {
    if(x>y) swap(x,y);
    printf("%lld %lld %lld\n",x,y,z);
    s.insert({x,y});
}
signed main() {
    n=read(), m=read();
    for(int i=1;i<=n;++i) {
        mn=min(d[i]=read(),mn);
        if(i>1&&i<n) {
            if((d[i]-d[1])&1) odd.push_back(i);
            else even.push_back(i);
        }
    }
    int nd=1+even.size();
    if(odd.size()) nd+=odd.size()+1;
    if(m>n*(n-1)/2||nd>m||d[1]!=d[n]||d[1]!=mn||d[n]!=mn||(!mn&&odd.size()))
    // 如果m超过了完全图的边数，显然也无解
        { puts("No"); return 0; }
    puts("Yes");
    add(1,n,d[1]);
    for(auto x:even) add(1,x,(d[x]-d[1])/2);
    if(odd.size()) {
        sort(odd.begin(),odd.end(),cmp);
        int a=odd[0];
        add(1,a,d[a]/2+d[a]%2);
        add(a,n,d[a]/2);
        for(int i=1;i<odd.size();++i) {
            int b=odd[i];
            add(a,b,(d[b]-d[a])/2);
        }
    }
    m-=nd;
    for(int i=1;i<=n&&m;++i) for(int j=1;j<i;++j) {
        if(s.count({j,i})) continue;
        // 注意是{j,i}
        add(j,i,1e9);
        if(--m==0) goto end;
    }
    end:;
}
```
