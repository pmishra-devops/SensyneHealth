'use strict'

var path = require('path')
var fs = require('fs')

var express = require('express')
var app = express()
var app_wait = express()
var morgan = require('morgan')
var bodyParser = require('body-parser')
var methodOverride = require('method-override')

const PORT = process.env.PORT || 3000

var accessLogStream = (process.env.USE_LOG_FILE && process.env.USE_LOG_FILE.toLowerCase() === 'true') ? fs.createWriteStream(path.join('/tmp/', 'server.log'), {flags: 'a'}) : process.stdout

app.use(morgan(':remote-addr [:date[clf]] :method :url :status :res[content-length] :response-time ":user-agent"', {stream: accessLogStream}))
app.use(express.static('./public'))
app.use(bodyParser.urlencoded({'extended': 'true'}))
app.use(bodyParser.json())
app.use(bodyParser.json({type: 'application/vnd.api+json'}))
app.use(methodOverride('X-HTTP-Method-Override'))

// Cosmos DB
var documentClient = require("documentdb").DocumentClient;
const uriFactory = require('documentdb').UriFactory;
var config = require('./config');

var client = new documentClient(config.endpoint, { "masterKey": config.primaryKey });
var AppRouter = require('./lib/api')

app.use('/api/', AppRouter(null))

app.get('*', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

app.listen(PORT)
console.log('App listening on port ' + PORT)
