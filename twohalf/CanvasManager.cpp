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

CanvasManager::CanvasManager():mpEntBackground(0),mpCurOpenNode(0)
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

void CanvasManager::changeBackgroud(TexturePtr tex, float fWidth, float fHeight)
{
    static int matnum = 0;
    String matNmae = "mat";
    
    matNmae += StringConverter::toString(++matnum);
    MaterialPtr mat = MaterialManager::getSingletonPtr()->create(matNmae, ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
    TextureUnitState* texUnit = mat->getTechnique(0)->getPass(0)->createTextureUnitState();
    texUnit->setTexture(tex);
    
    mpEntBackground->setCorners(-fWidth, fHeight, fWidth, -fHeight);
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
    if(mpCurOpenNode)
        mpCurOpenNode->showBoundingBox(false);
    
    static int nNum = 0;
    ++nNum;
    String sPref = "Ent";
    sPref += StringConverter::toString(nNum);
    Entity* ent = OgreFramework::getSingletonPtr()->m_pSceneMgr->createEntity(sPref, name);
    if(ent->getAllAnimationStates())
    {
        AnimationState* aniState = ent->getAnimationState("RunBase");
        if(aniState)
        {
            aniState->setLoop(true);
            aniState->setEnabled(true);
            mTestAni = aniState;
        }
    }
    
    sPref = "Node";
    sPref += StringConverter::toString(nNum);
	mpCurOpenNode = OgreFramework::getSingletonPtr()->m_pSceneMgr->getRootSceneNode()->createChildSceneNode(sPref);
	mpCurOpenNode->attachObject(ent);
    const AxisAlignedBox& box = ent->getBoundingBox();
    Real scal = 10/box.getSize().y;
    mpCurOpenNode->setScale(scal,scal,scal);
    mpCurOpenNode->showBoundingBox(true);
    return true;
}

void CanvasManager::onPinchGesture(float fScale)
{
    if(!mpCurOpenNode)
    {
        OgreFramework::getSingletonPtr()->m_pCamera->move(Vector3(0.0,0.0,fScale<0?-0.3:0.3));
    }
    else
    {
        Vector3 srcScale = mpCurOpenNode->getScale();
        float fCof = fScale<0?0.005:-0.005;
        mpCurOpenNode->setScale(Vector3(srcScale.x+fCof, srcScale.y+fCof, srcScale.z+fCof));
    }
}

void CanvasManager::onPanGesture(Vector2 screenPos)
{
    if(!mpCurOpenNode)
        return;
    
    Vector3 pos = mpCurOpenNode->getPosition();
    Ray ray = OgreFramework::getSingletonPtr()->m_pCamera->getCameraToViewportRay(screenPos.x, screenPos.y);
    std::pair<bool, Real> res = ray.intersects(Plane(Vector3(Vector3::UNIT_Z), pos.z));
    if(res.first)
    {
        mpCurOpenNode->setPosition(ray*res.second);
    }
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
            if(mpCurOpenNode)
            {
                mpCurOpenNode->showBoundingBox(false);
            }
            mpCurOpenNode = ent->getParentSceneNode();
            mpCurOpenNode->showBoundingBox(true);
        }
    }
    else
    {
        if(mpCurOpenNode)
        {
            mpCurOpenNode->showBoundingBox(false);
            mpCurOpenNode = NULL;
        }
    }
}
