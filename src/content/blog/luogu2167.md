---
title: luogu2167 [SDOI2009] Bill的挑战 题解
pubDate: 2023-07-16
tags:
  - DP
  - 状态压缩
  - 搜索
  - 计数
  - 二项式反演
categories:
  - 题解
description: 'Solution'
---

## 状压DP做法

字符串长度不大，考虑刻画 $T$ 的每一位。

设 $f(i,S)$ 表示考虑了 $T$ 的前 $i$ 位，匹配了 $S$ 内的字符串的方案数。

枚举下一位的字符，然后把能匹配上的字符集合设为 $S_0$，这样就能转移到 $f(i+1,S \cap S_0)$。

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
const int N=20, mod=1000003;
int T, n, m, k, U, f[1<<15][55], v[30];
char s[N][55];
int ctz(int x) {
    int cnt=0;
    while(x) cnt+=x&1, x>>=1;
    return cnt; 
}
void solve() {
    n=read(), k=read();
    U=(1<<n)-1;
    rep(i,0,n-1) scanf("%s",s[i]);
    m=strlen(s[0]);
    if(n<k) {
        puts("0");
        return;
    }
    SET(f,0);
    f[0][0]=f[U][0]=1;
    for(int i=0;i<m;++i) for(int S=U;S;--S) if(f[S][i]) {
        for(int j=0;j<26;++j) {
            int S0=0;
            for(int k=0;k<n;++k) if(s[k][i]=='?'||s[k][i]-'a'==j) S0|=(1<<k);
            (f[S&S0][i+1]+=f[S][i])%=mod;
        }
    }
    int ans=0;
    for(int S=0;S<=U;++S) if(ctz(S)==k) (ans+=f[S][m])%=mod;
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    while(T--) solve();
}
```

## 容斥做法

考虑二项式反演。设 $f(k)$ 为至少匹配了 $k$ 个串的方案数，$g(k)$ 为恰好匹配了 $k$ 个串的方案数，那么

$$
g(k)=\sum_{i=k}^n \binom{i}{k} (-1)^{i-k} f(i)
$$



对于 $f(i)$，我们只需要搜索出任意  $i$ 个字符串的并，然后乘上 $26^{m-i}$ 即可。

其中 $m$ 是字符串长度。

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
const int N=20, mod=1000003;
int T, n, m, k, U, f[N], pw[55], C[N][N];
int cup, id[55];
char s[N][55], Ts[55];
void dfs(int x,int cnt) {
    if(n-x+1+cnt<k) return;
    if(x>n) {
        (f[cnt]+=pw[m-cup])%=mod;
        return;
    }
    dfs(x+1,cnt);
    for(int i=1;i<=m;++i) {
        if(Ts[i]&&s[x][i]!='?'&&Ts[i]!=s[x][i]) return;
        // 有冲突，不能并
    }
    int cc=cup;
    for(int i=1;i<=m;++i) if(!Ts[i]&&s[x][i]!='?') Ts[i]=s[x][i], id[++cup]=i;
    dfs(x+1,cnt+1);
    while(cup>cc) Ts[id[cup--]]=0;
    // 撤销求并操作
}
void solve() {
    n=read(), k=read();
    U=(1<<n)-1;
    rep(i,1,n) scanf("%s",s[i]+1), f[i]=f[i+1]=0; 
    m=strlen(s[1]+1);
    if(n<k) {
        puts("0");
        return;
    }
    dfs(1,0);
    int ans=0;
    for(int i=k;i<=n;++i) {
        if((i-k)&1) (ans-=C[i][k]*f[i]%mod-mod)%=mod;
        else (ans+=C[i][k]*f[i]%mod)%=mod;
    }
    printf("%lld\n",ans);
}
signed main() {
    T=read();
    pw[0]=1;
    rep(i,1,50) pw[i]=pw[i-1]*26%mod;
    C[0][0]=1;
    rep(i,1,15) {
        C[i][0]=C[i][i]=1;
        rep(j,1,i-1) C[i][j]=(C[i-1][j]+C[i-1][j-1])%mod;
    }
    while(T--) solve();
}
```
