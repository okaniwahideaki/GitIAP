//
//  InAppPurchaseManager.m
//  IAP
//
//  Created by 岡庭英晃 on 2014/05/20.
//
//

#import "InAppPurchaseManager.h"

@implementation InAppPurchaseManager

static InAppPurchaseManager* _sharedInstance = nil;
static dispatch_queue_t _serialQueue;

+(InAppPurchaseManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[InAppPurchaseManager alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedInstance];
    });
    return _sharedInstance;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serialQueue = dispatch_queue_create("IAP.SerialQueue", NULL);
        if(_sharedInstance == nil)
        {
            _sharedInstance = [super allocWithZone:zone];
        }
    });
    
    return _sharedInstance;
}

-(id)init
{
    id __block obj;
    dispatch_sync(_serialQueue, ^{
        obj = [super init];
        if( obj ) {
        }
    });
    self = obj;
    return self;
}


#pragma mark SKProductsRequestDelegate
// プロダクト情報の取得が完了した後に呼ばれる.
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //
    if(response == nil)
    {
        [self showAlert:@"responseがありません"];
        return;
    }
    
    // 無効なProduct IDが渡された時、その一覧が返される.
    for(NSString* identifier in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product identifier: %@", identifier);
        [self showAlert:@"無効なProduct IDです"];
    }
    
    // 商品情報(SKProduct)はresponse.productsに配列で入っている.
    for(SKProduct* product in response.products)
    {
        NSLog(@"Product %@", product);
        // 購入処理の開始.
        SKPayment* payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

// エラーの場合.
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlert:@"商品情報を取得できませんでした"];
}

#pragma mark SKPaymentTransactionObserver
// トランザクションオブザーバー通知.
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction* transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // 購入処理中.
                // インジケータ処理など.
                break;
            case SKPaymentTransactionStatePurchased:
                // 購入処理成功.
                NSLog(@"payment transaction.payment.productIdentifier : %@",transaction.payment.productIdentifier);
                [queue finishTransaction:transaction];
                
                // NSNotificationを投げて、カスタム処理.
                
                break;
            case SKPaymentTransactionStateFailed:
                // 購入処理失敗または購入キャンセル.
                [queue finishTransaction:transaction];
                
                if(!transaction.error.code == SKErrorPaymentCancelled)
                {
                    NSLog(@"payment error : %@", transaction.error.localizedDescription);
                }
                else
                {
                    NSLog(@"payment transaction is canceled");
                }
                
                // NSNotificationを投げて、カスタム処理.
                
                break;
            case SKPaymentTransactionStateRestored:
                // リストア処理.
                [queue finishTransaction:transaction];
                NSLog(@"payment transaction.originalTransaction.payment.productIdentifier : %@",transaction.originalTransaction.payment.productIdentifier);
                
                // NSNotificationを投げて、カスタム処理.
                
                break;
            default:
                
                break;
        }
    }
}

#pragma mark PUBLIC.

//// 課金処理はOSレベルで行われるので、AppDelegateなどに設置するのが望ましい.
//-(void)resisterTransactionObserver
//{
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//}

-(BOOL)canMakePurchases
{
    // アプリ内課金が許可されているか確認.
    if([SKPaymentQueue canMakePayments]) {
        return YES;
    }
    
    return NO;
}

-(void)requestProductData:(NSString *)productID
{
    productResult = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
    productResult.delegate = self;
    [productResult start];
    
}

#pragma mark PRIVATE

//Alert
- (void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Message"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

@end
