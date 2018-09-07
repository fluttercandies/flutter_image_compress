# flutter_image_compress

compress image with native code(objc kotlin)

## why
Q：Dart has image related libraries to compress. Why use native?

A：For efficiency reasons, the compression efficiency of some dart libraries is not high, and it will be stuck to UI, even if isolate is used.

