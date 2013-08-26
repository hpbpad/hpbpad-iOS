//
//  PostList.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/03.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import "Post.h"
#import "Taxonomy.h"
#import "PostType.h"

@interface PostList : NSObject

//@property (nonatomic, strong) NSDictionary *postType;
@property (nonatomic, strong) PostType *postType;
@property (nonatomic, strong) Blog *blog;
@property (nonatomic, strong) NSNumber *hasOlderPosts;
//@property (nonatomic, strong) NSSet *posts;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, assign) BOOL isSyncingPosts;
@property (nonatomic, strong) NSDate *lastPostsSync;
@property (nonatomic, strong) NSString *lastUpdateWarning;
@property (nonatomic, strong) NSMutableArray *taxonomies;

- (id)initWithBlog:(Blog *)_blog postType:(NSDictionary *)_postType;
- (void)syncPostsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more;
    
@end
