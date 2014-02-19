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
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinch];
    [pinch release];

    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    [pan release];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    [tap release];
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint pos = [recognizer locationInView:self];
    CanvasManager::getSingletonPtr()->onPanGesture(Vector2(pos.x/320.0f,pos.y/568.0f));
}
- (void) handleTap:(UITapGestureRecognizer*) recognizer
{
    CGPoint pos = [recognizer locationInView:self];
    CanvasManager::getSingletonPtr()->onClickModel(Vector2(pos.x/320.0f,pos.y/568.0f));
}

-(IBAction)onModelLib:(id)sender
{
    FrameManager::getSingletonPtr()->addToMainView("ModelDisplay");
}

// 缩放
-(void)handlePinch:(id)sender {
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    if([(UIPinchGestureRecognizer*)sender scale] > _lastScale)
    {
        CanvasManager::getSingletonPtr()->onPinchGesture(-0.3);
    }
    else
    {
        CanvasManager::getSingletonPtr()->onPinchGesture(0.3);
    }
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}


-(IBAction)onOpenPic:(id)sender
{
    [self UesrImageClicked];
}

-(IBAction)onSave:(id)sender
{
    UIImage* image = nil;
    UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
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
    printf("screenSize %f %f\n",screenSize.width,screenSize.height);
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
