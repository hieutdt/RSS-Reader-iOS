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
    
    [_webView loadRequest:request];
}

@end

