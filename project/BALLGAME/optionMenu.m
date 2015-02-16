//
//  optionMenu.m
//  GLSkeleton
//
//  Created by Andrew on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
/*Option menu is a class that holds the various options the game needs to run.
//This class has a shared version of itself that allows anyone to access it. in fact, this class should never be instantiated. Only use the shared version
  its sort of cool how it works, all you have to do is give a pointer to the UIView you are using, then the class will find the parent view (or window if we only have 
  one view) and then swap out the original view for this view, leaving the original intact. 
  Then, when we are done of the View, it uses the same pointer to swap back again! 
  Its a really cool trick that */

#import "optionMenu.h"


@implementation optionMenu
static optionMenu *sharedOptionMenu = nil;

@synthesize timeSlider;
@synthesize gravSlider;
@synthesize soundSwitch;
@synthesize navBar;
@synthesize segControlStyle;
@synthesize gravLabel;
@synthesize timeLabel;
@synthesize barLabel;
@synthesize txtControlInfo;
@synthesize parentView;

/* strings to change the text in the textHolder*/
NSString *tiltInfo=@"Tilt Controls use the built in accelerometer to control the ball. \
Manouver the device to an angle you want the ball to fall at.\
No screen spinning in this mode!";

NSString *arrowInfo=@"Arrow Controls add buttons to the screen to move around.\
Press the left button to spin the level left, and the \
Right button to spin the screen right.\
The screen will spin and it is ACHAHCA CRAZY!!!";

NSString *circleInfo=@"Circle control adds a circular control ring around the ball.\
Move your finger around the screen to spin the level around!\
Originally for debugging, NOW ITS A FEATURE!!!11!!!one!";


//Return shared sound manager among whole program
+(optionMenu*)sharedOptionMenu
{
    @synchronized(self) 
	{
        if (sharedOptionMenu == nil) 
		{
			NSLog(@"OptionMenu: Sharedmanager nil, creating new sharedManager");
            sharedOptionMenu=[[self alloc] initWithNibName:@"optionMenu" bundle:[NSBundle mainBundle] parent:nil]; 
        }
    }
    return sharedOptionMenu;
}

+ (void) releaseSharedOptionMenu
{
	NSLog(@"OptionMenu: Releasing sharedOptionMenu");
	@synchronized(self) 
	{
		if (sharedOptionMenu != nil) 
		{
			[sharedOptionMenu release]; 
		}
	}
}

// Load ourselves up from the XIB file called optionMenu
// Quick note, why are they XIB files but loaded as nib? weird
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(UIView*)parent
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		parentView=parent;
		[parentView retain];
		self.view.frame=CGRectMake(0,0,320,480);
		
    }
    return self;
}

// Viewdidload is called right after we finish loading the view. Set up all of the variables and add the navigation bar
- (void)viewDidLoad {
    [super viewDidLoad];
	options = malloc(sizeof(struct gameParam));
		
	//set initial values for the variables
	options->timeLimit=60;
	options->maxGravity=4.0;
	options->soundEnabled=YES;
	options->controlScheme=0;
	
	//create the navigation bar
	navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,20,320,44)];
	navBar.barStyle=UIBarStyleBlackOpaque;
	
	//Add a navigation item and buttons
	barLabel = [[UINavigationItem alloc] initWithTitle:@"Options"];
	barButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
	barLabel.leftBarButtonItem=barButton;
	
	//navBar expect an array of views to load, so we just put our baritem in an array of 1
	array=[NSArray arrayWithObject:barLabel];
	navBar.items=array;
	[self.view addSubview:navBar];

	//setup the gravity slider
	gravSlider.maximumValue=8;
	gravSlider.minimumValue=1;
	gravSlider.value=6.0;
	
	//setup the timelimit slider
	timeSlider.minimumValue=5;
	timeSlider.maximumValue=120;
	timeSlider.value=60;
	
	//setup sound
	soundSwitch.on=YES;
	options->soundEnabled=soundSwitch.on;
	[[soundManager sharedSoundManager] enableSound:options->soundEnabled];

	//setup control style
	segControlStyle.selectedSegmentIndex=0;
	[self slideValueChanged:self];
	[self switchValueChanged:self];
	[self segmentValueChanged:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
	NSLog(@"memory warning at optoinmenu");
}


- (void)dealloc {
	[barButton release];
	[gravSlider release];
	[timeSlider release];
	[soundSwitch release];
	[segControlStyle release];
	[navBar release];
	[barLabel release];
	[txtControlInfo release];
	[timeLabel release];
	[gravLabel release];
	[parentView release];
    [super dealloc];
}


//Update the game after changing a slider
-(IBAction)slideValueChanged:(id)sender
{
	gravLabel.text=[NSString stringWithFormat:@"Gravity: %f",gravSlider.value];
	timeLabel.text=[NSString stringWithFormat:@"Time Limit: %d Seconds",(int)timeSlider.value];
	
	options->maxGravity=gravSlider.value;
	options->timeLimit=timeSlider.value;
}

//Update the game after pressing sound switch
-(IBAction)switchValueChanged:(id)sender
{
	options->soundEnabled=soundSwitch.on;
	[[soundManager sharedSoundManager] enableSound:options->soundEnabled];
}

//Update after control style changes
-(IBAction)segmentValueChanged:(id)sender
{
	options->controlScheme=(int)segControlStyle.selectedSegmentIndex;
	//also change the text in the textbox
	if(options->controlScheme==0)
	{
		txtControlInfo.text=tiltInfo;
	}
	else if(options->controlScheme==1)
	{
		txtControlInfo.text=arrowInfo;
	}
	else
	{
		txtControlInfo.text=circleInfo;
	}
}

//this is the method that loads up witht he parent view
-(void)showWithParentView:(UIView*)in_parent;
{
	parentView=in_parent;
	
	// get the the underlying UIWindow, or the view containing the current view view
	UIView *theWindow = [parentView superview];
	[theWindow addSubview:self.view];
	
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	//show the status bar
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[[theWindow layer] addAnimation:animation forKey:@"SwitchToOptionView"];
}

//Print out the current set of options
-(void)printOptions
{
	printf("Options: \n timeLimit: %d \n gravity: %f \n soundEnabled: %d \n controlStyle: %d\n",
		   options->timeLimit,options->maxGravity,options->soundEnabled, options->controlScheme);	

}

//return to the original window with this
-(void) goBack:(id)sender
{
	// get the the view above you
	UIView *theWindow = [self.view superview];

	[theWindow addSubview:parentView];
	[self.view removeFromSuperview];

	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	//hide the status bar again
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[[theWindow layer] addAnimation:animation forKey:@"SwitchToOptionView"];
}


//methods to get the variables
-(float)getMaxGrav
{
	return options->maxGravity;
}
-(int)getTimeLimit
{
	return options->timeLimit;
}
-(int)getSoundEnabled
{
	return options->soundEnabled;
}
-(int)getControlStyle
{
	return options->controlScheme;
}
@end
