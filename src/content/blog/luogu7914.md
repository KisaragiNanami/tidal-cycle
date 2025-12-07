---
title: luogu7914 括号序列 题解
tags:
  - DP
  - 区间DP
  - 计数
categories: 题解
description: 'Solution'
pubDate: 2022-04-13
---



## Solution

为了防止与下标混淆，这里用 $m$ 表示题目中的 $k$。

设 $f(i,j)$ 为考虑区间 $[i,j]$ 内的字符，确定合法串的方案数，$q(i,j)$ 为 $[i,j]$ 能否变成不超过 $k$ 个`*`组成的串。



显然合法串的左右端点必须分别是左括号与右括号，所以以下转移都是在满足 $i$ 能够成为左括号，$j$ 能够成为右括号的前提下。

除了两个串合并，其他几种情况都是比较平凡的。

1. `()`
   
   $$
   f(i,j) = 1
   $$

2. `(S)`
   
   $$
   q(i+1,j-1) \rightarrow f(i,j)
   $$

3. `(A)`
   
   $$
   f(i+1,j-1) \rightarrow f(i,j)
   $$

4. `(SA)`
   枚举`S`最后一个字符的位置 $k$。
   
   $$
   q(i+1,k) \times f(k+1,j-1) \rightarrow f(i,j)
   $$

5. `(AS)`
   与上一种情况类似，枚举`A`最后一个字符的位置 $k$，可以与上一步一起转移。
   
   $$
   f(i+1,k) \times q(k+1,j-1) \rightarrow f(i,j)
   $$

6. `AB`
   为了避免重复，我们只考虑加入最后一个不是通过合并得到的合法串，所以记录 $g(i,j)$ 为只用上面那些方式确定合法串的方案数。套路性地枚举断点即可。
   
   $$
   \sum_{k=i+1}^{j-2} f(i,k) \times g(k+1,j) \rightarrow f(i,j)
   $$

7. `ASB`
   直接做的话就是枚举`S`的左右端点，然后`B`还是要用 $g$ 来转移。但是这样的复杂度过高，考虑优化。
   能发现当`A`确定时，`S`是有一个明显的取值区间的，并且右端点单调不降，所以可以枚举`A`的末尾字符位置 $k$，找到一个 $pos$，满足 $[k+1,pos-1]$ 可以作为`S`并且极长，此时`B`的方案数就是一个后缀和，预处理即可。
   
   $$
   \Bigg( \sum_{k=i}^{j-2} f(i,k) \times  \Big( \sum_{l=k+2}^{pos}  g(l,j) \Big) \Bigg) \rightarrow f(i,j)
   $$
   
   
   
   

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
const int N=505, mod=1e9+7;
int n, m, f[N][N], g[N][N], valid[N][N];
int suf[N];
char s[N];
bool check(int i,int j) {
    return (s[i]=='('||s[i]=='?')&&(s[j]==')'||s[j]=='?');
}
signed main() {
    n=read(), m=read();
    scanf("%s",s+1);
    rep(l,1,n) rep(r,l,n) {
        if(r-l+1>m) break;
        if(s[r]!='*'&&s[r]!='?') break;
        valid[l][r]=1;
    }
    rep(l,2,n) for(int i=1;i+l-1<=n;++i) {
        int j=i+l-1;
        if(check(i,j)) {
            if(i+1==j) {
                f[i][j]=g[i][j]=1;
                continue;
            }
            f[i][j]=(f[i+1][j-1]+valid[i+1][j-1])%mod;
            for(int k=i+1;k<=j-2;++k) {
                (f[i][j]+=(valid[i+1][k]*f[k+1][j-1]+f[i+1][k]*valid[k+1][j-1])%mod)%=mod;
            }
            g[i][j]=f[i][j];
            for(int k=i;k<=j-1;++k) (f[i][j]+=f[i][k]*g[k+1][j]%mod)%=mod;
            suf[j+1]=suf[j+2]=0;
            for(int k=j;k>=i;--k) suf[k]=(suf[k+1]+g[k][j])%mod;
            int pos=0;
            for(int k=i;k<=j-2;++k) {
                pos=max(pos,k+1);
                while(pos<=j&&valid[k+1][pos]) ++pos;
                (f[i][j]+=f[i][k]*(suf[k+2]-suf[pos+1]+mod)%mod)%=mod;
            }
        }
    }
    printf("%lld\n",f[1][n]);
    return 0;
}

```
