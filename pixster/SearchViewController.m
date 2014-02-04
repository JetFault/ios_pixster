//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSString *currentQuery;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *imageNib = [UINib nibWithNibName:@"ImageViewCell" bundle:nil];
    [self.collectionView registerNib:imageNib forCellWithReuseIdentifier:@"ImageViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [[self.imageResults[indexPath.row] valueForKeyPath:@"tbHeight"] floatValue];
    CGFloat width  = [[self.imageResults[indexPath.row] valueForKeyPath:@"tbWidth"] floatValue];
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Infinite scroll
    if(indexPath.row == ([self.imageResults count] - 1)) {
        [self getImages:nil withOffset:[self.imageResults count]];
    }
    
    static NSString *CellIdentifier = @"ImageViewCell";
    
    // Dequeue or create a cell of the appropriate type.
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = nil;
    
    const int IMAGE_TAG = 1;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.tag = IMAGE_TAG;
    [cell.contentView addSubview:imageView];
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]];
    
    return cell;
    
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    self.currentQuery = searchBar.text;
    
    [self.imageResults removeAllObjects];
    [self getImages:searchBar.text withOffset:[self.imageResults count]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (void)getImages:(NSString *)query withOffset:(int)offset
{
    
    if (query == nil) {
        query = self.currentQuery;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d", [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], offset]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults addObjectsFromArray:results];
        }
        NSLog(@"%@", self.imageResults);
        [self.collectionView reloadData];
    } failure:nil];
    
    [operation start];
    
}

@end
