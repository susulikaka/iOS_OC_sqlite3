//
//  AppDelegate.m
//  SQLITE3
//
//  Created by admin on 16/7/21.
//  Copyright © 2016年 SupingLi. All rights reserved.
//

#import "AppDelegate.h"
#import <sqlite3.h>

@interface AppDelegate ()
{
    sqlite3  *db;
    NSString *susutable;
    NSString *name;
    NSString *age;
    NSString *address;
    char *ERROR;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // get the path
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path objectAtIndex:0];
    NSString * basePa = [documentDir stringByAppendingPathComponent:@"firstDataBase.sqlite"];
    // create or open new dataBase |db|
    if (sqlite3_open([basePa UTF8String],&db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"after create sql fail");
    }
    NSLog(@"%@",basePa);
    [self printQuary:@"open the dataBase"];
    
    // create new table in sql |SUSUTABLE|
    NSString *creatTable = @"CREATE TABLE IF NOT EXISTS SUSUTABLE (name TEXT PRIMARY KEY AUTOINCREMENT,age INTEGER,address TEXT)";
    if (sqlite3_exec(db,[creatTable UTF8String],NULL,NULL,&ERROR) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"create table fail");
    }
    [self printQuary:@"after create the table"];
    
    // delete the old date
    sqlite3_stmt *deleteStmt;
    NSString * deleteData = [NSString stringWithFormat:@"DELETE FROM SUSUTABLE WHERE age=?"];
    const char *deleteSql = [deleteData UTF8String];
    if (sqlite3_prepare_v2(db, deleteSql, -1, &deleteStmt, nil) == SQLITE_OK) {
        sqlite3_bind_int(deleteStmt, 1, 22);
    }
    if (sqlite3_step(deleteStmt) != SQLITE_OK) {
        NSLog(@"delete fail");
    }
    [self printQuary:@"after delete the data : age == 22"];
    

    //1. inset data into |SUSUTABLE| , just inset the date by insert
    NSString * sq1 = [NSString stringWithFormat:@"INSERT INTO susutable (name, age, address) VALUES ('%@', '%@', '%@')", @"张三",@"22",@"西湖区"];
    NSString * sq2 = [NSString stringWithFormat:@"INSERT INTO susutable (name, age, address) VALUES ('%@', '%@', '%@')", @"里斯",@"22",@"西湖区"];
    if (sqlite3_exec(db,[sq1 UTF8String],NULL,NULL,&ERROR) != SQLITE_OK) {
        sqlite3_close(db);
    }
    if (sqlite3_exec(db,[sq2 UTF8String],NULL,NULL,&ERROR) != SQLITE_OK) {
        sqlite3_close(db);
    }
    [self printQuary:@"after insert data"];
    
    //2. insert data into |SUSUTABLE| , prepare the sql and bind the param to the stmt
    char *update = "INSERT OR REPLACE INTO SUSUTABLE(name,age,address)""VALUES(?,?,?);";
    char *errorMsg;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db,update,-1,&stmt,nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt,1,[@"newone" UTF8String],-1,NULL);
        sqlite3_bind_int(stmt,2,11);
        sqlite3_bind_text(stmt,3,[@"文二西路" UTF8String],-1,NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"fail to update the data");
        NSAssert(0, @"error updating: %s",errorMsg);
    }
    [self printQuary:@"update the data newone"];
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return YES;
}

- (void)printQuary:(NSString *)step {
    // quary the db
    sqlite3_stmt *stmt;
    NSString * quary = @"SELECT * FROM SUSUTABLE";
    NSLog(@"------------%@\n",step);
    if (sqlite3_prepare_v2(db, [quary UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            char * name = (char *)sqlite3_column_text(stmt,1);
            NSString * nameStr = [[NSString alloc] initWithUTF8String:name];
            NSLog(@"%@",nameStr);
            
            int age = sqlite3_column_int(stmt,2);
            NSLog(@"%d",age);
            
            char * address = (char *)sqlite3_column_text(stmt,3);
            NSString * addressName = [[NSString alloc ] initWithUTF8String:address];
            NSLog(@"%@",addressName);
        }
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
