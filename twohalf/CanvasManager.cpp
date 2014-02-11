//
//  CanvasManager.cpp
//  twohalf
//
//  Created by yons on 14-2-11.
//
//

#include "CanvasManager.h"
#include "FrameManager.h"
#include "OgreFramework.h"
template<> CanvasManager* Singleton<CanvasManager>::msSingleton = 0;
bool CanvasManager::initMgr()
{
    FrameManager::getSingletonPtr()->addToMainView("TopView");
    
    openModel("ogrehead.mesh");
    return true;
}

bool CanvasManager::openModel(String name)
{
    static int nNum = 0;
    ++nNum;
    String sPref = "Ent";
    sPref += StringConverter::toString(nNum);
    mpCurOpenEnt = OgreFramework::getSingletonPtr()->m_pSceneMgr->createEntity(sPref, name);
    sPref = "Node";
    sPref += StringConverter::toString(nNum);
	mpCurOpenNode = OgreFramework::getSingletonPtr()->m_pSceneMgr->getRootSceneNode()->createChildSceneNode(sPref);
	mpCurOpenNode->attachObject(mpCurOpenEnt);
    mpCurOpenNode->setScale(0.5, 0.5, 0.5);
    return true;
}
