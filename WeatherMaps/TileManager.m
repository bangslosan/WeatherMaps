//
//  TileManager.m
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import "TileManager.h"

@interface TileManager ()
- (void)enumerateTileAreaInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale usingBlock:(void (^)(NSInteger x, NSInteger y, NSInteger z, float scale))block;
- (Tile *)tileForX:(NSInteger)x y:(NSInteger)y z:(NSInteger)z scale:(float)scale;
- (void)insertNewTileWithX:(NSInteger)x y:(NSInteger)y z:(NSInteger)z scale:(float)scale completion:(void (^)(void))completion;
- (void)mergeSubContextChanges:(NSNotification *)notification;
@end



@implementation TileManager

@synthesize managedObjectContext = __managedObjectContext;


#pragma mark - Instance

+ (id)sharedTileManager
{
    static dispatch_once_t pred;
    static TileManager *tileManager = nil;
    
    dispatch_once(&pred, ^{ tileManager = [[self alloc] init]; });
    return tileManager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.managedObjectContext = nil;
    
    [super dealloc];
}


#pragma mark - Public methods

- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale
{
    NSMutableArray *tiles = [NSMutableArray array];

    [self enumerateTileAreaInMapRect:rect zoomScale:scale usingBlock:^(NSInteger x, NSInteger y, NSInteger z, float scale){
        Tile *tile = [self tileForX:x y:y z:z scale:scale];
        
        if (tile) {
            [tiles addObject:tile];
        }
    }];
    
    return [NSArray arrayWithArray:tiles];
}

- (void)loadTilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale completion:(void (^)(void))completion
{
    
    [self enumerateTileAreaInMapRect:rect zoomScale:scale usingBlock:^(NSInteger x, NSInteger y, NSInteger z, float scale){
        [self insertNewTileWithX:x y:y z:z scale:scale completion:completion];
    }];
}


#pragma mark - Private methods

- (void)enumerateTileAreaInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale usingBlock:(void (^)(NSInteger x, NSInteger y, NSInteger z, float scale))block {
    double numTilesAt1_0 = MKMapSizeWorld.width / TILE_SIZE;
    NSInteger zoomLevelAt1_0 = log2(numTilesAt1_0);
    NSInteger z = MAX(0, zoomLevelAt1_0 + floor(log2f(scale) + 0.5));
    
    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / TILE_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / TILE_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / TILE_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / TILE_SIZE);
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            block(x, y, z, scale);
        }
    }
}

- (Tile *)tileForX:(NSInteger)x y:(NSInteger)y z:(NSInteger)z scale:(float)scale
{

	NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:x], @"x",
                            [NSNumber numberWithInt:y], @"y",
                            [NSNumber numberWithInt:z], @"z",
                            [NSNumber numberWithFloat:scale], @"scale"
                            , nil];
	
	NSManagedObjectModel *model =  [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
	NSFetchRequest *fetch = [model fetchRequestFromTemplateWithName:@"FetchRequest" substitutionVariables:subs];
	
	NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetch error:&error];
	if (error) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		return nil;
	}
    
    if (results.count == 0) {
        return nil;
    }
    
    return [results objectAtIndex:0];

}

- (void)insertNewTileWithX:(NSInteger)x y:(NSInteger)y z:(NSInteger)z scale:(float)scale completion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{

        Tile *tile = [self tileForX:x y:y z:z scale:scale];
        if (tile) {
            return;
        }

        NSManagedObjectContext *subManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [subManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
        [subManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeSubContextChanges:) name:NSManagedObjectContextDidSaveNotification object:subManagedObjectContext];
            
            NSString *urlString = [@"http://mt0.google.com/mapslt?"
                                   stringByAppendingFormat:@"lyrs=%@%%7Cinvert:%d&x=%d&y=%d&z=%d&w=256&h=256",
                                   TEMPERATURE,
                                   CHAR_INVERT,
                                   x, y, z
                                   ];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

            if (!error) {
                
                Tile *tile = [NSEntityDescription insertNewObjectForEntityForName:@"Tile" inManagedObjectContext:subManagedObjectContext];
                tile.x = [NSNumber numberWithInt:x];
                tile.y = [NSNumber numberWithInt:y];
                tile.z = [NSNumber numberWithInt:z];
                tile.scale = [NSNumber numberWithFloat:scale];
                tile.image = data;
                
                NSError *saveError = nil;
                if (![subManagedObjectContext save:&saveError]) {
                    NSLog(@"error, %@ %@", saveError, [saveError localizedDescription]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
                
            } else {
                NSLog(@"error: %@, %@", error, [error localizedDescription]);
            }

            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:subManagedObjectContext];
            [subManagedObjectContext release];
            
        });
    });
}

- (void)mergeSubContextChanges:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

@end
