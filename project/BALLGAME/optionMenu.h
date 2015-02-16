//
//  optionMenu.h
//  GLSkeleton
//
//  Created by Andrew on 10/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
/*Option menu is a class that holds the various options the game needs to run.
//This class has a shared version of itself that allows anyone to access it. in fact, this class should never be instantiated. Only use the shared version
its sort of cool how it works, all you have to do is give a pointer to the UIView you are using, then the class will find the parent view (or window if we only have 
																																		   one view) and then swap out the original view for this view, leaving the original intact. 
Then, when we are done of the View, it uses the same pointer to swap back again! 
Its a really cool trick that */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GLView.h"
#import "soundManager.h"

@interface optionMenu : UIViewController {
	struct gameParam *options;
	IBOutlet UISlider* gravSlider;
	IBOutlet UISlider* timeSlider;
	IBOutlet UISwitch* soundSwitch;
	IBOutlet UISegmentedControl* segControlStyle;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *gravLabel;
	IBOutlet UITextView* txtControlInfo;
	
	UIView* parentView;
	IBOutlet UINavigationBar* navBar;
	IBOutlet UINavigationItem* barLabel;
	UIBarButtonItem* barButton;
	NSArray* array;
}
@property (nonatomic, retain) UISlider* gravSlider;
@property (nonatomic, retain) UISlider* timeSlider;
@property (nonatomic, retain) UISwitch* soundSwitch;
@property (nonatomic, retain) UISegmentedControl* segControlStyle;
@property (nonatomic, retain) UINavigationBar* navBar;
@property (nonatomic, retain) UINavigationItem* barLabel;
@property (nonatomic, retain) UITextView* txtControlInfo;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *gravLabel;
@property (nonatomic, retain) UIView* parentView;

-(IBAction)slideValueChanged:(id)sender;
-(IBAction)switchValueChanged:(id)sender;
-(IBAction)segmentValueChanged:(id)sender;

+(optionMenu*)sharedOptionMenu;
+ (void) releaseSharedOptionMenu;

-(void)showWithParentView:(UIView*)in_parent;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(UIView*)parent;
-(float)getMaxGrav;
-(int)getTimeLimit;
-(int)getSoundEnabled;
-(int)getControlStyle;
@end
