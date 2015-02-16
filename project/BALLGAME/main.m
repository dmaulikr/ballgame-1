//-----------------------------------------------------------------------------
// File:	main.m
// Author:	Gordon Wood
//
// Entry point into the app
//-----------------------------------------------------------------------------
#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"GLSkeletonAppDelegate");
    [pool release];
    return retVal;
}
