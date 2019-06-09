#import "NewsReaderView.h"

@interface NewsReaderView()

@property (strong, nonatomic) NSURL *targetURL;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NewsReaderView
@synthesize url;
@synthesize targetURL;
@synthesize request;
@synthesize data;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    targetURL = [NSURL URLWithString:url];
    request = [NSURLRequest requestWithURL:targetURL];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [_webView loadRequest:request];
    
    if (!_isOffline) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:@"Your device don't have Internet connection! Please check and try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
