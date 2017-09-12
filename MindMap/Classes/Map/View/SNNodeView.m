//
//  SNNodeView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNodeView.h"
#import "SNRect.h"
#import "SNNodeFrameMananger.h"
#import "SNPathLayer.h"
#import "SNPathView.h"
#import "UIColor+SN.h"
#import "SNDefaultStyle.h"
@interface SNNodeView ()

@property (assign, nonatomic) CGFloat baseline;
@property (assign, nonatomic) CGFloat rightBand;
@property (assign, nonatomic) CGFloat leftBand;
@property (assign, nonatomic) BOOL justCreate;
@property (strong, nonatomic) SNPathLayer *borderLayer;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;


@end

static NSString *const KeyNameJustCreate = @"justCreate";
static NSString *const KeyNameAssociatePathView = @"associatePathView";
static NSString *const KeyNameborderLayer = @"borderLayer";
static NSString *const KeyNameStyle = @"style";
static NSString *const KeyNameStatus = @"status";
static NSString *const KeyNameDirection = @"direction";
static NSString *const KeyNameChilds = @"childs";
static NSString *const KeyNameFrameManager = @"frameManager";
static NSString *const KeyNameVisible = @"visible";
static NSString *const KeyNameChildVisiable = @"childVisiable";
static NSString *const KeyNameNeedRedraw = @"needRedraw";



@implementation SNNodeView


#pragma mark - setter getter

-(SNPathLayer *)borderLayer{
    if (_borderLayer == nil) {
        _borderLayer =  [[SNPathLayer alloc]init];
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.lineWidth = LINE_WIDTH;
        _borderLayer.lineCap = kCALineCapRound;
        _borderLayer.lineJoin = kCALineJoinRound;
    }
    return _borderLayer;
}

-(CAGradientLayer *)gradientLayer{
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0, 1);
        _gradientLayer.locations = @[@(0.0f), @(1.0f)];
    }
    return _gradientLayer;
}

-(SNPathView *)associatePathView{
    if (_associatePathView == nil) {
        _associatePathView = [[SNPathView alloc]init];
        
    }
    return _associatePathView;
}

-(SNNodeFrameMananger *)frameManager{
    if (_frameManager == nil) {
        _frameManager = [[SNNodeFrameMananger alloc]initWithNote:self];
    }
    return _frameManager;
}


-(void)setStyle:(SNMapStyle *)style{
    _style = style;
    self.style.depth = self.depth;
    self.associatePathView.strokeColor =  self.depth == 0 ? [UIColor clearColor] : _style.lineColor;
    [self.closeButton setImage:_style.openImage forState:(UIControlStateSelected)];
    [self.closeButton setImage:_style.closeImage forState:(UIControlStateNormal)];
    [self updateLayer];
    [self updateLinkedPathBetweenNode];
    [self.frameManager updateNodeFrame];
    [self updateCloseButtonFrame];
}


-(void)setStatus:(SNNodeStatus)status{
    _status = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNNodeViewStatusChangedNotification object:self];
}

-(void)setDirection:(SNNodeDirection)direction{
    _direction = direction;
    if (_direction != SNNodeDirectionNone) {
        for (SNNodeView * node in self.childs) {
            node.direction = _direction;
        }
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self updateLinkedPathBetweenNode];
    [self updateLayer];
    [self updateCloseButtonFrame];
}

-(NSMutableArray<SNNodeView *> *)visibleChilds{
    NSMutableArray <SNNodeView *>* tmp = [NSMutableArray array];
    for (SNNodeView * node in self.childs) {
        if (node.visiable) {
            [tmp addObject:node];
        }
    }
    return tmp;
}

-(void)setVisiable:(BOOL)visiable{
    _visiable = visiable;
    CGFloat alpha = _visiable ? 1 : 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = alpha;
        self.associatePathView.alpha = alpha;
        self.closeButton.alpha = alpha;
    } completion:^(BOOL finished) {
        self.hidden = !_visiable;
        self.associatePathView.hidden = !_visiable;
        self.closeButton.hidden = !_visiable;
    }];
    
}

-(NSInteger)depth{
    if (self.parent == nil) {
        return 0;
    }
    return self.parent.depth + 1;
}

-(CGFloat)baseline{
    return self.center.y;
}

-(CGFloat)rightBand{
    SNRect *frame_sn = [[SNRect alloc]initWithCGRect:self.frame];
    return frame_sn.rightCenter.x + MIND_NODE_HAND_LENGTH;
}
-(CGFloat)leftBand{
    SNRect *frame_sn = [[SNRect alloc]initWithCGRect:self.frame];
    return frame_sn.leftCenter.x + MIND_NODE_HAND_LENGTH;
}

-(UIButton *)closeButton{
    if (_closeButton == nil && self.childs.count > 0) {
        CGRect frame = CGRectMake(0, 0, CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE);
        _closeButton = [[UIButton alloc]initWithFrame:frame];
        UIImage * closeImage = self.style.closeImage;
        
        UIImage * openImage = self.style.openImage;
        [_closeButton setImage:closeImage forState:(UIControlStateNormal)];
        [_closeButton setImage:openImage forState:(UIControlStateSelected)];
        [_closeButton addTarget:self action:@selector(closeOrOpenChild) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _closeButton;
}
-(void)closeOrOpenChild{
    self.closeButton.selected = !self.closeButton.selected;
    BOOL visible = YES;
    if (self.closeButton.selected == YES) {
        visible = NO;
    }
    self.childVisiable = visible;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNNodeViewCloseChangedNotification
                                                        object:self];
    [SNPathView animateWithDuration:0.3 animations:^{
        [self refresh];
    }];
    
}

-(void)setChildVisiable:(BOOL)childVisiable{
    _childVisiable = childVisiable;
    
    for (SNNodeView * childNode in self.childs) {
        if (self.closeButton != nil && self.closeButton.selected == YES) {
            childNode.childVisiable = NO;
            childNode.visiable = NO;
        }else{
            childNode.childVisiable = childVisiable;
            childNode.visiable = childVisiable;
        }
    }
}

#pragma mark - init
-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, CHILD_NODE_SIZE.width, CHILD_NODE_SIZE.height)];
    if (self) {
        [self configure];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
        
    }
    return self;
}
-(void)configure{
    _visiable = YES;
    _justCreate = YES;
    _childVisiable = YES;
    _style = [[SNDefaultStyle alloc]init];
    _status = SNNodeStatusNormal;
    _direction = SNNodeDirectionNone;
    _childs = [NSMutableArray array];
    _needRedraw = YES;
    self.clearsContextBeforeDrawing = NO;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    [self.layer addSublayer:self.borderLayer];
    self.backgroundColor = [UIColor clearColor];
}


-(void)setNeedsDisplay{
    if (_needRedraw) {
        [super setNeedsDisplay];
    }
}

-(void)drawRect:(CGRect)rect{
    if (self.style != nil) {
        UIImage * image =[self imageForGradientRect:rect
                                         startColor:self.style.startColor.CGColor
                                           endColor:self.style.endColor.CGColor];
        CGRect newRect = CGRectMake(0, 0, rect.size.width, rect.size.height + 2);
        [image drawInRect:newRect];
    }
    CGRect textFrame = self.frameManager.textFrame;

    NSMutableAttributedString * attributeText = [[NSMutableAttributedString alloc]initWithAttributedString:self.frameManager.attributeText];
    
    [attributeText addAttribute:NSForegroundColorAttributeName value:self.style.textColor range:NSMakeRange(0, attributeText.length)];
    if (!CGRectEqualToRect(textFrame, CGRectZero)&&attributeText!=nil) {
        CGRect r = CGRectMake(textFrame.origin.x + self.frameManager.textContainerInset.left,
                              textFrame.origin.y + self.frameManager.textContainerInset.top,
                              textFrame.size.width - self.frameManager.textContainerInset.left - self.frameManager.textContainerInset.right,
                              textFrame.size.height - self.frameManager.textContainerInset.top - self.frameManager.textContainerInset.bottom);
        
        [attributeText drawInRect:r];
    }
    CGRect imageFrame = self.frameManager.imageFrame;
    UIImage * image = self.frameManager.image;
    if (!CGRectEqualToRect(imageFrame, CGRectZero)&&image!=nil) {
        [image drawInRect:imageFrame];
    }
    
    CGRect tipImageFrame = self.frameManager.tipImageFrame;
    UIImage * tipImage = self.frameManager.tipImage;
    if (!CGRectEqualToRect(tipImageFrame, CGRectZero)&&tipImage != nil) {
        [tipImage drawInRect:tipImageFrame];
    }
    
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.style.depth != self.depth) {
        self.style.depth = self.depth;
    }
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.visiable = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNNodeViewDidMoveToSuperView object:self];
}
-(void)removeFromSuperview{
    [super removeFromSuperview];
    self.visiable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNNodeViewDidRemoveFromSuperView object:self];
}

#pragma mark - metohs

-(void)clearToInitialView{
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.layer.cornerRadius = 0;
}
-(SNNodeView *)root{
    if (self.parent == nil) {
        return self;
    }else{
        return [self.parent root];
    }
}

-(void)refresh{
    NSLog(@"refresh");
    [[self root] refreshChild];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNNodeViewBeenRefreshNotification object:self userInfo:nil];
}
-(void)refreshChild{
    if (self.visiable == NO) {
        return;
    }
    CGFloat height = self.frameManager.childHeight;
    CGFloat top = self.baseline - height / 2;
    for (SNNodeView * node in self.visibleChilds) {
        if (node.justCreate) {
            [UIView setAnimationsEnabled:NO];
        }
        SNRect * node_frame_sn = [[SNRect alloc] initWithCGRect:node.frame];
        node_frame_sn.left = self.rightBand;
        node_frame_sn.top = top + (node.frameManager.height - node_frame_sn.rect.size.height) / 2;
        top = top + node.frameManager.height;
        node.frame = node_frame_sn.rect;
        [node refreshChild];
        if (node.justCreate) {
            [UIView setAnimationsEnabled:YES];
        }
        node.justCreate = NO;
        [node updateCloseButtonFrame];
    }
}
-(void)updateLayer{
   
    self.borderLayer.lineWidth = LINE_WIDTH;
    self.borderLayer.strokeColor = self.style.borderColor.CGColor;
    self.layer.masksToBounds = YES;
    CGFloat radius = MIN(MAX(5, MAX(self.bounds.size.height, self.bounds.size.width)* 0.15), 10);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    self.layer.cornerRadius = radius;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.borderLayer.path = path.CGPath;
    [CATransaction commit];
}



-(void)updateLinkedPathBetweenNode{
    
    for (SNNodeView * node in self.childs) {
        node.associatePathView.startPoint = self.frameManager.startAnchor;
    }
    self.associatePathView.endPoint = self.frameManager.endAnchor;
    self.associatePathView.midPoint =  self.frameManager.midAnchor;
    
    
    CGPoint start  = self.parent.frameManager.startAnchor;
    if (CGPointEqualToPoint(start, CGPointZero)) {
        start = self.center;
    }
    self.associatePathView.startPoint = start;
}

-(void)updateCloseButtonFrame{
    if (![self isRoot]) {
        if (self.closeButton) {
            [self.superview addSubview:self.closeButton];
        }
    }
    CGPoint point = self.frameManager.A;
    point.x -= CLOSE_BUTTON_SIZE / 2;
    self.closeButton.center = point;
}


-(void)remove{
    for (SNNodeView * node in self.visibleChilds) {
        [node remove];
    }
    if (self.visiable) {
        [self.parent.childs removeObject:self];
        if (self.parent.childs.count <= 0) {
            [self.parent.closeButton removeFromSuperview];
            self.parent.closeButton = nil;
        }
        [self removeFromSuperview];
    }
    
}

-(BOOL)isRoot{
    return self.parent == nil;
}

-(SNNodeView *)append{

    SNNodeView * v = [[SNNodeView alloc]init];
    [self.childs addObject:v];
    v.parent = self;
    v.frame = CGRectMake(self.center.x, self.center.y, 0, 0);
    v.style = [[[self.style class] alloc]init];
    v.style.depth = self.depth + 1;
    v.associatePathView.strokeColor = v.style.lineColor;
    v.borderLayer.strokeColor = v.style.lineColor.CGColor;
    [self.superview addSubview:v];
    if (![self isRoot]) {
        if (self.closeButton) {
            [self.superview addSubview:self.closeButton];
        }
    }
    [SNPathView animateWithDuration:0.3 animations:^{
        [self refresh];
    }];
    return v;
}
- (UIImage *)imageForGradientRect:(CGRect)rect
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.gradientLayer.frame = rect;
    self.gradientLayer.colors = @[(__bridge id)startColor,
                                  (__bridge id)endColor];
    [self.gradientLayer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Archive


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _justCreate = [aDecoder decodeBoolForKey:KeyNameJustCreate];
        _borderLayer = [aDecoder decodeObjectForKey:KeyNameborderLayer];
        _associatePathView = [aDecoder decodeObjectForKey:KeyNameAssociatePathView];
        _style = [aDecoder decodeObjectForKey:KeyNameStyle];
        _status = [aDecoder decodeIntegerForKey:KeyNameStatus];
        _direction = [aDecoder decodeIntegerForKey:KeyNameDirection];
        _childs = [aDecoder decodeObjectForKey:KeyNameChilds];
        _childs = [NSMutableArray arrayWithArray:_childs];
        for (SNNodeView * node in _childs) {
            node.parent = self;
        }
        _frameManager = [aDecoder decodeObjectForKey:KeyNameFrameManager];
        _frameManager.node = self;
        _visiable = [aDecoder decodeBoolForKey:KeyNameVisible];
        _childVisiable = [aDecoder decodeBoolForKey:KeyNameChildVisiable];
        _needRedraw = [aDecoder decodeBoolForKey:KeyNameNeedRedraw];
        [self.layer addSublayer:_borderLayer];
        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.justCreate forKey:KeyNameJustCreate];
    [aCoder encodeObject:self.borderLayer forKey:KeyNameborderLayer];
    [aCoder encodeObject:self.associatePathView forKey:KeyNameAssociatePathView];
    [aCoder encodeObject:self.style forKey:KeyNameStyle];
    [aCoder encodeInteger:self.status forKey:KeyNameStatus];
    [aCoder encodeInteger:self.direction forKey:KeyNameDirection];
    [aCoder encodeObject:self.childs forKey:KeyNameChilds];
    [aCoder encodeObject:self.frameManager forKey:KeyNameFrameManager];
    [aCoder encodeBool:self.visiable forKey:KeyNameVisible];
    [aCoder encodeBool:self.childVisiable forKey:KeyNameChildVisiable];
    [aCoder encodeBool:self.needRedraw forKey:KeyNameNeedRedraw];
}


-(void)dealloc{
    NSLog(@"%s",__func__);
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
    
}


@end
