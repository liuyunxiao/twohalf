//
//  FrameManager.h
//  twohalf
//
//  Created by yons on 14-2-11.
//
//

#ifndef __twohalf__FrameManager__
#define __twohalf__FrameManager__

class FrameManager : public Singleton<FrameManager>
{
public:
    bool initMgr();
    bool addToMainView(String frameName);
private:
};
#endif /* defined(__twohalf__FrameManager__) */
