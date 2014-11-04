url      = require 'url'
_        = require 'underscore'
Backbone = require 'backbone'
events   = require 'events'
httpNode = require './httpNode'


class controller
    options:
        port: 8000
        cors: 
            enabled: true

        timeout: 30000

    routes:
        "/":
            "GET": "code200"

    constructor: (options)->
        _.extend @options, options
        _.extend @, Backbone.Events
        @_routeToRegexp()

        @requestCollection = new httpNode.Requests null, @options.cors
        @listenTo @requestCollection, 'dataReady', @_newRequest

        @server = new httpNode.server @options.port
        @listenTo @server, 'request', @_serverRequest

    _routeToRegexp: ->
        newRoutes = []
        for route of _.result @, 'routes'
            newRoutes.push
                exp: Backbone.Router.prototype._routeToRegExp(route)
                resource: @routes[route]

        @_routesReg = newRoutes

    _serverRequest: (requestData)->
        @requestCollection.add requestData

    _newRequest: (reqModel)->
        reqModel.set 'timeout', setTimeout =>
            @code502 reqModel

        , @options.timeout

        @navigate reqModel

    navigate: (reqModel)->
        addr = url.parse reqModel.get('request').url
        params = []

        currentRoute = _.find @_routesReg, (route)->
            return route.exp.test addr.pathname

        if currentRoute?
            params = _.union [reqModel], addr.pathname.match(currentRoute.exp).slice(1)

            method = currentRoute.resource[reqModel.get('request').method]

            if method and _.isFunction @[method]
                @[method].apply @, params

            else
                @code405 reqModel, currentRoute.resource

        else
            @code404 reqModel

    code200: (req)->
        req.response
            code: 200
            body: '{"success": true}'

    code404: (req)->
        req.response
            code: 404,
            body: '{"success": false, "error_code": "resource_not_found"}'

    code405: (req, allowed)->
        req.response
            code: 406,
            headers:
                Allow: _.keys allowed

            body: JSON.stringify success: false, error_code: "resource_not_allowed_this_method", allow: _.keys allowed

    code500: (req, attr)->
        req.response
            code: 500,
            body: JSON.stringify "success": false, "error_code": attr.error_code

    code502: (req)->
        req.response
            code: 502,
            body: '{"success": false, "error": 502}'


controller.extend = (protoProps, staticProps)->
    parent = @

    if protoProps and _.has(protoProps, 'constructor')
        child = protoProps.constructor

    else
        child = ->
            return parent.apply @, arguments

    _.extend child, parent, staticProps
    _.extend child.prototype, parent.prototype, protoProps

    return child


module.exports = controller
