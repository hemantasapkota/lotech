return [=[
@interface MBProgressHUD () {
  BOOL useAnimation;
  SEL methodForExecution;
  id targetForExecution;
  id objectForExecution;
  UILabel *label;
  UILabel *detailsLabel;
  BOOL isFinished;
  CGAffineTransform rotationTransform;
}

@property (atomic, MB_STRONG) UIView *indicator;
@property (atomic, MB_STRONG) NSTimer *graceTimer;
@property (atomic, MB_STRONG) NSTimer *minShowTimer;
@property (atomic, MB_STRONG) NSDate *showStarted;

@end
]=]
