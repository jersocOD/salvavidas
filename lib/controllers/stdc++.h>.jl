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
    int maxSum=nums[0];
    int actualLength=1;
    for(int i=1;i<b;i++){
        
        
        if(actualLength>=a){
            int oldSum=maxSum;
           maxSum=max(maxSum,maxSum+nums[i]) ;
           if(maxSum!=oldSum)actualLength++;
        }else{
            maxSum+=nums[i];
            actualLength++;
        }
        


    }
    
    int windowSum= maxSum;
    cout<<maxSum<<" AL: "<<actualLength<<endl;
    for(int i=actualLength;i<n;i++){
       
        

        if(actualLength==b){ 
             int oldWindowSum=windowSum;
            windowSum=max(windowSum+nums[i]-nums[i-actualLength]-nums[i-actualLength-1],windowSum+nums[i]-nums[i-actualLength]);
            if(windowSum==oldWindowSum+nums[i]-nums[i-actualLength]-nums[i-actualLength-1])actualLength--;
            maxSum=max(maxSum,windowSum);
           /*  windowSum+=nums[i]-nums[i-b];
              maxSum=max(oldSum,windowSum);

         if(maxSum!=oldSum)actualLength++; */
        }else if(actualLength==a){
            
            int oldWindowSum=windowSum;
            windowSum=max(windowSum+nums[i],windowSum+nums[i]-nums[i-actualLength]);
            if(windowSum==oldWindowSum+nums[i])actualLength++;
            
            maxSum=max(maxSum,windowSum);

            //if(maxSum==windowSum+nums[i]-nums[i-b]||maxSum==windowSum+nums[i]-nums[i-a])actualLength--;
        }else{
            int oldWindowSum=windowSum;
            windowSum=max(windowSum+nums[i],max(windowSum+nums[i]-nums[i-actualLength]-nums[i-actualLength-1],windowSum+nums[i]-nums[i-actualLength]));
            if(windowSum==oldWindowSum+nums[i])actualLength++;
            if(windowSum==oldWindowSum+nums[i]-nums[i-actualLength]-nums[i-actualLength-1])actualLength--;
            maxSum=max(maxSum,windowSum);
        }
       
cout<<maxSum<<" AL: "<<actualLength<<endl;

    }

  
    cout<<maxSum<<endl;
}

int main(){
    fastio;
    go();
    return 0;
}
