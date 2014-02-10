//|||||||||||||||||||||||||||||||||||||||||||||||

#ifndef OGRE_FRAMEWORK_H
#define OGRE_FRAMEWORK_H

//|||||||||||||||||||||||||||||||||||||||||||||||

#include <Ogre.h>
#include <OgreCamera.h>
#include <OgreEntity.h>
#include <OgreLogManager.h>
#include <OgreOverlay.h>
#include <OgreOverlayElement.h>
#include <OgreOverlayManager.h>
#include <OgreRoot.h>
#include <OgreViewport.h>
#include <OgreSceneManager.h>
#include <OgreRenderWindow.h>
#include <OgreConfigFile.h>
using namespace Ogre;
#ifdef OGRE_STATIC_LIB
#  define OGRE_STATIC_GL
#  if OGRE_PLATFORM == OGRE_PLATFORM_WIN32
#    define OGRE_STATIC_Direct3D9
// dx10 will only work on vista, so be careful about statically linking
#    if OGRE_USE_D3D10
#      define OGRE_STATIC_Direct3D10
#    endif
#  endif
#  define OGRE_STATIC_CgProgramManager
#  ifdef OGRE_USE_PCZ
#    define OGRE_STATIC_PCZSceneManager
#    define OGRE_STATIC_OctreeZone
#  endif
#  if OGRE_VERSION >= 0x10800
#    if OGRE_PLATFORM == OGRE_PLATFORM_APPLE_IOS
#      define OGRE_IS_IOS 1
#    endif
#  else
#    if OGRE_PLATFORM == OGRE_PLATFORM_IPHONE
#      define OGRE_IS_IOS 1
#    endif
#  endif
#  ifdef OGRE_IS_IOS
#    undef OGRE_STATIC_CgProgramManager
#    undef OGRE_STATIC_GL
#    define OGRE_STATIC_GLES 1
#    ifdef OGRE_USE_GLES2
#      define OGRE_STATIC_GLES2 1
#      define INCLUDE_RTSHADER_SYSTEM
#      undef OGRE_STATIC_GLES
#    endif
#    ifdef __OBJC__
#      import <UIKit/UIKit.h>
#    endif
#  endif
#  include "OgreStaticPluginLoader.h"
#endif

#ifdef OGRE_IS_IOS
#   include <OISMultiTouch.h>
#endif


class OgreFramework : public Singleton<OgreFramework>
{
public:
	OgreFramework();
	~OgreFramework();
    
    bool initOgre(String wndTitle);
	void updateOgre(double timeSinceLastFrame);
    
	bool isOgreToBeShutDown()const{return m_bShutDownOgre;}
	
	Root*               m_pRoot;
	SceneManager*		m_pSceneMgr;
	RenderWindow*		m_pRenderWnd;
	Camera*				m_pCamera;
	Viewport*			m_pViewport;
	Log*                m_pLog;
	Timer*				m_pTimer;

protected:
   // Added for Mac compatibility
   String                 m_ResourcePath;
    
private:
	OgreFramework(const OgreFramework&);
	OgreFramework& operator= (const OgreFramework&);
    
    FrameEvent          m_FrameEvent;
	int                 m_iNumScreenShots;
    
	bool                m_bShutDownOgre;
#ifdef OGRE_STATIC_LIB
    StaticPluginLoader    m_StaticPluginLoader;
#endif
};

//|||||||||||||||||||||||||||||||||||||||||||||||

#endif 

//|||||||||||||||||||||||||||||||||||||||||||||||
