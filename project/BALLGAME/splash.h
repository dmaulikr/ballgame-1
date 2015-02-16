//-----------------------------------------------------------------------------
// File:	splash.h
// Author:	Andrew Reddin
//
// Splash screen delegate
//-----------------------------------------------------------------------------
#import "GLView.h"
#import "GLTexture.h"
#import <QuartzCore/QuartzCore.h>
#import "optionMenu.h"
#import "soundManager.h"

@interface splash : NSObject <GLViewDelegate, UIAccelerometerDelegate>
{
	GLTexture *m_tex[6];
	
	float rot;
	float touchX,touchY;
	unsigned char alpha;
	int splash_state;
	int bool_fadeIn;
	int curTex;
	
	// accelerometer support
    float firstCalibrationReading;
    float currentRawReading;
    float calibrationOffset;
	UIAccelerationValue accelerationX;
    UIAccelerationValue accelerationY;
	float calibratedAngle;
	
	//We keep a copy of the parent view because we want to access the option menu
	UIView* parentView;

	
}
-(id) initWithParent:(UIView*)parent;
-(void) render;
-(int) process;
void DrawQuad(float x, float y, float* uvs, float* verticies);
-(void) initScreen;
-(void) setUpGame;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
- (float)calibratedAngleFromAngle:(float)rawAngle;

@end
