//
//  ViewController.m

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define bitcoinBuyURL [NSURL URLWithString: @"http://data.mtgox.com/api/1/BTCUSD/depth/fetch"] //2

#import "ViewController.h"

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateExchangeRate];
    
    buy_bitcoin = true;
}
- (void) updateExchangeRate{
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: bitcoinBuyURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}
double calculatePrice(NSString* quantity_string, NSArray* ticker, bool quantity_in_BTC)
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:quantity_string];
    double max_quantity = [myNumber doubleValue];
    
    double quantity_considered = 0;
    double price_total = 0;
    int order_count = 0;
    while (quantity_considered < max_quantity) {
        double current_price = [[[ticker objectAtIndex:order_count] objectForKey:@"price"] floatValue];
        double current_quantity = [[[ticker objectAtIndex:order_count] objectForKey:@"amount"] floatValue];
        
        if (quantity_in_BTC) {
            //make sure we arent considereing too many bitcoins
            if (current_quantity > (max_quantity-quantity_considered) )
                current_quantity = max_quantity-quantity_considered;
            //note how many bitcoins have been considered
            quantity_considered += current_quantity;
            //find out the total cost
            price_total += current_price* current_quantity;
        }
        else
        {
            //how many usd are we considering right now
            double current_USD_quantity = current_price*current_quantity;
            if (current_USD_quantity > (max_quantity-quantity_considered) )
                current_USD_quantity = max_quantity-quantity_considered;
            
            quantity_considered += current_USD_quantity;
            
            //we need the price in bitcoins, so since the price is in USD
            price_total += current_USD_quantity/current_price;
        }
        order_count ++;
    }    
    return price_total * (1+COMMISSION);
}
- (IBAction) updatedBTC{
    [BTC_entry resignFirstResponder];

    USD_label.text = @"loading...";
    
    must_update_USD = TRUE;
    must_update_BTC = FALSE;
    
    [self updateExchangeRate];
}
- (IBAction) updatedUSD{
    
    [USD_entry resignFirstResponder];

    BTC_label.text = @"loading...";

    must_update_USD = FALSE;
    must_update_BTC = true;
    
    
    [self updateExchangeRate];
}
- (IBAction) changedBuySellSwitch{
    if (buyOrSell.selectedSegmentIndex  == 0)
        buy_bitcoin = true;
    else
        buy_bitcoin = false;
    BTC_entry.text = nil;
    BTC_label.text = nil;
    USD_entry.text = nil;
    USD_label.text = nil;
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:kNilOptions 
                                                           error:&error];
    
    NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
    [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    if (buy_bitcoin) {
        NSArray* latestAsks = [[json objectForKey:@"return"] objectForKey:@"asks"];
        if (must_update_BTC) {
            double price = calculatePrice(USD_entry.text, latestAsks, false);
            [BTC_label setText:[NSString stringWithFormat:@"%f",price]];
        }
        else if (must_update_USD){
            double price = calculatePrice(BTC_entry.text, latestAsks, true);
            NSNumber *amount = [NSNumber numberWithDouble:price];
            [USD_label setText:[currencyStyle stringFromNumber:amount]];
        }
    }
    else{
        NSArray* latestBids = [[json objectForKey:@"return"] objectForKey:@"bids"];
        if (must_update_BTC) {
            double price = calculatePrice(USD_entry.text, latestBids, false);
            [BTC_label setText:[NSString stringWithFormat:@"%f",price]];
        }
        else if (must_update_USD){
            double price = calculatePrice(BTC_entry.text, latestBids, true);
            NSNumber *amount = [NSNumber numberWithDouble:price];
            [USD_label setText:[currencyStyle stringFromNumber:amount]];
        }

    }
    must_update_USD = false;
    must_update_BTC = false;

}

@end
