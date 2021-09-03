# StanHook
Objective-C Hook Framework



### Example

```objective-c
#import "StanHook.h"

Xclass(SomeClassName)
- (void)someFunction {
  NSLog("hooked success");
  [Xorig someFunction]; //invoke the original method.
}
Xend
```
