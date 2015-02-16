//-----------------------------------------------------------------------------
// File:	GLTexture.m
// Author:	Gordon Wood
//
// Simple class to allow easy loading and binding of textures.
// Othen then fixing a memory leak, no changes
//-----------------------------------------------------------------------------
#import "GLTexture.h"

@implementation GLTexture

-(id) initWithFile:(NSString*)path
{
	if( !(self = [super init]) )
		return nil;
	//cant use imagenamed because it caches files and doesnt release them
	//just as easy to use imageWithcontents of file
	m_img = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:nil]] CGImage];

	if( !m_img )
	{
		NSLog(@"Error: Couldn't load texture %@",path);
		[self release];
		return nil;
	}
	
	// Grab the width and height from it
	m_width		= CGImageGetWidth(m_img);
	m_height	= CGImageGetHeight(m_img);
	
	if( m_width != 2 && m_width != 4 && m_width != 8 && m_width != 16 && m_width != 32 &&
		m_width != 64 && m_width != 128 && m_width != 256 && m_width != 512 && m_width != 1024 )
	{
		NSLog(@"Error: Width of texture %@ is invalid",path);
		[self release];
		return nil;
	}
	
	if( m_height != 2 && m_height != 4 && m_height != 8 && m_height != 16 && m_height != 32 &&
	   m_height != 64 && m_height != 128 && m_height != 256 && m_height != 512 && m_height != 1024 )
	{
		NSLog(@"Error: Height of texture %@ is invalid",path);
		[self release];
		return nil;
	}
	
	// Need to load the data into RAM first, so allocate. Assuming RGBA 8888 format
	GLubyte* pBmpData  = (GLubyte *) malloc(m_width * m_height * 4);
	
	// Uses the bitmatp creation function provided by the Core Graphics framework. 
	CGContextRef ctx = CGBitmapContextCreate(pBmpData, m_width, m_height, 8, m_width * 4, CGImageGetColorSpace(m_img), kCGImageAlphaPremultipliedLast);
	
	// After you create the context, you can draw the sprite image to the context.
	CGContextDrawImage(ctx, CGRectMake(0.0f, 0.0f, (CGFloat)m_width, (CGFloat)m_height), m_img);
	
	// Finished with the context, so release it
	CGContextRelease(ctx);
	
	
	// Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, &m_texName);
	
	// Bind the texture name. 
	glBindTexture(GL_TEXTURE_2D, m_texName);
	
	// Specify a 2D texture image, providing the pointer to the image data in memory, and other
	// necessary attributes
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_width, m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pBmpData);
	
	// Set the texture parameters to use a linear filtering for min and mag
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	// OpenGL has it now, we can release our copy
	free(pBmpData);
	
	
	return self;
}

-(void) dealloc
{
	
	glDeleteTextures(1, &m_texName);
//	CGImageRelease(m_img);
	[super dealloc];

}

-(void) bind
{
	glBindTexture(GL_TEXTURE_2D, m_texName);
}

-(void) setWrapMode:(GLenum)p_mode
{
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, p_mode);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, p_mode);
}

-(void) setMinFilterMode:(GLenum)p_mode
{
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, p_mode);
}

-(void) setMagFilterMode:(GLenum)p_mode
{
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, p_mode);
}

@end
