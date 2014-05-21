//
//  ViewController.h
//  IAP
//
//  Created by 岡庭英晃 on 2014/05/20.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
//    InAppPurchaseManager* iap;
}

@property (weak, nonatomic) IBOutlet UIButton* buttonIAP;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (nonatomic) NSArray* items;


@end
