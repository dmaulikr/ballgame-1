//-----------------------------------------------------------------------------
// File:	GLSkeletonAppDelegate.h
// Author:	Gordon Wood
//
// Main application delegate.
//-----------------------------------------------------------------------------
#import <UIKit/UIKit.h>
#import "GLView.h"
#import "Game.h"




@interface GLSkeletonAppDelegate : NSObject <UIApplicationDelegate> 
{
	UIWindow	*m_window;
	GLView		*m_glview;
}
@end

