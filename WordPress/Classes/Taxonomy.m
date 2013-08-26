//
//  Taxonomy.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/08.
//

#import "Taxonomy.h"
#import "PostList.h"

@implementation Taxonomy

@synthesize taxonomy;
@synthesize terms;
@synthesize postList;
@synthesize name;

- (id)initWithPostList:(PostList *)_postList name:(NSString *)_name {
    self.postList = _postList;
    self.name = _name;
    [self syncTermsWithSuccess:nil failure:nil loadMore:nil];
    [self syncTaxonomyWithSuccess:nil failure:nil loadMore:nil];
    
    return self;
}

- (void)syncTaxonomyWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    WPXMLRPCRequestOperation *operation = [self operationForTaxonomyWithSuccess:success failure:failure loadMore:more];
    [self.postList.blog.api enqueueXMLRPCRequestOperation:operation];
}

- (void)syncTermsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure{
    [self syncTermsWithSuccess:success failure:failure loadMore:NO];
}

- (void)syncTermsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    WPXMLRPCRequestOperation *operation = [self operationForTermsWithSuccess:success failure:failure loadMore:more];
    [self.postList.blog.api enqueueXMLRPCRequestOperation:operation];
}

- (WPXMLRPCRequestOperation *)operationForTaxonomyWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    
    //NSDictionary *extra = [NSDictionary dictionaryWithObject:self.name forKey:@"taxonomy"];
    NSArray *parameters = [self.postList.blog getXMLRPCArgsWithExtra:self.name];
    WPXMLRPCRequest *request = [self.postList.blog.api XMLRPCRequestWithMethod:@"wp.getTaxonomy" parameters:parameters];
    WPXMLRPCRequestOperation *operation = [self.postList.blog.api XMLRPCRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.postList.blog isDeleted] || self.postList.blog.managedObjectContext == nil)
            return;
        
        self.taxonomy = responseObject;
        
        //[self mergePosts:response];

        //self.lastPostsSync = [NSDate date];
        //self.isSyncingPosts = NO;

        if (success) { success(); }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //self.isSyncingPosts = NO;
        
        if (failure) { failure(error); }
    }];
    
    return operation;        
}

- (WPXMLRPCRequestOperation *)operationForTermsWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure loadMore:(BOOL)more {
    NSArray *parameters = [self.postList.blog getXMLRPCArgsWithExtra:self.name];
    WPXMLRPCRequest *request = [self.postList.blog.api XMLRPCRequestWithMethod:@"wp.getTerms" parameters:parameters];
    WPXMLRPCRequestOperation *operation = [self.postList.blog.api XMLRPCRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([self.postList.blog isDeleted] || self.postList.blog.managedObjectContext == nil)
            return;
        
        self.terms = [NSMutableArray array];
        
        [self mergeTerms:responseObject];
        
        if (success) { success(); }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) { failure(error); }
    }];
    return operation;
}

- (void)mergeTerms:(NSArray *)newTerms {
    if ([self.postList.blog isDeleted] || self.postList.blog.managedObjectContext == nil)
        return;

	NSMutableArray *termsToKeep = [NSMutableArray array];
    for (NSDictionary *termInfo in newTerms) {
        Term *newTerm = [Term createOrReplaceFromDictionary:termInfo forBlog:self.postList.blog];
        
        //if (newTerm != nil && [newTerm.taxonomy isEqualToString:self.name]) {
        //if (newTerm != nil && [newTerm.taxonomy isEqualToString:[self.taxonomy valueForKey:@"name"]]) {
        if (newTerm != nil) {
            [termsToKeep addObject:newTerm];
            [self.terms addObject:newTerm];
        } else {
            //WPFLog(@"-[Category createOrReplaceFromDictionary:forBlog:] returned a nil category: %@", categoryInfo);
            WPFLog(@"-[Term createOrReplaceFromDictionary:forBlog:] returned a nil term: %@", newTerm);
        }
    }
    //TODO: syncedTermsは、本来は、今までのデータを読み込んで取得する。
	NSMutableArray *syncedTerms = self.terms;
	if (syncedTerms && (syncedTerms.count > 0)) {
		for (Term *term in syncedTerms) {
			if(![termsToKeep containsObject:term]) {
				WPLog(@"Deleting Term: %@", term);
				[[self.postList.blog managedObjectContext] deleteObject:term];
			}
		}
    }
    [self.postList.blog dataSave];
}
@end
