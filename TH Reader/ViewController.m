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

@interface ViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    
    Feed *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *description;
    NSString *element;
    
    NSMutableString *passURL;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *feedsButton;

- (void) splitDescription;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor:[UIColor blackColor]];
    [bar setBackgroundColor:[UIColor colorWithRed:0 green:184 blue:0 alpha:10]];
    
    [_feedsButton setTintColor:[UIColor blueColor]];
    
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://www.cnet.com/rss/news/"];
    //NSURL *url = [NSURL URLWithString:@"https://vnexpress.net/rss/the-thao.rss"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:(id)self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

/*
- (IBAction)buttonOnClick:(id)sender {
 
}*/

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
        NewsReaderView *vc = (NewsReaderView*)segue.destinationViewController;
        vc.url = passURL;
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
    
    if (feeds.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FAILED" message:@"Can't found this RSS link" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        feeds = oldFeeds;
    }
    else {
        [_tableView reloadData];
    }
}

@end
