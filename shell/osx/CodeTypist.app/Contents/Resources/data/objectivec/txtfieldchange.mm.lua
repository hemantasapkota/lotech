return [=[
-(void)textFieldViewDidChange:(NSNotification*)notification
{
    UITextView *textView = (UITextView *)notification.object;

    CGRect line = [textView caretRectForPosition:
                            textView.selectedTextRange.start];

    CGFloat overflow =
            CGRectGetMaxY(line) - (textView.contentOffset.y +
            CGRectGetHeight(textView.bounds) - textView.contentInset.bottom -
            textView.contentInset.top);

    if ( overflow > 0  && overflow < FLT_MAX)
    {
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7;

        [UIView animateWithDuration:_animationDuration
                delay:0
                options:(_animationCurve |
                         UIViewAnimationOptionBeginFromCurrentState)
                animations:^{
            [textView setContentOffset:offset];
        } completion:NULL];
    }
}
]=]
