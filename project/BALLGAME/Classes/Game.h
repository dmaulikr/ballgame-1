//-----------------------------------------------------------------------------
// File:	Game.h
// Author:	Gordon Wood
//
// Jump-off point for a game
//-----------------------------------------------------------------------------
#import "GLView.h"
#import "GLTexture.h"
#import "level.h"
#import "splash.h"
#import "soundManager.h";


@interface Game : NSObject <GLViewDelegate, UIAccelerometerDelegate>
{

	level *gameLevel;
	float		m_rot;
	float		touchX,touchY;
	
	// calibration support
    float firstCalibrationReading;
    float currentRawReading;
    float calibrationOffset;
	
	UIAccelerationValue accelerationX;
    UIAccelerationValue accelerationY;
	float calibratedAngle;
	
	int numTiles;
	UIView* m_ParentView;
	UINavigationBar* navBar;
	UINavigationItem* barLabel;
	UIBarButtonItem* barButton;
	NSArray* array;
	bool running;
	bool screenTouched;
	
	int frameCounter,timeLimit;
}
//-(id) initWithFile:(NSString*)fileName parentView:(UIView*)m_view;
-(id) initWithFile:(NSString*)fileName parentView:(UIView*)m_view options:(struct gameParam)in_options;

-(void) render;
-(int) process;

void DrawQuad(float x, float y, float* uvs, float* verticies);
-(void) initScreen;
- (float)calibratedAngleFromAngle:(float)rawAngle;
-(void) setUpGame;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
