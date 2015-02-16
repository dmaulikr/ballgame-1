//
//  soundManager.h
//  GLSkeleton
//
//  Created by Andrew     on 11/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
/*stand alone sound manager for blitzball. all sound playing happens with this class
Uses a combination of Avaudioplayer and systemSoundID's to play sound. 
I didnt bother with OpenAL because I didnt see any reason to use it over this. I don't use stereo sound, but for my next project I probably will, so openAL will be implemented eventually

 Another thing to note is we can only handle one compressed sound file at a time. While we do this we can still play uncompressed sound files if we use AudioServicesPlaySystemSound, so thats what I do. 
 I don't know if OpenAL has a sound mixer or not, but if it doesnt then this would be a plus in favor of doing it this way.

*/
//Add these frameworks to your project
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface soundManager : NSObject {
	SystemSoundID shortSound;
	AVAudioPlayer *audioPlayer;
	int soundEnabled;
}

+ (soundManager*) sharedSoundManager;		//get the sound manager shared among the whole program
+ (void) releaseSharedSoundManager;			//release the shared sound manager
-(id)init;	
-(void)loadSound:(NSString*)filePath;		//load in a sound effect to play
-(void)loadMusic:(NSString*)filePath;		//load in a music file to play
-(void)playOrPauseMusic;					//play or pause the music file
-(void)stopMusic;							//stop the music file
-(void)playSound;							//play an uncompressed sound effect
-(void)enableSound:(int)soundOn;			//enable or disable sound
@end
