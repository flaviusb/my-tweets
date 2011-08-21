sys = require('sys')
twitter = require('twitter')
fs = require 'fs'
process.env.TZ = 'Pacific/Auckland'

if not process.argv[2]?
  console.log "No post provided. Not posting anything."
  process.exit(1)

fs.readFile 'conf.json', 'utf-8', (err, data) ->
  if err?
    console.log err
    return
  conf = JSON.parse data
  twit = new twitter({
      consumer_key: conf.c_k,
      consumer_secret: conf.c_s,
      access_token_key: conf.a_t_k,
      access_token_secret: conf.a_t_s
  })
  newtweet = process.argv[2]
  twit.updateStatus shorttext, (err) ->
    if err?
      console.log err
    console.log 'Yuss, tweeted stuff.'
