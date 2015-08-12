//
//  PopupTextFieldInput.m
//  Lee
//
//  Created by lichq on 7/21/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "PopupTextFieldInput.h"

@implementation PopupTextFieldInput


- (IBAction)goOK:(id)sender{
    if ([self.delegate respondsToSelector:@selector(goOK:)]) {
        [self.delegate goOK:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.tfName resignFirstResponder];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
