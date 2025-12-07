---
title: 「NOIP Record」#24 数位DP急救
pubDate: 2023-11-16
tags:
  - DP
  - 数位DP
  - 计数
categories: Record
description: '少年生怕失败'
---

因为时间紧迫所以忽略所有时间复杂度的计算。

## luogu2657 [SCOI2009] windy 数

板子。

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
int a, b;
int f[20][20][2][2];
vector<int> dim;
int dfs(int i,int pre,int lim,int lead) {
	if(i<0) return 1;
	if(~f[i][pre][lim][lead]) return f[i][pre][lim][lead];
	int& res=f[i][pre][lim][lead];
	int up=lim? dim[i]:9;
	res=0;
	rep(k,0,up) {
		if(lead) {
			if(k==0) res+=dfs(i-1,0,lim&&(k==up),1);
			else res+=dfs(i-1,k,lim&&(k==up),0);
		}
		else if(abs(k-pre)>=2) res+=dfs(i-1,k,lim&&(k==up),0);
	}
	return res;
}
int calc(int x) {
	dim.clear();
	while(x) {
		dim.pb(x%10);
		x/=10;
	}
	SET(f,-1);
	int cnt=dim.size();
	return dfs(cnt-1,0,1,1);
}
signed main() {
	a=read(), b=read();
	printf("%lld\n",calc(b)-calc(a-1));
    return 0;
}
```

## luogu4317 花神的数论题

对于每个 $i$ 都算一遍，然后快速幂解决。

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
const int mod=1e7+7;
int n, m, tar, cnt[55];
int f[55][2][55];
vector<int> bit;
int fp(int a,int b) {
	int c=1;
	for(;b;a=a*a%mod,b>>=1) if(b&1) c=c*a%mod;
	return c;
}
int dfs(int i,int lim,int c) {
	if(i==0) return (c==tar);
	if(~f[i][lim][c]) return f[i][lim][c];
	int& res=f[i][lim][c];
	res=0;
	int up=lim? bit[i-1]:1;
	rep(k,0,up) res+=dfs(i-1,lim&&k==up,c+k);
	return res;
}
signed main() {
	n=read();
	int t=n;
	while(t) {
		bit.pb(t&1);
		t>>=1;
	}
	m=bit.size();
	SET(f,-1);
	rep(i,1,50) {
		tar=i;
		SET(f,-1);
		cnt[i]=dfs(m,1,0);
	}
	int ans=1;
	rep(i,1,50) (ans*=fp(i,cnt[i]))%=mod;
	printf("%lld\n",ans);
    return 0;
}
```

## luogu2602 [ZJOI2010] 数字计数

对每种数字算一遍。

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
int a, b, d;
int f[15][15][2][2];
vector<int> dim;
int dfs(int i,int c,int lim,int lead) {
	if(i<0) return c;
	if(~f[i][c][lim][lead]) return f[i][c][lim][lead];
	int& res=f[i][c][lim][lead];
	res=0;
	int up=lim? dim[i]:9;
	rep(k,0,up) {
		if(lead&&k==0) res+=dfs(i-1,c,lim&&(k==up),1);
		else res+=dfs(i-1,c+(k==d),lim&&(k==up),0);
	}
	return res;
}
int calc(int n) {
	SET(f,-1);
	int t=n;
	dim.clear();
	while(t) {
		dim.pb(t%10);
		t/=10;
	}
	int cnt=dim.size();
	return dfs(cnt-1,0,1,1);
}
signed main() {
	a=read(), b=read();
	rep(i,0,9) {
		d=i; 
		printf("%lld ",calc(b)-calc(a-1));
	}
    return 0;
}
```

## luogu4127 [AHOI2009] 同类分布

枚举各位数字之和，然后 DP 求模这个值为 $0$ 的个数。

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
int a, b, mod;
int f[20][180][180][2];
vector<int> dim;
int dfs(int i,int sum,int d,int lim) {
	if(i<0) return sum==mod&&d==0;
	if(~f[i][sum][d][lim]) return f[i][sum][d][lim];
	int& res=f[i][sum][d][lim];
	res=0;
	int up=lim? dim[i]:9;
	rep(k,0,up) {
		res+=dfs(i-1,sum+k,(10*d+k)%mod,lim&&(k==up));
	}
	return res;
}
int calc(int n) {
	dim.clear();
	int t=n;
	while(t) {
		dim.pb(t%10);
		t/=10;
	}
	int res=0;
	for(mod=1;mod<=dim.size()*9;++mod) {
		SET(f,-1);
		int cnt=dim.size();
		res+=dfs(cnt-1,0,0,1);
	}
	return res;
}
signed main() {
	a=read(), b=read();
	printf("%lld\n",calc(b)-calc(a-1));
    return 0;
}
```

## CF55D Beautiful numbers

$$
\forall i, A \bmod m_i = A \bmod \text{lcm}_{i=1}^{n} \{m_i\}
$$

所以我们状压当前数出现了哪些数字以及其对 $\text{lcm}_{i=1}^9 \{i\}=2520$ 取模的结果即可。

内存开不下，多次清空数组效率太低。

不记忆化顶了上界的情况，这样空间足够且数组得以复用。

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
const int mod=2520;
int T, a, b;
int f[19][512][2521];
vector<int> dig;
int dfs(int i,int S,int d,int lim) {
	if(i<0) {
		rep(k,0,7) if((S>>k)&1) {
			if(d%(k+2)) return 0;
		}
		return 1;
	}
	if(!lim&&~f[i][S][d]) return f[i][S][d];
	int res=0;
	int up=lim? dig[i]:9;
	rep(k,0,up) {
		if(k<=1) res+=dfs(i-1,S,(d*10+k)%mod,lim&&(k==up));
		else res+=dfs(i-1,S|(1<<(k-2)),(d*10+k)%mod,lim&&(k==up));
	}
	if(!lim) return f[i][S][d]=res;
	return res;
}
int calc(int n) {
	dig.clear();
	while(n) {
		dig.pb(n%10);
		n/=10;
	}
	int m=dig.size();
	return dfs(m-1,0,0,1);
}
void solve() {
	a=read(), b=read();
	printf("%lld\n",calc(b)-calc(a-1));
}
signed main() {
	T=read();
	SET(f,-1);
	while(T--) solve();
    return 0;
}
```

## CF1073E Segment Sum

状压存在的数字集合，然后一个记录个数一个记录和，随便转移。

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
const int U=1030, mod=998244353;
int l, r, m, popcount[U], pw[20];
int f[20][U][2][2], g[19][U][2][2];
vector<int> dig;
PII dfs(int i,int S,int lim,int lead) {
	if(i<0) return MP(popcount[S]<=m,0);
	if(~f[i][S][lim][lead]) return MP(f[i][S][lim][lead],g[i][S][lim][lead]);
	int r1=0, r2=0, up=lim? dig[i]:9;
	rep(k,0,up) {
		int T=S;
		if(!(lead&&k==0)) T=S|(1<<k);
		PII t=dfs(i-1,T,lim&&k==up,lead&&k==0);
		(r1+=t.fi)%=mod;
		(r2+=((t.fi*k%mod*pw[i]%mod+t.se)%mod)%mod)%=mod;
	}
	f[i][S][lim][lead]=r1;
	g[i][S][lim][lead]=r2;
	return MP(r1,r2);
}
int calc(int n) {
	dig.clear();
	while(n) {
		dig.pb(n%10);
		n/=10;
	}
	SET(f,-1);
	int m=dig.size();
	PII res=dfs(m-1,0,1,1);
	return res.se;
}
signed main() {
	l=read(), r=read(), m=read();
	pw[0]=1;
	rep(S,1,1023) popcount[S]=popcount[S>>1]+(S&1);
	rep(i,1,18) pw[i]=pw[i-1]*10%mod;
	printf("%lld\n",(calc(r)-calc(l-1)+mod)%mod); 
    return 0;
}
```

## luogu6669 [清华集训2016] 组合数问题

考虑 Lucas 定理。
$$
\binom{n}{m} \equiv \binom{\lfloor n/p \rfloor}{\lfloor m/p \rfloor} \binom{n \bmod p}{m \bmod p} \pmod {p}
$$
如果存在 $k \mid \binom{n}{m}$，由于 $k$ 是质数，所以后面那一坨在模 $k$ 意义下等于 $0$。

这个式子还有另一个意义，设 $t_i(n)$ 为 $k$ 进制下 $n$ 的第 $i$ 位，那么
$$
\binom{n}{m} \equiv \prod_i \binom{t_i(n)}{t_i(m)} \pmod{k}
$$
右式等于 $0$，当且仅当存在一个 $t_i(n) < t_i(m)$。

求不合法方案显然更容易，所以问题转化为求范围内有多少对 $k$ 进制数 $i,j$，满足 $i$ 的每一位都大于等于 $j$。

数位 DP 容易解决。

令 $m = \min(n,m)$，那么总方案数是
$$
\frac{(m+1)(m+2)}{2} + (n-m)(m-1)
$$
做减法即可。

注意 $n,m$ 很大，需要随时取模。

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
const int mod=1e9+7, inv2=500000004;
int T, k, n, m;
int f[70][2][2];
vector<int> dig1, dig2;
int dfs(int i,int lim1,int lim2) {
	if(i<0) return 1;
	if(~f[i][lim1][lim2]) return f[i][lim1][lim2];
	int& res=f[i][lim1][lim2];
	res=0;
	int up1=lim1? dig1[i]:k-1, up2=lim2? dig2[i]:k-1;
	rep(j1,0,up1) for(int j2=0;j2<=min(up2,j1);++j2) {
		(res+=dfs(i-1,lim1&&j1==up1,lim2&&j2==up2))%=mod;
	}
	return res;
}
int calc(int n,int m) {
	dig1.clear();
	dig2.clear();
	while(n) {
		dig1.pb(n%k);
		n/=k;
	}
	while(m) {
		dig2.pb(m%k);
		m/=k;
	}
	while(dig2.size()<dig1.size()) dig2.pb(0);
	int cnt=dig1.size();
	return dfs(cnt-1,1,1); 
}
void solve() {
	n=read(), m=read();
	m=min(n,m);
	int all=((m+1)%mod)*((m+2)%mod)%mod*inv2%mod;
	(all+=((n%mod-m%mod+mod)%mod)*((m+1)%mod)%mod)%=mod;
	SET(f,-1);
	printf("%lld\n",(all-calc(n,m)+mod)%mod);
}
signed main() {
	T=read(), k=read();
	while(T--) solve();
    return 0;
}
```

## luogu9821 [ICPC2020 Shanghai R] Sum of Log

由于 $i \text{ and } j =0$，所以 $i+j$ 的运算中就不会有进位，所以 $\lfloor \log_2(i+j)+1 \rfloor$ 就等于 $i,j$ 中最高位的 $1$ 所在的位数 $+1$。

数位 DP 可以解决。

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
const int mod=1e9+7;
int T, n, m;
int f[32][2][2][2];
vector<int> dig1, dig2;
int dfs(int i,int lim1,int lim2,int lead) {
	if(i<0) return 1;
	if(~f[i][lim1][lim2][lead]) return f[i][lim1][lim2][lead];
	int& res=f[i][lim1][lim2][lead];
	res=0;
	int up1=lim1? dig1[i]:1, up2=lim2? dig2[i]:1;
	rep(j,0,up1) rep(k,0,up2) {
		if(j&k) continue;
		int lg=1;
		if(lead&&(j||k)) lg=i+1;
		(res+=lg*dfs(i-1,lim1&&j==up1,lim2&&k==up2,lead&&j==0&&k==0)%mod)%=mod;
	}
	return res;
}
int calc(int n,int m) {
	dig1.clear();
	dig2.clear();
	while(n) dig1.pb(n&1), n>>=1;
	while(m) dig2.pb(m&1), m>>=1;
	while(dig2.size()<dig1.size()) dig2.pb(0);
	while(dig1.size()<dig2.size()) dig1.pb(0);
	SET(f,-1);
	int cnt=dig1.size();
	return (dfs(cnt-1,1,1,1)-1+mod)%mod;
}
void solve() {
	n=read(), m=read();
	printf("%lld\n",calc(n,m));
}
signed main() {
	T=read();
	while(T--) solve();
    return 0;
}
```

