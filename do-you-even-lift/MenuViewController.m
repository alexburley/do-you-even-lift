//
//  ViewController.m
//  do-you-even-lift
//
//  Created by Alex Burley on 07/01/2017.
//  Copyright © 2017 Alex Burley. All rights reserved.
//

#import "MenuViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreData/CoreData.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"






//Test Commit

@interface MenuViewController () <FBSDKLoginButtonDelegate>



@end

@implementation MenuViewController{
    
    // FB User ID and full name
    NSString *_userID;
    NSString *_userName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Facebook login button
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    loginButton.readPermissions = @[@"public_profile"];
    [loginButton setDelegate:self];
    [self.view addSubview:loginButton];
    
    //Set up custom users button for testing purposes
    //MEMORY ALLOCATION?
    usersButton = [UIButton buttonWithType:UIButtonTypeCustom];
    usersButton.backgroundColor = [UIColor redColor];
    [usersButton addTarget:self action:NSSelectorFromString(@"usersButtonPressed") forControlEvents:UIControlEventTouchUpInside];
    [usersButton setTitle:@"Users" forState:UIControlStateNormal];
    usersButton.frame = CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.1, self.view.frame.size.width*0.6, self.view.frame.size.height*0.10);
    
    startWorkoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startWorkoutButton addTarget:self action:NSSelectorFromString(@"startWorkoutButtonPressed") forControlEvents:UIControlEventTouchUpInside];
    [startWorkoutButton setTitle:@"Start Workout" forState:UIControlStateNormal];
    startWorkoutButton.frame = CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.2, self.view.frame.size.width*0.6, self.view.frame.size.height*0.10);
    [self.view addSubview:startWorkoutButton];
    
    workoutPlansButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [workoutPlansButton addTarget:self action:NSSelectorFromString(@"workoutPlansButtonPressed") forControlEvents:UIControlEventTouchUpInside];
    [workoutPlansButton setTitle:@"Workout Plans" forState:UIControlStateNormal];
    workoutPlansButton.frame = CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.3, self.view.frame.size.width*0.6, self.view.frame.size.height*0.1);
    [self.view addSubview:workoutPlansButton];
    
    
    
    
    
   
    //If a user already has access we can process that and add the necessary view
    if ([FBSDKAccessToken currentAccessToken]){
        [self finishLogin];
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    [usersButton removeFromSuperview];
    _userID = nil;
    _userName = nil;
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    //Seperate large code from delegate method
    [self finishLogin];
    
}

-(void)usersButtonPressed{
    [self performSegueWithIdentifier:@"showUsers" sender:self];
    
}

-(void)startWorkoutButtonPressed {
    
    [self performSegueWithIdentifier:@"startWorkout" sender:self];
    
}

-(void)workoutsButtonPressed{
    [self performSegueWithIdentifier:@"workouts" sender:self];
}

-(void)workoutPlansButtonPressed{
    [self performSegueWithIdentifier:@"workoutPlans" sender:self];
}

-(void)finishLogin{
    
    //If a user is logged in we want to give them access to the view users
    [self.view addSubview:usersButton];
    
    //Access the user identification number and set the instance variable
    NSLog(@"User ID: %@", [FBSDKAccessToken currentAccessToken].userID);
    _userID = [FBSDKAccessToken currentAccessToken].userID;
    
    //We only want to request the id and name of the user
    NSMutableDictionary* paramaters = [NSMutableDictionary dictionary];
    [paramaters setValue:@"id,name" forKey:@"fields"];
    //Use FB graph api to get the data. Note the completion handler, this operates asychronously and may lead to errors if you operate outside the block relying on objects that are set within in the block.
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:paramaters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id results, NSError *error) {
         
         //Set the name
         NSLog(@"Name: %@", [results valueForKey:@"name"]);
         _userName = [results valueForKey:@"name"];
         
         //Retrieve the application context using the public appdelegate method
         AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
         NSManagedObjectContext *context = app.managedObjectContext;
         
         //Initiate fetch request with a predicate to retrieve the necessary object(s)
         NSFetchRequest *request = [[NSFetchRequest alloc] init];
         request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %@", _userID];
         request.predicate = predicate;
         NSError *requestError = nil;
         NSArray *objs = [context executeFetchRequest:request error:&requestError];
         
         if (requestError) {
             [NSException raise:@"Error on fetch request" format:@"%@", [requestError localizedDescription]];
         }
         else {
             if (objs.count > 0){
                 //Update the last login date
                 [[objs objectAtIndex:0] setValue:[NSDate date] forKey:@"last_login"];
                 NSLog(@"objs count: %i", objs.count);
             }
             else {
                 //Create a new object
                 NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
                 NSLog(@"user = %@", _userName);
                 [newUser setValue:_userID forKey:@"user_id"];
                 [newUser setValue:_userName forKey:@"name"];
                 [newUser setValue:[NSDate date] forKey:@"created_at"];
                 [newUser setValue:[NSDate date] forKey:@"last_login"];
                 
             }
         }
         
         NSError *saveError = nil;
         
         if(![context save:&saveError]){
             NSLog(@"Unable to save user %@, %@", saveError, [saveError localizedDescription]);
         }

     }];
    
}


@end