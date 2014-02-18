#ifndef __AppDelegate_H__
#define __AppDelegate_H__

#include "OgrePlatform.h"

#if !defined(OGRE_IS_IOS)
#  error This header is for use with iOS only
#endif

#ifdef __OBJC__

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// To use CADisplayLink for smoother animation on iPhone comment out
// the following line or define it to 1.  Use with caution, it can
// sometimes cause input lag.
#define USE_CADISPLAYLINK 1


@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    DemoApp demo;

    CADisplayLink *mDisplayLink;
    NSDate* mDate;
    NSTimeInterval mLastFrameTime;
}

- (void)go;
- (void)renderOneFrame:(id)sender;
@property (nonatomic) NSTimeInterval mLastFrameTime;
@end

@implementation AppDelegate

@dynamic mLastFrameTime;


- (double)mLastFrameTime
{
    return mLastFrameTime;
}

- (void)setLastFrameTime:(double)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        mLastFrameTime = frameInterval;
    }
}

- (void)go {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    mLastFrameTime = 1;
    
    try {
        demo.startDemo();
        
        Ogre::Root::getSingleton().getRenderSystem()->_initRenderTargets();
        
        // Clear event times
		Ogre::Root::getSingleton().clearEventTimes();
    } catch( Ogre::Exception& e ) {
        std::cerr << "An exception has occurred: " <<
        e.getFullDescription().c_str() << std::endl;
    }

    [pool release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    mLastFrameTime = 2;
    mDisplayLink = nil;
    
    [self go];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
//    Ogre::Root::getSingleton().queueEndRendering();
//    
//    if (mDisplayLinkSupported)
//    {
//        [mDate release];
//        mDate = nil;
//        
//        [mDisplayLink invalidate];
//        mDisplayLink = nil;
//    }
//    else
//    {
//        [mTimer invalidate];
//        mTimer = nil;
//    }
//    [[UIApplication sharedApplication] performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    Ogre::Root::getSingleton().saveConfig();
    
    [mDate release];
    mDate = nil;
    
    [mDisplayLink invalidate];
    mDisplayLink = nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    Ogre::Root::getSingleton().clearEventTimes();
    mDate = [[NSDate alloc] init];
    mLastFrameTime = 2; // Reset the timer
    
    mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderOneFrame:)];
    [mDisplayLink setFrameInterval:mLastFrameTime];
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)renderOneFrame:(id)sender
{
    // NSTimeInterval is a simple typedef for double
    NSTimeInterval currentFrameTime = -[mDate timeIntervalSinceNow];
    NSTimeInterval differenceInSeconds = currentFrameTime - mLastFrameTime;
    mLastFrameTime = currentFrameTime;
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        if(!OgreFramework::getSingletonPtr()->isOgreToBeShutDown() &&
           Ogre::Root::getSingletonPtr() && Ogre::Root::getSingleton().isInitialised())
        {
            if(OgreFramework::getSingletonPtr()->m_pRenderWnd->isActive())
            {
                OgreFramework::getSingletonPtr()->updateOgre(differenceInSeconds);
                OgreFramework::getSingletonPtr()->m_pRoot->renderOneFrame();
            }
        }
    });
    
}

- (void)dealloc {
    
    [super dealloc];
}

@end

#endif

#endif
