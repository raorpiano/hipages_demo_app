//
//  TableViewCell.h
//  HiPages
//
//  Created by roy orpiano on 20/07/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexedCollectionView.h"

@protocol TableViewCellDelegate <NSObject>

- (void)cellCloseButtonPressedAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *jobTitle;
@property (strong, nonatomic) IBOutlet UILabel *datePosted;
@property (strong, nonatomic) IBOutlet UILabel *connectedMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet IndexedCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *closedButton;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<TableViewCellDelegate> delegate;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
