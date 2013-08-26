//
//  Term.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/08.
//

#import <CoreData/CoreData.h>
#import "Blog.h"

@interface Term : NSManagedObject

@property (nonatomic, strong) NSNumber *termID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *parent;
//@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *taxonomy;
@property (nonatomic, strong) NSString *description_;
@property (nonatomic, strong) NSString *termGroup;
@property (nonatomic, strong) NSMutableSet *posts;
@property (nonatomic, strong) Blog *blog;

+ (Term *)newTermForBlog:(Blog *)blog;
+ (Term *)findWithBlog:(Blog *)blog andTermID:(NSNumber *)termID andTaxonomy:(NSString *)taxonomy;
+ (Term *)createOrReplaceFromDictionary:(NSDictionary *)termInfo forBlog:(Blog *)blog;
+ (BOOL)existsName:(NSString *)name forBlog:(Blog *)blog withParentId:(NSNumber *)parentId taxonomy:(NSString *)taxonomy;

// Takes the NSDictionary from a XMLRPC call and creates or updates a post
+ (void)createTerm:(NSString *)name parent:(Term *)parent taxonomy:(NSString *)taxonomy forBlog:(Blog *)blog success:(void (^)(Term *term))success failure:(void (^)(NSError *error))failure;


@end
