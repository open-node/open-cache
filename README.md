## open-cache ![NPM version](https://img.shields.io/npm/v/open-cache.svg?style=flat)

Cache by redis, easy use. Include functions get/set/del.

### Installation
```bash
$ npm install open-cache
```

### Example
```js
var cache = require('open-cache');
```

### API

- cache(keyTpl, fn, life, bind)
  * Auto cache async function
  * example
```js
var cache = require('open-cache')
  , fs    = require('fs');
cache.init(6397, '127.0.0.1', options); // options.namespace `String`
var readFile = function(path, callback) {
  fs.readFile(path, function(error, data) {
    if(error) {
      return callback(error);
    }
    return callback(null, data.toString());
  });
};

/* params
 *  keyTpl `String` {0}, {1}, {n} will be replaced arguments[0], arguments[2]...., arguments[n]
 *  fn `Function` be cached function
 *  life `Number` fn results cache life, second (s)
 *  bind `Object` `optional` fn bind object
 */
var readFileCached = cache(keyTpl = "readFile:{0}", fn = readFile, life = 60, bind = null);

//note result dont cached when error isnt null/undefined
readFileCached('/tmp/test', function(error, data) {
  console.log(error, data);
});
```

- cache.init(port = 6379, host = '127.0.0.1', options)
  * initialized cache, once per process
  * port redis-server port
  * host redis-server address
  * options `optional`
    * namespace

- cache.del(key)
  * delete cache by key

- cache.set(key, value, life, done)
  * set cache
  * key `String`
  * value `Mixed`
  * life cache expired second (s)
  * done `Function` be call when cache.set completed
    * error first argument when cache.set failed, else null

-  cache.get(key, done)
  * key `String`
  * done `Function` be call when cache.get completed
    * error first argument when cache.get failed, else null
    * value results of the cache.

### Contributing
- Fork this repo
- Clone your repo
- Install dependencies
- Checkout a feature branch
- Feel free to add your features
- Make sure your features are fully tested
- Open a pull request, and enjoy <3

### MIT license
Copyright (c) 2015 Redstone Zhao

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the &quot;Software&quot;), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

