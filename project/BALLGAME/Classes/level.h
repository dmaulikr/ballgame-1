//
//  level.h
//  GLSkeleton
//
//  Created by Andrew     on 19/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// Level handles loading and changing levels 

#import <Foundation/Foundation.h>
#import "GLTexture.h"

//maximum textures
#define NUMTEX 10
//A structure to represent a tile
struct square 
{
	float x;
	float y; 	     // X and Y position of square		
	int collided;
	int type;
	unsigned char r;
	unsigned char g;
	unsigned char b;
}; 

@interface level : NSObject {
	//List of levels retrieved from a Plist
	NSArray *levelList;
	
	int curLevel;				//current level loaded. Is an index into levelList
	struct square *grid;		//create a grid out of the squares
	GLTexture *level_tex[NUMTEX]; //array of textures
	int NUMSQUARESPERROW;		//num squares horizontally
	int NUMCOLUMN;				//num squares vertically
	int squareWidth;			//how big the squares are Widthwise
	int squareHeight;			//how big the squares are heightwise
	int ballRadius;				//how big the ball is
	int numLevel;				//number of levels inside levellist
}

@property(readwrite, assign) int curLevel;
@property(readwrite,assign) struct square *grid;
@property(readwrite, assign) int NUMSQUARESPERROW;
@property(readwrite, assign) int NUMCOLUMN;
@property(readwrite, assign) int squareWidth;
@property(readwrite, assign) int squareHeight;
@property(readwrite, assign) int ballRadius;
 
-(void) setTexture:(int)num;
-(void) setTextureMode:(int)num mode:(GLenum)p_mode;

-(id)initWithArray:(NSArray*)array;
-(int)nextLevel;
-(void) createLevel;
-(int)gotoLevel:(int)levelNum;
@end
