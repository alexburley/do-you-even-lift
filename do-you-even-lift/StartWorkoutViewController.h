//
//  StartWorkoutViewController.h
//  do-you-even-lift
//
//  Created by aca13ab on 11/01/2017.
//  Copyright © 2017 Alex Burley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartWorkoutViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    
    UIButton *startButton;
    UILabel *label;
    NSTimer *timer;
    UITableView *tableView;
}

@property (nonatomic, assign)BOOL isStart;

@end
