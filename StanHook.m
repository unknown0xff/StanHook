//# coding by *
#import <Foundation/Foundation.h>
#import <objc/objc.h>
#import <objc/objc-api.h>
#import <objc/runtime.h>

#import "StanHook.h"

static stanhook_node_t stanhook_node_list[STANHOOK_MAX];
static int stanhook_node_count = 0;

@interface StanhookXselfclass: NSObject
@property (nonatomic, weak) id realSelf;
+ (instancetype)XselfWithRealSelf:(id)realSelf;
@end

@implementation StanhookXselfclass
+ (instancetype)XselfWithRealSelf:(id)realSelf {
    StanhookXselfclass *xself;
    if ((xself = [[StanhookXselfclass alloc] init])) {
        xself.realSelf = realSelf;
    }
    return xself;
}
@end

id stanhook_make_xself(id real_self) {
    return [StanhookXselfclass XselfWithRealSelf:real_self];
}

id stanhook_get_real_self(StanhookXselfclass *xself) {
    return xself.realSelf;
}

BOOL is_inst_kindof_class(id inst, Class cls) {
    return [inst isKindOfClass:cls] || [inst class] == cls;
}

IMP stanhook_get_imp(id real_self, const char* sel_name) {
    Class cls = [real_self class];
    BOOL is_meta = real_self == cls;
    for (int i = 0; i < stanhook_node_count; ++i) {
        if (is_inst_kindof_class(real_self, stanhook_node_list[i].cls) &&
            stanhook_node_list[i].is_meta == is_meta &&
            strcmp(stanhook_node_list[i].sel_name, sel_name) == 0) {
            return stanhook_node_list[i].imp;
        }
    }
    return nil;
}

void stanhook_hook_methods(Class clsa, Class clsb, BOOL isMeta) {
    Class XselfClass = [StanhookXselfclass class];
    
    clsb = isMeta ? object_getClass(clsb): clsb;
    Class clst = isMeta ? object_getClass(clsa): clsa;

    unsigned int count = 0;
    Method* mlist = class_copyMethodList(clsb, &count);
    
    for (unsigned int i = 0; i <count; ++i) {
        Method mb = mlist[i];
        SEL sel = method_getName(mb);
        Method ma = class_getInstanceMethod(clst, sel);

        if (stanhook_node_count >= STANHOOK_MAX) {
            return;
        }

        if (!ma) {
            fprintf(stderr, "stanhook: could not hook method:%s\n",
                   sel_getName(sel));
            return;
        }

        IMP impa = method_getImplementation(ma);
        IMP impb = method_getImplementation(mb);

        //# mark Callback
        stanhook_node_t* node = &stanhook_node_list[stanhook_node_count++];

        node->cls = clsa;
        node->is_meta = isMeta;
        node->sel_name = sel_getName(sel);
        node->imp = impa;
        
        //# mark
        const char* typeEncoding = method_getTypeEncoding(ma);
        class_addMethod(XselfClass, sel, _stanhook_handler, typeEncoding);
        
        //# Set Hook
        method_setImplementation(ma, impb);
    }
}

void stanhook_apply(const char* classa, Class clsb) {
    Class clsa = objc_getClass(classa);
    stanhook_hook_methods(clsa, clsb, NO);
    stanhook_hook_methods(clsa, clsb, YES);
}
