//-----------------------------------------------------------------------------
// File:	Gameover.m
// Author:	Andrew Reddin
//
// Loads a gameover screen. Doesnt really do anything different then splash so it isnt really needed.
//-----------------------------------------------------------------------------
#import "gameover.h"
#define NUMTEX 2



void DrawQuad(float x, float y, float* uvs, float* verticies);
//Set of verticies the size of the screen
static GLfloat s_aSquareVertices[] = {
0, 0,0,
320,  0,0,
0,   480,0,
320,  480,0
};

// UVs for the images vertical on a 512*512 picture
// cryptic numbers come from WIDTH/512 and HEIGHT/512 
static GLfloat backdropUVs[] = {
0, 0,
0.625, 0,
0, 0.9375,
0.625, 0.9375
};

@implementation gameOver

// Constructor
-(id) init;
{
	if( !(self = [super init]) )
		return nil;
	NSLog(@"CREATING SPLASH");
	return self;
}

// Main process loop for our game
-(int) process
{
	//Splash state holds the state of the game. Depending on the state we handle differnt things.
	//First state is for the splash screens
	switch(splash_state)
	{
		case 0:
			//Fade in then when touched fade out
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
				//Screen was touched so we start fading out
				if(alpha>=255)
				{
					//Screen is totally faded out 
					if(curTex+1 < NUMTEX)
					{
						//Continue doing this til we go thru all the images
						curTex++;
						bool_fadeIn=0;
					}
					else
					{
						//When we have faded all images then go to the next splash state
						alpha=0;
						bool_fadeIn=0;  //reset the touch variable
						curTex++;       //go to the next Texture!
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
			//in case 2 we just terminate the application.
			//It gives a warning on compilation but it will work. terminate is a hidden method
			glDisable(GL_BLEND);
			[[UIApplication sharedApplication] terminate];
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
	//bind the current texture and draw it
	[m_tex[curTex] bind];
	glColor4ub(255,255,255,alpha);
	DrawQuad(0,0,backdropUVs,s_aSquareVertices);
	
	// deactivate vertex arrays after drawing
	glDisableClientState(GL_VERTEX_ARRAY);	
}



//initial game setup
-(void) setUpGame
{
	//Create our two textures
	m_tex[0] = [[GLTexture alloc] initWithFile:@"gameOver.png"];
	m_tex[1] = [[GLTexture alloc] initWithFile:@"xcode.png"];
	
	//tell the sound manager to load up the music and play it
	[[soundManager sharedSoundManager] loadMusic:@"flea.mp3"];
	[[soundManager sharedSoundManager] playOrPauseMusic];
		
	//setup variables for fading
	bool_fadeIn=0;
	alpha=255;
	curTex=0;
		
	//set up the GL screen
	[self initScreen];  //initScreen sets up projection and shit like that
}

//reshape function
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
	bool_fadeIn=1; //tell the game to fade out!
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view{}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{}
-(void) dealloc
{
	//deallocate
	[m_tex[0] release];
	[m_tex[1] release];

	[super dealloc];
}
@end
