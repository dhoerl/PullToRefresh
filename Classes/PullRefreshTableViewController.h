//
//  PullRefreshTableViewController.h
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

#import "BaseViewController.h"

#if 0 // If not using BaseViewController as superclass
typedef void(^showBlock)();
#endif

@interface PullRefreshTableViewController : BaseViewController // UI Table View Controller
@property (nonatomic, assign) BOOL usingPullToRefreshCell;
@property (nonatomic, assign) BOOL isPullToRefreshing;
@property (nonatomic, assign) CGFloat width;		// Width of View spinner is contained in


- (void)refreshStart;		// User overrides this - message telling saying time to refresh table
- (void)refreshDone;		// User must call this when refresh is done

- (UITableViewCell *)hiddenPullToRefreshCell;
- (showBlock)showPullToRefreshCell;
- (showBlock)hidePullToRefreshCell;
- (void)showPullToRefreshCellNow;

@end

@interface PullRefreshTableViewController (TableViewHelper)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
