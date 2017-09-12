//
//  SNNodeFrameMananger.m
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNodeFrameMananger.h"
#import "SNNodeView.h"
#import "SNRect.h"
#import "UIImage+SN.h"
@interface SNNodeFrameMananger ()

@property (nonatomic,strong) SNNodeView *parent ;
@property (nonatomic,strong) NSMutableArray <SNNodeView *>*childs;
@property (nonatomic,assign) CGFloat NODE_FRAME_MARGIN;
@property (nonatomic,assign) CGFloat needWidth;
@property (nonatomic,assign) CGSize textSize;
@property (nonatomic,assign) CGSize realImageSize;
@property (nonatomic,assign) CGSize tipImageSize;
@property (nonatomic,assign) CGPoint C;
@property (nonatomic,assign) CGPoint D;
@end



static NSString *keyNameRecommendContainerBounds = @"recommendContainerBounds";
static NSString *keyNameTextContainerInset = @"textContainerInset";
static NSString *keyNameAttributeText = @"attributeText";
static NSString *keyNameImageMode = @"imageMode";
static NSString *keyNameImageWidthOnFreedomMode = @"imageWidthOnFreedomMode";
static NSString *keyNameImage = @"_image";
static NSString *keyNameResized = @"resized";
static NSString *keyNameTextFrame = @"textFrame";
static NSString *keyNameImageFrame = @"imageFrame";
static NSString *keyNameTipImage = @"TipImage";
static NSString *keyNameTipImageFrame = @"TipImageFrame";

@implementation SNNodeFrameMananger

-(instancetype)initWithNote:(SNNodeView *)node{
    self = [super init];
    if (self) {
        self.node = node;
        self.attributeText = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"sub_node", @"子主题")];
    }
    return self;
}

#pragma mark - setter getter


-(void)setImage:(UIImage *)image{
    _image = image;
    [self updateNodeFrame];
    [self.node refresh];
}

-(void)setTipImage:(UIImage *)tipImage{
    _tipImage = tipImage;
    [self updateNodeFrame];
    [self.node refresh];
}


-(CGSize)textSize{
    CGSize size = self.recommendContainerBounds.size;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        return CGSizeMake(size.width - self.textContainerInset.left - self.textContainerInset.right,
                          size.height - self.textContainerInset.top - self.textContainerInset.bottom);
    }
    if (self.attributeText == nil) {
        return CGSizeZero;
    }
    
    CGFloat tipImageHolderWidth = self.tipImageSize.width > 1 ? self.tipImageSize.width + self.NODE_FRAME_MARGIN : 0;
    
    CGFloat textWith = self.needWidth - tipImageHolderWidth- self.textContainerInset.left - self.textContainerInset.right - self.NODE_FRAME_MARGIN * 2;
    CGFloat textHight = [self.attributeText boundingRectWithSize:CGSizeMake(textWith, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    return CGSizeMake(textWith, textHight);
    
}
-(CGSize)realImageSize{
    if (self.image == nil) {
        return CGSizeZero;
    }
    CGFloat ratio = self.image.size.width / self.image.size.height;
    CGSize size = CGSizeZero;
    switch (self.imageMode) {
        case SNNodeImageModeFreedom:
            size = CGSizeMake(self.imageWidthOnFreedomMode, self.imageWidthOnFreedomMode/ratio);
            break;
        case SNNodeImageModeLimited:
        {
            CGRect rect = CGRectMake(0, 0, MAX_HEIGHT_OF_IAMGE, MAX_HEIGHT_OF_IAMGE);
            size = CGRectContain(rect, self.image.size).size;
            self.imageWidthOnFreedomMode = size.width;
        }
            break;
        default:
            break;
    }
    return size;
}
-(CGFloat)innerWidth{
    return self.needWidth - self.NODE_FRAME_MARGIN * 2;
}

-(CGFloat)needWidth{
    CGFloat width1 = self.node.frame.size.width;
    CGFloat width2 = self.realImageSize.width + self.tipImageSize.width + self.NODE_FRAME_MARGIN * 2 ;
    if (self.tipImageSize.width > 0) {
        width2 += self.NODE_FRAME_MARGIN;
    }
    
    CGFloat width3 = 0;
    if (!CGRectEqualToRect(self.recommendContainerBounds, CGRectZero)) {
        width3 = self.recommendContainerBounds.size.width;
    }
    CGFloat max = MAX(width1, width2);
    max = MAX(max, width3);
    return max;
}



-(CGSize)tipImageSize{
    if (self.tipImage) {
        CGRect rect = CGRectMake(0, 0, TIP_IMAGE_SIZE, TIP_IMAGE_SIZE);
        CGSize size = CGRectContain(rect, self.tipImage.size).size;
        return size;
    }
    return CGSizeZero;
}


-(CGFloat)NODE_FRAME_MARGIN{
    return self.node.depth == 0 ? 10 : 6;
}
-(SNNodeView *)parent{
    return self.node.parent;
}
-(NSMutableArray<SNNodeView *> *)childs{
    return self.node.childs;
}

-(CGFloat)height{
    CGFloat se = self.node.frame.size.height + MIND_NODE_MARGIN * 2;
    return MAX(se, self.childHeight);
}

-(CGFloat)childHeight{
    NSArray * vchilds = self.node.visibleChilds;
    if (vchilds == nil) {
        return self.node.frame.size.height + MIND_NODE_MARGIN * 2;
    }
    if (vchilds.count == 0) {
        return self.node.frame.size.height + MIND_NODE_MARGIN * 2;
    }
    CGFloat height = 0;
    for (SNNodeView * node in vchilds) {
        height = height + node.frameManager.height;
    }
    return height;
}

-(CGPoint)A{
    return CGPointMake(self.node.frame.origin.x - 2,
                       self.node.frame.origin.y + self.node.frame.size.height /2);

}
-(CGPoint)B{
    return CGPointMake(self.node.frame.origin.x + self.node.frame.size.width + 2,
                       self.node.frame.origin.y + self.node.frame.size.height /2);
}




-(CGPoint)startAnchor{
    if ([self.node isRoot]) {
        return self.node.frameManager.B;
    }
    
    if (self.parent != nil ) {
        return self.node.center.x < self.parent.center.x ? self.A : self.B;
    }
    return self.node.frameManager.B;
}

-(CGPoint)midAnchor{
    if ([self.node isRoot]) {
        return self.node.center;
    }
    if (self.parent != nil ) {
        CGPoint left = self.A;
        CGPoint right = self.B;
        if ([self canChangePahtViewEndPoint]) {
            left.x -= CLOSE_BUTTON_SIZE / 2;
        }
        
        if ([self canChangePahtViewEndPoint]) {
            right.x += CLOSE_BUTTON_SIZE / 2;
        }
        return self.node.center.x < self.parent.center.x ? right : left;
    }
    return self.node.center;
}
-(BOOL)canChangePahtViewEndPoint{
    for (SNNodeView * node in self.parent.childs) {
        if (node.closeButton != nil) {
            return YES;
        }
    }
    return NO;
}
-(CGPoint)endAnchor{
    if ([self.node isRoot]) {
        return self.node.center;
    }
    
    if (self.parent != nil ) {
        if (self.node.childs.count > 0) {
            return self.midAnchor;
        }else{
            CGPoint left = self.A;
            CGPoint right = self.B;
            return self.node.center.x < self.parent.center.x ? right : left;
        }
    }
    return self.node.center;
}


#pragma mark - archive

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.recommendContainerBounds = ((NSValue *)[aDecoder decodeObjectForKey:keyNameRecommendContainerBounds]).CGRectValue;
        self.textContainerInset = ((NSValue *)[aDecoder decodeObjectForKey:keyNameTextContainerInset]).UIEdgeInsetsValue;
        self.attributeText = (NSAttributedString*)[aDecoder decodeObjectForKey:keyNameAttributeText];
        self.imageMode = [aDecoder decodeIntegerForKey:keyNameImageMode];
        self.imageWidthOnFreedomMode = [aDecoder decodeDoubleForKey:keyNameImageWidthOnFreedomMode];
        self.image = [aDecoder decodeObjectForKey:keyNameImage];
        self.tipImage = [aDecoder decodeObjectForKey:keyNameTipImage];
        
        self.resized = [aDecoder decodeBoolForKey:keyNameResized];
        self.textFrame = ((NSValue *)[aDecoder decodeObjectForKey:keyNameTextFrame]).CGRectValue;
        self.imageFrame = ((NSValue *)[aDecoder decodeObjectForKey:keyNameImageFrame]).CGRectValue;
        self.textFrame = ((NSValue *)[aDecoder decodeObjectForKey:keyNameTipImageFrame]).CGRectValue;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSValue valueWithCGRect:self.recommendContainerBounds] forKey:keyNameRecommendContainerBounds];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.textContainerInset] forKey:keyNameTextContainerInset];
    [aCoder encodeObject:self.attributeText forKey:keyNameAttributeText];
    [aCoder encodeInteger:self.imageMode forKey:keyNameImageMode];
    [aCoder encodeDouble:self.imageWidthOnFreedomMode forKey:keyNameImageWidthOnFreedomMode];
    [aCoder encodeObject:self.image forKey:keyNameImage];
    [aCoder encodeObject:self.tipImage forKey:keyNameTipImage];
    [aCoder encodeBool:self.resized forKey:keyNameResized];
    [aCoder encodeObject:[NSValue valueWithCGRect:self.textFrame] forKey:keyNameTextFrame];
    [aCoder encodeObject:[NSValue valueWithCGRect:self.imageFrame] forKey:keyNameImageFrame];
    [aCoder encodeObject:[NSValue valueWithCGRect:self.tipImageFrame] forKey:keyNameTipImageFrame];
}


#pragma mark - methods

-(void)updateNodeFrame{
    
    CGSize size = self.recommendContainerBounds.size;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        self.node.frame = CGRectMake(self.node.frame.origin.x,
                                     self.node.frame.origin.y,
                                     size.width + self.NODE_FRAME_MARGIN * 2,
                                     size.height + self.NODE_FRAME_MARGIN * 2);
        [self.node setNeedsDisplay];
    }
//-------------------------
    CGSize imageSize = self.realImageSize;
    CGSize textSize = self.textSize;
    CGSize tipImageSize = self.tipImageSize;
    CGFloat Marign = self.NODE_FRAME_MARGIN;
    if (self.image != nil && self.attributeText == nil && self.tipImage == nil) {
        CGSize s = CGSizeMake(imageSize.width + Marign * 2,
                              imageSize.height + Marign * 2);
       
        self.textFrame = CGRectZero;
        self.imageFrame = CGRectInset(self.node.bounds, Marign, Marign);
        self.tipImageFrame = CGRectZero;
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    if (self.image != nil && self.attributeText == nil && self.tipImage != nil) {
        CGSize s = CGSizeMake(imageSize.width + tipImageSize.width + Marign * 3,
                              imageSize.height + Marign * 2);
        
        self.textFrame = CGRectZero;
        self.tipImageFrame = CGRectMake(Marign,
                                        (s.height - tipImageSize.height)/2 ,
                                        tipImageSize.width,
                                        tipImageSize.height);
        self.imageFrame = CGRectMake(CGRectGetMaxX(self.tipImageFrame) + Marign,
                                     Marign,
                                     imageSize.width,
                                     imageSize.height);
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    
//-------------------------
    if (self.image != nil && self.attributeText != nil && self.tipImage == nil) {
        CGSize sizeA = CGSizeMake(self.innerWidth, imageSize.height);
        CGSize sizeB = CGSizeMake(textSize.width + self.textContainerInset.left + self.textContainerInset.right,
                                  textSize.height + self.textContainerInset.top + self.textContainerInset.bottom);
        CGFloat h = sizeA.height + sizeB.height + DISTANCE_BETWEEN_TEXT_AND_IMAGE + Marign * 2;
        CGSize s = CGSizeMake(self.needWidth, h);
        
        CGRect fA = CGRectMake(Marign, Marign, sizeA.width, sizeA.height);
        self.imageFrame = CGRectContain(fA, imageSize);
        self.textFrame = CGRectMake(Marign,
                                    Marign + imageSize.height + DISTANCE_BETWEEN_TEXT_AND_IMAGE,
                                    imageSize.width,
                                    sizeB.height);
        self.tipImageFrame = CGRectZero;
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    if (self.image != nil && self.attributeText != nil && self.tipImage != nil) {
        CGSize sizeA = CGSizeMake(self.innerWidth, imageSize.height);
        CGSize sizeB = CGSizeMake(textSize.width + self.textContainerInset.left + self.textContainerInset.right,
                                  textSize.height + self.textContainerInset.top + self.textContainerInset.bottom);
        CGFloat h = sizeA.height + sizeB.height + DISTANCE_BETWEEN_TEXT_AND_IMAGE + Marign * 2;
        CGSize s = CGSizeMake(self.needWidth, h);
        
        self.tipImageFrame = CGRectMake(Marign,
                                        (s.height - tipImageSize.height)/2 ,
                                        tipImageSize.width,
                                        tipImageSize.height);
        self.imageFrame = CGRectMake(CGRectGetMaxX(self.tipImageFrame) + Marign,
                                     Marign,
                                     imageSize.width,
                                     imageSize.height);
        self.textFrame = CGRectMake(CGRectGetMaxX(self.tipImageFrame) + Marign,
                                    Marign + imageSize.height + DISTANCE_BETWEEN_TEXT_AND_IMAGE,
                                    imageSize.width,
                                    sizeB.height);
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    
//-------------------------
    if (self.image == nil && self.attributeText != nil && self.tipImage == nil) {
        CGSize s = CGSizeMake(textSize.width + Marign * 2 + self.textContainerInset.left + self.textContainerInset.right,
                              textSize.height + Marign * 2 + self.textContainerInset.top + self.textContainerInset.bottom);
        
        self.imageFrame = CGRectZero;
        self.textFrame = CGRectInset(self.node.bounds, Marign, Marign);
        self.tipImageFrame = CGRectZero;
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    if (self.image == nil && self.attributeText != nil && self.tipImage != nil) {
        CGSize s = CGSizeMake(textSize.width + tipImageSize.width + Marign * 3 + self.textContainerInset.left + self.textContainerInset.right,
                              textSize.height + Marign * 2 + self.textContainerInset.top + self.textContainerInset.bottom);
        
        self.imageFrame = CGRectZero;
        self.tipImageFrame = CGRectMake(Marign,
                                        (s.height - tipImageSize.height)/2 ,
                                        tipImageSize.width,
                                        tipImageSize.height);
        self.textFrame = CGRectMake(CGRectGetMaxX(self.tipImageFrame) + Marign,
                                    Marign,
                                    textSize.width + self.textContainerInset.left + self.textContainerInset.right,
                                    textSize.height + self.textContainerInset.top + self.textContainerInset.bottom);
        CGRect frame = self.node.frame;
        frame.size = s;
        self.node.frame = frame;
        [self.node setNeedsDisplay];
        return;
    }
    
}


-(CGRect)CGRectContain:(CGRect)rect size:(CGSize)size{
    CGRect ra = CGRectMake(0,
                           0,
                           rect.size.width,
                           rect.size.width * size.height/size.width);
    CGRect rb = CGRectMake(0,
                           0,
                           rect.size.height * size.width / size.height,
                           rect.size.height);
    CGRect inner = ra.size.height * ra.size.width > rb.size.height * rb.size.width ? rb : ra;
    SNRect *inner_sn = [[SNRect alloc]initWithCGRect:inner];
    SNRect *rect_sn = [[SNRect alloc]initWithCGRect:rect];
    inner_sn.center = rect_sn.center;
    inner = inner_sn.rect;
    return inner;
}
CGRect CGRectContain(CGRect rect, CGSize size){
    CGRect ra = CGRectMake(0,
                           0,
                           rect.size.width,
                           rect.size.width * size.height/size.width);
    CGRect rb = CGRectMake(0,
                           0,
                           rect.size.height * size.width / size.height,
                           rect.size.height);
    CGRect inner = ra.size.height * ra.size.width > rb.size.height * rb.size.width ? rb : ra;
    SNRect *inner_sn = [[SNRect alloc]initWithCGRect:inner];
    SNRect *rect_sn = [[SNRect alloc]initWithCGRect:rect];
    inner_sn.center = rect_sn.center;
    inner = inner_sn.rect;
    return inner;
}

CGRect CGRectByTwoPoint(CGPoint point1, CGPoint point2){
    CGRect rect = CGRectMake(point1.x,
                             point1.y,
                             point2.x - point1.x,
                             point2.y - point1.y);
    return CGRectStandardize(rect);
}
@end
