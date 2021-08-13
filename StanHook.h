//# coding by *

#ifndef StanHook_h
#define StanHook_h

#ifndef STANHOOK_MAX
#define STANHOOK_MAX 0x200
#endif

#define SConcat_(a, b) a ## b
#define SConcat(a, b) SConcat_(a, b)

// Constructor
#define SConstructor static __attribute__((constructor)) void SConcat(SConstructor, __LINE__)()

#define Xclass(x) @interface __##x: NSObject @end \
SConstructor{stanHookInstall(#x, [__##x class]);}\
@implementation __##x

#define Xorig stanHookMakeSprigBoard(self)
#define Xend @end

#define StanHook(x) @interface __##x: NSObject @end \
SConstructor{stanHookInstall(#x, [__##x class]);}\
@implementation __##x
#define StanCallback stanHookMakeSprigBoard(self)
#define StanHookEnd @end

typedef struct {
    Class cls;
    const char* selName;
    IMP imp;
    BOOL isMeta;
} StanHookInfo;

id stanHookGetInst(id inst);
IMP stanHookGetIMP(id inst, const char* selName);

id stanHookMakeSprigBoard(id inst);
void stanHookMethodList(Class clsa, Class clsb, BOOL isMeta);
void stanHookInstall(const char* classa, Class clsb);

#endif /* StanHook_h */
