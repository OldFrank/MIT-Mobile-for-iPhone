#import "WorldCatSearchController.h"
#import "WorldCatBook.h"
#import "LibrariesModule.h"
#import "MobileRequestOperation.h"
#import "MITMobileWebAPI.h"
#import "UIKit+MITAdditions.h"

@interface WorldCatSearchController (Private)

- (void)doSearch;

@end

@implementation WorldCatSearchController
@synthesize nextIndex;
@synthesize searchTerms;
@synthesize searchResults;
@synthesize searchResultsTableView;

- (void)dealloc {
    self.searchTerms = nil;
    self.searchResults = nil;
    self.nextIndex = nil;
    self.searchResultsTableView = nil;
    [super dealloc];
}

- (void) doSearch:(NSString *)theSearchTerms {
    self.searchResults = [NSMutableArray array];
    self.nextIndex = nil;
    self.searchTerms = theSearchTerms;
    [self doSearch];
}

- (void) doSearch {
    
    LibrariesModule *librariesModule = (LibrariesModule *)[MIT_MobileAppDelegate moduleForTag:LibrariesTag];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:searchTerms forKey:@"q"];
    if (self.nextIndex) {
        [parameters setObject:[NSString stringWithFormat:@"%d", [self.nextIndex intValue]] forKey:@"startIndex"];
    }
    
    MobileRequestOperation *request = [[[MobileRequestOperation alloc] initWithModule:LibrariesTag command:@"search" parameters:parameters] autorelease];
    
    request.completeBlock = ^(MobileRequestOperation *operation, id jsonResult, NSError *error) {
        if (error) {
            NSLog(@"Request failed with error: %@",[error localizedDescription]);
            [MITMobileWebAPI showError:error header:@"WorldCat Search" alertViewDelegate:nil];
        } else {
            id aNextIndex = [jsonResult objectForKey:@"nextIndex"];
            if (aNextIndex) {
                if([aNextIndex isKindOfClass:[NSNumber class]]) {
                    self.nextIndex = aNextIndex;
                } else {
                    NSLog(@"World cat next index field invaild");
                    [MITMobileWebAPI showErrorWithHeader:@"WorldCat Search"];
                    return;
                }
            } else {
                self.nextIndex = nil;
            }
            
            id items = [jsonResult objectForKey:@"items"];
            if ([items isKindOfClass:[NSArray class]]) {
                NSMutableArray *temporarySearchResults = [NSMutableArray array];
                for (NSDictionary *dict in items) {
                    WorldCatBook *book = [[[WorldCatBook alloc] initWithDictionary:dict] autorelease];
                    if (book.parseFailure) {
                        [MITMobileWebAPI showErrorWithHeader:@"WorldCat Search"];
                        return;
                    }
                    [self.searchResults addObject:book];
                }
                [self.searchResults addObjectsFromArray:temporarySearchResults];                
                [self.searchResultsTableView reloadData];
            } else {
                NSLog(@"World cat result not an array");
                [MITMobileWebAPI showErrorWithHeader:@"WorldCat Search"];
            }            
        }
    };
    
    librariesModule.requestQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    [librariesModule.requestQueue addOperation:request];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchResults) {
        if (self.nextIndex) {
            return [NSString stringWithFormat:@"Showing the first %@ results", self.nextIndex];
        } else {
            return [NSString stringWithFormat:@"%d results found", self.searchResults.count];
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.searchResultsTableView = tableView;
    
    if (!self.searchResults) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"] autorelease];
        }
        return cell;
    }
    
    if (indexPath.row == self.searchResults.count) {
        // this is load more row
        NSString *loadMore = @"LoadMore";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMore];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMore] autorelease];
            cell.textLabel.text = @"Loading more...";
            [cell applyStandardFonts];
        }
        return cell;
    }
    
    NSString *cellIdentifier = @"book";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        [cell applyStandardFonts];
    }
    WorldCatBook *book = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = [book.authors componentsJoinedByString:@" "];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.searchResults.count) {
        [self doSearch];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchResults) {
        if (self.nextIndex) {
            return self.searchResults.count + 1;
        } else {
            return self.searchResults.count;
        }
    }
    return 1;  // returning 1 prevents "No results"
}

- (void)clearSearch {
    self.searchResults = nil;
    self.searchResultsTableView = nil;
    self.nextIndex = nil;
}

@end
