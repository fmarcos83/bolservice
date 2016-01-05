express = require 'express'
jwt = require 'express-jwt'
UnauthorizedError = require 'express-jwt/lib/errors/UnauthorizedError'
app = express()
bodyParser = require 'body-parser'

app.use bodyParser.urlencoded extended: true
app.use bodyParser.json()
pdf = require './pdf_stream'

port = process.env.PORT || 8080

router = express.Router();

router.route('/document')
      .post (req, res)->
        pdf req.body, res

jwtConfig =
  secret:'secret_key'
  getToken: (req, res)->
    response = undefined
    if req.headers.authorization
      response = req.headers.authorization.split(':')[1] if req.headers.authorization.split(':')[0] is 'Bearer'
    if response is undefined
      throw new UnauthorizedError('Token not present', {message:'No token'})
    response
app.use '/api', jwt jwtConfig
app.use (err, req, res, next)->
  if err.name is 'UnauthorizedError'
    res.status 401
       .json err : err.message

app.use '/api', router
app.listen port