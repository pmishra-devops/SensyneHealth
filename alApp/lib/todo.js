'use strict'

var path = require('path')
var documentClient = require("documentdb").DocumentClient;
const uriFactory = require('documentdb').UriFactory;
var config = require('./../config');
const UUID = require('uuid/v1');

var client = new documentClient(config.endpoint, { "masterKey": config.primaryKey });

var HttpStatusCodes = { NOTFOUND: 404 };
var databaseId = config.database.id;
var collectionId = config.collection.id;

module.exports = function TodoApp () {
  return {
    list: (callback) => {
      /**
       * Get the database by ID, or create if it doesn't exist.
       */
      function getDatabase() {
          console.log(`Getting database:\n${databaseId}\n`);
          let databaseUrl = uriFactory.createDatabaseUri(databaseId);
          return new Promise((resolve, reject) => {
              client.readDatabase(databaseUrl, (err, result) => {
                  if (err) {
                      if (err.code == HttpStatusCodes.NOTFOUND) {
                          client.createDatabase({ id: databaseId }, (err, created) => {
                              if (err) reject(err)
                              else resolve(created);
                          });
                      } else {
                          reject(err);
                      }
                  } else {
                      resolve(result);
                  }
              });
          });
      }

      /**
       * Get the collection by ID, or create if it doesn't exist.
       */
      function getCollection() {
          console.log(`Getting collection:\n${collectionId}\n`);
          let collectionUrl = uriFactory.createDocumentCollectionUri(databaseId, collectionId);
          return new Promise((resolve, reject) => {
              client.readCollection(collectionUrl, (err, result) => {
                  if (err) {
                      if (err.code == HttpStatusCodes.NOTFOUND) {
                          let databaseUrl = uriFactory.createDatabaseUri(databaseId);
                          client.createCollection(databaseUrl, { id: collectionId }, { offerThroughput: 400 }, (err, created) => {
                              if (err) reject(err)
                              else resolve(created);
                          });
                      } else {
                          reject(err);
                      }
                  } else {
                      resolve(result);
                  }
              });
          });
      }

      async function query(){
        await getDatabase();
        await getCollection();
        const done = (err, res) => callback(null, {
              statusCode: err ? '400' : '200',
              body: err ? err.message : res,
              headers: {
                'Content-Type': 'application/json',
              },
            });

        console.log(`Querying the collection:\n${collectionId}`);
        let collectionUrl = uriFactory.createDocumentCollectionUri(databaseId, collectionId);
        return new Promise((resolve, reject) => {
            client.queryDocuments(collectionUrl,
              'SELECT * FROM c',
            ).toArray((err, res) => {
              if (err) reject(err)
              else {
                if(typeof res === undefined){
                  res={};
                }
                else {
                  var new_res=[];
                  res.forEach(function(obj) {
                    var temp={};
                    temp.id=obj.id;
                    temp.text=obj.text;
                    new_res.push(temp);
                  });
                  res=new_res;
                }
                resolve(res);
              }
              done(err,res);
            });
        });
      };
      query();
    },
    add: (post, callback) => {
      const done = (err, res) => callback(null, {
            statusCode: err ? '400' : '200',
            body: err ? err.message : res,
            headers: {
              'Content-Type': 'application/json',
            },
      });
      var newdoc = {}
      newdoc = {
            "id": UUID(),
            "text": post.text
      };
      console.log(`Getting document:\n${newdoc.id}\n`);
      let documentUrl = uriFactory.createDocumentUri(databaseId, collectionId, newdoc.id);
      console.log("Document Url:   ", documentUrl);
      return new Promise((resolve, reject) => {
        let collectionUrl = uriFactory.createDocumentCollectionUri(databaseId, collectionId);

        client.createDocument(collectionUrl, newdoc, (err, res) => {
          if (err) reject(err)
          else resolve(res);
          done(err,res);
        });

      });
    },
    delete: (post, callback) => {
      const done = (err, res) => callback(null, {
        statusCode: err ? '400' : '200',
        body: err ? err.message : res,
        headers: {
          'Content-Type': 'application/json',
        },
      });
      console.log('Deleting document id:  ', post._id);
      let documentUrl = uriFactory.createDocumentUri(databaseId, collectionId, post._id);
      return new Promise((resolve, reject) => {
          client.deleteDocument(documentUrl, (err, res) => {
              if (err) reject(err)
              else resolve(res);
              done(err,res);
          });
      });

    }
  }
}
