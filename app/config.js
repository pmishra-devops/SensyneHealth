var config = {}

config.host = process.env.HOST || "https://12345678cosmodanish.documents.azure.com:443/";
config.authKey = process.env.AUTH_KEY || "CBxpWRPb4kZiz6GjHbWRy7D0P02ah7OkdFsPeb5LcOFCWI2C1bsDRhhK3C7jGpTRrFf1Bvhd4wXWslRpVa1x7g==";
config.databaseId = "ToDoList";
config.collectionId = "Items";

module.exports = config;
