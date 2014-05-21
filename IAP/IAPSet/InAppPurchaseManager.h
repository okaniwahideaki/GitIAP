//
//  InAppPurchaseManager.h
//  IAP
//
//  Created by 岡庭英晃 on 2014/05/20.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest* productResult;
}

// シングルトン.
+(InAppPurchaseManager*)sharedInstance;


//// トランザクションオブザーバーの登録.
//-(void)resisterTransactionObserver;
// 購入処理判断.
-(BOOL)canMakePurchases;
// プロダクトに関する情報を取得開始.
-(void)requestProductData:(NSString*)productID;

@end
