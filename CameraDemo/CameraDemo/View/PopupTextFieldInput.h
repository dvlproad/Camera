//
//  PopupTextFieldInput.h
//  Lee
//
//  Created by lichq on 7/21/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupTextFieldInput;
@protocol PopupTextFieldInputDelegate <NSObject>

- (void)goOK:(PopupTextFieldInput *)popupTextFieldInput;

@end



@interface PopupTextFieldInput : UIView

@property(nonatomic, strong) id<PopupTextFieldInputDelegate> delegate;
@property(nonatomic, strong) IBOutlet UITextField *tfName;

@end
