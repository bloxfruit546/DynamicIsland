#import "DICompactView.h"

@implementation DICompactView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 7, 20, 20)];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    _iconView.clipsToBounds = YES;
    _iconView.layer.cornerRadius = 4;
    _iconView.hidden = YES;
    [self addSubview:_iconView];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 8, 74, 18)];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    _statusLabel.textAlignment = NSTextAlignmentLeft;
    _statusLabel.hidden = YES;
    [self addSubview:_statusLabel];
}

- (void)showIcon:(UIImage *)icon statusText:(NSString *)text {
    _iconView.image  = icon;
    _iconView.hidden = (icon == nil);
    _statusLabel.text   = text;
    _statusLabel.hidden = (text.length == 0);
    
    if (icon != nil && text.length > 0) {
        _iconView.frame = CGRectMake(8, 7, 20, 20);
        _statusLabel.frame = CGRectMake(34, 8, 78, 18);
    } else if (text.length > 0) {
        _statusLabel.frame = CGRectMake(10, 8, 100, 18);
    }
}

- (void)showDefault {
    _iconView.hidden   = YES;
    _statusLabel.hidden = YES;
}

@end
