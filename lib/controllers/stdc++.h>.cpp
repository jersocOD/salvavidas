#include <bits/stdc++.h>
#define fastio                    \
    ios_base::sync_with_stdio(0); \
    cin.tie(0)
#define INF 999999999
using namespace std;

void go()
{
    int n, a, b;
    long long x;
    cin >> n >> a >> b;
    vector<long long> nums;
    long long initSum = 0LL;
    for (int i = 0; i < n; i++)
    {
        cin >> x;
        nums.push_back(x);
        if (i < a)
        {
         initSum += nums[i];
        }
        
    }
    long long allMaxSum = initSum;

    for (int k = a; k <= b; k++)
    {
        if(k!=a)
        initSum += nums[k-1];

        allMaxSum=max(allMaxSum,initSum);
        long long windowSum = initSum;
        for (int i = k; i < n; i++)
        {

            windowSum += nums[i] - nums[i - k];
            allMaxSum = max(windowSum, allMaxSum);
        }
    }

    cout << allMaxSum << endl;
}

int main()
{
    fastio;
    go();
    return 0;
}
