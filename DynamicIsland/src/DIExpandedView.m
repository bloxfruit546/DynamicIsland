#import "DIExpandedView.h"

// ── Notification subview ──────────────────────────────────────
@interface DINotificationSubview : UIView
@property (nonatomic, strong) UIImageView *appIconView;
@property (nonatomic, strong) UILabel     *appNameLabel;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *bodyLabel;
- (void)updateWithContent:(DIActivityContent *)content;
@end

@implementation DINotificationSubview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _appIconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 28, 28)];
        _appIconView.layer.cornerRadius = 6;
        _appIconView.clipsToBounds = YES;
        _appIconView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_appIconView];
        
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 12, 160, 14)];
        _appNameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        _appNameLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        [self addSubview:_appNameLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 28, 220, 16)];
        _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        
        _bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 52, 256, 16)];
        _bodyLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _bodyLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        _bodyLabel.numberOfLines = 1;
        [self addSubview:_bodyLabel];
    }
    return self;
}

- (void)updateWithContent:(DIActivityContent *)content {
    _appIconView.image  = content.icon;
    _appNameLabel.text  = content.subtitle;  // app name
    _titleLabel.text    = content.title;
    _bodyLabel.text     = content.detail;
}
@end

// ── Music subview ─────────────────────────────────────────────
@interface DIMusicSubview : UIView
@property (nonatomic, strong) UIImageView *artworkView;
@property (nonatomic, strong) UILabel     *songLabel;
@property (nonatomic, strong) UILabel     *artistLabel;
@property (nonatomic, strong) UIView      *progressBar;
@property (nonatomic, strong) UIView      *progressTrack;
- (void)updateWithContent:(DIActivityContent *)content;
@end

@implementation DIMusicSubview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _artworkView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 68, 68)];
        _artworkView.layer.cornerRadius = 8;
        _artworkView.clipsToBounds = YES;
        _artworkView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        [self addSubview:_artworkView];
        
        _songLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 14, 196, 18)];
        _songLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _songLabel.textColor = [UIColor whiteColor];
        [self addSubview:_songLabel];
        
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 34, 196, 14)];
        _artistLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _artistLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self addSubview:_artistLabel];
        
        // Progress track
        _progressTrack = [[UIView alloc] initWithFrame:CGRectMake(86, 56, 196, 3)];
        _progressTrack.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        _progressTrack.layer.cornerRadius = 1.5;
        [self addSubview:_progressTrack];
        
        // Progress bar (50% placeholder)
        _progressBar = [[UIView alloc] initWithFrame:CGRectMake(86, 56, 98, 3)];
        _progressBar.backgroundColor = [UIColor whiteColor];
        _progressBar.layer.cornerRadius = 1.5;
        [self addSubview:_progressBar];
    }
    return self;
}

- (void)updateWithContent:(DIActivityContent *)content {
    _artworkView.image = content.artwork;
    _songLabel.text    = content.title;
    _artistLabel.text  = content.subtitle;
}
@end

// ── Call subview ──────────────────────────────────────────────
@interface DICallSubview : UIView
@property (nonatomic, strong) UIView  *greenDot;
@property (nonatomic, strong) UILabel *callerLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSTimer *pulseTimer;
- (void)updateWithContent:(DIActivityContent *)content;
- (void)startPulse;
- (void)stopPulse;
@end

@implementation DICallSubview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _greenDot = [[UIView alloc] initWithFrame:CGRectMake(12, 24, 12, 12)];
        _greenDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.85 blue:0.4 alpha:1.0];
        _greenDot.layer.cornerRadius = 6;
        [self addSubview:_greenDot];
        
        _callerLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 12, 248, 22)];
        _callerLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _callerLabel.textColor = [UIColor whiteColor];
        [self addSubview:_callerLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 36, 248, 16)];
        _statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        _statusLabel.textColor = [UIColor colorWithRed:0.2 green:0.85 blue:0.4 alpha:1.0];
        [self addSubview:_statusLabel];
    }
    return self;
}

- (void)updateWithContent:(DIActivityContent *)content {
    _callerLabel.text = content.title;
    _statusLabel.text = content.subtitle;
    [self startPulse];
}

- (void)startPulse {
    [self stopPulse];
    _pulseTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(doPulse)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)stopPulse {
    [_pulseTimer invalidate];
    _pulseTimer = nil;
}

- (void)doPulse {
    [UIView animateWithDuration:0.3
                     animations:^{ self.greenDot.transform = CGAffineTransformMakeScale(1.3f, 1.3f); }
                     completion:^(BOOL f) {
        [UIView animateWithDuration:0.3 animations:^{
            self.greenDot.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)dealloc {
    [self stopPulse];
}
@end

// ── DIExpandedView (main container) ──────────────────────────
@interface DIExpandedView ()
@property (nonatomic, strong) DINotificationSubview *notifView;
@property (nonatomic, strong) DIMusicSubview         *musicView;
@property (nonatomic, strong) DICallSubview          *callView;
@end

@implementation DIExpandedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _notifView = [[DINotificationSubview alloc] initWithFrame:self.bounds];
    _notifView.hidden = YES;
    [self addSubview:_notifView];
    
    _musicView = [[DIMusicSubview alloc] initWithFrame:self.bounds];
    _musicView.hidden = YES;
    [self addSubview:_musicView];
    
    _callView = [[DICallSubview alloc] initWithFrame:self.bounds];
    _callView.hidden = YES;
    [self addSubview:_callView];
}

- (void)updateWithContent:(DIActivityContent *)content {
    [self hideAllSubviews];
    
    switch (content.type) {
        case DIActivityTypeNotification:
            [_notifView updateWithContent:content];
            _notifView.hidden = NO;
            break;
        case DIActivityTypeMusic:
            [_musicView updateWithContent:content];
            _musicView.hidden = NO;
            break;
        case DIActivityTypeCall:
            [_callView updateWithContent:content];
            _callView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)clearContent {
    [self hideAllSubviews];
    [_callView stopPulse];
}

- (void)hideAllSubviews {
    _notifView.hidden = YES;
    _musicView.hidden = YES;
    _callView.hidden  = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _notifView.frame = self.bounds;
    _musicView.frame = self.bounds;
    _callView.frame  = self.bounds;
}

@end
