---
title: luogu4774 屠龙勇士 题解
tags:
  - 数论
  - 扩展中国剩余定理
categories: 题解
description: 'Solution'
pubDate: 2022-08-09
---

## 分析

首先预处理出杀死每条龙时要使用哪一把剑，设杀死第 $i$ 条龙用的剑的攻击力为 $atk_i$。

那么问题转化为求解

$$
\left\{\begin{array}{l}atk_1 \cdot x &\equiv a_1 \pmod{p_1}\\atk_2 \cdot x &\equiv a_2 \pmod{p_2}\\&\vdots\\atk_n \cdot x &\equiv a_n \pmod{p_2}\end{array}\right.
$$



由于 $p_i$ 不一定两两互质，所以如果没有 $atk_i$ 的话，就可以直接上 exCRT。这里需要多预处理几步。

数论中有一个结论：如果

$$
ax \equiv ay \pmod p
$$



那么

$$
x \equiv y \pmod{\frac{p}{\gcd(a,p)}}
$$



其实这里的能这么做是因为 $\gcd(a,a)=a$，所以我们只要求出 $d_i = \gcd(atk_i,a_i)$，就能化成

$$
\frac{atk_i}{d_i} x \equiv \frac{a_i}{d_i} \pmod {\frac{p_i}{\gcd(d_i,p_i)}}
$$



由于此时 $\frac{atk_i}{d_i}$ 与 $\frac{p_i}{\gcd(d_i,p_i)}$ 必然互质，所以一定存在模 $\frac{p_i}{\gcd(d_i,p_i)}$ 意义下 $\frac{atk_i}{d_i}$ 的逆元。于是乎再次转化

$$
x \equiv \frac{a_i}{atk_i} \pmod{\frac{p_i}{\gcd(d_i,p_i)}}
$$



这样就能用 exCRT 求解了。

注意到数据范围中有不少点都满足 $p_i =1$，而模 $1$ 的情况十分简单，那么就可以特判一下。

不同推式子，直接考虑实际意义。当巨龙的生命为负时，它就会一直回复一滴血直到血量为 $0$，然后去世。也就是说，只要 $atk_i \cdot x \ge a_i$ 就行，所以答案就是 $x = \lceil \frac{a_i}{atk_i} \rceil$ 取个最大值。

注意为了防止乘法溢出，要用光速乘。

## CODE

```cpp
#include<bits/stdc++.h>
using namespace std;
#define int long long
#define uint unsigned long long
const int N=1e5+5;
int T, n, m, fg, a[N], p[N], sw[N], rec[N], atk[N];
int M, R, ans, t[N];
multiset<int> st;
int read() {
    int a=0, f=1; char c=getchar();
    while(!isdigit(c)) {
        if(c=='-') f=-1;
        c=getchar();
    }
    while(isdigit(c)) a=a*10+c-'0', c=getchar();
    return a*f;
}
int gcd(int x,int y) { return y? gcd(y,x%y):x; }
int exgcd(int a,int b,int& x,int& y) {
    if(!b) { x=1, y=0; return a; }
    int d=exgcd(b,a%b,y,x);
    y-=a/b*x;
    return d;
}
int inv(int a,int mod) {
    int x, y;
    exgcd(a,mod,x,y);
    return (x+mod)%mod;
    // 返回a在模mod意义下的逆元
}
int cil(int x,int y) { return (x+y-1)/y; }
// 向上取整函数
int mul(int x,int y,int p) {
    int z=(long double)x/p*y;
    int res=(uint)x*y-(uint)z*p;
    return (res+p)%p;
    // 非常玄学的O(1)光速乘
}
void exCRT() {
    R=t[1], M=p[1];
    for(int i=2;i<=n;++i) {
        int d=t[i]-R, g, mod, x, y;
        g=exgcd(M,p[i],x,y);
        if(d%g) { ans=-1; return; }
        mod=p[i]/g;
        x=(mul(x,d/g,mod))%mod;
        int P=M/g*p[i];
        R=(mul(x,M,P)+R)%P; 
        M=M/g*p[i]; 
    }
    ans=R;
    // 板子
}

void solve() {
    st.clear();
    fg=ans=0;
    n=read(), m=read();
    for(int i=1;i<=n;++i) a[i]=read();
    for(int i=1;i<=n;++i) fg+=(p[i]=read())==1;
    for(int i=1;i<=n;++i) rec[i]=read();
    for(int i=1;i<=m;++i) sw[i]=read(), st.insert(sw[i]);
    for(int i=1;i<=n;++i) {
        auto p=st.upper_bound(a[i]);
        if(p!=st.begin()) --p;
        atk[i]=*p;
        st.erase(p), st.insert(rec[i]);
    }
    if(fg==n) {
        for(int i=1;i<=n;++i) ans=max(ans,cil(a[i],atk[i]));
        printf("%lld\n",ans);
        return;
    }
    for(int i=1;i<=n;++i) {
        int _d=gcd(atk[i],p[i]), d=gcd(_d,a[i]);
        atk[i]/=_d, a[i]/=_d, p[i]/=d;
        t[i]=mul(a[i],inv(atk[i],p[i]),p[i]);
    }
    exCRT();
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
}
```
