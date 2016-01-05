INSTRUCTIONS
------------

- install coffeescript globally
- execute coffee server.coffee
- to change the port use
  export PORT={YOUR_PORT};coffee server.coffee

HOW TO USE
----------

- import coders_clan.json.postman_collection and see an example about how to use the service
  NOTE: this dump file is already using port 8080

GENERATE A JWT TOKEN FOR YOUR APPLICATIONS
------------------------------------------

- coffee jwt.generator.coffee
  NOTE: the secret string has to be changed on both server.coffee and jwt.generator.coffee
