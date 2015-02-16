//-----------------------------------------------------------------------------
// File:	GameOver.h
// Author:	Andrew Reddin
//
//A delegate providing a game over screen 
//Basically the same as splash.m
//-----------------------------------------------------------------------------
#import "GLView.h"
#import "GLTexture.h"
#import <QuartzCore/QuartzCore.h>
#import "optionMenu.h"
#import "soundManager.h"

@interface gameOver : NSObject <GLViewDelegate>
{
	GLTexture *m_tex[2];	
	unsigned char alpha;
	int splash_state;
	int bool_fadeIn;	//boolean that tells us what direction to fade in
	int curTex;
}
-(id) init;
-(void) render;
-(int) process;
void DrawQuad(float x, float y, float* uvs, float* verticies);
-(void) initScreen;
-(void) setUpGame;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end
