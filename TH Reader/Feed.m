//
//  Feed.m
//  TH Reader
//
//  Created by Trần Đình Tôn Hiếu on 6/7/19.
//  Copyright © 2019 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Feed.h"

@implementation Feed
@synthesize title;
@synthesize link;
@synthesize description;

- (id)init {
    if (self = [super init]) {
        title = nil;
        link = nil;
        description = nil;
    }
    return self;
}

//init with all properties
- (id)initWithTitle:(NSMutableString*)feedTitle Link:(NSMutableString*)feedLink Description:(NSMutableString*)feedDescription {
    if (self = [super init]) {
        title = [feedTitle copy];
        link = [feedLink copy];
        description = [feedDescription copy];
    }
    return self;
}

//setters
- (void)setTilte:(NSMutableString*)feedTitle {
    title = [feedTitle copy];
}

- (void)setLink:(NSMutableString *)feedLink {
    link = [feedLink copy];
}

- (void)setDescription:(NSMutableString *)feedDescription {
    description = [feedDescription copy];
}

//getters
- (NSMutableString*)getTitle {
    return self.title.copy;
}

- (NSMutableString*)getLink {
    return [link copy];
}

- (NSMutableString*)getDescription {
    return [description copy];
}

@end
