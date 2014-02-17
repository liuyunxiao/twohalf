//
//  CanvasManager.h
//  twohalf
//
//  Created by yons on 14-2-11.
//
//

#ifndef __twohalf__CanvasManager__
#define __twohalf__CanvasManager__

class CanvasManager : public Singleton<CanvasManager>
{
public:
    CanvasManager();
    
    bool initMgr();
    
    bool openModel(String name);
    
    void onClickModel(Vector2 pos);
    
    void change(TexturePtr tex);
private:
    SceneNode*          mpCurOpenNode;
    Entity*             mpCurOpenEnt;
    RaySceneQuery*      mCursorQuery;
    
    SceneNode*          mpNodeBackground;
    Rectangle2D*        mpEntBackground;
};
#endif /* defined(__twohalf__CanvasManager__) */
