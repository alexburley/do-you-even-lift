//
//  StartWorkoutViewController.m
//  do-you-even-lift
//
//  Created by aca13ab on 11/01/2017.
//  Copyright © 2017 Alex Burley. All rights reserved.
//

#import "StartWorkoutViewController.h"

@interface StartWorkoutViewController ()

@end

@implementation StartWorkoutViewController

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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myIdentifier = @"myIdentifier";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:myIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:myIdentifier];
    }
  
    return cell;
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
