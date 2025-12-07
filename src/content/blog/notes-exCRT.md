---
title: 「数论学习笔记」#1 扩展中国剩余定理
tags:
  - 数论
  - 中国剩余定理
  - 扩展中国剩余定理
categories: 学习笔记
pubDate: 2022-07-29
---

## 中国剩余定理（CRT）

由于扩展中国剩余定理和中国剩余定理没啥关系，所以我们先来复习一下中国剩余定理。



同余方程组
$$
\begin{cases}
x \equiv a_1 \pmod {m_1}
\\
x \equiv a_2 \pmod {m_2}
\\
\quad \vdots
\\
x \equiv a_n \pmod {m_n}
\end{cases}
$$
当 $m_1,m_2,\cdots ,m_n$ 两两互质时，对于任意正整数 $a_1,a_2,\cdots,a_n$，此方程组有解，如下。

设 $M = \prod_{i=1}^n m_i$，$M_i = \frac{M_i}{m_i}$。

设 $t_i = M_i^{-1}$，在 $\bmod m_i$ 的意义下。

那么方程组的通解为 $x = kM + \sum_{i=1}^n a_i t_i M_i$，其中 $k \in \mathbb{Z}$。

 最小正整数解只要令 $k=0$，后面那一块对 $M$ 取模即可。

代码

```cpp
MM=1;
for(int i=1;i<=n;++i) MM*=m[i];
for(int i=1;i<=n;++i) {
    M[i]=MM/m[i];
    int x, y;
    exgcd(M[i],m[i],x,y);
    t[i]=x;
    ans=(ans+a[i]*M[i]*t[i]%MM)%MM
}
ans=(ans%MM+MM)%MM;
```

证明略。

## 扩展中国剩余定理（exCRT）

当 $m_1,m_2,\cdots m_n$ 不满足两两互质时，就要用到扩展中国剩余定理了。

考虑
$$
\begin{cases}
x \equiv a_1 \pmod {m_1}
\\
x \equiv a_2 \pmod {m_2}
\end{cases}
$$
转化一下
$$
\begin{cases}
x = k_1 m_1 + a_1
\\
x = k_2 m_2 + a_2
\end{cases}
$$

$$
k_1 m_1 - k_2 m_2 = a_1 - a_2
$$

注意到此方程有解，当且仅当 $\gcd(m_1,m_2) \mid a_1-a_2$。

设 $g=\gcd(m_1,m_2)$，$p_1 = \frac{m_1}{g}$，$p_2 = \frac{m_2}{g}$，代入得
$$
k_1 p_1 - k_2 p_2 = \frac{a_1-a_2}{g}
$$
由于 $\gcd(p_1,p_2)=1$，此方程有解当且仅当 $1 \mid \frac{a_1 - a_2}{g}$。那么一定有 $g \mid a_1 - a_2$，否则无解。

那么先求出一组特解
$$
p_1 x_1  + p_2 x_2  = 1
$$
得到
$$
\begin{cases}
k_1 = \frac{a_2-a_1}{g} x_1
\\
k_2 = \frac{a_2-a_1}{g} x_2
\end{cases}
$$
代入原式
$$
x = k_1 m_1 + a_1 = \frac{a_2 - a_1}{g}x_1 m_1 + a_1
$$
至此，得到一个解。

不妨称同余号右边的数为“同余数”。

考虑数论里一个结论，若 $a \equiv b \pmod {m_i}$，其中 $i \in [1,n]$，则
$$
a \equiv b \pmod {\operatorname{lcm}\{m_1,m_2,\cdots ,m_n\}}
$$
因此，求出两个方程的解时，只要模数取原来两个模数的最小公倍数，就能将原来两个方程合并成一个方程。

且慢，不是还要求同余数相等吗？令他为 $xm_1 + a_1$ 即可，~~虽然我也不知道为什么~~。

设当前同余数为 $R$，$M$ 为 $m_1,m_2,\cdots,m_{i-1}$ 的最小公倍数，则对于一个新的方程组
$$
\begin{cases}
x \equiv R  \pmod M
\\
x \equiv a_i \pmod {m_i}
\end{cases}
$$
再次求解即可。

代码

```cpp
void exCRT() {
    M=m[1], R=r[1];
    // m[]是模数，r[]是同余数
    for(int i=2;i<=n;++i) {
        int d=r[i]-R, g, mod, x, y;
        g=exgcd(M,m[i],x,y);
        // 这里求解的是 Mx+m[i]y=gcd(M,m[i])
        // 根据等式的性质，易得等价于上文中的 p1x1+p2x2=1
        if(d%g) { ans=-1; return; }
        // 无解
        mod=m[i]/g;
        // 取模是因为要求最小正整数解，mod为什么这样算详见exgcd
        x=((x*d/g)%mod+mod)%mod;
        // 解
        R=x*M+R;
        // 更新R
        M=(M*m[i])/g;
        // M取lcm
    }
    ans=R;
    // 答案
}
```



&nbsp;

参考：

- [OI Wiki 中国剩余定理](https://oi-wiki.org/math/number-theory/crt/)
- [学习笔记 - 扩展中国剩余定理](https://luckyglass.github.io/2019/OldVer5/)
- [『学习笔记』中国剩余定理](https://xixike.github.io/%E3%80%8E%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0%E3%80%8F%E4%B8%AD%E5%9B%BD%E5%89%A9%E4%BD%99%E5%AE%9A%E7%90%86/)
