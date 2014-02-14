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
    FrameManager::getSingletonPtr()->addToMainView("MainView");
    
    FrameManager::getSingletonPtr()->addToMainView("TopView");
    
    openModel("ogrehead.mesh");
    //openModel("sphere.mesh");
    
    mCursorQuery = OgreFramework::getSingletonPtr()->m_pSceneMgr->createRayQuery(Ray());
    return true;
}

void CanvasManager::change(TexturePtr tex)
{
    static int matnum = 0;
    String matNmae = "mat";
    matNmae += StringConverter::toString(++matnum);
    MaterialPtr mat = MaterialManager::getSingletonPtr()->create(matNmae, ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
    TextureUnitState* texUnit = mat->getTechnique(0)->getPass(0)->createTextureUnitState();
    texUnit->setTexture(tex);
    Pass* pass = mat->getTechnique(0)->getPass(0);
    pass->setDiffuse(1.0, 0.7, 0.7, 1.0);
    pass->setAmbient(0.1, 0.1, 0.1);
    
    for(int i = 0; i < mpCurOpenEnt->getNumSubEntities(); ++i)
    {
        SubEntity* sub = mpCurOpenEnt->getSubEntity(i);
        if(!sub)
            continue;
        sub->setMaterial(mat);
    }
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
    //mpCurOpenNode->yaw(Radian(Degree(180)));
    return true;
}

void CanvasManager::onClickModel(Vector2 pos)
{
    printf("%f  %f\n",pos.x,pos.y);
    Ray ray = OgreFramework::getSingletonPtr()->m_pCamera->getCameraToViewportRay(pos.x, pos.y);
    mCursorQuery->setRay(ray);
    RaySceneQueryResult& result = mCursorQuery->execute();
    
    if (!result.empty())
    {
        // using the point of intersection, find the corresponding texel on our texture
        Vector3 pt = ray.getPoint(result.back().distance);
        MovableObject* ent = result[0].movable;
        if(ent)
        {
            ent->getParentSceneNode()->showBoundingBox(!ent->getParentSceneNode()->getShowBoundingBox());
        }
        //mBrushPos = (Vector2(pt.x, -pt.y) / mPlaneSize + Vector2(0.5, 0.5)) * TEXTURE_SIZE;
    }
}
