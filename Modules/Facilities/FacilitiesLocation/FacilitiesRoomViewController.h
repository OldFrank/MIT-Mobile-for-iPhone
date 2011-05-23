#import <UIKit/UIKit.h>

@class FacilitiesLocation;
@class FacilitiesCategory;
@class MITLoadingActivityView;
@class FacilitiesLocationData;
@class HighlightTableViewCell;

@interface FacilitiesRoomViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate> {
    UITableView *_tableView;
    MITLoadingActivityView *_loadingView;
    
    FacilitiesLocationData *_locationData;
    NSArray *_cachedData;
    NSArray *_filteredData;
    NSPredicate *_filterPredicate;
    NSString *_searchString;
	FacilitiesLocation *_location;
}

@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic,retain) MITLoadingActivityView* loadingView;
@property (retain) FacilitiesLocationData* locationData;
@property (nonatomic,retain) NSPredicate* filterPredicate;

@property (nonatomic,retain) NSArray* cachedData;
@property (nonatomic,retain) NSArray* filteredData;
@property (nonatomic,retain) NSString* searchString;

@property (nonatomic,retain) FacilitiesLocation* location;

- (NSArray*)dataForMainTableView;
- (NSArray*)resultsForSearchString:(NSString*)searchText;

- (void)configureMainTableCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;
- (void)configureSearchCell:(HighlightTableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;

@end
