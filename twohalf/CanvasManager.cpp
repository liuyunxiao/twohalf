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
#include "macUtils.h"
template<> CanvasManager* Singleton<CanvasManager>::msSingleton = 0;

CanvasManager::CanvasManager():mpEntBackground(0),mpCurOpenNode(0),mTestAni(0)
{
    
}
bool CanvasManager::initMgr()
{
    FrameManager::getSingletonPtr()->addToMainView("MainView");
    FrameManager::getSingletonPtr()->addToMainView("TopView");
    
    
    
    mCursorQuery = OgreFramework::getSingletonPtr()->m_pSceneMgr->createRayQuery(Ray());
    
    mpEntBackground = new Rectangle2D(true);
    mpEntBackground->setRenderQueueGroup(RENDER_QUEUE_BACKGROUND);
    mpEntBackground->setCorners(-1, 1, 1, -1);
    mpNodeBackground = OgreFramework::getSingleton().m_pSceneMgr->getRootSceneNode()->createChildSceneNode();
    mpNodeBackground->attachObject(mpEntBackground);
    mpNodeBackground->setVisible(false);
    
    mNodeTagIndex = 0;
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

int CanvasManager::openModel(String name)
{
    if(mpCurOpenNode)
        mpCurOpenNode->showBoundingBox(false);
    
    static int nNum = 0;
    ++nNum;
    String sPref = "Ent";
    sPref += StringConverter::toString(nNum);
    Entity* ent = OgreFramework::getSingletonPtr()->m_pSceneMgr->createEntity(sPref, name);
//    if(ent->getAllAnimationStates())
//    {
//        AnimationState* aniState = ent->getAnimationState("RunBase");
//        if(aniState)
//        {
//            aniState->setLoop(true);
//            aniState->setEnabled(true);
//            mTestAni = aniState;
//        }
//    }
    
    sPref = "Node";
    sPref += StringConverter::toString(nNum);
	mpCurOpenNode = OgreFramework::getSingletonPtr()->m_pSceneMgr->getRootSceneNode()->createChildSceneNode(sPref);
	mpCurOpenNode->attachObject(ent);
    const AxisAlignedBox& box = ent->getBoundingBox();
    Real scal = 10/box.getSize().y;
    mpCurOpenNode->setScale(scal,scal,scal);
    mpCurOpenNode->showBoundingBox(true);
    
    mMapNodeNameTag[sPref] = ++mNodeTagIndex;
    return mNodeTagIndex;
}

void CanvasManager::onScaleModel(float fScale)
{
    if(!mpCurOpenNode)
        return;
    
    Vector3 srcScale = mpCurOpenNode->getScale();
    float fCof = fScale<0?0.005:-0.005;
    mpCurOpenNode->setScale(Vector3(srcScale.x+fCof, srcScale.y+fCof, srcScale.z+fCof));
}

void CanvasManager::printScreen()
{
    
}

void CanvasManager::onMoveModel(Vector2 screenPos)
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

void CanvasManager::onRotateModel(Vector2 screenDis)
{
    if(!mpCurOpenNode)
        return;
    
    mpCurOpenNode->yaw(Radian(screenDis.x));
    //mpCurOpenNode->pitch(Radian(screenDis.y));
    //mpCurOpenNode->rotate(Vector3::UNIT_X, Radian(screenDis.y));
    //mpCurOpenNode->rotate(Vector3::UNIT_Y, Radian(screenDis.x));
    
    
}

void CanvasManager::onMoveCamera(float fDis)
{
    OgreFramework::getSingletonPtr()->m_pCamera->move(Vector3(0.0,0.0,fDis<0?-0.3:0.3));
}

void CanvasManager::cancelCurSel()
{
    if(mpCurOpenNode)
    {
        mpCurOpenNode->showBoundingBox(false);
        mpCurOpenNode = NULL;
    }
}

void CanvasManager::removeCurSel()
{
    if(mpCurOpenNode)
    {
        OgreFramework::getSingletonPtr()->m_pSceneMgr->getRootSceneNode()->removeChild(mpCurOpenNode);
        cancelCurSel();
    }
}

int CanvasManager::onClickScreen(Vector2 screenPos)
{
    Ray ray = OgreFramework::getSingletonPtr()->m_pCamera->getCameraToViewportRay(screenPos.x, screenPos.y);
    mCursorQuery->setRay(ray);
    RaySceneQueryResult& result = mCursorQuery->execute();
    if (result.empty())
        return -1;
    
    int nSelModelIndex = -1;
    Vector3 pt = ray.getPoint(result.back().distance);
    MovableObject* ent = result[0].movable;
    if(ent)
    {
        if(!mpCurOpenNode)
        {
            mpCurOpenNode = ent->getParentSceneNode();
            mpCurOpenNode->showBoundingBox(true);
            MapNodeNameTagItor itor = mMapNodeNameTag.find(mpCurOpenNode->getName());
            if(itor != mMapNodeNameTag.end())
            {
                nSelModelIndex = itor->second;
            }
        }
        else if(mpCurOpenNode == ent->getParentSceneNode())
        {
            MapNodeNameTagItor itor = mMapNodeNameTag.find(mpCurOpenNode->getName());
            if(itor != mMapNodeNameTag.end())
            {
                nSelModelIndex = itor->second;
            }
            cancelCurSel();
        }
    }

    return nSelModelIndex;
}
