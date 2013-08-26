//
//  PostType.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/16.
//

#import "PostType.h"

@implementation PostType
@dynamic name, label, taxonomies ,hierarchical ,public ,show_ui ,builtin ,has_archive ,map_meta_cap ,menu_position ,menu_icon ,show_in_menu;
@dynamic blog;

+ (PostType *)newPostTypeForBlog:(Blog *)blog {
    PostType *postType = [[PostType alloc] initWithEntity:[NSEntityDescription entityForName:@"PostType"
                                                          inManagedObjectContext:[blog managedObjectContext]]
                                                  insertIntoManagedObjectContext:[blog managedObjectContext]];
    postType.blog = blog;
    return postType;
}

+ (PostType *)createOrReplaceFromDictionary:(NSDictionary *)postTypeInfo forBlog:(Blog *)blog {
    if ([postTypeInfo objectForKey:@"name"] == nil) { return nil; }
    PostType *postType = [PostType findWithBlog:blog andName:[postTypeInfo objectForKey:@"name"]];
    
    if (postType == nil) {
        postType = [PostType newPostTypeForBlog:blog];
    }
    postType.name = [postTypeInfo objectForKey:@"name"];
    postType.label = [postTypeInfo objectForKey:@"label"];
    postType.menu_icon = [postTypeInfo objectForKey:@"menu_icon"];
    postType.taxonomies = [postTypeInfo objectForKey:@"taxonomies"];
    postType.hierarchical   = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"hierarchical"] intValue]];
    postType.public         = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"public"] intValue]];
    postType.show_ui        = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"show_ui"] intValue]];
    postType.builtin       = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"_builtin"] intValue]];
    postType.has_archive    = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"has_archive"] intValue]];
    postType.menu_position  = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"menu_position"] intValue]];
    postType.show_in_menu   = [NSNumber numberWithBool:[[postTypeInfo objectForKey:@"show_in_menu"] intValue]];
    return postType;
}

+ (PostType *)findWithBlog:(Blog *)blog andName:(NSString *)name {
    NSSet *postTypes = blog.postTypes;
    NSSet *results = [postTypes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
    if (results && (results.count > 0)) {
        return [[results allObjects] objectAtIndex:0];
    }
    return nil;
}

@end