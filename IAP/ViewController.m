//
//  ViewController.m
//  IAP
//
//  Created by 岡庭英晃 on 2014/05/20.
//
//

#import "InAppPurchaseManager.h"
#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController
{
    dispatch_queue_t main_queue;
    dispatch_queue_t timeline_queue;
    dispatch_queue_t image_queue;
    
    NSTimer *completedTimer;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 空の配列.
    self.items = [NSArray array];
    
    //2秒後にセレクタメソッドを実行する
//    completedTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
//                                                       target:self
//                                                     selector:@selector(getJSON:)
//                                                     userInfo:nil
//                                                      repeats:NO];
    [self getJSON];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    main_queue = dispatch_get_main_queue();
//    timeline_queue = dispatch_queue_create("com.timeline", NULL);
    
//    dispatch_async(timeline_queue, ^{
        // JSON取得処理.
//        [self getJSON];
//    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d", [self.items count]);
    
    return [self.items count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSLog(@"++");
    
    NSDictionary* item = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [[item objectForKey:@"im:name"] objectForKey:@"label"];
    
    return cell;
}

#pragma mark ACTIONDelegate

-(IBAction)touchButtonIAP:(id)sender
{
    NSLog(@"touchButtonIAP");
    InAppPurchaseManager* iap = [InAppPurchaseManager sharedInstance];
    
    if([iap canMakePurchases])
    {
        [iap requestProductData:@"com.mushikago.InAppPurchaseXcode.unLock"];
        
        NSLog(@"======");
    }
    else
    {
        UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Message"
                                                         message:@"課金が許可されていません"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark PRIVATE

-(void)getJSON
{
    NSURL* url = [NSURL URLWithString:@"http://itunes.apple.com/jp/rss/topfreeapplications/limit=10/json"];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    // 非同期リクエスト.
    NSOperationQueue* subQueue = [[NSOperationQueue alloc] init];
    
    [subQueue addOperationWithBlock:^{
       // timeline取得.
        [NSURLConnection sendAsynchronousRequest:request queue:subQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            //
            NSLog(@"取得中...");
            //
            NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // アプリデータの配列を格納.
            self.items = [[jsonDic objectForKey:@"feed"] objectForKey:@"entry"];
            
            //
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                NSLog(@"取得完了...");
                
                NSLog(@"GitStage1.");
                
            }];
        }];
    }];
    
    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        //
//        NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        
//        // アプリデータの配列を格納.
//        self.items = [[jsonDic objectForKey:@"feed"] objectForKey:@"entry"];
//        
//        //
//        [self.tableView reloadData];
//        
//    }];
    
}


@end
