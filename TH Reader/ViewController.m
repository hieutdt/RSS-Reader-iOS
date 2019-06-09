//
//  ViewController.m
//  TH Reader
//
//  Created by Trần Đình Tôn Hiếu on 6/7/19.
//  Copyright © 2019 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ViewController.h"
#import "Feed.h"
#import "NewsReaderView.h"
#import "DBManager.h"
#import "Reachability.h"

@interface ViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    
    Feed *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSString *element;
    
    NSMutableString *passURL;
    
    DBManager *db;
    NSArray *newsInfoArray;
    
    NSString *tableDatabaseName;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) BOOL isOffline;

- (void) splitDescription;

- (void)loadData;

- (BOOL)connectedToInternet;

@end




//-------------- implementation -----------------------------------------------

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor blackColor]];
    [bar setBackgroundColor:[UIColor colorWithRed:0 green:184 blue:0 alpha:10]];
    
    _isOffline = FALSE;
    
    //init database connection
    db = [[DBManager alloc] initWithDatabaseFileName:@"news.sql"];
    
    //init feeds array
    feeds = [[NSMutableArray alloc] init];
    
    //connect to RSS Url and Parse RSS
    NSURL *url = [NSURL URLWithString:@"https://www.cnet.com/rss/news/"];
    //NSURL *url = [NSURL URLWithString:@"https://vnexpress.net/rss/the-thao.rss"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:(id)self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    //if cant get any feeds by dont have Internet connection
    if (feeds.count == 0) {
        //read data from db
        _isOffline = TRUE;
        
        [self loadData];
        
        //get index
        NSInteger indexOfLink = [db.columnNamesArray indexOfObject:@"link"];
        NSInteger indexOfTitle = [db.columnNamesArray indexOfObject:@"title"];
        NSInteger indexOfDescription = [db.columnNamesArray indexOfObject:@"description"];
        
        //get data from database --> feeds (tableView show data from feeds)
        for (int i = 0; i < newsInfoArray.count; i++) {
            Feed *obj = [[Feed alloc] initWithTitle:[[newsInfoArray objectAtIndex:i] objectAtIndex:indexOfTitle] Link:[[newsInfoArray objectAtIndex:i] objectAtIndex:indexOfLink] Description:[[newsInfoArray objectAtIndex:i] objectAtIndex:indexOfDescription]];
            [feeds addObject:obj];
        }
    }
    //Online
    else {
        //drop old table
        NSString *query = @"DROP TABLE news;";
        [db executeQuery:query];
        
        //create new table
        query = @"CREATE TABLE IF NOT EXISTS news (id int PRIMARY KEY, link text, title text, description text) WITHOUT ROWID;";
        [db executeQuery:query];
        
        //write data from feeds to database
        for (int i = 0; i < feeds.count; i++) {
            NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO news VALUES(%d, '%@', '%@', '%@');", i, [[feeds objectAtIndex:i] getLink], [[feeds objectAtIndex:i] getTitle], [[feeds objectAtIndex:i] getDescription]];
            [db executeQuery:insertQuery];
            
            //log
            NSLog(@"Insert affected rows: %d\n", [db affectedRows]);
        }
    }
}

- (NSInteger)numberOfSelectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ListIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    UILabel *lblTitle = [[cell contentView] viewWithTag:101];
    lblTitle.text = [[feeds objectAtIndex:indexPath.row] getTitle];
    
    UILabel *lblDescription = [[cell contentView] viewWithTag:103];
    lblDescription.text = [[feeds objectAtIndex:indexPath.row] getDescription];
    
    return cell;
}

//select one row in table view --> jump to Reader view controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    passURL = [[feeds objectAtIndex:indexPath.row] getLink];
    [self performSegueWithIdentifier:@"newsPushSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newsPushSegue"]) {
        //check Internet connection first
        self.isOffline = [self connectedToInternet];
        
        NewsReaderView *vc = (NewsReaderView*)segue.destinationViewController;
        vc.url = passURL;
        vc.isOffline = self.isOffline;
    }
}

//parse XML file, if startElement = "item" then initializes item, title and link objects
- (void)parser:(NSXMLParser *)parser didStartElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(nonnull NSDictionary<NSString *,NSString *> *)attributeDict {
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        item = [[Feed alloc] init];
        
        title = [[NSMutableString alloc] init];
        link = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
    }
}

//do parse and push this string data to container of them;
- (void)parser:(NSXMLParser *)parser foundCharacters:(nonnull NSString *)string {
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    }
    else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }
    else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }
}

//Nếu đến thẻ kết thúc của 1 phần tử, kiểm tra xem phần tử đó có phải thẻ <item> không, nếu là
//thẻ item thì gọi hàm didEndElement và thêm vào feeds
- (void)parser:(NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        [self splitDescription];
        
        //set values for item
        [item setTitle:title];
        [item setLink:link];
        [item setDescription:description];
        
        //add item to feeds array
        [feeds addObject:item];
    }
}

- (void)splitDescription {
    NSMutableString *tmp = [description copy];
    for (int i = (int)tmp.length - 2; i >= 0; i--) {
        if ([tmp characterAtIndex:i] == '>') {
            description = [NSMutableString stringWithString:[tmp substringFromIndex:i + 1]];
            break;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.tableView reloadData];
}

- (IBAction)searchOnClick:(id)sender {
    NSString *newRSSUrl = [[NSString alloc] initWithString: _searchBar.text];
    NSMutableArray *oldFeeds = [feeds copy];
    
    //feeds.count = 0
    feeds = [[NSMutableArray alloc] init];
    //parse new RSS file
    NSURL *newURL = [NSURL URLWithString:newRSSUrl];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:newURL];
    [parser setDelegate:(id)self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    //if can't find any feeds from that RSS url
    if (feeds.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILED" message:@"Can't found this RSS link" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        feeds = oldFeeds;
    }
    else {
        [_tableView reloadData];
    }
}

//read data from database --> newsInfoArray
- (void)loadData {
    NSString *query = @"select * from news";
    
    if (newsInfoArray != nil) {
        newsInfoArray = nil;
    }
    
    newsInfoArray = [[NSArray alloc] initWithArray:[db loadDataFromDB:query]];
}

//get HTML text string from Url
- (NSString*)getHTMLFromURL:(NSString*)url {
    NSURL *targetURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return html;
}

- (BOOL)connectedToInternet {
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if (myStatus == NotReachable) {
        return FALSE;
    }
    else {
        return TRUE;
    }
}

@end
