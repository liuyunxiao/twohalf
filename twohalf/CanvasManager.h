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
    bool initMgr();
    
    bool openModel(String name);
private:
    SceneNode*          mpCurOpenNode;
    Entity*             mpCurOpenEnt;
};
#endif /* defined(__twohalf__CanvasManager__) */
