//
//  soundManager.m
//  GLSkeleton
//
//  Created by Andrew     on 11/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "soundManager.h"

static soundManager *sharedSoundManager = nil;

@implementation soundManager


//Return shared sound manager among whole program
+ (soundManager*) sharedSoundManager
{
    @synchronized(self) 
	{
        if (sharedSoundManager == nil) 
		{
			NSLog(@"Sound Manager: Sharedmanager nil, creating new sharedManager");
            sharedSoundManager=[[self alloc] init]; 
        }
    }
    return sharedSoundManager;
}

+ (void) releaseSharedSoundManager
{
	NSLog(@"SoundManager: releasing sharedSoundManager");
	@synchronized(self) 
	{
	if (sharedSoundManager != nil) 
	{
		[sharedSoundManager release]; 
	}
	}
}

-(id)init
{
	if(!(self = [super init]))
	{
		NSLog(@"error loading sound manager");
	}
	//enable sound by default
	soundEnabled=YES;
	return self;
}


//Load in a sound effect
-(void)loadSound:(NSString*)filePath
{
	NSURL* audioFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filePath ofType:nil]]; 
	if(shortSound!=NULL)
	{
		NSLog(@"SoundManager: Removing old sound effect");
		AudioServicesDisposeSystemSoundID(shortSound);
	}
	NSLog(@"SoundManager: Creating new sound from %@",filePath);
	AudioServicesCreateSystemSoundID((CFURLRef)audioFile, &shortSound); 
}

//load in a compressed music file
-(void)loadMusic:(NSString*)filePath
{
	NSLog(@"sound manager loading music");
	//	//Creating it
	NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filePath ofType:nil]];  
	if(audioPlayer!=nil)
	{
		NSLog(@"SoundManager: Removing old audio");
		[audioPlayer release];
	}
	NSLog(@"SoundManager: Creating new audio from %@",filePath);
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
}

//Play or pause the compressed music file
-(void)playOrPauseMusic
{
	if(soundEnabled)
	{
		if(audioPlayer.playing)
		{
			[audioPlayer pause];
		}
		else
		{
			[audioPlayer play];
		}
	}
}

//stop the compressed music file
-(void)stopMusic
{
	[audioPlayer stop];
}

//play uncompressed sound effect
-(void)playSound
{
	if(soundEnabled)
	{
	if(shortSound!=NULL)
		AudioServicesPlaySystemSound(shortSound);
	}
}

//enable or disable sound
-(void)enableSound:(int) soundOn
{
	soundEnabled=soundOn;
	if(!soundEnabled)
	{
		[self stopMusic];
	}
	else
	{
		//stop the music if sound is disabled
		[self playOrPauseMusic];
	}

}

-(void) dealloc
{
	AudioServicesDisposeSystemSoundID(shortSound);
	[audioPlayer release];	
	[super dealloc];
}
@end
