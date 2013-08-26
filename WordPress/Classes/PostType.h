//
//  PostType.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/16.
//

#import <CoreData/CoreData.h>
#import "Blog.h"

@interface PostType : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *menu_icon;
@property (nonatomic, strong) NSArray *taxonomies;
@property (nonatomic, strong) NSNumber *hierarchical;
@property (nonatomic, strong) NSNumber *public;
@property (nonatomic, strong) NSNumber *show_ui;
@property (nonatomic, strong) NSNumber *builtin;
@property (nonatomic, strong) NSNumber *has_archive;
@property (nonatomic, strong) NSNumber *map_meta_cap;
@property (nonatomic, strong) NSNumber *menu_position;
@property (nonatomic, strong) NSNumber *show_in_menu;

@property (nonatomic, strong) Blog *blog;

+ (PostType *)newPostTypeForBlog:(Blog *)blog;
+ (PostType *)createOrReplaceFromDictionary:(NSDictionary *)postTypeInfo forBlog:(Blog *)blog;
+ (PostType *)findWithBlog:(Blog *)blog andName:(NSString *)name;
    
@end
