//
//  StandardFilter1.m
//  Phostock
//
//  Created by Roman Truba on 02.10.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "StandardFilter4.h"
NSString *const kGPUImageStandardFilter4 = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform lowp mat4 colorMatrix;
  uniform lowp float saturation;
 
 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     //Sepia
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 outputColor = textureColor * colorMatrix;
     textureColor = (0.4891 * outputColor) + ((1.0 - 0.4891) * textureColor);
     
     //Saturation
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     lowp vec3 greyScaleColor = vec3(luminance);
     textureColor = vec4(mix(greyScaleColor, textureColor.rgb, 1.5342), textureColor.w);
     
     //Gamma     
     gl_FragColor = vec4(pow(textureColor.rgb, vec3(0.74)), textureColor.w);
 }
 );
@implementation StandardFilter4
-(id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageStandardFilter4]))
    {
        return nil;
    }
    /*
     Sepia : 0.4891
     Saturation : 1.5342
     Gamma : 0.74
     
     */
    
    //For Sepia
    GLuint colorMatrixUniform = [filterProgram uniformIndex:@"colorMatrix"];
    GPUMatrix4x4 matrix = (GPUMatrix4x4){
        {0.3588, 0.7044, 0.1368, 0.0},
        {0.2990, 0.5870, 0.1140, 0.0},
        {0.2392, 0.4696, 0.0912 ,0.0},
        {0,0,0,1.0},
    };
    [self setMatrix4f:matrix forUniform:colorMatrixUniform program:filterProgram];
    [self prepareForImageCapture];
    return self;
}


@end
