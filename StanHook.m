//# coding by *
#import <Foundation/Foundation.h>
#import <objc/objc.h>
#import <objc/objc-api.h>
#import <objc/runtime.h>

#import "StanHook.h"

extern void StanHookSpringBoardf(void);

static StanHookInfo stanHookInfoList[STANHOOK_MAX];
static int stanHookCount = 0;

@interface StanHookSpringBoardC: NSObject
@property (nonatomic, weak) id impInst;
@end

@implementation StanHookSpringBoardC
-(instancetype)initWithInstance:(id)inst {
    if ((self = [super init])) {
        self.impInst = inst;
    }
    return self;
}
@end

id stanHookMakeSprigBoard(id inst) {
    return [[StanHookSpringBoardC alloc] initWithInstance:inst];
}

id stanHookGetInst(id inst) {
    return [inst impInst];
}

IMP stanHookGetIMP(id inst, const char* selName) {
    Class cls = [inst class];
    BOOL isMeta = inst == cls;
    for (int i = 0; i < stanHookCount; ++i) {
        if (stanHookInfoList[i].cls == cls &&
            stanHookInfoList[i].isMeta == isMeta &&
            strcmp(stanHookInfoList[i].selName, selName) == 0) {
            return stanHookInfoList[i].imp;
        }
    }
    return nil;
}

void stanHookMethodList(Class clsa, Class clsb, BOOL isMeta) {
    Class sbc = [StanHookSpringBoardC class];
    
    clsb = isMeta ? object_getClass(clsb): clsb;
    Class clst = isMeta ? object_getClass(clsa): clsa;

    unsigned int count = 0;
    Method* mlist = class_copyMethodList(clsb, &count);
    
    for (unsigned int i = 0; i <count; ++i) {
        Method mb = mlist[i];
        SEL sel = method_getName(mb);
        Method ma = class_getInstanceMethod(clst, sel);

        if (stanHookCount >= STANHOOK_MAX) {
            printf("StanHook: Hook too many method.\n");
            return;
        }

        if (!ma) {
            printf("StanHook: Could not hook method:%s\n",
                   sel_getName(sel));
            return;
        }

        IMP impa = method_getImplementation(ma);
        IMP impb = method_getImplementation(mb);
        
        //# mark Callback
        StanHookInfo* hookInfo = &stanHookInfoList[stanHookCount++];

        hookInfo->cls = clsa;
        hookInfo->isMeta = isMeta;
        hookInfo->selName = sel_getName(sel);
        hookInfo->imp = impa;
        
        //# mark
        const char* typeEncoding = method_getTypeEncoding(ma);
        class_addMethod(sbc, sel, StanHookSpringBoardf, typeEncoding);
        
        //# Set Hook
        method_setImplementation(ma, impb);
    }
}

void stanHookInstall(const char* classa, Class clsb) {
    Class clsa = objc_getClass(classa);
    stanHookMethodList(clsa, clsb, NO);
    stanHookMethodList(clsa, clsb, YES);
}
