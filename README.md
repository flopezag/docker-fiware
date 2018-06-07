# docker-fiware

## Introduction

Sample docker-compose and configuration files to deploy almost a complete FIWARE architecture example.


## Install

Simple clone the repository in your local folder:

```
$ git clone https://github.com/flopezag/docker-fiware
```

Once you did it you can go into the IdM Instance and configure your application (in this case the Wirecloud). Remember that in this case you need to put the URL of the application http://127.0.0.1 and the callback url http://127.0.0.1/complete/fiware. Leave the rest of questions without change. Optionally, you can provide some description just to know what is about.

Click on Next and Finish the process. It will generage your OAuth2 credentials (Client ID and Client Secret values) of your application. It is needed in order to configure Wirecloud to connect to this IdM instance.

To configure your wirecloud instance just execute the configuration script:

```
$ ./setup.sh init
```

It will request you the OAuth2 credentials and automatically will change all the parameters in wirecloud in order to use the authentication using your own instance of IdM.

Last but not least, due to internal communication of the Wirecloud it is needed that your /etc/hosts file could include the following line:

```
127.0.0.1       localhost fiware-idm
```

## Usage

```js
var trimNewlines = require('trim-newlines');

trimNewlines('\nunicorn\r\n');
//=> 'unicorn'
```


## API

### trimNewlines(input)

Trim from the start and end of a string.

### trimNewlines.start(input)

Trim from the start of a string.

### trimNewlines.end(input)

Trim from the end of a string.


## Related

- [trim-left](https://github.com/sindresorhus/trim-left) - Similar to `String#trim()` but removes only whitespace on the left
- [trim-right](https://github.com/sindresorhus/trim-right) - Similar to `String#trim()` but removes only whitespace on the right.


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)