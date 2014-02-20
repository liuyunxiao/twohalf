//
//  TestView.h
//  OGame
//
//  Created by mac on 13-6-6.
//
//
typedef enum
{
    EMET_Null = -1,
    EMET_Move,
    EMET_Scale,
    EMET_Rotate,
} EModelEditType;

@interface NonRotatingUIImagePickerController : UIImagePickerController
@end
@interface TopView : UIView<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UIView*            m_viewEdit;
    IBOutlet UIView*            m_viewMenu;
    
    UIGestureRecognizer*        m_gestureCur;
    
    float                       m_fLastScale;
    int                         m_nTagSelModel;
    
    CGPoint                     m_pointLastRotate;
}
@end
