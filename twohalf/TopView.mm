//
//  TestView.m
//  OGame
//
//  Created by mac on 13-6-6.
//
//

#import "TopView.h"
#include "FrameManager.h"
@implementation TopView

-(IBAction)onModelLib:(id)sender
{
    FrameManager::getSingletonPtr()->addToMainView("ModelDisplay");
}
@end
