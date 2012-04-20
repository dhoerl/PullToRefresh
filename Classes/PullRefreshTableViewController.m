//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>

#import "PullRefreshTableViewController.h"

#import "UIColor+Hex.h"

#define REFRESH_HEADER_HEIGHT 60.0f

@interface PullRefreshTableViewController ()

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

@implementation PullRefreshTableViewController
{
	UITableViewCell *cell;	// save the last one so we can animate it if needbe
	BOOL isDragging;
}
@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner, isPullToRefreshing;
@synthesize usingPullToRefreshCell;

#if 0	// Lot18 is not using this
- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}
#endif

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self addPullToRefreshHeader];
}

- (void)setupStrings {
  textPull = [[NSString alloc] initWithString:@"Pull down to refresh…"];
  textRelease = [[NSString alloc] initWithString:@"Release to refresh…"];
  textLoading = [[NSString alloc] initWithString:@"Loading…"];
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];

	{
		UIView *bv = [[UIView alloc] initWithFrame:CGRectMake(0, 0+0, 320, REFRESH_HEADER_HEIGHT - 0)];	// was 4 and 8
		bv.backgroundColor = [UIColor colorWithHex:0x111111];
		CALayer *layer = bv.layer;
		//layer.cornerRadius = 12;
		layer.masksToBounds = YES;
		[refreshHeaderView addSubview:bv];
	}

    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 320-50, REFRESH_HEADER_HEIGHT)];
	refreshLabel.backgroundColor = [UIColor clearColor];
	refreshLabel.textColor = [UIColor colorWithHex:0xeeeeee];
    refreshLabel.font = [UIFont fontWithName:@"Arvo" size:12.0f];
    refreshLabel.textAlignment = UITextAlignmentCenter;

    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone_refresh.png"]];
    refreshArrow.frame = CGRectMake(floorf((88 - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 45) / 2),
                                    27, 45);

    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;

    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [TABLE_VIEW(self.view) addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isPullToRefreshing) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isPullToRefreshing) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            TABLE_VIEW(self.view).contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            TABLE_VIEW(self.view).contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshLabel.text = self.textRelease;
            [refreshArrow layer].transform = CATransform3DMakeRotation((CGFloat)M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshLabel.text = self.textPull;
            [refreshArrow layer].transform = CATransform3DMakeRotation((CGFloat)M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isPullToRefreshing) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isPullToRefreshing = YES;

    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    TABLE_VIEW(self.view).contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshLabel.text = self.textLoading;
    refreshArrow.hidden = YES;
    [refreshSpinner startAnimating];
    [UIView commitAnimations];

    // Refresh action!
	[self refreshStart];
}

- (void)stopLoading {
	if(isPullToRefreshing) {
		// Hide the header
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
		TABLE_VIEW(self.view).contentInset = UIEdgeInsetsZero;
		[refreshArrow layer].transform = CATransform3DMakeRotation((CGFloat)M_PI * 2, 0, 0, 1);
		[UIView commitAnimations];

		isPullToRefreshing = NO;
	}
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refreshStart {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(refreshDone) withObject:nil afterDelay:2.0];
}
- (void)refreshDone {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self stopLoading];
}

@end

@implementation PullRefreshTableViewController (TableViewHelper)

- (UITableViewCell *)hiddenPullToRefreshCell
{
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, kPullToFreshHeight);
		
		UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
		backgroundView.backgroundColor = [UIColor darkGrayColor];
		cell.backgroundView = backgroundView;
		
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.font				= [UIFont boldSystemFontOfSize:19];
		label.textAlignment		= UITextAlignmentCenter;
		label.backgroundColor	= [UIColor clearColor];
		label.textColor			= [UIColor whiteColor];
		label.text				= @"Pull Down to Refresh";
		[label sizeToFit];
		
		label.frame = [BaseViewController centeredFrameForSize:label.frame.size inRect:frame];
		[cell.contentView addSubview:label];

		cell.contentView.alpha		= 0;
		cell.backgroundView.alpha	= 0;
	}
	return cell;
}

- (void)showPullToRefreshCellNow
{
	cell.contentView.alpha		= 1;
	cell.backgroundView.alpha	= 1;
}

- (showBlock)showPullToRefreshCell
{
	showBlock b = ^
					{
						[UIView animateWithDuration:0.25f animations:^
							{
								cell.contentView.alpha		= 1;
								cell.backgroundView.alpha	= 1;
							} ];
					};
	return [b copy];
}
- (showBlock)hidePullToRefreshCell
{
	showBlock b = ^
					{
						[UIView animateWithDuration:0.25f animations:^
							{
								cell.contentView.alpha		= 0;
								cell.backgroundView.alpha	= 0;
							} ];
					};
	return [b copy];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kPullToFreshHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return [self hiddenPullToRefreshCell];
}

@end
