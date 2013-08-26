//
//  PostList.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/03.
//

#import "PostList.h"


@interface PostList (PrivateMethods)
- (NSArray *)syncedPosts;
- (NSArray *)syncedPostsWithEntityName:(NSString *)entityName;
@end

@implementation PostList

@synthesize postType;
@synthesize blog;
@synthesize hasOlderPosts;
@synthesize posts;
@synthesize isSyncingPosts;
@synthesize lastPostsSync;
@synthesize lastUpdateWarning;
@synthesize taxonomies;

- (id)initWithBlog:(Blog *)_blog postType:(PostType *)_postType{
    if (self = [super init]) {
        self.blog = _blog;
        self.postType = _postType;
        
        [self syncPostsWithSuccess:nil failure:nil loadMore:nil];
        [self syncTaxonomies];
    }
    return self;
}

- (NSArray *)syncedPostsWithEntityName:(NSString *)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[self.blog managedObjectContext]]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(remoteStatusNumber = %@) AND (postID != NULL) AND (original == NULL) AND (blog = %@) AND (postType = %@)",
							  [NSNumber numberWithInt:AbstractPostRemoteStatusSync],
                              self.blog,
                              self.postType.name];
                              //[self.postType valueForKey:@"name"]];
    
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date_created_gmt" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *array = [[self.blog managedObjectContext] executeFetchRequest:request error:&error];
    if (array == nil) {
        array = [NSArray array];
    }
    return array;
}

- (NSArray *)syncedPosts {
    return [self syncedPostsWithEntityName:@"Post"];
}

- (void)syncPostsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    if (self.isSyncingPosts) {
        WPLog(@"Already syncing posts. Skip");
        return;
    }
    self.isSyncingPosts = YES;

    WPXMLRPCRequestOperation *operation = [self operationWithSuccess:success failure:failure loadMore:more];
    [self.blog.api enqueueXMLRPCRequestOperation:operation];
}

- (WPXMLRPCRequestOperation *)operationWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    int num;

    // Don't load more than 20 posts if we aren't at the end of the table,
    // even if they were previously donwloaded
    // 
    // Blogs with long history can get really slow really fast, 
    // with no chance to go back
    int postBatchSize = 40;
    if (more) {
        num = MAX([self.posts count], postBatchSize);
        if ([self.hasOlderPosts boolValue]) {
            num += postBatchSize;
        }
    } else {
        num = postBatchSize;
    }
    
    // numberも指定しておく。
    NSDictionary *extra = @{ @"post_type" : self.postType.name, @"number" : [NSNumber numberWithInt:num] };
    NSArray *parameters = [self.blog getXMLRPCArgsWithExtra:extra];
    WPXMLRPCRequest *request = [self.blog.api XMLRPCRequestWithMethod:@"wp.getPosts" parameters:parameters];
    WPXMLRPCRequestOperation *operation = [self.blog.api XMLRPCRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.blog isDeleted] || self.blog.managedObjectContext == nil)
            return;
        
        NSArray *response = (NSArray *)responseObject;

        // If we asked for more and we got what we had, there are no more posts to load
        if (more && ([response count] <= [self.posts count])) {
            self.hasOlderPosts = [NSNumber numberWithBool:NO];
        } else if (!more) {
            //we should reset the flag otherwise when you refresh this blog you can't get more than 20 posts
            self.hasOlderPosts = [NSNumber numberWithBool:YES];
        }

        [self mergePosts:response];

        self.lastPostsSync = [NSDate date];
        self.isSyncingPosts = NO;

        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WPFLog(@"Error syncing posts: %@", [error localizedDescription]);
        self.isSyncingPosts = NO;

        if (failure) {
            failure(error);
        }
    }];
    
    return operation;        
}

-(void) mergePosts:(NSArray *)newPosts {
    
    // Don't even bother if blog has been deleted while fetching posts
    if ([self.blog isDeleted] || self.blog.managedObjectContext == nil)
        return;

    self.posts = [NSMutableArray array];
    NSMutableArray *postsToKeep = [NSMutableArray array];
    for (NSDictionary *postInfo in newPosts) {
        NSNumber *postID = [[postInfo objectForKey:@"post_id"] numericValue];
        Post *newPost = [Post findOrCreateWithBlog:self.blog andPostID:postID];
        if (newPost.remoteStatus == AbstractPostRemoteStatusSync) {
            [newPost updateFromDictionary:postInfo];
        }
        [postsToKeep addObject:newPost];
        
        [self.posts addObject:newPost];
    }

    NSArray *syncedPosts = [self syncedPosts];
    for (Post *post in syncedPosts) {

        if (![postsToKeep containsObject:post]) {  /*&& post.blog.blogID == self.blogID*/
			//the current stored post is not contained "as-is" on the server response

            if (post.revision) { //edited post before the refresh is finished
				//We should check if this post is already available on the blog
				BOOL presence = NO;

				for (Post *currentPostToKeep in postsToKeep) {
					if([currentPostToKeep.postID isEqualToNumber:post.postID]) {
						presence = YES;
						break;
					}
				}
				if( presence == YES ) {
					//post is on the server (most cases), kept it unchanged
				} else {
					//post is deleted on the server, make it local, otherwise you can't upload it anymore
					post.remoteStatus = AbstractPostRemoteStatusLocal;
					post.postID = nil;
					post.permaLink = nil;
				}
			} else {
				//post is not on the server anymore. delete it.
                WPLog(@"Deleting post: %@", post.postTitle);
                WPLog(@"%d posts left", [self.posts count]);
                [[self.blog managedObjectContext] deleteObject:post];
            }
        }
    }
    
    [self.blog dataSave];
}

// この投稿タイプに結びついているタクソノミーを準備する
- (void)syncTaxonomies{
    //NSArray *array = [self.postType valueForKey:@"taxonomies"];
    NSArray *array = self.postType.taxonomies;
    Taxonomy *taxonomy = nil;
    self.taxonomies = [NSMutableArray array];
    for (NSString *name in array) {
        taxonomy = [[Taxonomy alloc] initWithPostList:self name:name];
        //[self.taxonomies arrayByAddingObject:taxonomy];
        [self.taxonomies addObject:taxonomy];
    }
}

@end
