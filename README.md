api-srv
=======

Node.js JSON-API server

## Fast start

Simple configurating

~~~~~ js
var ApiSrv = require('api-srv')

var Srv = ApiSrv.extend({
	routes: {
		"GET": "main"
	},
	main: function(request){
		request.response({
			code: 200,
			body: '{"success": true, "text": "Hello world!"}'
		});
	}
});

new Srv({port: 8000});
~~~~~

## Options

* `Number` **port** — Server port, default `8000`
* `Number` **timeout** — Request timeout, trfault `30000` (30 sec)
* `Object` **cors** — [CORS](https://ru.wikipedia.org/wiki/Cross-origin_resource_sharing) settings
	* `Boolean` **enabled** — CORS enabled flag, default `true`
	* `String` **allowOrigin** — Value of `Access-Control-Allow-Origin` header, default `"*"`
	* `String` **allowHeaders** — Value of `Access-Control-Allow-Headers` header, default `"origin, authorization, content-type, accept"`
	* `String` **allowMethods** — Value of `Access-Control-Allow-Methods` header, default `"POST, GET, OPTIONS, PUT, DELETE"`
