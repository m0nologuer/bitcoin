//
//  ViewController.h


#import <UIKit/UIKit.h>
#define COMMISSION 0.01

@interface ViewController : UIViewController {
    IBOutlet UITextField *BTC_entry;
    IBOutlet UITextField *USD_entry;
    
    IBOutlet UILabel    *BTC_label;
    IBOutlet UILabel    *USD_label;

    IBOutlet UISegmentedControl* buyOrSell;
        
    bool must_update_USD;
    bool must_update_BTC;
        
    bool buy_bitcoin;
    
    //NSString *currency;
    //NSString *mtGoxURL;
}
- (IBAction) updatedBTC;
- (IBAction) updatedUSD;
- (IBAction) changedBuySellSwitch;

@end
