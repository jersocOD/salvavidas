#include<bits/stdc++.h>
#define fastio ios_base::sync_with_stdio(0); cin.tie(0)
#define INF 999999999
using namespace std;

void go(){
    int n, a,b,x; cin>>n>>a>>b;
    vector<int> nums;
    for(int i=0; i<n; i++){
        cin>>x;
        nums.push_back(x);
    }
    int sumMax=0;
    int sumMaxA=0;
    int sumMaxB=0;
    for(int i=0;i<b;i++){
        if(i<a){
            sumMaxA+=nums[i];
        }
        sumMaxB+=nums[i];


    }
    sumMax=max(sumMaxA,sumMaxB);
    int windowASum=sumMax;
    int windowBSum=sumMax;
    for(int i=a;i<n;i++){
        
        
         windowASum+=nums[i]-nums[i-a];
        sumMax=max(sumMax,windowASum);
       
       
         windowBSum+=nums[i]-nums[i-b];
        sumMax=max(sumMax,windowBSum);

    }

  
    cout<<sumMax<<endl;
}

int main(){
    fastio;
    go();
    return 0;
}
