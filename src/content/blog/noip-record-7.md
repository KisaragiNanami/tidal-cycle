---
title: 「NOIP Record」#7 计数杂题 (2)
pubDate: 2023-06-21
tags:
  - DP
  - 计数
  - 组合数学
  - 二项式反演
categories:
  - Record
description: '少年不得不审视自己'
---

专门放一些不大可能会考的计数题，长期更新。

大约是输入的只有问题规模，输出的只有相应方案数。

## luogu6561 [SBCOI2020] 人

两两不相邻这个条件不是很容易搞。

考虑把 $[1,2m]$ 分成 $m$ 个数对，形如 $(\text{odd},\text{even})$，其中 $\text{odd} +1 =\text{even} $

把选择了 $\text{odd}$ 的数对称为`A`，选择了 $\text{even}$ 的数对称为`B`，没有选择的称为`C`。那么问题等价于有多少个只有`A`，`B`，`C`的字符串，满足有 $a$ 个`A`，$b$ 个`B`和 $m-a-b$ 个`C`，且不存在子串`BA`。

由于`B`与`C`没有限制，所以可以任意安排，只要在 $m-a$ 个里面钦定 $b$ 个`B`即可，方案 $\binom{m-a}{b}$。

接着要插入`A`，除了在 $b$ 个`B`后面，其他位置均可，方案 $\binom{m-b}{a}$。

因此答案为
$$
\binom{m-a}{b} \binom{m-b}{a}
$$
其实映射到不允许子串`BA`这一步，就没有什么难的了。

而如果没有做到映射这一步，那么推理相当痛苦啊。



## luogu8594 「KDOI-02」一个仇的复

能用到的只有 $1 \times x$ 与 $2 \times 1$ 的矩形。

先不关心后者，考虑只用前者的方案数。设一共用 $k$ 个举行铺满 $2 \times m$ 的网格。

枚举使用个数，如果第一行用了 $i$ 个，那么第二行就要用 $k-i$ 个，每一行内部都是一个经典问题
$$
\sum_{i=1}^{k-1} \binom{m-1}{i-1} \binom{m-1}{k-i-1} = \sum_{i=0}^{k-2} \binom{m-1}{i}\binom{m-1}{k-i-2}
$$
根据范德蒙德卷积可以知道这个就是
$$
\binom{2m-2}{k-2}
$$
然后就是用若干 $2 \times 1$ 的矩形把原问题分割成若干上述问题。

枚举把 $2 \times n$ 的网格分成 $i$ 段，使用了 $j$ 个 $2 \times 1$ 的矩形

划分方式就是某问题，方案数
$$
\binom{j+1}{i}
$$
还有 $n-j$ 个位置分给 $i$ 段
$$
\binom{n-j-1}{i-1}
$$
最后是把 $k-j$ 个矩形填满 $i$ 段，设第 $l$ 段大小为 $2 \times a_l$，用 $b_l$ 个矩形
$$
\sum_{\sum_{l=1}^i b_l = k-j} \prod_{p=1}^i \binom{2a_p -2}{b_p - 2}
$$
发现是一个扩展后的范德蒙德卷积，根据组合意义得到上式即为
$$
\binom{2\sum_{p=1}^i a_p - 2i}{\sum_{p=1}^i b_p - 2i} = \binom{2(n-j)-2i}{k-j-2i}
$$
因此答案为
$$
\sum_{i=1}^k \sum_j^{r} \binom{j+1}{i}\binom{n-j-1}{i-1}\binom{2(n-j)-2i}{k-j-2i}
$$


直接枚举 $i,j$ 显然不能接受，注意到如果 $k-j-2i<0$，那么没有贡献，再综合一下其他的边界，对于每个 $i$ 都能找到一个上界 $r$，满足 $r<k$。所以复杂度为 $O(n+k^2)$

## ABC242F Black and White Rooks

看起来像是某经典问题的扩展（？

不是很容易直接做。

考虑每一种合法方案必然使得黑车与白车所占用的行与列无交，所以答案可以表示为
$$
\sum_{i=1}^n \sum_{j=1}^{n-i}\sum_{k=1}^m\sum_{l=1}^{m-k} \binom{n}{i}\binom{n-i}{j}\binom{m}{k}\binom{m-k}{l} f_B(i,k)f_W(j,l)
$$
一开始的思路被局限到两重循环的枚举上了。

其中 $f_k(i,j)$ 表示用 $k$ 个车恰好放满 $i$ 行与 $j$ 列的方案数。

考虑如何求出。

$\texttt{solution 1}$

显然可以容斥。

存在至少 $i$ 行 $j$ 列上没有车的方案数显然是
$$
\binom{n}{i}\binom{m}{j}\binom{(n-i)(m-j)}{k}
$$
带上一个 $(-1)^{i+j}$ 的系数。

$\texttt{solution 2}$

也可以换一种思路。
$$
f_k(n,m) = \binom{nm}{k} - \sum_{i=1}^n\sum_{j=1 \texttt{ and } (i,j) \neq (n,m)}^m \binom{n}{i}\binom{m}{j}f_k(i,j)
$$

- 容斥这个东西，尽量不要考虑在整体思路建立起来之前。
- 计数题，不要那么吝惜复杂度。毕竟有很多优化方法。适当地放宽计数的限制。
- 不要不经过思考就往自己知道的模型上靠。必须改掉这个习惯。

## CF1342E Placing Rooks

同样是关于车的。

每个点都在车的攻击范围内，说明要么每一行都有车，要么每一列都有车。当 $k \neq 0$ 时二者不能同时存在。

可以钦定每一行都有车，求出的方案数的 $2$ 倍即为答案。

设 $f_i$ 为恰好放 $i$ 个攻击型车的方案数，$g_i$ 为至少。

不难发现只要钦定所有车都在 $n-i$ 列即可。
$$
g_i = \binom{n}{n-i}(n-i)^n
$$

$$
g_k = \sum_{i=k}^n \binom{i}{k} f_i
$$

$$
f_k = \sum_{i=k}^n (-1)^{i-k} \binom{i}{k} g_i
$$

## CF1794D Counting Factorizations

考虑这样一个事实：如果确定了 $n$ 个质因数，那么方案数就是剩下 $n$ 个指数做多重集全排列。

由于每个质因数只能出现一次，所以设 $P$ 为 $A$ 中的不同质数集合，$|P|=m$。问题转化为求在 $P$ 中选择 $n$ 个数相对应的多重集全排列之和。

若 $m<n$，那么无解，因为必须满足有 $n$ 个质因数。

若 $m=n$，那么答案就是

$$
\frac{(2n-m)!}{\prod_{i=1}^{2n} (cnt_{A_i}!)}
$$

其中 $cnt_{A_i}$ 表示 $A_i$ 在 $A-P$ 中出现的次数。

若 $m>n$，那么就是要把 $m-n$ 个数放到指数集合中，由于放哪些数会影响全排列的值，所以考虑用 DP 求所有合法的全排列的和。

设 $f_{i,j}$ 表示考虑前 $i$ 个数，已经选了 $j$ 个，$f_{0,0}$ 就是上面那个式子。

如果不选，直接继承 $f_{i-1,j}$。如果选，就会让指数集合增大 $1$，且 $P_i$ 相应的集合增大 $1$，因此


$$
f_{i,j} = f_{i-1,j} + [j>0] \Big(f_{i-1,j-1} \cdot \frac{2n-m+j}{cnt_{P_i}+1} \Big)
$$

答案 $f_{m,m-n}$。

貌似可以多项式优化。


```cpp
#include<bits/stdc++.h>
using namespace std;
#define SET(a,b) memset(a,b,sizeof(a))
#define CPY(a,b) memcpy(a,b,sizeof(a))
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
const int N=4050, M=1e6+5, mod=998244353;
int n, m, facn, nn, D, a[N], p[N], cnt[M], f[N][N/2];
int tot, pr[M];
bool v[M], mp[M], mpp[M];
int fac[N], inv[N];
int fp(int a,int b) {
	int c=1;
	for(;b;a=1ll*a*a%mod,b>>=1) if(b&1) c=1ll*c*a%mod;
	return c;
}
void init() {
	for(int i=2;i<=1e6;++i) {
		if(!v[i]) pr[++tot]=i;
		for(int j=1;j<=tot&&i*pr[j]<=1e6;++j) {
			v[i*pr[j]]=1;
			if(i%pr[j]==0) break;
		}
	}
	fac[0]=inv[0]=1;
	for(int i=1;i<=2*n;++i) fac[i]=1ll*fac[i-1]*i%mod;
	inv[2*n]=fp(fac[2*n],mod-2);
	for(int i=2*n-1;i;--i) inv[i]=1ll*inv[i+1]*(i+1)%mod; 
}
int rev(int x) { return fac[x-1]*inv[x]%mod; }
signed main() {
	n=read();
	for(int i=1;i<=2*n;++i) a[i]=read(), ++cnt[a[i]];
	init();
	D=1;
	for(int i=1;i<=2*n;++i) {
		if(a[i]!=1&&!v[a[i]]&&!mp[a[i]]) mp[a[i]]=1, --cnt[a[i]], p[++m]=a[i];
		if(cnt[a[i]]&&!mpp[a[i]]) mpp[a[i]]=1, D=1ll*D*inv[cnt[a[i]]]%mod;
	}
	nn=2*n-m, facn=fac[nn];
	if(m<n) { puts("0"); exit(0); }
	if(m==n) {
		printf("%lld\n",1ll*facn*D%mod);
		exit(0);
	}
	f[0][0]=1ll*facn*D%mod;
	for(int i=1;i<=m;++i) for(int j=0;j<=m-n&&j<=i;++j) {
		if(!j) f[i][j]=f[i-1][j];
		else f[i][j]=(1ll*f[i-1][j-1]*(nn+j)%mod*rev(cnt[p[i]]+1)%mod+f[i-1][j])%mod;
	}
	printf("%d\n",f[m][m-n]);
}
```

## CF1806D DSU Master

注意题目中的「排列」是 $\{a_i\}$ 的排列，而 $\{a_i\}$ 是决定 $i$ 与 $i+1$ 所在弱连通分量的连边情况的。

容易知道如果从 $1$ 连出去了任意一条边，后续的操作便不会产生贡献了。考虑到这是一个临界情况，递推之。

设 $f_i$ 为考虑操作序列 $[1,i]$ 的排列，最终 $1$ 仍然没有出边的方案数。

若 $a_i=0$，那么在 $f_{i-1}$ 中一定是从 $i+1$ 连向 $1$，随便放即可。

否则 $1$ 一定不能是 $i$ 所在弱连通分量的无出边点，考虑在 $f_{i-1}$ 中，若 $a_1$ 在最后面，那么只要放到除了 $a_1$ 后面的 $i-1$ 个位置即可。

否则设 $a_1$ 的位置是 $p$，在这之前的所有位置可以任选。考虑操作排列 $[p,i-1]$ 内一定不存在从 $1$ 所在弱连通分量 $G'$ 连出去的边，因此要么是连入 $G'$ 的边，要么是相对孤立的两个点连边，此时证明 $i-1 \notin G'$。

>假设如此，那么如果 $i-1$ 连入了 $G'$，那么一定有 $i-2 \in G'$ 中，进而 $i-3 \in G'$。由此递归下去得到此时必须连完了所有边，与 $p \neq i-1$ 矛盾。

由于 $i-1 \notin G'$，所以 $a_i$ 不影响 $1$，仅仅不能放在最后一个位置，方案仍然是 $i-1$。

于是

$$
f_i=
\begin{cases}
f_{i-1} \cdot i & a_i = 0
\\
f_{i-1} \cdot (i-1) & a_i =1\end{cases}
$$

考虑统计答案，设 $ans_i$ 为 $[1,i]$ 的贡献。考虑 $ans_{i-1} \rightarrow ans_i$，首先把 $a_i$ 扔到里面任何位置不会改变原有的贡献。其次如果 $a_i = 0$，那么有 $f_{i-1}$ 种方法使得 $ans_{i-1}$ 贡献 $f_{i-1}$ 个 $1$ 出去；而当 $a_i = 1$ 时，无论如何都无法使得 $1$ 的入边增加。

$$
ans_i = ans_{i-1} \cdot i + (1-a_i) \cdot f_{i-1}
$$
