//
//  TestView.h
//  OGame
//
//  Created by mac on 13-6-6.
//
//

@interface UIModelItem : UIView
{
    IBOutlet UILabel*       mTexName;
}
-(void)onUpdate:(id)data;
@end

@interface ModelDisplay : UIView
{
    IBOutlet UIScrollView*      mScrollModels;
}
@end
