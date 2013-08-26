//
//  Taxonomy.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/08.
//

#import <Foundation/Foundation.h>
#import "Term.h"
//#import "PostList.h"
@class PostList;

@interface Taxonomy : NSObject

@property (nonatomic, strong) NSDictionary *taxonomy;
@property (nonatomic, strong) NSMutableArray *terms;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) PostList *postList;

- (id)initWithPostList:(PostList *)postList name:(NSString *)name;
- (void)mergeTerms:(NSArray *)newTerms;
- (void)syncTermsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;
    
//- (WPXMLRPCRequestOperation *)operationForTermsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more;

//- (WPXMLRPCRequestOperation *)operationForTaxonomyWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more;
    
@end
