//# coding by *

#ifndef StanHook_h
#define StanHook_h

#ifndef STANHOOK_MAX
#define STANHOOK_MAX 1024
#endif

#define SConcat_(a, b) a ## b
#define SConcat(a, b) SConcat_(a, b)
#define XConstructor static __attribute__((constructor)) void SConcat(SConstructor, __LINE__)()

#define Xclass(x) @interface __##x: NSObject @end \
XConstructor{stanhook_apply(#x, [__##x class]);}\
@implementation __##x

#define Xself (stanhook_make_xself(self))
#define Xend @end

extern void _stanhook_handler(void);

struct stanhook_node_s{
    Class cls;
    const char* sel_name;
    IMP imp;
    BOOL is_meta;
};

typedef struct stanhook_node_s stanhook_node_t;

BOOL is_inst_kindof_class(id inst, Class cls);

id stanhook_get_real_self(id xself);
IMP stanhook_get_imp(id real_self, const char* sel_name);

id stanhook_make_xself(id real_self);

void stanhook_hook_methods(Class clsa, Class clsb, BOOL isMeta);
void stanhook_apply(const char* classa, Class clsb);

#endif /* StanHook_h */
