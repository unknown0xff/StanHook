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
    BOOL isMetaClass = inst == [inst class];
    const char* clsName = class_getName([inst class]);
    for (int i = 0; i < stanHookCount; ++i) {
        if (strcmp(stanHookInfoList[i].clsName, clsName) == 0 &&
            strcmp(stanHookInfoList[i].selName, selName) == 0 &&
            stanHookInfoList[i].isMetaClass == isMetaClass) {
            return stanHookInfoList[i].imp;
        }
    }
    return nil;
}

void stanHookMap(Class clsa, Class clsb) {
    BOOL isMetaClass = class_isMetaClass(clsa);
    const char* classa = class_getName(clsa);
    
    Class sbc = [StanHookSpringBoardC class];

    unsigned int count = 0;
    Method* mlist = class_copyMethodList(clsb, &count);
    
    for (unsigned int i = 0; i <count; ++i) {
        Method mb = mlist[i];
        SEL sel = method_getName(mb);
        Method ma = class_getInstanceMethod(clsa, sel);

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
        int idx = stanHookCount;
        stanHookInfoList[idx].clsName = classa;
        stanHookInfoList[idx].selName = sel_getName(sel);
        stanHookInfoList[idx].imp = impa;
        stanHookInfoList[idx].isMetaClass = isMetaClass;
        stanHookCount += 1;
        
        //# mark
        const char* typeEncoding = method_getTypeEncoding(ma);
        class_addMethod(sbc, sel, StanHookSpringBoardf, typeEncoding);
        
        //# Set Hook
        method_setImplementation(ma, impb);
    }
}

void stanHookInstall(const char* classa, Class clsb ) {
    Class clsa = objc_getClass(classa);
    stanHookMap(clsa, clsb);
    Class metaa = object_getClass(clsa);
    Class metab = object_getClass(clsb);
    stanHookMap(metaa, metab);
}
