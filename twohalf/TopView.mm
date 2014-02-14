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
@implementation NonRotatingUIImagePickerController
// Disable Landscape mode.
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end

@implementation TopView

-(IBAction)onModelLib:(id)sender
{
//    UIImage* image = [UIImage imageNamed:@"bg_common.png"];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    //UIImage *compressedImage = [UIImage imageWithData:imageData];
//    
//    DataStreamPtr stream(OGRE_NEW MemoryDataStream((void*)imageData.bytes, imageData.length));
//    Image img;
//    img.load(stream,"png");
//    static int texnum = 0;
//    String texName = "tex";
//    texName += StringConverter::toString(++texnum);
//    TexturePtr tex = TextureManager::getSingleton().loadImage( texName,ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME, img, TEX_TYPE_2D, MIP_DEFAULT);
//    Image imgsave;
//    tex->convertToImage(imgsave,false);
//    CanvasManager::getSingletonPtr()->change(tex);
//    imgsave.save(Ogre::macBundlePath() + "/mm.png");
    [self UesrImageClicked];
    //FrameManager::getSingletonPtr()->addToMainView("ModelDisplay");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    CanvasManager::getSingletonPtr()->onClickModel(Vector2(pos.x/568.0f,pos.y/320.0f));
    return [super touchesBegan:touches withEvent:event];
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
    //userImageView.image = image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    //UIImage *compressedImage = [UIImage imageWithData:imageData];
    
    static int texnum = 0;
    String texName = "tex";
    texName += StringConverter::toString(++texnum);
    
    DataStreamPtr stream(OGRE_NEW MemoryDataStream((void*)imageData.bytes, imageData.length));
    Image img;
    img.load(stream,"png");
    img.save(Ogre::macBundlePath() + "/media/materials/textures/" + texName + ".png");
    
    TexturePtr tex = TextureManager::getSingleton().load(texName+".png", ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
    
    //Image imgsave;
    //tex->convertToImage(imgsave,false);
    CanvasManager::getSingletonPtr()->change(tex);
}
@end
