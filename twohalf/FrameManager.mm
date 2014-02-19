//
//  FrameManager.cpp
//  twohalf
//
//  Created by yons on 14-2-11.
//
//

#include "FrameManager.h"
#include "OgreFramework.h"

#define OGRE_MAINVIEW(pView) OgreFramework::getSingletonPtr()->m_pRenderWnd->getCustomAttribute("VIEW", &pView);
#define FRAME_BASEVIEW_TAG 100
template<> FrameManager* Singleton<FrameManager>::msSingleton = 0;

bool FrameManager::initMgr()
{
    mTagIndex = 0;
    
    UIView* pView = NULL;
    OGRE_MAINVIEW(pView);
    if(!pView) return false;
    
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:nil options:nil];
    UIView* v = (UIView*)[items objectAtIndex:0];
    v.tag = FRAME_BASEVIEW_TAG;
    [pView addSubview:v];
    
    return true;
}

bool FrameManager::addToMainView(String frameName)
{
    NSString* name = [NSString stringWithCString:frameName.c_str() encoding:NSUTF8StringEncoding];
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    UIView* v = (UIView*)[items objectAtIndex:0];
    if(!v) return false;
    
    UIView* pView = NULL;
    OGRE_MAINVIEW(pView);
    if(!pView) return false;
    
    UIView* baseView = [pView viewWithTag:FRAME_BASEVIEW_TAG];
    ++mTagIndex;
    v.tag = mTagIndex;
    mMapViewNameTag[frameName] = mTagIndex;
    [baseView addSubview:v];
    
    return true;
}

void FrameManager::closeView(String frameName)
{
    UIView* pView = NULL;
    OGRE_MAINVIEW(pView);
    
    if(!pView) return;
    
    MapViewNameTagItor itor = mMapViewNameTag.find(frameName);
    if(itor == mMapViewNameTag.end())
        return;
    
    UIView* baseView = [pView viewWithTag:FRAME_BASEVIEW_TAG];
    UIView* view = [baseView viewWithTag:itor->second];
    if(!view) return;

    [view removeFromSuperview];
}
