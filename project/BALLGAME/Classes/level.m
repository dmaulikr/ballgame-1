//
//  level.m
//  GLSkeleton
//
//  Created by Andrew     on 19/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "level.h"


@implementation level

@synthesize curLevel;
@synthesize grid;
@synthesize NUMSQUARESPERROW;
@synthesize NUMCOLUMN;
@synthesize squareWidth;
@synthesize squareHeight;
@synthesize ballRadius;

//create our level class with an array obtained from levels.dict
-(id)initWithArray:(NSArray*)array
{
	if(self = [super init])
	{
		curLevel=0;
		//set all the textures to nil to avoid nullpointers
		for(int i=0;i<NUMTEX;i++)
		{
			level_tex[i]=nil;
		}
		
			levelList=array; //keep it
			[levelList retain]; //retain it
			numLevel = (int) [levelList count]; //get the amount of levels 
			NSLog(@"Level count %d",numLevel);  
	}
	else
	{
	ERROR:
		NSLog(@"Error in init Level.m");
		return nil;
	}
	//load up the first level
	[self gotoLevel:curLevel];
	return self;
}


//Bind a texture from the tex array
-(void) setTexture:(int)num
{
	if(num >=0 && num<NUMTEX)
	{
		[level_tex[num] bind];
	}
}

//allows us to set the wrap mode for a texture
-(void) setTextureMode:(int)num mode:(GLenum)p_mode
{
	if(num >=0 && num<NUMTEX)
	{
		[level_tex[num] setWrapMode:p_mode];
	}
}

//increment the level counter then load up a new level with the new array index
-(int)nextLevel
{
	curLevel++;
	int retVal=1;
	if(curLevel< numLevel)
	{
		retVal=0;
		[self gotoLevel:curLevel];
	}
	else
	{
		NSLog(@"NO MORE LEVELS");
	}
	return retVal;
}

//Load up the level from the dictionary held inside the array
-(int)gotoLevel:(int)levelNum
{
	//dealloc the grid because we will be reallocing it
	free(grid);
	
	//make a dictionary file from the dictionary in the array
	NSDictionary *tempDict = [levelList objectAtIndex:levelNum];
	
	//Get values from the dictionary file for all the variables
	NSInteger *sqrWidth = [tempDict objectForKey:@"squareWidth"];
	squareWidth = [sqrWidth intValue];
	NSInteger *sqrHeight = [tempDict objectForKey:@"squareHeight"];
	squareHeight=[sqrHeight intValue];
	
	
	NSInteger *balRad = [tempDict objectForKey:@"ballRadius"];
	ballRadius = [balRad intValue];
	
	
	NSInteger *n_row = [tempDict objectForKey:@"NUMQUARESPERROW"];
	NUMSQUARESPERROW = [n_row intValue];
	
	
	NSInteger *n_column = [tempDict objectForKey:@"NUMCOLUMN"];
	NUMCOLUMN = [n_column intValue];
	
	
	/*get a string that we will then convert into a level
	if you look at the levels.plist file you will see that this is just a huge string of numbers.
	 each number in the array is used to tell what type of tile this is. It is also used to
	 know which texture we should draw in it*/
	
	NSString *gridString = [tempDict objectForKey:@"grid"];
	//allocate memory for each tile
	grid = malloc(sizeof(struct square)*([n_row intValue]*[n_column intValue]));

	//use a scanner to scan thru the string
	NSScanner *scan = [[NSScanner alloc] initWithString:gridString];
	
	printf("******\n");
	//create a grid entry for every tile int he string
	for(int i=0;i<[n_row intValue]*[n_column intValue];i++)
	{
		grid[i].collided=0;
		int getVal;
		[scan scanInt:&getVal];
		grid[i].type=getVal;
	}

	//textures are stored in a seperate array inside the dictionary. Just extract the array using objectforkey
	NSString *texString;
	NSArray *tex_array = [tempDict objectForKey:@"textures"];
	NSLog(@"%@",tex_array);
	
	//for each texture in the array make a GLtexture to use it
	for(int i=0;i<NUMTEX;i++)
	{
		[level_tex[i] release];
		texString = [tex_array objectAtIndex:i];
		level_tex[i]=[[GLTexture alloc] initWithFile:texString];
		NSLog(@"Tex %d   %@",i,texString);
	}
	
	NSLog(@"sqrWidth %@ \n sqrHeight %@ \n balRad %@ \n numRow %@ \n numColumn %@ \n \n   grid\n %@",sqrWidth,sqrHeight,balRad,n_row,n_column,gridString);
	//Now give each tile its proper vertexes
	[self createLevel];
	[scan release];
	return 0;
}


//gives vertexes to the tile array.
//we want to rotate around the ball, not the origin, so we cant just use the individual tile bounds to do this.
//we have to pretend that instead of a million small tiles we just have one big tile, and allocate vertex based on that
-(void) createLevel
{	
	int restartX=squareWidth*NUMSQUARESPERROW/2; 
	int restartY=squareHeight*NUMCOLUMN/2;
	int tempX=-restartX; 
	int tempY=-restartY; 
	int i;
	
	
	//start giving out vertexes based on the total size of the tiles
	for(i=0;i<NUMSQUARESPERROW*NUMCOLUMN;i++)
	{
		if(i % NUMSQUARESPERROW == 0)
		{
			tempX=-restartX-squareWidth; 
			tempY+=squareHeight; 
		}
		tempX+=squareWidth;
		grid[i].x=tempX; 
		grid[i].y=tempY; 
		
		if(grid[i].type==4)
		{
			grid[i].r=255;
			grid[i].g=255;
			grid[i].b=255;
		}
		else if(grid[i].type==0x0003)
		{
			grid[i].r=255;
			grid[i].g=255;
			grid[i].b=255;
		}
	}
}


-(void)dealloc
{
	for(int i=0;i<NUMTEX;i++)
	{
		[level_tex[i] release];
	}
	free(grid);
	[super dealloc];
}
@end
