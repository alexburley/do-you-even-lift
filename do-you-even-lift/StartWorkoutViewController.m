//
//  StartWorkoutViewController.m
//  do-you-even-lift
//
//  Created by aca13ab on 11/01/2017.
//  Copyright © 2017 Alex Burley. All rights reserved.
//

#import "StartWorkoutViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface StartWorkoutViewController () <NSFetchedResultsControllerDelegate>

@end

@implementation StartWorkoutViewController   {
    NSFetchedResultsController *_fetchedResultsController;
}

int sec = 0;
int min = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton addTarget:self action:NSSelectorFromString(@"startButtonPressed") forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"START" forState:UIControlStateNormal];
    startButton.backgroundColor = [UIColor blueColor];
    startButton.layer.cornerRadius = 50;
    startButton.clipsToBounds = YES;
    startButton.frame = CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.1, self.view.frame.size.width*0.2, self.view.frame.size.height*0.1);
    [self.view addSubview:startButton];
    
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.3, 60, 30)];
    
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:label];
    label.text = [NSString stringWithFormat:@"00:00"];
    
    UISwitch *onoff = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.3, self.view.frame.size.height*0.4,40,50)];
    [onoff addTarget:self action:@selector(flip:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:onoff];
    
    tableView=[[UITableView alloc]init];
    tableView.frame = CGRectMake(self.view.frame.size.width*0, self.view.frame.size.height*0.5,self.view.frame.size.width,self.view.frame.size.height*0.5);
    tableView.dataSource=self;
    tableView.delegate=self;
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [tableView reloadData];
    [self.view addSubview:tableView];
    
    
    // Do any additional setup after loading the view.
   
    NSError *error;
    NSLog(@"%@", [self fetchedResultsController]);
    //_workouts= [context executeFetchRequest:fetchRequest error:&error];
    if (![[self fetchedResultsController] performFetch:&error]){
        NSLog(@"unresolved error %@, %@", error, [error userInfo]);
    }


}
  // NSArray *array = [[NSArray alloc]initWithObjects:@"daniel", nil];

-(IBAction)flip:(id)sender{
    UISwitch *onoff = (UISwitch * )sender;
    if(onoff.on){
        startButton.enabled = NO;
        startButton.alpha = 0.5;
    }else{
        startButton.enabled = YES;
        startButton.alpha = 1.0;
    }
}


-(void)timerTick{
    
    sec++;
    if (sec == 60)
    {
        sec = 0;
        min++;
    }
    //Format the string 00:00
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    //Display on your label
    //[timeLabel setStringValue:timeNow];
    label.text= timeNow;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)startButtonPressed{
    self.isStart = !self.isStart;
    
    if (self.isStart){
        sec = 0;
        min = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:TRUE];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [startButton setTitle:@"STOP" forState:UIControlStateNormal];
    }else{
        [startButton setTitle:@"START" forState:UIControlStateNormal];
        [timer invalidate];
        label.text = [NSString stringWithFormat:@"00:00"];
    }

    
    
}

-(void)viewWillDisapper:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    id workoutPlan = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [workoutPlan valueForKey:@"plan_name"];
}


-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil){
        return _fetchedResultsController;
    }
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = app.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WorkoutPlan" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"plan_name" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [tableView endUpdates];
}




/*
#pragma mark - Navigation
x
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
