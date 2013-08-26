//
//  Term.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/08.
//

#import "Term.h"

@implementation Term
@dynamic termID, name, parent, slug, taxonomy, description_, termGroup;
//@dynamic count;
@dynamic blog;
@dynamic posts;

+ (Term *)newTermForBlog:(Blog *)blog {
    Term *term = [[Term alloc] initWithEntity:[NSEntityDescription entityForName:@"Term"
                                                          inManagedObjectContext:[blog managedObjectContext]]
                                                  insertIntoManagedObjectContext:[blog managedObjectContext]];
    term.blog = blog;
    return term;
}

+ (BOOL)existsName:(NSString *)name forBlog:(Blog *)blog withParentId:(NSNumber *)parentId taxonomy:(NSString *)taxonomy {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name like %@) AND (taxonomy = %@) AND (parent = %@)",
                              name, taxonomy, (parentId ? parentId : [NSNumber numberWithInt:0])];
    NSSet *items = [blog.terms filteredSetUsingPredicate:predicate];
    if ((items != nil) && (items.count > 0)) {
        // Already exists
        return YES;
    } else {
        return NO;
    }
}

+ (Term *)createOrReplaceFromDictionary:(NSDictionary *)termInfo forBlog:(Blog *)blog {
    if ([termInfo objectForKey:@"term_id"] == nil) { return nil; }
    if ([termInfo objectForKey:@"name"] == nil) { return nil; }
    
    Term *term = [Term findWithBlog:blog andTermID:[[termInfo objectForKey:@"term_id"] numericValue] andTaxonomy:[termInfo valueForKey:@"taxonomy"]];
    
    if (term == nil) {
        term = [Term newTermForBlog:blog];
    }
    
    term.termID     = [[termInfo objectForKey:@"term_id"] numericValue];
    term.name       = [termInfo objectForKey:@"name"];
    term.parent     = [[termInfo objectForKey:@"parent"] numericValue];
    
    term.slug       = [termInfo objectForKey:@"slug"];
    term.termGroup  = [termInfo objectForKey:@"term_group"];
    term.taxonomy   = [termInfo objectForKey:@"taxonomy"];
    term.description_  = [termInfo objectForKey:@"description"];
    
    return term;
}

+ (Term *)findWithBlog:(Blog *)blog andTermID:(NSNumber *)termID andTaxonomy:(NSString *)taxonomy {
    NSSet *terms = blog.terms;
    NSSet *results = [terms filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"termID == %@ AND taxonomy == %@",termID,taxonomy]];
    if (results && (results.count > 0)) {
        return [[results allObjects] objectAtIndex:0];
    }
    return nil;
}

+ (void)createTerm:(NSString *)name parent:(Term *)parent taxonomy:(NSString *)taxonomy forBlog:(Blog *)blog success:(void (^)(Term *))success failure:(void (^)(NSError *))failure {
    Term *term = [Term newTermForBlog:blog];
    term.name = name;
    term.taxonomy = taxonomy;
	if (parent.termID){
		term.parent = parent.termID;
    } else {
		term.parent = nil;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                term.name, @"name",
                                term.taxonomy, @"taxonomy",
                                term.parent, @"parent",
                                nil];
    
    void (^successBlock)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
         NSNumber *termID = responseObject;
         int newID = [termID intValue];
         if (newID > 0) {
             term.termID = [termID numericValue];
             [blog dataSave];
             
             if (success) { success(term); }
         }
    };

    void (^failureBlock)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation, NSError *error) {
         WPLog(@"Error while creating term: %@", [error localizedDescription]);
         // Just in case another thread has saved while we were creating
         [[blog managedObjectContext] deleteObject:term];
         [blog dataSave]; // Commit core data changes
        
         if (failure) { failure(error); }
     };
    
    [blog.api callMethod:@"wp.newTerm"
              parameters:[blog getXMLRPCArgsWithExtra:parameters]
                 success:successBlock
                 failure:failureBlock];
}

@end
