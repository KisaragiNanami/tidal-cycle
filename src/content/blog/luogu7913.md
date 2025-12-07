---
title: luogu7913 廊桥分配 题解
tags: 贪心
categories:
  - 题解
pubDate: 2022-06-20

---



## Solution

两个区分开做。

先考虑只有一个廊桥会怎么样。

注意到**先到先得**，所以第一个廊桥怎么分就确定了。

如果再多一个廊桥，那么最优策略是先前廊桥不动，它自己再重复一遍先到先得的过程。

下面证明。

> 考虑剩下的飞机里到达时间最早的 $i$，把他换进去需要至少一个时间比它更早的已经安排了廊桥的飞机，为了方便就钦定是一个，设其为 $j$。换掉二者后总数是不变的，唯一有可能使得上述策略假掉的情况就是，新廊桥第一个飞机换成 $j$ 后右端点变小，能兼容更多的飞机。但是由于 $j$ 的右端点小于 $j+1$ 的左端点，而此时如果有左端点小于 $j+1$ 的左端点，大于 $j$ 的右端点的飞机，但是选出的就一定不是 $j+1$，所以这种情况不存在，所以不可能会更优秀。如果 $j$ 是廊桥最后一个飞机，那么也不存在。

用`std::set`维护区间端点即可，每个飞机最多进出`std::set`一次，复杂度 $O(n \log n)$。

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
const int N=1e5+5;
int n, m1, m2, ans[N][2];
PII a[N], b[N];
set<PII > s1, s2;
signed main() {
    freopen("airport.in","r",stdin);
    freopen("airport.out","w",stdout);
    n=read(), m1=read(), m2=read();
    rep(i,1,m1) a[i].fi=read(), a[i].se=read(), s1.insert(a[i]);
    rep(i,1,m2) b[i].fi=read(), b[i].se=read(), s2.insert(b[i]);
    sort(a+1,a+m1+1);
    sort(b+1,b+m2+1);
    rep(i,1,n) {
        ans[i][0]=ans[i-1][0];
        int cnt=0;
        PII t=MP(0,0);
        while(1) {
            if(!s1.size()) break;
            auto p=s1.lower_bound(MP(t.se,0));
            if(p!=s1.end()) ++cnt, s1.erase(p), t=*p;
            else break;
        }
        ans[i][0]+=cnt;
    }
    rep(i,1,n) {
        ans[i][1]=ans[i-1][1];
        int cnt=0;
        PII t=MP(0,0);
        while(1) {
            if(!s2.size()) break;
            auto p=s2.lower_bound(MP(t.se,0));
            if(p!=s2.end()) ++cnt, s2.erase(p), t=*p;
            else break;
        }
        ans[i][1]+=cnt;
    }
    int Ans=0;
    rep(i,0,n) Ans=max(Ans,ans[i][0]+ans[n-i][1]);
    printf("%lld\n",Ans);
    return 0;
}
```
