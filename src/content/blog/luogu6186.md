---
title: luogu6186 冒泡排序 题解
tags: 树状数组
categories:
  - 题解
pubDate: 2022-05-01
description: 'Solution'
---

## 分析

手算一下不难发现，一轮冒泡排序会让所有逆序对个数大于 1 的位置减少 1 个逆序对，逆序对为 0 的则不受影响。

设 $f_i$ 表示位置 $i$ 的逆序对数，那么经过 $k$ 轮冒泡排序后，逆序对的个数为

$$
\sum_{ i=1 \text{ and } f_i > k}^n f_i - k \cdot \sum_{i \in [1,n]} [f_i > k]
$$



树状数组维护之，具体见代码。交换的操作分类讨论就行了。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long
const int N=2e5+5;
int n, m, a[N];
ll sum, f[N];
struct BIT {
    ll c[N];
    void reset() { memset(c,0,sizeof(c)); }
    void modify(ll x,ll y) {
        if(!x) return;
        // 放置下标为0
        for(;x<=n;x+=x&-x) c[x]+=y;
    }
    ll query(ll x) {
        ll y=0;
        for(;x;x-=x&-x) y+=c[x];
        return y;
    }
} t1, t2;
void pre() {
    for(int i=1;i<=n;++i) {
        t1.modify(a[i],1);
        f[i]=t1.query(n)-t1.query(a[i]);
//        printf("%lld\n",f[i]);
        t2.modify(f[i],f[i]);

    }
    // 先利用t1求出原本的逆序对，再维护f[i]的权值数列
    // t2维护t1对应的和
    t1.reset();
    for(int i=1;i<=n;++i) t1.modify(f[i],1);
}
int main() {
    scanf("%d%d",&n,&m);
    for(int i=1;i<=n;++i) scanf("%d",&a[i]);

    pre();
    while(m--) {
        int op, x; scanf("%d%d",&op,&x);
        if(op&1) {
            t1.modify(f[x],-1), t1.modify(f[x+1],-1);
            t2.modify(f[x],-f[x]), t2.modify(f[x+1],-f[x+1]);
            // 把交换的这两个数先从树状数组中删了
            if(a[x]>a[x+1]) --f[x+1]; else if(a[x]<a[x+1]) ++f[x];
            // a[x]>a[x+1]，交换后x+1这个位置的逆序会减少1
            // 反之，x这个位置逆序对会增加1。
            swap(f[x],f[x+1]), swap(a[x],a[x+1]);
            // 交换他们的值
            t1.modify(f[x],1), t1.modify(f[x+1],1);
            t2.modify(f[x],f[x]), t2.modify(f[x+1],f[x+1]);
            // 重新插入回去
        } else {
            if(x>=n) { puts("0"); continue; }
            int cnt=t1.query(n)-t1.query(x);
            printf("%lld\n",t2.query(n)-t2.query(x)-1ll*cnt*x);
            // 注意1ll*cnt
        }
    }
} 
```
