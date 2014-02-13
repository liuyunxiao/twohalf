//
//  FrameManager.cpp
//  twohalf
//
//  Created by yons on 14-2-11.
//
//

#include "FrameManager.h"
#include "OgreFramework.h"

template<> FrameManager* Singleton<FrameManager>::msSingleton = 0;

bool FrameManager::initMgr()
{
    return true;
}

bool FrameManager::addToMainView(String frameName)
{
    NSString* name = [NSString stringWithCString:frameName.c_str() encoding:NSUTF8StringEncoding];
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
    UIView* v = (UIView*)[items objectAtIndex:0];
    
    if(!v) return false;

    UIView* pView = NULL;
    OgreFramework::getSingletonPtr()->m_pRenderWnd->getCustomAttribute("VIEW", &pView);
    
    if(pView)
        [pView addSubview:v];
    
    return true;
}
