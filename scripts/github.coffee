module.exports = (robot) ->
  robot.router.post '/hubot/github-listen', (req, res) ->
    data   = req.body
    
    if data.action == "labeled" && data.pull_request? && data.label? && data.label.name == "ready to review"
      #robot.send data.pull_request.url
      
      robot.messageRoom "#develop-backend", data.pull_request.html_url + " - " + data.pull_request.title
  
    res.send 'OK'
