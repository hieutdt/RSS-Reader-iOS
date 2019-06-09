
#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property (strong, nonatomic) NSMutableString *title;
@property (strong, nonatomic) NSMutableString *link;
@property (strong, nonatomic) NSMutableString *description;

- (id)initWithTitle:(NSMutableString*)title Link:(NSMutableString*)link Description:(NSMutableString*)description;

- (void)setTilte:(NSMutableString*)feedTitle;
- (void)setLink:(NSMutableString *)feedLink;
- (void)setDescription:(NSMutableString *)feedDescription;

- (NSMutableString*)getTitle;
- (NSMutableString*)getLink;
- (NSMutableString*)getDescription;

@end
