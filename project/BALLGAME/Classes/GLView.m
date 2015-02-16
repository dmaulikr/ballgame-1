//-----------------------------------------------------------------------------
// File:	GLView.m
// Author:	Gordon Wood
//
// Class used to create a view that can be used for OpenGL rendering. Also
// defines a protocol that must be adhered to for delegates of this class.
// The class will call its delegate to allow you to do custom drawing (which
// will, of course, always be needed)
//-----------------------------------------------------------------------------
#import "GLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/glext.h>
#import "Game.h"
#import "splash.h"
#import "gameover.h"

// Defines a private interface. We don't expose these methods to the outside world
// as they should never need to be called except internally
@interface GLView (PrivateAPI)
-(BOOL) createFramebuffer;
-(void) destroyFramebuffer;
-(void) drawView;
@end

// Define the class's methods
@implementation GLView

// Constructor taking in rectange to paint into and the frames per second to run the loop at
-(id) initWithFrame:(CGRect)rect fps:(float)fps
{
	if( !(self = [super initWithFrame:rect]) )
		return nil;
	p_rect=rect;
	p_fps = fps;
	[self setUpView];
	currentLevel=0;
	[self createDelegate];
    return self;
}

-(void)setUpView
{
		
	//Set up default options for game.
	options.timeLimit=60;
	options.maxGravity=6.0;
	options.soundEnabled=YES;
	options.controlScheme=0;
	
	m_delegate			= nil;
	m_viewFramebuffer	= 0;
	m_viewRenderbuffer	= 0;
	m_depthRenderbuffer	= 0;
	
	// Get our Core Animation layer
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	// Make sure it's opaque to get full performance
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, 
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, 
									nil];
    
    // Create the EAGLContext
	m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if( !m_context || ![EAGLContext setCurrentContext:m_context] ) 
	{
		// initWithFrame succeeded, so we have been allocated. Make sure we release
		[self release];
		return;
	}
	// Create a timer that will drive our main loop
	//m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/p_fps target:self selector:@selector(drawView) userInfo:nil repeats:YES];
	
}

-(id) initWithFrame:(CGRect)rect
{
    return [self initWithFrame:(CGRect)rect fps:(float)30.0f];
}


// We must override this to make our view return an OpenGL-compatible layer.
+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

// Called whenever the views need to be re-organised. Called when the view is first created
- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:m_context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

// creates the frame buffers needed, including the frame buffer object, the view buffer (back bufer), 
// and the depth buffer. The frame buffer object is a combination of both these buffers
- (BOOL)createFramebuffer 
{
    glGenFramebuffersOES(1, &m_viewFramebuffer);
    glGenRenderbuffersOES(1, &m_viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_viewRenderbuffer);
    [m_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, m_viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &m_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &m_backingHeight);
    
	glGenRenderbuffersOES(1, &m_depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, m_backingWidth, m_backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, m_depthRenderbuffer);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
	{
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

// Destroys our frame buffer (and its attachments)
- (void)destroyFramebuffer 
{
    if( m_viewFramebuffer )
	{
		glDeleteFramebuffersOES(1, &m_viewFramebuffer);
		m_viewFramebuffer = 0;
	}
	
	if( m_viewRenderbuffer )
    {
		glDeleteRenderbuffersOES(1, &m_viewRenderbuffer);
		m_viewRenderbuffer = 0;
	}
	
	if( m_depthRenderbuffer )
	{
		glDeleteRenderbuffersOES(1, &m_depthRenderbuffer);
		m_depthRenderbuffer = 0;
	}
}

// Called every time the view needs to be redrawn - and also whenever the timer fires
- (void)drawView 
{
    // Make sure our EAGL context is current
    [EAGLContext setCurrentContext:m_context];
    
	// Bind our frame buffer objects
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_viewFramebuffer);
	
	// Make sure our viewport represents the whole screen
    glViewport(0, 0, m_backingWidth, m_backingHeight);
    
	
	// Call our delegate's process and render method.
	//Check if everything is ok
	if([m_delegate process]==0)
		
	{
		[m_delegate render];
	}
	else
	{
		//if we return something that isnt one, we know its time to change the delegate
		[m_timer invalidate];
		currentLevel++;
		[m_delegate release];
		[self createDelegate];
	}
    
	// Make sure the render buffer is bound, before presenting it
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_viewRenderbuffer);
    [m_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

// Destructor
- (void)dealloc 
{
	// Remove the timer from the run loop
	[m_timer invalidate];
    
	// Before we delete the context, make sure we remove it from being the current context
    if ([EAGLContext currentContext] == m_context) 
	{
        [EAGLContext setCurrentContext:nil];
    }
    
	// Now we can delete it
    [m_context release];  
	
	// Always call the parent's destructor!
    [super dealloc];
}

-(void) setDelegate:(id)p_del
{
	m_delegate = p_del;
}

-(void) printExists
{
	NSLog(@"I exist");
}

//Function to load a different delegate
//Right now it just loads Splash, game, and then gameover in sequential order.
-(void) createDelegate
{
	NSLog(@"GLView: current level: %d",currentLevel);
	//since the previous delegate, game, used the accelerometer, game is the delegate for th accelerometer.
	//the problem is that game doesnt exist anymore so we will get an exception if UIAccelerometer attempts to access it
	//so just set the new delegate as GLView and dont implement the optional protocol methods
	[UIAccelerometer sharedAccelerometer].delegate=self;
	if(currentLevel==0)
	{
		m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/p_fps target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		m_delegate = [[splash alloc] initWithParent:self];
		[m_delegate setUpGame];					
	}
	else if(currentLevel==1)
	{
		printf("GLVIEW Options BEFORE GAME: \n timeLimit: %d \n gravity: %f \n soundEnabled: %d \n controlStyle: %d\n",
			   options.timeLimit,options.maxGravity,options.soundEnabled,options.controlScheme);
		glClear(GL_COLOR_BUFFER_BIT);
		m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/p_fps target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		m_delegate = [[Game alloc] initWithFile:@"levels.plist" parentView:self options:options];
		[m_delegate setUpGame];			
	}
	else
	{
		m_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/p_fps target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		m_delegate = [[gameOver alloc] init];
		[m_delegate setUpGame];						
	}
}

//Send the touches in their entirety to the delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{		[m_delegate touchesBegan:touches withEvent:event fromView:self];}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{		[m_delegate touchesMoved:touches withEvent:event fromView:self];}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{		[m_delegate touchesEnded:touches withEvent:event];}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{	[m_delegate touchesCancelled:touches withEvent:event];}



@end
