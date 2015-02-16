//-----------------------------------------------------------------------------
// File:	GLSkeletonAppDelegate.m
// Author:	Gordon Wood modified by andrew reddin
//
// Main application delegate.
// nothing really changed here except now we alloc the game inside of GLView
//-----------------------------------------------------------------------------
#import "GLSkeletonAppDelegate.h"
#import "soundManager.h"
#import "optionMenu.h"
@implementation GLSkeletonAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	[application setStatusBarHidden:YES animated:NO];
	
	m_window	= [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	m_glview	= [[GLView alloc] initWithFrame:m_window.frame fps:60.0f];

	[m_window addSubview:m_glview];
    [m_window makeKeyAndVisible];
}

- (void)dealloc 
{
	//Also release sharedManagers!
	[soundManager releaseSharedSoundManager];
	[optionMenu releaseSharedOptionMenu];
	[m_glview release];
    [m_window release];
    [super dealloc];
}

@end
