//-----------------------------------------------------------------------------
// File:	GLTexture.h
// Author:	Gordon Wood
//
// Simple class to allow easy loading and binding of textures.
//-----------------------------------------------------------------------------
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>

@interface GLTexture : NSObject 
{
	CGImageRef	m_img;
	size_t		m_width;
	size_t		m_height;
	GLuint		m_texName;
}
-(id) initWithFile:(NSString*)p_file;
-(void) bind;
-(void) setWrapMode:(GLenum)p_mode;
-(void) setMinFilterMode:(GLenum)p_mode;
-(void) setMagFilterMode:(GLenum)p_mode;
@end
