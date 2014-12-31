return [=[
- (void)layoutSubviews
{
  if (_mode == _FBTweakTableViewCellModeBoolean) {

    [_switch sizeToFit];

    _accessoryView.bounds = _switch.bounds;

  } else if (_mode == _FBTweakTableViewCellModeInteger ||
             _mode == _FBTweakTableViewCellModeReal) {
    [_stepper sizeToFit];

    CGRect textFrame = CGRectMake(0, 0, self.bounds.size.width / 4,
    self.bounds.size.height);

    CGRect stepperFrame =
      CGRectMake(textFrame.size.width + 6.0, (textFrame.size.height -
      _stepper.bounds.size.height) / 2, _stepper.bounds.size.width,
      _stepper.bounds.size.height);

    _textField.frame = CGRectIntegral(textFrame);
    _stepper.frame = CGRectIntegral(stepperFrame);

    CGRect accessoryFrame = CGRectUnion(stepperFrame, textFrame);

    _accessoryView.bounds = CGRectIntegral(accessoryFrame);

  } else if (_mode == _FBTweakTableViewCellModeString) {
    CGFloat margin = CGRectGetMinX(self.textLabel.frame);

    CGFloat textFieldWidth = self.bounds.size.width - (margin * 3.0) -
    [self.textLabel sizeThatFits:CGSizeZero].width;

    CGRect textBounds = CGRectMake(0, 0, textFieldWidth, self.bounds.size.height);
    _textField.frame = CGRectIntegral(textBounds);
    _accessoryView.bounds = CGRectIntegral(textBounds);

  } else if (_mode == _FBTweakTableViewCellModeAction) {
    _accessoryView.bounds = CGRectZero;
  }

  // This positions the accessory view, so call it after updating its bounds.
  [super layoutSubviews];
}
]=]
