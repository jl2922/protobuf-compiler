# protobuf-compiler
Compile ProtoBuf .proto files to JavaScript .js classes.

[![Build Status](https://travis-ci.org/jl2922/protobuf-compiler.svg?branch=master)](https://travis-ci.org/jl2922/protobuf-compiler)

## Installation

```
sudo npm install -g protobuf-compiler
```

## Usage

Compile with the command line interface.
```
protobuf-compile example.proto # exports exampleProto.js.
protobuf-compile exampleFolder # compiles all protoes in the folder.
```

Import the generated js files and use.

```js
/* 
 * Suppose we have the following in example.proto:
 * message Request {
 *   enum Type {
 *     GET = 1;
 *     POST = 2;
 *   }
 *   optional string url = 1;
 *   optional Type type = 2;
 *   repeated string cookie = 3;
 * }
 */
var Request = require('./exampleProto').Request;
var request =
    Request.newBuilder()
        .setUrl('test.com')
        .setType(Request.Type.GET)
        .addCookie('test')
        .build();
console.log(request.getUrl()); // 'test.com'
console.log(request.getCookieList()); // ['test']

var json = JSON.stringify(request); // ["test.com", 1, "test"]
var requestFromJSON = Request.newBuilder().fromJSON(json).build();
```

Check [`tests`](https://github.com/jl2922/protobuf-compiler/tree/master/tests) folder for more examples.