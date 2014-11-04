http        = require 'http'
_           = require 'underscore'
Backbone    = require 'backbone'
url         = require 'url'


Request = Backbone.Model.extend
    initialize: ->
        @prepareRequest()

    prepareRequest: ->
        switch @get('request').method
            when 'POST', 'PUT', 'DELETE'
                @setParams()
                @loadData =>
                    @setReadyState()

            when 'OPTIONS'
                @response code: 200

            else
                @setParams()
                @setReadyState()

    setParams: ->
        @set 'params', url.parse(@get('request').url, true).query

    loadData: (callback)->
        data = ''
        @get('request').addListener "data", (chunk)->
            data += chunk.toString()

        @get('request').addListener "end", =>
            @set 'data', data
            callback.apply()

    setReadyState: ->
        @set('ready', true)
        @collection.trigger 'dataReady', @

    onSendEmpty: (callback)->
        if typeof callback is 'function'
            if @get 'sendEmpty'
                callback()

            else
                @on 'sendEmpty', ->
                    callback()

        else
            @set('sendEmpty', true)
            @trigger 'sendEmpty'

    response: (params={})->
        clearTimeout @get 'timeout'
        response = @get 'response'

        if params.code
            params.headers = {} unless params.headers
            response.writeHead params.code, _.defaults( params.headers, @getCrossDomainJSONHeaders() )

        if params.body
            response.write params.body

        response.end()
        @destroy()

    getCrossDomainJSONHeaders: ->
        headers = {}
        if @collection.cors.enabled
            headers['Access-Control-Allow-Origin'] = @collection.cors.allowOrigin if @collection.cors.allowOrigin
            headers['Access-Control-Allow-Headers'] = @collection.cors.allowHeaders if @collection.cors.allowHeaders
            headers['Access-Control-Allow-Methods'] = @collection.cors.allowMethods if @collection.cors.allowMethods
            headers['Content-Type'] = @collection.cors.contentType if @collection.cors.contentType

        return headers


Requests = Backbone.Collection.extend
    model: Request

    initialize: (models, cors={})->
        @cors = _.defaults cors,
            enabled: true
            allowOrigin: "*"
            allowHeaders: "origin, authorization, content-type, accept"
            allowMethods: "POST, GET, OPTIONS, PUT, DELETE"
            contentType: "application/json; charset=utf-8"


class httpNode
    constructor: (port=8000)->
        _.extend @, Backbone.Events

        @server = http.createServer _.bind(@request, @)
        @server.listen port        

        return @

    request: (req, res)->
        @trigger 'request', 
            request: req
            response: res
            timestamp: new Date()


module.exports =
    server: httpNode
    Requests: Requests
