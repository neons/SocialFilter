//
//  CaptionShadowFilter.m
//  Phostock
//
//  Created by Roman Truba on 03.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "CaptionShadowFilter.h"
NSString *const kGPUImageCaptionShadowFilter = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 
 const mediump float vignetteStart = 0.7;
 const mediump float vignetteEnd = 1.1;
 
 void main()
 {
     lowp vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     lowp float d = distance(textureCoordinate, vec2(textureCoordinate.x,0.0));
     rgb *= smoothstep(vignetteEnd, vignetteStart, d);
     gl_FragColor = vec4(vec3(rgb),1.0);
 }
);
@implementation CaptionShadowFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageCaptionShadowFilter]))
    {
		return nil;
    }
    return self;
}
@end
