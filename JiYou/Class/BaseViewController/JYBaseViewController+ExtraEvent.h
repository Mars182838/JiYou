//
//  BKBaseViewController+KeyboardEvent.h
//  BEIKOO
//
//  Created by leo on 14-9-9.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "JYBaseViewController.h"

@protocol KeyboardEventDelegate <NSObject>
@optional
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardDidShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;
- (void)keyboardDidHide:(NSNotification*)notification;
- (void)keyboardWillChangeFrame:(NSNotification*)notification;
- (void)keyboardDidChangeFrame:(NSNotification*)notification;

@end

@protocol TextFieldEventDelegate <NSObject>
@optional
- (void)textFieldTextDidChange:(NSNotification*)notification;
- (void)textFieldTextDidBeginEditing:(NSNotification*)notification;
- (void)textFieldTextDidEndEditing:(NSNotification*)notification;

@end


@interface JYBaseViewController (ExtraEvent) <KeyboardEventDelegate, TextFieldEventDelegate>

- (void)addKeyboardWillShowNotification;
- (void)removeKeyboardWillShowNotification;

- (void)addKeyboardWillHideNotification;
- (void)removeKeyboardWillHideNotification;

- (void)addKeyboardWillChangeFrameNotification;
- (void)removeKeyboardWillChangeFrameNotification;

- (void)addKeyboardDidShowNotification;
- (void)removeKeyboardDidShowNotification;

- (void)addKeyboardDidHideNotification;
- (void)removeKeyboardDidHideNotification;

- (void)addKeyboardDidChangeFrameNotification;
- (void)removeKeyboardDidChangeFrameNotification;

- (void)addTextFieldTextDidChangeNotfication;
- (void)removeTextFieldTextDidChangeNotfication;

- (void)addTextFieldTextDidBeginEditingNotfication;
- (void)removeTextFieldTextDidBeginEditingNotfication;

- (void)addTextFieldTextDidEndEditingNotfication;
- (void)removeTextFieldTextDidEndEditingNotfication;

@end
