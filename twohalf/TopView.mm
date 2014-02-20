//
//  TestView.m
//  OGame
//
//  Created by mac on 13-6-6.
//
//

#import "TopView.h"
#include "FrameManager.h"
#include "CanvasManager.h"
#include "OgreFramework.h"
#include "macUtils.h"
#include "OgreBitwise.h"
@implementation NonRotatingUIImagePickerController
// Disable Landscape mode.
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscape;
//}
@end

@implementation TopView

-(void)awakeFromNib
{
    m_nTagSelModel = CanvasManager::getSingletonPtr()->openModel("ogrehead.mesh");
    
    [self onBtnMove:nil];
}

- (void) handlePanMove:(UIPanGestureRecognizer*) recognizer
{
    if(m_nTagSelModel)
    {
        CGPoint pos = [recognizer locationInView:self];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CanvasManager::getSingletonPtr()->onMoveModel(Vector2(pos.x/screenSize.width,pos.y/screenSize.height));
    }
}

- (void) handlePanRotate:(UIPanGestureRecognizer*) recognizer
{
    if(m_nTagSelModel)
    {
        if([recognizer state] == UIGestureRecognizerStateBegan) {
            m_pointLastRotate = [recognizer locationInView:self];
        }
        
        CGPoint pos = [recognizer locationInView:self];
        CGPoint nDif;
        nDif.x = m_pointLastRotate.x-pos.x;
        nDif.y = m_pointLastRotate.y-pos.y;
        CanvasManager::getSingletonPtr()->onRotateModel(Vector2(-nDif.x/80.0, -nDif.y/80.0));
        m_pointLastRotate = [recognizer locationInView:self];
    }
    
}

- (void) handleTap:(UITapGestureRecognizer*) recognizer
{
    CGPoint pos = [recognizer locationInView:self];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    int nTagSelModel = CanvasManager::getSingletonPtr()->onClickScreen(Vector2(pos.x/screenSize.width,pos.y/screenSize.height));
    if(m_nTagSelModel == nTagSelModel)
    {
        m_nTagSelModel = -1;
    }
    else
    {
        m_nTagSelModel = nTagSelModel;
    }
}

// 缩放
-(void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        m_fLastScale = 1.0;
    }
    if([recognizer scale] > m_fLastScale)
    {
        if(m_nTagSelModel)
            CanvasManager::getSingletonPtr()->onScaleModel(-0.3);
        else
            CanvasManager::getSingletonPtr()->onMoveCamera(0.3);
    }
    else
    {
        if(m_nTagSelModel)
            CanvasManager::getSingletonPtr()->onScaleModel(0.3);
        else
            CanvasManager::getSingletonPtr()->onMoveCamera(-0.3);
    }
    m_fLastScale = [recognizer scale];
}

-(IBAction)onModelLib:(id)sender
{
    FrameManager::getSingletonPtr()->addToMainView("ModelDisplay");
}

-(IBAction)onOpenPic:(id)sender
{
    [self UesrImageClicked];
}

-(IBAction)onSave:(id)sender
{
    //CanvasManager::getSingletonPtr()->printScreen();
//    int left, top, width, height;
//    OgreFramework::getSingletonPtr()->m_pViewport->getActualDimensions(left, top, width, height);
//    
//    Ogre::PixelFormat format = Ogre::PF_A8B8G8R8;
//    int outWidth = width;
//    int outHeight = height;
//    int outBytesPerPixel = Ogre::PixelUtil::getNumElemBytes(format);
//    
//    printf("Left %d, Top %d, Width: %d, Height: %d\n", left, top, width, height);
//    
//    unsigned char *data = new unsigned char [outWidth*outHeight*outBytesPerPixel];
//    Ogre::Box extents(left, top, left + width, top + height);
//    Ogre::PixelBox pb(extents, format, data);
//    OgreFramework::getSingletonPtr()->m_pRenderWnd->copyContentsToMemory(pb);
//    printf("PixelBox: %d, %d, w: %d, h: %d\n", pb.left, pb.right, pb.getWidth(), pb.getHeight());
//    
//    Image().loadDynamicImage(data, width, height, 1, format, false, 1, 0).save(Ogre::macBundlePath() + "/media/ddddd.jpg");
//    delete [] data;
    OgreFramework::getSingletonPtr()->m_pRenderWnd->writeContentsToFile(Ogre::macBundlePath() + "/media/ddddd.jpg");
//    NSData* nsData = [NSData dataWithBytes:pb.data length:pb.getConsecutiveSize()];
//    UIImage* image = [UIImage imageWithData:nsData];
//    
//    UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
    
//    UIView* pMainView;
//    OgreFramework::getSingletonPtr()->m_pRenderWnd->getCustomAttribute("VIEW", &pMainView);
//    //FrameManager::getSingleton().hideAllUIView(true);
//    UIGraphicsBeginImageContext(pMainView.frame.size);
//    [pMainView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    //FrameManager::getSingleton().hideAllUIView(false);
//    UIImageWriteToSavedPhotosAlbum(viewImage,nil,nil,nil);
}

-(IBAction)onBtnSel:(id)sender
{
    [self removeCurGesture];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    m_gestureCur = tap;
    [tap release];
}

-(IBAction)onBtnRemove:(id)sender
{
    if(m_nTagSelModel)
    {
        [self removeCurGesture];
        CanvasManager::getSingletonPtr()->removeCurSel();
        m_nTagSelModel = -1;
    }
    
}

-(IBAction)onBtnScale:(id)sender
{
    [self removeCurGesture];
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinch];
    m_gestureCur = pinch;
    [pinch release];
}

-(IBAction)onBtnMove:(id)sender
{
    [self removeCurGesture];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanMove:)];
    [self addGestureRecognizer:pan];
    m_gestureCur = pan;
    [pan release];
}

-(IBAction)onBtnRotate:(id)sender
{
    [self removeCurGesture];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanRotate:)];
    [self addGestureRecognizer:pan];
    m_gestureCur = pan;
    [pan release];
}

-(void)removeCurGesture
{
    if(m_gestureCur != nil)
    {
        [self removeGestureRecognizer:m_gestureCur];
        m_gestureCur = nil;
    }
}

- (void)UesrImageClicked
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self];
}


#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[NonRotatingUIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        UIWindow* pWin = NULL;
        OgreFramework::getSingletonPtr()->m_pRenderWnd->getCustomAttribute("WINDOW", &pWin);
    
        [pWin.rootViewController presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    int scale = [[UIScreen mainScreen] scale];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float xDif = (image.size.width/scale)/(screenSize.width);
    float yDif = (image.size.height/scale)/(screenSize.height);
    bool bNeedResize = true;
    if(xDif > 1.0 && yDif > 1.0)
    {
        if(xDif > yDif)
        {
            yDif = 1.0/xDif;
            xDif = 1.0/xDif;
        }
        else
        {
            xDif = 1.0/yDif;
            yDif = 1.0/yDif;
        }
    }
    else if(xDif > 1.0)
    {
        yDif = 1.0/xDif;
        xDif = 1.0/xDif;
    }
    else if(yDif > 1.0)
    {
        xDif = 1.0/yDif;
        yDif = 1.0/yDif;
    }
    else
    {
        xDif = 1.0;
        yDif = 1.0;
        bNeedResize = false;
    }
    
    NSData *imageData = nil;
    int nNewWidth = image.size.width*xDif;
    int nNewHeight = image.size.height*yDif;
    printf("nNewWidth %d nNewHeight %d\n",nNewWidth,nNewHeight);
    if(bNeedResize)
    {
        UIImage* subImage = nil;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(nNewWidth, nNewHeight), NO, scale);
        [image drawInRect:CGRectMake(0, 0, nNewWidth, nNewHeight)];
        subImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageData = UIImageJPEGRepresentation(subImage,1.0);
    }
    else
    {
        imageData = UIImageJPEGRepresentation(image,1.0);
    }

    NSString* path = [info objectForKey:UIImagePickerControllerReferenceURL];
    static int texnum = 0;
    String texName = "tex";
    texName += StringConverter::toString(++texnum);
    
    DataStreamPtr stream(OGRE_NEW MemoryDataStream((void*)imageData.bytes, imageData.length));
    Image img;
    img.load(stream,"jpg");
    //img.flipAroundX();
    img.save(Ogre::macBundlePath() + "/media/materials/textures/" + texName + ".jpg");
    
    TexturePtr tex = TextureManager::getSingleton().load(texName+".jpg", ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
    
    //TexturePtr tex = TextureManager::getSingletonPtr()->createManual(texName+"fff", ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME, TextureType::TEX_TYPE_2D,Bitwise::firstPO2From(img.getWidth()) , Bitwise::firstPO2From(img.getHeight()), img.getDepth(), MIP_DEFAULT, img.getFormat());
//    Image img1;
//    img1.load(texName+".jpg",ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
//    tex->loadImage(img1);
    
    //TexturePtr tex = TextureManager::getSingleton().loadImage(texName+".jpg", ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME, img);

    xDif = (nNewWidth/scale)/(screenSize.width);
    yDif = (nNewHeight/scale)/(screenSize.height);
    if(xDif > 1.0 && yDif > 1.0)
    {
        if(xDif > yDif)
        {
            yDif *= 1.0/xDif;
            xDif = 1.0;
        }
        else
        {
            xDif *= 1.0/yDif;
            yDif = 1.0;
        }
    }
    else if(xDif > 1.0)
    {
        yDif *= 1.0/xDif;
        xDif = 1.0;
    }
    else if(yDif > 1.0)
    {
        xDif *= 1.0/yDif;
        yDif = 1.0;
    }

    CanvasManager::getSingletonPtr()->changeBackgroud(tex,xDif,yDif);
}
@end
