//
//  TestView.h
//  OGame
//
//  Created by mac on 13-6-6.
//
//
@interface NonRotatingUIImagePickerController : UIImagePickerController

@end
@interface TopView : UIView<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@property(nonatomic,assign) float lastScale;
@end
