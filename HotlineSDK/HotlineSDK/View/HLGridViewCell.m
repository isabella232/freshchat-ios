//
//  HLCollectionViewCell.m
//  HotlineSDK
//
//  Created by kirthikas on 22/09/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//

#import "HLGridViewCell.h"
#import "FCTheme.h"
#import "FDAutolayoutHelper.h"

@interface HLGridViewCell()

@property (nonatomic,strong) UIView *view;
@property (nonatomic, strong) FCTheme *theme;

@end

@implementation HLGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]init];
        self.theme = [FCTheme sharedInstance];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [self.theme gridViewImageBackgroundColor];
        self.imageView.clipsToBounds = YES;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
    
        self.label = [[UILabel alloc]init];
        self.label.font = [self.theme gridViewCellTitleFont];
        self.label.lineBreakMode=NSLineBreakByTruncatingTail;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.backgroundColor = [self.theme gridViewCellBackgroundColor];
        self.label.textColor = [self.theme gridViewCellTitleFontColor];
        [self.label  setNumberOfLines:2];
        [self.label sizeToFit];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.label];
        
        NSDictionary *views = @{ @"imageView" : self.imageView, @"label" : self.label};
        
        [FDAutolayoutHelper centerX:self.imageView onView:self.contentView];
        [FDAutolayoutHelper centerY:self.imageView onView:self.contentView M:0.8 C:0];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0.4
                                                                      constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:0.4
                                                                      constant:0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-[label]" options:0 metrics:nil views:views]];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.label.preferredMaxLayoutWidth = self.bounds.size.width;
    [self.view layoutIfNeeded];
}

@end
