//
//  YSingletonSynthesizer.h
//  YuanGongBao
//
//  Created by wangyaqing on 14-9-9.
//  Copyright (c) 2014年 YiJie. All rights reserved.
//

#ifndef YuanGongBao_YSingletonSynthesizer_h
#define YuanGongBao_YSingletonSynthesizer_h

#ifndef SYNTHESIZE_ARC_SINGLETON_FOR_CLASS

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define SYNTHESIZE_ARC_SINGLETON_FOR_CLASS_HEADER(SINGLETONCLASSNAME)	\
+ (SINGLETONCLASSNAME*)sharedInstance;


#define SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(SINGLETONCLASSNAME)	\
\
static volatile SINGLETONCLASSNAME* sharedInstance##SINGLETONCLASSNAME = nil;	\
\
+ (SINGLETONCLASSNAME*)sharedInstanceNoSynch	\
{	\
return (SINGLETONCLASSNAME*)sharedInstance##SINGLETONCLASSNAME;	\
}	\
\
+ (SINGLETONCLASSNAME*)sharedInstanceSynch	\
{	\
@synchronized(self)	\
{	\
if(nil == sharedInstance##SINGLETONCLASSNAME)	\
{	\
sharedInstance##SINGLETONCLASSNAME = [[self alloc] init];	\
}	\
}	\
return (SINGLETONCLASSNAME*)sharedInstance##SINGLETONCLASSNAME;	\
}	\
\
+ (SINGLETONCLASSNAME*)sharedInstance	\
{	\
return [self sharedInstanceSynch]; \
}	\
\
+ (id)allocWithZone:(NSZone*) zone	\
{	\
@synchronized(self)	\
{	\
if (nil == sharedInstance##SINGLETONCLASSNAME)	\
{	\
sharedInstance##SINGLETONCLASSNAME = [super allocWithZone:zone];	\
if(nil != sharedInstance##SINGLETONCLASSNAME)	\
{	\
}	\
}	\
}	\
return (id)sharedInstance##SINGLETONCLASSNAME;	\
}
#endif

#endif
