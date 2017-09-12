//
//  NSObject+id.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "NSObject+id.h"

@implementation NSObject (id)


-(BOOL)isPad{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        return YES;
    }
    return NO;
}
-(CGSize)getImageSizeWithType:(NSString *)idType{
    
    if ([idType isEqualToString:ID_TYPE_XIAOYICUN]) {//xiao一寸
        return  CGSizeMake(259, 378);
    }
    else if ([idType isEqualToString:ID_TYPE_YICUN]){//yi cun
        return  CGSizeMake(295, 413);
    }
    else if ([idType isEqualToString:ID_TYPE_DAYICUN]){//da yi cun
        return  CGSizeMake(389, 567);
    }
    else if ([idType isEqualToString:ID_TYPE_XIAOERCUN]){//xiao er cun
        return  CGSizeMake(413, 531);
    }
    else if ([idType isEqualToString:ID_TYPE_ERCUN]){ // er cun
        return  CGSizeMake(413, 578);
    }
    else if ([idType isEqualToString:ID_TYPE_SANCUNCUN]){// san cun
        return  CGSizeMake(649, 992);
    }
    else if ([idType isEqualToString:ID_TYPE_WUCUN]){//wu cun
        return  CGSizeMake(1050, 1500);
    }
    else if ([idType isEqualToString:ID_TYPE_S2R]){//wu cun
        return  CGSizeMake(600, 900);
    }
    else if ([idType isEqualToString:ID_TYPE_2R]){//wu cun
        return  CGSizeMake(750, 1050);
    }
    else if ([idType isEqualToString:ID_TYPE_S3R]){//wu cun
        return  CGSizeMake(974, 1417);
    }
    else if ([idType isEqualToString:ID_TYPE_3R]){//wu cun
        return  CGSizeMake(1050, 1500);
    }
    else if ([idType isEqualToString:ID_TYPE_4R]){//wu cun
        return  CGSizeMake(1200, 1800);
    }
    return CGSizeMake(295, 413);
}

-(UIColor *)getBGColorWithType:(IDPhotoBGType)type{
    
    if (type == IDPhotoBGTypeRed)
        return RED_BG_COLOR;
    else if (type == IDPhotoBGTypeBlue)
        return BLUE_BG_COLOR;
    else if (type == IDPhotoBGTypeWhite)
        return WHITE_BG_COLOR;
    else
        return BLUE_BG_COLOR;
    
}
@end
