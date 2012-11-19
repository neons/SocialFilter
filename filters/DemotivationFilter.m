//
//  DemotivationFilter.m
//  Phostock
//
//  Created by Roman Truba on 04.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "DemotivationFilter.h"

NSString *const kGPUImageDemotivatorFilter = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 const mediump float motivatorBorder = 0.05;
 const mediump float motivatorLowBorder = 0.2;
 void main()
 {
     lowp vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     if (((motivatorBorder * 0.8 < textureCoordinate.x && textureCoordinate.x < motivatorBorder * 0.9) ||
          (1.0 - motivatorBorder * 0.9 < textureCoordinate.x && textureCoordinate.x < 1.0 - motivatorBorder * 0.8)) &&
         (motivatorBorder * 0.8 < textureCoordinate.y && textureCoordinate.y < 1.0 - motivatorLowBorder + motivatorBorder * 0.2))
     {
         rgb = vec3(1.0, 1.0, 1.0);
     }
     else if (((motivatorBorder * 0.8 < textureCoordinate.y && textureCoordinate.y < motivatorBorder * 0.9) ||
               (1.0 - motivatorLowBorder + motivatorBorder * 0.2 < textureCoordinate.y && textureCoordinate.y < 1.0 - motivatorLowBorder + motivatorBorder * 0.3)) &&
              (motivatorBorder * 0.8 < textureCoordinate.x && textureCoordinate.x < 1.0 - motivatorBorder * 0.8))
     {
         rgb = vec3(1.0, 1.0, 1.0);
     }
     else if (textureCoordinate.x < motivatorBorder  || textureCoordinate.x > 1.0 - motivatorBorder ||
         textureCoordinate.y < motivatorBorder || textureCoordinate.y > 1.0 - motivatorBorder * 4.0)
     {
         rgb *= 0.0;
     }
     gl_FragColor = vec4(vec3(rgb),1.0);
 }
 );
@implementation DemotivationFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageDemotivatorFilter]))
    {  
		return nil;
    }
    return self;
}
@end
