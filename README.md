# TCKit

[![CI Status](http://img.shields.io/travis/ttmdaniel@gmail.com/TCKit.svg?style=flat)](https://travis-ci.org/ttmdaniel@gmail.com/TCKit)
[![Version](https://img.shields.io/cocoapods/v/TCKit.svg?style=flat)](http://cocoapods.org/pods/TCKit)
[![License](https://img.shields.io/cocoapods/l/TCKit.svg?style=flat)](http://cocoapods.org/pods/TCKit)
[![Platform](https://img.shields.io/cocoapods/p/TCKit.svg?style=flat)](http://cocoapods.org/pods/TCKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
#

#GET Request

NSURL *url = [NSURL URLWithString:@""];
    //
    TCRequest *request = [TCRequest requestWithURL:url];
    request[@"key1"] = @"value1";
    request[@"key2"] = @"value2";
    request[@"key3"] = @"value3";
    request[@"key4"] = @"value4";
    //
    [request GET:^(TCObject *Object, NSError *error) {
        //
        if (!error) {
            NSLog(@"Object : %@", Object);
            //
            NSArray *userList = Object[@"user_list"].array;
            TCObject *firstUser = Object[@"user_list"][0].object;
            NSString *firstUsersName = Object[@"user_list"][0][@"name"].string;
            //OR
            NSString *firstUsersName = firstUser[@"name"].string;
        } else {
            NSLog(@"error = %@", error);
        }
    }];
    
    #POST Request
    
    NSURL *url = [NSURL URLWithString:@""];
    //
    TCRequest *request = [TCRequest requestWithURL:url];
    request[@"key1"] = @"value1";
    request[@"key2"] = @"value2";
    request[@"key3"] = @"value3";
    request[@"key4"] = @"value4";
    //
    [request POST:^(TCObject *Object, NSError *error) {
        //
        if (!error) {
            NSLog(@"Object : %@", Object);
            //
            NSArray *userList = Object[@"user_list"].array;
            TCObject *firstUser = Object[@"user_list"][0].object;
            NSString *firstUsersName = Object[@"user_list"][0][@"name"].string;
            //OR
            NSString *firstUsersName = firstUser[@"name"].string;
        } else {
            NSLog(@"error = %@", error);
        }
    }];

## Requirements

## Installation

TCKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TCKit"
```

## Author

T T Marshel Daniel, ttmdaniel@gmail.com

## License

TCKit is available under the MIT license. See the LICENSE file for more info.
