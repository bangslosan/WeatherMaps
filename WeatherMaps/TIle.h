//
//  Tile.h
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright (c) 2011年 FLCL.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tile : NSManagedObject {
@private
}
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * scale;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * z;

@end
