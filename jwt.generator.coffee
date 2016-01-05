jwt = require 'jsonwebtoken'
token = jwt.sign 'pdf_download', 'secret_key'
console.log token
