//
//  DemotivationFilter.m
//  Phostock
//
//  Created by Roman Truba on 04.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "PolaroidFilter.h"

NSString *const kGPUImagePolaroidFilter = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 const mediump float motivatorBorder = 0.05;
 const mediump float motivatorLowBorder = 0.2;
 void main()
 {
     lowp vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     if (textureCoordinate.x < motivatorBorder  || textureCoordinate.x > 1.0 - motivatorBorder ||
         textureCoordinate.y < motivatorBorder || textureCoordinate.y > 1.0 - motivatorBorder * 4.0)
     {
         rgb = vec3(1.0, 1.0, 1.0);
     }
     gl_FragColor = vec4(vec3(rgb),1.0);
 }
 );
@implementation PolaroidFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePolaroidFilter]))
    {  
		return nil;
    }
    return self;
}
@end
