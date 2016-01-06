express = require 'express'
jwt = require 'express-jwt'
cors = require 'cors'
UnauthorizedError = require 'express-jwt/lib/errors/UnauthorizedError'
app = express()
app.use(cors())
bodyParser = require 'body-parser'

app.use('/example', express.static('example'))
app.use bodyParser.urlencoded extended: true
app.use bodyParser.json()
pdf = require './pdf_stream'

port = process.env.PORT || 8080

router = express.Router();

router.route('/document')
      .post (req, res,next)->
        filename = "not_blind"
        filename="blind" if req.body.blind
        pdf req.body, res
        res.attachment("#{filename}.pdf") if req.body.download

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
