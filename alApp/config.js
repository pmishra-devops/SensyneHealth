var config = {}

config.endpoint = process.env.HOST || "https://burgerman3db.documents.azure.com:443/";
config.primaryKey = process.env.AUTH_KEY || "vbpRrNPxFWfXK0dTro2VpoA80YE8Qo0LbnukZjSD9OIuxRvE91rTWCzpvwACzEAbzMmNSfNndBmxcP3J19vojg==";

config.database = {
    "id": "ToDoList"
};

config.collection = {
    "id": "Items"
};

module.exports = config;
