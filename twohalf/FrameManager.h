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
    void closeView(String frameName);
    
    void hideAllUIView(bool hide);
    typedef map<String,int>::type MapViewNameTag;
    typedef map<String,int>::type::iterator MapViewNameTagItor;
private:
    MapViewNameTag      mMapViewNameTag;
    int                 mTagIndex;
};
#endif /* defined(__twohalf__FrameManager__) */
