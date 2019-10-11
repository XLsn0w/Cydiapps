
#import "XXSendButton.h"
#import "AllButtonsView.h"

@interface XXSendButton () {
    
    CGPoint startPoint;
    CGPoint originPoint;
    BOOL isShow;
}

@property (nonatomic, strong) UIButton *button;

@end

@implementation XXSendButton

+ (instancetype)sharedInstance {
    
    static XXSendButton *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[XXSendButton alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    if(self = [super init]) {
        
        self.userInteractionEnabled = YES;

        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, 45, 45);
        [_button addTarget:self action:@selector(gotoFuck) forControlEvents:UIControlEventTouchUpInside];
        _button.backgroundColor = [UIColor lightGrayColor];
        [_button setTitle:@"X" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        _button.titleLabel.numberOfLines = 0;
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_button];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
        [self addGestureRecognizer:longGesture];
        
        _button.layer.cornerRadius = _button.frame.size.width/2;
        _button.layer.masksToBounds = YES;
        
        self.layer.cornerRadius = self.frame.size.width/2;
        self.layer.masksToBounds = YES;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        float x = LTSWidth - 15 - 45;
        self.frame = CGRectMake(x, LTSHeight/2, 45, 45);
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }
    
    return self;
}

- (void)gotoFuck {
    [AllButtonsView sharedInstance].hidden = ![AllButtonsView sharedInstance].hidden;
}

- (void)buttonLongPressed:(UILongPressGestureRecognizer *)sender {
    
    UIView *view = sender.view;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        startPoint = [sender locationInView:sender.view];
        originPoint = view.center;
        [UIView animateWithDuration:.3 animations:^{
            
            view.transform = CGAffineTransformMakeScale(1.1, 1.1);
            view.alpha = 0.7;
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint newPoint = [sender locationInView:sender.view];
        
        CGFloat deltaX = newPoint.x - startPoint.x;
        CGFloat deltaY = newPoint.y - startPoint.y;
        
        originPoint = CGPointMake(view.center.x + deltaX, view.center.y + deltaY);
        
        if(originPoint.x <= (view.bounds.size.width / 2)) {
            originPoint.x = view.bounds.size.width / 2;
        }
        else if(originPoint.x >= ([self superview].frame.size.width - (view.bounds.size.width / 2))) {
            originPoint.x = [self superview].frame.size.width - (view.bounds.size.width / 2);
        }
        if(originPoint.y <= (view.bounds.size.height / 2)) {
            originPoint.y = view.bounds.size.height / 2;
        }
        else if(originPoint.y >= ([self superview].frame.size.height - (view.bounds.size.height / 2))) {
            originPoint.y = [self superview].frame.size.height - (view.bounds.size.height / 2);
        }
        
        view.center = originPoint;
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:.3 animations:^{
            
            view.transform = CGAffineTransformIdentity;
            
            view.alpha = 1.0;
        }];
    }
}
@end
