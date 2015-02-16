//-----------------------------------------------------------------------------
// File:	Game.m
// Author:	Andrew Reddin
//
// The main game
//-----------------------------------------------------------------------------
#import "Game.h"


static GLfloat s_aSquareVertices[] = {
0, 0,0,
320,  0,0,
0,   480,0,
320,  480,0
};

static GLfloat s_aButtonVertices[] = {
0, 0,0,
60,  0,0,
0, 120,0,
60,  120,0
};

// UVs for the backdrop and Alpha map
// cryptic numbers come from squareWidth/512 and squareHeight/512 
GLfloat ballUVs[] = {
0, 0,
1, 0,
0, 1,
1,1
};

//defines for the accelerometer and PI
#define wsquareWidth 320
#define wsquareHeight 480
#define PI 3.14152 
#define kTransitionDuration	0.75
#define kUpdateFrequency 50  // Hz
#define kFilteringFactor 0.05
#define kNoReadingValue 999

#define USE_DEPTH_BUFFER 0
#define PI 3.14152 

//variables to move the background
GLfloat UVvarX=1; 
GLfloat UVvarY=1; 

//A bunch of global variables. 
//this is carryover from the original linux version of the game. the vars will be moved somewhere more appropriate come summer but right now they stay
int collision=0; //boolean for collision
BOOL SCALE=false;
int collisionLastFrame=0;
int bounceX=50;
int bounceY=50;
int bounceMaxX=50;
int bounceMaxY=50;

float angle=0;
float gravAngle=0;
float gravSpeed=0.5; //angle and vertical angletime_t timer;
float X=-20.0;
float Y=10.0;
float speedX=1.0;
float speedY=1.0;
float max_speed=4.0;

GLfloat *ballVertexArray;
@implementation Game


//file init function
-(id) initWithFile:(NSString*)fileName parentView:(UIView*)m_view options:(struct gameParam)in_options
{
	if(self= [super init])
	{
		frameCounter=0;
		running=true;
		
		//Create the navigation bar
		navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,320,60)];
		navBar.barStyle=UIBarStyleBlackOpaque;
		//create the navigationbar item and add the buttons to it
		barLabel = [[UINavigationItem alloc] initWithTitle:@"TIME LIMIT"];
		//Set the action to pausepressed
		barButton = [[UIBarButtonItem alloc] initWithTitle:@"Pause" style:UIBarButtonItemStylePlain target:self action:@selector(pausePressed:)];
		barLabel.rightBarButtonItem=barButton;
		[barButton release];
		
		//set the action to options pressed
		barButton=[[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(optionsPressed:)];
		barLabel.leftBarButtonItem=barButton;
		[barButton release];

		//we need to pass an array to the navbar so put the navitem in an array of 1
		array=[NSArray arrayWithObject:barLabel];
		navBar.items=array;
		
		//retain the pointer to the parent. This is for making the option menu come up
		m_ParentView=m_view;
		[m_ParentView retain];
		
		[m_ParentView addSubview:navBar];
		
		// read the data from the plist
		NSString* plistPath = [[NSBundle mainBundle]  pathForResource:@"levels" ofType:@"plist"];
		NSArray *plistArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
		
		//send the plist data to our level holder
		gameLevel = [[level alloc] initWithArray:plistArray];
		[plistArray release];
		
		//get some values from the shared option menu
		max_speed=[[optionMenu sharedOptionMenu] getMaxGrav];
		timeLimit=[[optionMenu sharedOptionMenu] getTimeLimit];
		return self;
	}
	else
		return nil;
}

//pause button pressed, pause game
-(void)pausePressed:(id)sender
{
	
	if(running)
	{
		running=NO;
		barLabel.rightBarButtonItem.title=@"Unpause";
	}
	else
	{
		running=YES;
		barLabel.rightBarButtonItem.title=@"Pause";
	}
}

//open up the options menu
-(void)optionsPressed:(id)sender
{
	[self pausePressed:self];
	//tell the shared option menu to show itself. 
	//we just give it a pointer to the GLView and it will handle opening and closing automatically
	[[optionMenu sharedOptionMenu] showWithParentView:m_ParentView];	
}

// Main process loop for our game
//This is where collision, physics, and some control handling happens
//Note that I return a value to GLView when process completes. This is for swapping out delegates
-(int) process
{
	//Value to return to GLView
	int retVal=0;
	
	//If we are not paused
	if (running)
	{
		//update the maximum possible speed from the shared option menu
		max_speed=[[optionMenu sharedOptionMenu] getMaxGrav];
		//Update the time limit: decrement every 30 frames;
		frameCounter++;
		if(frameCounter==30)
		{
			timeLimit--;
			frameCounter=0;
		}
		if(timeLimit>0)
		{
			//If we are not out of time 
			//If we are in ARROW controls, check the "buttons" to make sure we arent pressing them
			if([[optionMenu sharedOptionMenu] getControlStyle]==1)
			{
				if(touchY>240)
				{
					if(touchY<=360)
					{
						if(touchX<=60)
						{
							//NSLog(@"LEFT BUTTON PRESSED");
							gravAngle+=5;
						}
						else if(touchX >=260)
						{
							//NSLog(@"Right button pressed");
							gravAngle-=5;
						}
					}
				}
			}
	

	//Start by extracting X and Y components from the gravity angle and add them to the balls speed
	float gravCompX = (gravSpeed)*cos((PI/180)*(gravAngle));   //X component of ball movement
	float gravCompY = (gravSpeed)*sin((PI/180)*(gravAngle));   //X component of ball movement
	speedX+=gravCompX;
	speedY+=gravCompY;
	int collisionCompX; //X Component of the collision 
	int collisionCompY; // Y component of the collision
	
	//Make sure we are not going above the maximum speed. 
	if(speedX >max_speed)
	{
		speedX=max_speed;
	}
	else if(speedX <-max_speed)
	{
		speedX=-max_speed;
	}
	
	if(speedY>max_speed)
	{
		speedY=max_speed;
	}
	else if(speedY < -max_speed)
	{
		speedY=-max_speed;
	}
	
	
	float tempX=X+speedX; //X + X movement component
	float tempY=Y+speedY; //Y + y movement component... just for convienience

	int Yok=1; //no problems with Y
	int Xok=1; //no problems with X
	
	//reset global collision variable
	collision=0;
	
	for(int i=0;i<gameLevel.NUMSQUARESPERROW*gameLevel.NUMCOLUMN+1;i++)
	{		
		//First do a quick bounds check on each tile to see if the tile square and ball square overlap
		gameLevel.grid[i].collided=0;
		switch(gameLevel.grid[i].type)
		{
			case 3:
			case 4:
				if(tempX < gameLevel.grid[i].x+gameLevel.squareWidth)
				{
					if(tempX+gameLevel.ballRadius/2 > gameLevel.grid[i].x)
					{
						if(tempY < gameLevel.grid[i].y+gameLevel.squareHeight)
						{
							if(tempY+gameLevel.ballRadius/2 > gameLevel.grid[i].y)
							{
							
								//********
								//if we get here we have a collision so we should find the components of the square overlap
								//*******
								//play sound effect 
								[[soundManager sharedSoundManager] playSound];
								//set collision flag
								collision=1;       

								//If we collided with a goal square then tell level manager load up the next level.
								//This will eventually be animated but right now it happens instantly.
								if(gameLevel.grid[i].type==3)
								{
									glClearColor(1.0,0.5,0.2,1.0);
									retVal=[gameLevel nextLevel];
									printf("retval %d \n",retVal);
									X=gameLevel.grid[(gameLevel.NUMSQUARESPERROW*2)+3].x;
									Y=gameLevel.grid[(gameLevel.NUMSQUARESPERROW*2)+3].y;
								}
								else //if we collided with a regular square
								{
									//find out how far we have penetrated the square.
									collisionCompX=(gameLevel.grid[i].x+(gameLevel.squareWidth/2))- tempX;
									collisionCompY=(gameLevel.grid[i].y+(gameLevel.squareHeight/2))- tempY;
									
									//ABS doesnt seem to work so I just created this quick method to get absolute values
									//first speed vars
									float tempSpeedX=speedX;
									float tempSpeedY=speedY;
									if(tempSpeedX<0)
										tempSpeedX=-tempSpeedX;
									if(tempSpeedY<0)
										tempSpeedY=-tempSpeedY;
									
									//then collision components
									if(collisionCompX<0)
										collisionCompX=-collisionCompX;
									if(collisionCompY<0)
										collisionCompY=-collisionCompY;
									
									//Depending on what collision component is bigger we want to handle the "bounce in different ways"
									if((collisionCompX + tempSpeedX) > (collisionCompY + tempSpeedY))
									{
										//X component is bigger so we adjust the speed of X;
										//first off move the ball out of the square. We determine the side to move to by the direction of the speed
										if(speedX<0)
										{
											//nsLog(@"collision going right %f %f",collisionCompX, (gameLevel.grid[i].x+(gameLevel.squareWidth/2))- collisionCompX);
											X=gameLevel.grid[i].x+gameLevel.squareWidth+1;//+gameLevel.ballRadius;
											Xok=0;
										}
										else
										{
											//nsLog(@"collision going left");
											X=gameLevel.grid[i].x-gameLevel.ballRadius;
											Xok=0;
										}
										//in order to bounce we actually need to Crank up the speed instead of lower it. This is because gravity works on the ball seperately from its momentum.
										//This also means that if we want to make the ball stop bouncing we have to modify the gravity variable, not the ball variable!that will be a task for summer though
										speedX=-(speedX*2);

									}
									else if((collisionCompX + tempSpeedX) < (collisionCompY + tempSpeedY))
									{
										//Y component is bigger so move the ball out of the square in the Y direction then adjust the Y speed accordingly
										if(speedY<0)
										{
											Y=gameLevel.grid[i].y+gameLevel.squareHeight+1;//+gameLevel.ballRadius;
											Yok=0;
										}
										else
										{
											Y=gameLevel.grid[i].y-gameLevel.ballRadius;
											Yok=0;
										}
										//Add to speed to stop because of gravity
										speedY=-(speedY*2);//(-40)*gravCompY;
									}
									else
									{
										speedY=0;
										speedX=0;
									}
			
									//Update X and Y variables
									X+=speedX;
									Y+=speedY;
									
								}
							}// bounds checking
						}//bounds checking
					}//bounds checking
				}//bounds checking
		}//switch statement
	//if we have found a collision then we dont have to process any more of them this frame.
	if(collision)break;}
	
	//If we didnt find a collision then update the X and Y anyways
	if(!collision)
	{
		X+=speedX;
		Y+=speedY;
	}
	}
	else
	{
		//timelimit ran out
		//go to gameover
		retVal=1;
	}
	}
	return retVal;
}

// Main render loop for our game
-(void) render
{
	//If we are not paused. 
	if(running)
	{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT); 
		
	//Set the Navigation bar to display the time
	//I know its slow to use Cocoa touch, but time was of an essence.
	barLabel.title=[NSString stringWithFormat:@"Time: %d",timeLimit];
	glLoadIdentity();
	//Set the color to Opaque white
	glColor4ub(255,255,255,255);
		
	//Draw the background.
	GLfloat backdropUVs[] = {
		UVvarX, UVvarY,
		UVvarX+1, UVvarY,
		UVvarX, UVvarY+1,
		UVvarX+1,UVvarY+1
	};
	//Bind the background texture and then set it to repeat
	[gameLevel setTexture:9];
	[gameLevel setTextureMode:9 mode:GL_REPEAT];
	DrawQuad(0,0,backdropUVs,s_aSquareVertices);

	//Create UV's for the background
	UVvarX=X/10000;
	UVvarY=Y/10000;

	//FOR loop to draw the squares.
	//Yes, I know this is horribly inneficient. 
	//Im going to change this program to load in a huge array of verticies and draw it once instead of creating verticies per vertex.
	//Im also going to sort the tiles in order of texture so that I reduce the amount of texture bind calls to a maximum of MAX_TEXTURE
	//From what i have read, binding a new texture is really slow, so this should give a decent preformance increase
//	for(int i=0;i<gameLevel.NUMCOLUMN * gameLevel.NUMSQUARESPERROW;i++)
	{
		// activate and specify pointer to vertex array
		glEnableClientState(GL_VERTEX_ARRAY);

		//If this is a 0 tile we dont check collision or draw it
	//	if(gameLevel.grid[i].type!=0)
	//	{
			glPushMatrix();
			
			//Translate to the middle of the screen
			glTranslatef(160,240,0);
			if(!SCALE)
			{
				//If we arent in TILT mode, we want to rotate the screen when we draw.
				//Notice that we rotate AFTER translation. This is because we want to rotate around the ball not the origin
				if([[optionMenu sharedOptionMenu] getControlStyle]!=0)
				{
					glRotatef((90-gravAngle),0.0,0.0,1.0);  //rotate with a and d keys
				}
				//translate from 160,240 to ball coord
				glTranslatef(-X,-Y,0);	
			}
			
			//If this is a GOAL block, draw slightly darker then usual
		//	if(gameLevel.grid[i].type==3)
		//	{
		//		glColor4ub(105,105,105,255);
		//	}

			//bind the texture of the brick. 
			//this should be changed since we rarely need any texture but the brick texture. 
			//As I said above the less we bind the faster we go!
			[gameLevel setTexture:8];
			
			//Also as stated above, this should just be one huge array instead of a million one square arrays.
			//This is an optimization that will happen shortly after school finishes.... time is short!!!
			//GLfloat vertices1[] = {(gameLevel.grid[i].x),(gameLevel.grid[i].y),0,
			//						(gameLevel.grid[i].x+gameLevel.squareWidth),(gameLevel.grid[i].y),0, 	
			//						(gameLevel.grid[i].x),(gameLevel.grid[i].y+gameLevel.squareHeight),0,
			//						(gameLevel.grid[i].x+gameLevel.squareWidth),(gameLevel.grid[i].y+gameLevel.squareHeight),0};     
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glTexCoordPointer(2, GL_FLOAT, 0, ballUVs);
			
			// Then draw it.
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(3, GL_FLOAT, 0, ballVertexArray);
			
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 32*4);
			//Finally, draw the brick. This is an inline function for a slight speed increase. 
			//DrawQuad(0,0,ballUVs,vertices1);
			glPopMatrix();
			
			//If we changed the color for a goal brick, then change it back after. This is to prevent having to do it for every block.
			//if(gameLevel.grid[i].type==3)
			//{
			//	glColor4ub(255,255,255,255);
			//}
		
	}
		

	//I think this is old linux code that isnt needed anymore
	if(SCALE)
	{
		glTranslatef(X+160,Y+240,0);	
	}
	
	//Translate to the middle of the screen to draw the ball
	glTranslatef(160+gameLevel.ballRadius/2,240+gameLevel.ballRadius/2,0);
	
	//Create vertex for the ball depending on its radius.
	//An easy optimization would be to create these once instead of every time
	glColor4ub(255,255,0,255);
	GLfloat ballVertex[]= {-gameLevel.ballRadius/2,-gameLevel.ballRadius/2,0,
							gameLevel.ballRadius/2,-gameLevel.ballRadius/2,0,
							-gameLevel.ballRadius/2,gameLevel.ballRadius/2,0,
							gameLevel.ballRadius/2,gameLevel.ballRadius/2.5,0};

		
		//Load the ball texture	
		[gameLevel setTexture:8];
		
		//Turn on alpha testing to erase crap around ball
		glEnable(GL_ALPHA_TEST);
			glAlphaFunc(GL_EQUAL,1);
			glColor4ub(255,255,255,255);
			DrawQuad(0,0,ballUVs,ballVertex);
		glDisable(GL_ALPHA_TEST);
		
		//Draw the touch indicators on screen
		if([[optionMenu sharedOptionMenu] getControlStyle]==2)
		{
			//if we are in CIRCLE mode and are touching the screen, draw a transparent square ot acknoledge this
			if(screenTouched)
			{
				glEnable(GL_BLEND);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				glColor4ub(200,100,100,100);
				glPushMatrix();
				[gameLevel setTexture:5];
				float fX = (125)*cos((PI/180)*(gravAngle+180));   //X component of ball movement
				float fY = (125)*sin((PI/180)*(gravAngle+180));   //X component of ball movement
				//glScalef(0.5, 0.5, 0.5);
				DrawQuad(fX,fY,ballUVs,ballVertex);
				glPopMatrix();
				glDisable(GL_BLEND);
			}
		}
		else if([[optionMenu sharedOptionMenu] getControlStyle]==1)
		{
			//if we are in ARROW mode, draw the buttons on the screen
			glEnable(GL_BLEND);
			glPushMatrix();
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			glLoadIdentity();
			[gameLevel setTexture:5];
			glColor4ub(200,100,100,100);
			DrawQuad(0,240,ballUVs,s_aButtonVertices);
			glLoadIdentity();
			DrawQuad(260,240,ballUVs,s_aButtonVertices);
			glPopMatrix();
			glDisable(GL_BLEND);
		}
		
	glDisable(GL_BLEND);
	glFlush();
	// deactivate vertex arrays after drawing
	glDisableClientState(GL_VERTEX_ARRAY);	
	}
}

// Utility function to easily draw a quad with a given set of UVs
//Modified to pass verticies as well. 
inline void DrawQuad(float x, float y, float* uvs, float* verticies)
{
	glPushMatrix();
	{
		// Translate the local space of this quad
		glTranslatef(x, y, 0);
		
		// Give it some texture coords
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, uvs);
		
		// Then draw it.
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, verticies);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	glPopMatrix();
}


-(void) setUpGame
{
	numTiles=0;
	//Set the X and Y Variables for the ball
	X=gameLevel.grid[(gameLevel.NUMSQUARESPERROW*2)+3].x;
	Y=gameLevel.grid[(gameLevel.NUMSQUARESPERROW*2)+3].y;
	
	ballVertexArray = malloc(sizeof(struct square)*gameLevel.NUMCOLUMN*gameLevel.NUMSQUARESPERROW*4*3);
	int p=0;
	for(int i=0;i<gameLevel.NUMCOLUMN * gameLevel.NUMSQUARESPERROW;i++)
	{
		if(gameLevel.grid[i].type!=0)
		{
		ballVertexArray[(p*12)]=(gameLevel.grid[i].x);
		ballVertexArray[(p*12)+1]=(gameLevel.grid[i].y);
		ballVertexArray[(p*12)+2]=0;
		ballVertexArray[(p*12)+3]=(gameLevel.grid[i].x+gameLevel.squareWidth);
		ballVertexArray[(p*12)+4]=(gameLevel.grid[i].y);
		ballVertexArray[(p*12)+5]=0; 	
		ballVertexArray[(p*12)+6]=(gameLevel.grid[i].x);
		ballVertexArray[(p*12)+7]=(gameLevel.grid[i].y+gameLevel.squareHeight);
		ballVertexArray[(p*12)+8]=0;
		ballVertexArray[(p*12)+9]=(gameLevel.grid[i].x+gameLevel.squareWidth);
		ballVertexArray[(p*12)+10]=(gameLevel.grid[i].y+gameLevel.squareHeight);
		ballVertexArray[(p*12)+11]=0;  
		
		printf("BALLVertexArray[%d]:\n\
			   %f,%f,%f\n\
			   %f,%f,%f\n\
			   %f,%f,%f\n\
			   %f,%f,%f\n",
			   p,(float)ballVertexArray[(i*12)],ballVertexArray[(i*12)+1],ballVertexArray[(i*12)+2],
		ballVertexArray[(i*12)+3],ballVertexArray[(i*12)+4],ballVertexArray[(i*12)+5],
		ballVertexArray[(i*12)+6],ballVertexArray[(i*12)+7],ballVertexArray[(i*12)+8],
		ballVertexArray[(i*12)+9],ballVertexArray[(i*12)+10],ballVertexArray[(i*12)+11]);
		
			numTiles++;
			p++;
		}
	}
	printf("numTiles %d  p:%d  malloc count %d",numTiles,p,gameLevel.NUMCOLUMN*gameLevel.NUMSQUARESPERROW*4*3);
	[self initScreen];  //initScreen sets up projection
}

//reshape function
-(void) initScreen
{
	//tell the sound manager to load up some sounds
	[[soundManager sharedSoundManager] loadMusic:@"party_boy.mp3"];
	[[soundManager sharedSoundManager] loadSound:@"hey.wav"];
	[[soundManager sharedSoundManager] playOrPauseMusic];
 
	//Setup the shared accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kUpdateFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	calibrationOffset = 0.0;
	firstCalibrationReading = kNoReadingValue;
	
	glClearColor(0.0,0.5,0.5,1.0);
	glViewport(0,0,320,480);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(	0, 320,  	480,  	0,  	1,  	-1);
	
	
	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_TEXTURE_2D);	
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    // Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
	//accelX and Y are UIAccellerometerValues that should be in your H file
    accelerationX = acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
    accelerationY = acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
    
    // keep the raw reading, to use during calibrations
	//I reverse the X axis in order to make it seem like gravity, you might not want this
    currentRawReading = atan2(accelerationY, -accelerationX);
	//Only change grav angle if we are in TILT controls!!!!
	if([[optionMenu sharedOptionMenu] getControlStyle]==0)
	{
		gravAngle= [self calibratedAngleFromAngle:currentRawReading];
	}
}


- (float)calibratedAngleFromAngle:(float)rawAngle {
	//Angle is received in Radians so convert to degrees (A*180/PI)
    float cAngle =( (calibrationOffset + rawAngle) * 180 / PI)+180; 
    return cAngle;
}


-(void) dealloc
{
	[navBar removeFromSuperview];
	[navBar release];
	[barLabel release];
	[gameLevel release];
	[m_ParentView release];
	[super dealloc];
}



//TOUCH METHODS
//I just send the entire reference view over to the delegate. I did it this way instead of just sending X and Y like your examples
//because this way I can extract any info I want out of the touches. For example tap count or multi touch. 
//It also comes in handy if I wanted to interact with other cocoa views;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view
{
	[self touchesMoved:touches withEvent:event fromView:view];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view
{
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:view];
	touchX=touchPoint.x;
	touchY=touchPoint.y;
	screenTouched=true;
	
	//This is where the handling for CIRCLE controls happens
	//These will eventually be in a function pointer to the controls and will be called using a callback.
	if([[optionMenu sharedOptionMenu] getControlStyle]==2)
	{
	//make a right angled triangle using the middle of the screen and the point of touch 
	//then extract the angle
	float tempX = (160 - touchX);
	float tempY = (240 - touchY);
	float angle = atan(tempY/-tempX) * 180 / 3.14159265;
	
	//adjust for negative numbers and such
	if(tempX <0 && tempY>0)
	{
		gravAngle=-angle;
	}
	else if(tempX >0 && tempY >0)
	{
		gravAngle=180-angle;
	}
	else if(tempX <0 && tempY <0)
	{
		gravAngle=360-angle;
	}
	else if(tempX>=0 && tempY <=0)
	{
		gravAngle=180-angle;
	}
	gravAngle+=180;
	if(gravAngle>360)
	{
		gravAngle = gravAngle - 360;
	}
	}
}
//get touches off the screen and tell the screen we arent touching it anymore
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{touchX=touchY=-1; screenTouched=false;}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{}


@end
