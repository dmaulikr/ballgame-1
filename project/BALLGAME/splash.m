//-----------------------------------------------------------------------------
// File:	Game.m
//
// Splash screen delegate.
// This method is dirty and should be revamped come summer
//-----------------------------------------------------------------------------
#import "splash.h"
#define NUMTEX 2
#define kTransitionDuration	0.75
#define kUpdateFrequency 40  // Hz
#define kFilteringFactor 0.05
#define kNoReadingValue 999
#define PI 3.14152 


void DrawQuad(float x, float y, float* uvs, float* verticies);
static GLfloat s_aSquareVertices[] = {
0, 0,0,
320,  0,0,
0,   480,0,
320,  480,0
};

// UVs for the backdrop and Alpha map
// cryptic numbers come from WIDTH/512 and HEIGHT/512 
static GLfloat backdropUVs[] = {
0, 0,
0.625, 0,
0, 0.9375,
0.625, 0.9375
};

//Quick variables for the start button
//I didnt even bother doing this for the other buttons,
//Ideally i should have a button class, but again, time limits 
#define START_BUTTON_X 30
#define START_BUTTON_Y 50
#define START_BUTTON_WIDTH 182
#define START_BUTTON_HEIGHT 192
static GLfloat startButtonVertices[] = {
-91, -96,0,
91,  -96,0,
-91,   96,0,
91,  96,0
};


static GLfloat optionButtonVertices[] = {
-64, -64,0,
64,  -64,0,
-64,   64,0,
64,  64,0
};

static GLfloat fullUVs[] = {
0, 0,
1, 0,
0,1,
1,1
};



@implementation splash

// Constructor
-(id) initWithParent:(UIView*)parent;
{
	if( !(self = [super init]) )
		return nil;
	NSLog(@"CREATING SPLASH");
	//Keep a copy of the parent pointer
	parentView=parent;
	[parentView retain];
		
	return self;
}

// Main process loop for our game
-(int) process
{
	//Splash state tells us what we should be processing. 
	//0 we are showing splash screens  
	//1 we are at the menu
	//2 we are ready to return to GLView
	switch(splash_state)
	{
		case 0:
			//Boolfadein is set by touching the screen. 
			if(!bool_fadeIn)
			{	
				if(alpha<=5)
				{
					alpha=0;
				}
				else
				{
					alpha-=5;
				}
			}
			else
			{
				if(alpha>=255)
				{
					//Our screen has flashed in and then out again
					if(curTex+1 < NUMTEX)
					{
						//load a different screen until we dont have any more to load
						curTex++;
						bool_fadeIn=0;
					}
					else
					{
						//no more screens to load so start drawing the menu
						alpha=0;
						bool_fadeIn=0;  //reset the touch variable
						curTex++;       //go to the next Texture which is in this case the background
						splash_state=1; //advance to the next state
					}
				}
				else
				{
					alpha+=5;
				}
			}
			break;
		case 1:
			//Do quick bounds checking to see if we are inside a button square
			if (bool_fadeIn)
				{
					if(touchX<START_BUTTON_X + START_BUTTON_WIDTH)
					{
						if(touchX>START_BUTTON_X)
						{
							if(touchY>START_BUTTON_Y)
							{
								if(touchY<START_BUTTON_Y+START_BUTTON_HEIGHT)
								{
									//Start button pressed play a sound
									[[soundManager sharedSoundManager] stopMusic];
									splash_state++;
								}
							}
						}
					}//Start button not pressed so check dont touch button
					else if(touchX>=180) 
					{
						if(touchX<180+128)
						{
							if(touchY>=220)
							{
								if(touchY<220+128)
								{
									//dont touch button pressed so load alertview
									NSLog(@"DONT TOUCH");
									UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"OMG" message:@"I SAID DONT TOUCH" delegate:nil cancelButtonTitle:@"I am an Idiot" otherButtonTitles:nil];
									[alert show];
									[alert release];
									
								}
							}
						}
					}
					//Check the option button
					if(touchX>=75)
					{
						if(touchX<75+128)
						{
							if(touchY>=350)
							{
								if(touchY<350+128)
								{
									//option button pressed so load up the option screen
									NSLog(@"OPTIONS");
									[[optionMenu sharedOptionMenu] showWithParentView:parentView];
									touchX=0;
									touchY=0;
								}
							}
						}
					}
					touchX=0;
					touchY=0;
				}
			break;
		case 2:
			//return to GLDelegate to load the main game
			glDisable(GL_BLEND);
			return 1;
			break;
	}
	return 0;
}
	

// Main render loop for our game
-(void) render
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);  
	
	glLoadIdentity();
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE_MINUS_SRC_ALPHA,GL_ONE_MINUS_DST_ALPHA);
	//draw the background. This could be a splash screen or the actual background
	[m_tex[curTex] bind];
	glColor4ub(255,255,255,alpha);
	DrawQuad(0,0,backdropUVs,s_aSquareVertices);
	
	if(splash_state==1)  //if we are in state 1, then we are past all the fadein crap and shold draw the menu
	{
		//draw the buttons rotating them depending on accelerometer angle
		glPushMatrix();
		glTranslatef((float)START_BUTTON_X+91,(float)START_BUTTON_Y+96,0);
		glRotatef(rot,0,0,1);
		[m_tex[3] bind];
		DrawQuad(0,0,fullUVs,startButtonVertices);
		glPopMatrix();
		
		glPushMatrix();
		glTranslatef(75+64, 350+64, 0);
		glRotatef(rot,0,0,1);
		[m_tex[4] bind];
		DrawQuad(0,0,fullUVs,optionButtonVertices);
		glPopMatrix();
		
		glPushMatrix();
		glTranslatef(180+64, 220+64,0);
		glRotatef(rot,0,0,1);
		[m_tex[5] bind];
		DrawQuad(0,0,fullUVs,optionButtonVertices);
		glPopMatrix();
		
	}
	glBlendFunc(GL_ONE_MINUS_SRC_ALPHA,GL_ONE_MINUS_DST_ALPHA);
	// deactivate vertex arrays after drawing
	glDisableClientState(GL_VERTEX_ARRAY);	
}



//Load up all of the game assets
-(void) setUpGame
{
	m_tex[0] = [[GLTexture alloc] initWithFile:@"UPEIVGPSSplash.png"];
	m_tex[1] = [[GLTexture alloc] initWithFile:@"HCplash.png"];
	m_tex[2] = [[GLTexture alloc] initWithFile:@"backdrop.png"];
	m_tex[3] = [[GLTexture alloc] initWithFile:@"startButton.png"];
	m_tex[4] = [[GLTexture alloc] initWithFile:@"optionButton.png"];
	m_tex[5] = [[GLTexture alloc] initWithFile:@"dontClickButton.png"];

	
//	load the sounds with the shared sound manager
	[[soundManager sharedSoundManager] loadMusic:@"bananaphone.mp3"];
	[[soundManager sharedSoundManager] playOrPauseMusic];

	//set the game states
	bool_fadeIn=0;  //fadeing in not out
	alpha=255;		//set alpha to max
	curTex=0;		//start by drawing the first texture
	rot=0;			//rotation angle
	
	//init the accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kUpdateFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	calibrationOffset = 0.0;
	firstCalibrationReading = kNoReadingValue;

	[self initScreen];  //initScreen sets up projection 
}

//reshape function
//nothing interesting here
-(void) initScreen
{
	glClearColor(0.0,0.5,0.5,1.0);
	glViewport(0,0,320,480);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(	0, 320,  	480,  	0,  	1,  	-1);
	glMatrixMode(GL_MODELVIEW);	
	glEnable(GL_TEXTURE_2D);
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view
{
	//start fading out
	bool_fadeIn=1;
	
	// We only support single touches, so anyObject retrieves just that touch from touches
	//get the X and Y values from it
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:view];
	touchX=touchPoint.x;
	touchY=touchPoint.y;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view{}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{}

//Get an angle from the accelerometer
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    // Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
    accelerationX = acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
    accelerationY = acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
    
    // keep the raw reading, to use during calibrations
	//flip the accelerationX so we are always facing down
    currentRawReading = atan2(accelerationY, -accelerationX);
    rot= [self calibratedAngleFromAngle:currentRawReading];
}


- (float)calibratedAngleFromAngle:(float)rawAngle {
    float cAngle =( (calibrationOffset + rawAngle) * 180 / PI)+90.0;  //add 90 to account for landscape
    return cAngle;
}


-(void) dealloc
{
	[m_tex[0] release];
	[m_tex[1] release];
	[m_tex[2] release];
	[m_tex[3] release];
	[m_tex[4] release];
	[m_tex[5] release];
	[parentView release];	
	[super dealloc];
}
@end
