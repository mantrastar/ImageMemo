//
//  IMSystem.m
//  ImageMemo
//
//  Created by Ven Jandhyala on 1/3/24.
//


#import "IMSystem.h"

#import "SystemMem.h"


@interface IMSystem()

@end


@implementation IMSystem

+ (instancetype)mainSystem
{
  static IMSystem * main = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    main = [[IMSystem alloc] init];
  });
  return main;
}

@end

