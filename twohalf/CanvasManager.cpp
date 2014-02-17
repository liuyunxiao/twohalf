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

CanvasManager::CanvasManager():mpEntBackground(0)
{
    
}
bool CanvasManager::initMgr()
{
    FrameManager::getSingletonPtr()->addToMainView("MainView");
    
    FrameManager::getSingletonPtr()->addToMainView("TopView");
    
    openModel("Sinbad.mesh");
    //openModel("sphere.mesh");
    
    mCursorQuery = OgreFramework::getSingletonPtr()->m_pSceneMgr->createRayQuery(Ray());
    
    mpEntBackground = new Rectangle2D(true);
    mpEntBackground->setRenderQueueGroup(RENDER_QUEUE_BACKGROUND);
    mpEntBackground->setCorners(-1, 1, 1, -1);
    mpNodeBackground = OgreFramework::getSingleton().m_pSceneMgr->getRootSceneNode()->createChildSceneNode();
    mpNodeBackground->attachObject(mpEntBackground);
    mpNodeBackground->setVisible(false);
    return true;
}

void CanvasManager::changeBackgroud(TexturePtr tex)
{
    static int matnum = 0;
    String matNmae = "mat";
    
    matNmae += StringConverter::toString(++matnum);
    MaterialPtr mat = MaterialManager::getSingletonPtr()->create(matNmae, ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
    TextureUnitState* texUnit = mat->getTechnique(0)->getPass(0)->createTextureUnitState();
    texUnit->setTexture(tex);
    float xDif = (tex->getWidth()/2.0) / (568/2)/2;
    float yDif = (tex->getHeight()/2.0) / (320/2)/2;
    mpEntBackground->setCorners(-xDif, yDif, xDif, -yDif);
    Pass* pass = mat->getTechnique(0)->getPass(0);
    pass->setDepthWriteEnabled(false);
    mpEntBackground->setMaterial(matNmae);
    mpNodeBackground->setVisible(true);
}

void CanvasManager::updateAni(double delta)
{
    if(mTestAni)
    {
        mTestAni->addTime(delta);
    }
}

bool CanvasManager::openModel(String name)
{
    static int nNum = 0;
    ++nNum;
    String sPref = "Ent";
    sPref += StringConverter::toString(nNum);
    Entity* ent = OgreFramework::getSingletonPtr()->m_pSceneMgr->createEntity(sPref, name);
    AnimationState* aniState = ent->getAnimationState("RunBase");
    if(aniState)
    {
        aniState->setLoop(true);
        aniState->setEnabled(true);
        mTestAni = aniState;
    }
    
    sPref = "Node";
    sPref += StringConverter::toString(nNum);
	mpCurOpenNode = OgreFramework::getSingletonPtr()->m_pSceneMgr->getRootSceneNode()->createChildSceneNode(sPref);
	mpCurOpenNode->attachObject(ent);
    return true;
}

void CanvasManager::onClickModel(Vector2 pos)
{
    Ray ray = OgreFramework::getSingletonPtr()->m_pCamera->getCameraToViewportRay(pos.x, pos.y);
    mCursorQuery->setRay(ray);
    RaySceneQueryResult& result = mCursorQuery->execute();
    
    if (!result.empty())
    {
        Vector3 pt = ray.getPoint(result.back().distance);
        MovableObject* ent = result[0].movable;
        if(ent)
        {
            ent->getParentSceneNode()->showBoundingBox(true);
            mpCurOpenNode = ent->getParentSceneNode();
        }
    }
    else
    {
        if(mpCurOpenNode)
            mpCurOpenNode->showBoundingBox(false);
    }
}
