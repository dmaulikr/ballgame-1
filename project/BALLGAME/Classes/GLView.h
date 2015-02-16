//-----------------------------------------------------------------------------
// File:	GLView.h
// Author:	Gordon Wood modified by andrew reddin
//
// Class used to create a view that can be used for OpenGL rendering. Also
// defines a protocol that must be adhered to for delegates of this class.
// The class will call its delegate to allow you to do custom drawing (which
// will, of course, always be needed)

//Modified to allow swapping of delegates after launch
//DrawView is slightly different and there is a new method to swap delegates
//-----------------------------------------------------------------------------
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>

// Conform to this protocol to have the view call your drawing routine
// Added methods for Touches. 
//We sent the entire touch event because then we can extract what we want from it ourselves. Keeps it more general
@protocol GLViewDelegate
-(int) process;
-(void) render;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event fromView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

// GLView class, extends UIView but allows for OpenGL rendering
@interface GLView : UIView <UIAccelerometerDelegate>
{
	EAGLContext*	m_context;
	GLuint			m_viewRenderbuffer;
	GLuint			m_viewFramebuffer;
	GLuint			m_depthRenderbuffer;
	GLint			m_backingWidth;
    GLint			m_backingHeight;
	NSTimer*		m_timer;
	id				m_delegate;
	float           p_fps;
	CGRect			p_rect;
	int currentLevel;		//Level is misleading it is actually what delegate we have loaded. 
							//level swapping happens inside of game.m
	struct gameParam options;
}

-(id) initWithFrame:(CGRect)aRect fps:(float)p_fps;
-(void) setDelegate:(id)del;
-(void) createDelegate;
-(void)setUpView;

@end
