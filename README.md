# xcode-nscoding
An Xcode-extension that automatically generates NSCoding-implementations from Objective-C properties.

## Description
NSCoding implementations always follow a certain formula. 
To me, it's so standardized that it is just boilerplate when having many model objects.
It's also easy to make a mistake, since NSCoding keys must always be correctly matched with their properties.

This extension aims to fix this, by automatically generating `initWithCoder:` and `encodeWithCoder:` functions
from your object properties.

## Example
The extension will convert the following properties:

```objc
@property (nonatomic, strong) NSNumber *objectNumber;
@property (assign, getter=isInteresting) BOOL interesting;
@property (nonatomic, assign) NSInteger anInteger;
```

Into the following NSCoding-implementations:
```objc
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.objectNumber = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(objectNumber))];
        self.interesting = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(interesting))];
        self.anInteger = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(anInteger))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.objectNumber forKey:NSStringFromSelector(@selector(objectNumber))];
    [aCoder encodeBool:self.interesting forKey:NSStringFromSelector(@selector(interesting))];
    [aCoder encodeInteger:self.anInteger forKey:NSStringFromSelector(@selector(anInteger))];
}
```

## Usage
In Xcode, select the properties you want NSCoding-implementations for, and choose `Editor -> NSCoding. 
In this menu, you will find three options:

- `Convert properties for encodeWithCoder:` Converts the properties in place into `encodeWithCoder:`-compatible code.
- `Convert properties for initWithCoder:` Same as above, but for `initWithCoder:`.
- `Copy NSCoding implementations` Creates full implementations of `encodeWithCoder:` and `initWithCoder:` and copies them to your clipboard, without changing the source text.

## Installation

### Using the pre-built binary
Download the binary, and put it somewhere it won't bother you. You will only have to run this binary once to install the extension,
but you need to keep it around since it contains the extension itself.

### Compiling yourself
Clone the project and open it in Xcode, then Product -> Archive. Then, in Organizer, choose "Export..." and "Save as macOS-application".
The app will run and install the extension. The extension may have to be enabled from your system preferences, in the `Extensions`-pane.
