//
//  TestView.m
//  OGame
//
//  Created by mac on 13-6-6.
//
//

#import "ModelDisplay.h"
#include "FrameManager.h"
#include "macUtils.h"
#include "CanvasManager.h"
@implementation UIModelItem

-(void)awakeFromNib
{
    
}

-(void)onUpdate:(id)data
{
    mTexName.text = data;
}

-(IBAction)onItemClick:(id)sender
{
    CanvasManager::getSingletonPtr()->openModel([mTexName.text cStringUsingEncoding:NSUTF8StringEncoding]);
    FrameManager::getSingletonPtr()->closeView("ModelDisplay");
}
@end

@implementation ModelDisplay

-(void)awakeFromNib
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    String path = Ogre::macBundlePath() + "/media/models";
    NSArray* files = [fileMgr subpathsAtPath:[NSString stringWithUTF8String:path.c_str()]];
    
    int nIndex = 0;
    for(NSString* fileName in files)
    {
        NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"UIModelItem" owner:nil options:nil];
        UIModelItem* v = (UIModelItem*)[items objectAtIndex:0];
        [mScrollModels addSubview:v];
        CGRect rec = v.frame;
        v.frame = CGRectMake((rec.size.width+10)*nIndex, 0, rec.size.width, rec.size.height);
        [v onUpdate:fileName];
        ++nIndex;
    }
    
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"UIModelItem" owner:nil options:nil];
    UIModelItem* v = (UIModelItem*)[items objectAtIndex:0];
    [mScrollModels addSubview:v];
    CGRect rec = v.frame;
    v.frame = CGRectMake((rec.size.width+10)*nIndex, 0, rec.size.width, rec.size.height);
    [v onUpdate:@"Sinbad.mesh"];
}

-(IBAction)onClose:(id)sender
{
    FrameManager::getSingletonPtr()->closeView("ModelDisplay");
}

@end
