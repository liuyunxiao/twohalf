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
    
    int openModel(String name);
    void changeBackgroud(TexturePtr tex, float fWidth, float fHeight);
    void updateAni(double delta);
    
    void cancelCurSel();
    void removeCurSel();
    void printScreen();
    void onMoveModel(Vector2 screenPos);
    void onScaleModel(float fScale);
    void onRotateModel(Vector2 screenDis);
    int  onClickScreen(Vector2 screenPos);
    void onMoveCamera(float fDis);
    
    typedef map<String,int>::type MapNodeNameTag;
    typedef map<String,int>::type::iterator MapNodeNameTagItor;
    
private:
    MapNodeNameTag      mMapNodeNameTag;
    int                 mNodeTagIndex;
    SceneNode*          mpCurOpenNode;
    RaySceneQuery*      mCursorQuery;
    
    SceneNode*          mpNodeBackground;
    Rectangle2D*        mpEntBackground;
    
    AnimationState*     mTestAni;
};
#endif /* defined(__twohalf__CanvasManager__) */
