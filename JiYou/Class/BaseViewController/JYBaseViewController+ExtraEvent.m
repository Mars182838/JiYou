//
//  BKBaseViewController+KeyboardEvent.m
//  BEIKOO
//
//  Created by leo on 14-9-9.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "JYBaseViewController+ExtraEvent.h"

@implementation JYBaseViewController (ExtraEvent)

#pragma mark - 添加以及删除键盘出现通知

- (void)addKeyboardWillShowNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)removeKeyboardWillShowNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)addKeyboardDidShowNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}
- (void)removeKeyboardDidShowNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}


#pragma mark - 添加以及删除键盘隐藏通知
- (void)addKeyboardWillHideNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)removeKeyboardWillHideNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)addKeyboardDidHideNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}
- (void)removeKeyboardDidHideNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


#pragma mark - 添加以及删除键盘改变大小通知(中英文切换)
- (void)addKeyboardWillChangeFrameNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)removeKeyboardWillChangeFrameNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)addKeyboardDidChangeFrameNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)removeKeyboardDidChangeFrameNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}


#pragma mark - UITextField 内容变化的通知
- (void)addTextFieldTextDidChangeNotfication{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)removeTextFieldTextDidChangeNotfication{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)addTextFieldTextDidBeginEditingNotfication{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBeginEditing:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)removeTextFieldTextDidBeginEditingNotfication{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
}

- (void)addTextFieldTextDidEndEditingNotfication{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidEndEditing:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)removeTextFieldTextDidEndEditingNotfication{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
}


#pragma mark - KeyboardEventDelegate

- (void)keyboardWillShow:(NSNotification*)notification{
    
}

- (void)keyboardDidShow:(NSNotification*)notification{
    
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
}

- (void)keyboardDidHide:(NSNotification*)notification{
    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification{
    
}

- (void)keyboardDidChangeFrame:(NSNotification*)notification{
    
}

#pragma mark - TextFieldEventDelegate
- (void)textFieldTextDidChange:(NSNotification *)notification{
    
}

- (void)textFieldTextDidBeginEditing:(NSNotification *)notification{
    
}

- (void)textFieldTextDidEndEditing:(NSNotification *)notification{
    
}

@end
