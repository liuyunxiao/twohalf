//
//  TestView.m
//  OGame
//
//  Created by mac on 13-6-6.
//
//

#import "TopView.h"
#include "FrameManager.h"
#include "CanvasManager.h"
@implementation TopView

-(IBAction)onModelLib:(id)sender
{
    FrameManager::getSingletonPtr()->addToMainView("ModelDisplay");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    CanvasManager::getSingletonPtr()->onClickModel(Vector2(pos.x,pos.y));
    
    return [super touchesBegan:touches withEvent:event];
}
@end
