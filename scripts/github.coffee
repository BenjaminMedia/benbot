inspect = (require('util')).inspect
url = require('url')
querystring = require('querystring')
eventActions = require('./github-events/all')
  
eventTypes = [
  "pull_request:*"
  "pull_request_review_comment:*"
  "status:*"
]

module.exports = (robot) ->
  robot.router.post '/hubot/github-listen', (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = req.body
    robot.logger.debug "github-repo-event-notifier: Received POST to /hubot/github-listen with data = #{inspect data}"
    room = "ericson"
    eventType = req.headers["x-github-event"]
    robot.logger.debug "github-repo-event-notifier: Processing event type: \"#{eventType}\"..."

    try

      filter_parts = eventTypes
        .filter (e) ->
          # should always be at least two parts, from eventTypes creation above
          parts = e.split(":")
          event_part = parts[0]
          action_part = parts[1]

          if event_part != eventType
            return false # remove anything that isn't this event

          if action_part == "*"
            return true # wildcard on this event

          if !data.hasOwnProperty('action')
            return true # no action property, let it pass

          if action_part == data.action
            return true # action match

          return false # no match, fail

      if filter_parts.length > 0
        announceRepoEvent data, eventType, (what) ->
          robot.messageRoom room, what
      else
        console.log "Ignoring #{eventType}:#{data.action} as it's not allowed."
    catch error
      robot.messageRoom room, "Whoa, I got an error: #{error}"
      console.log "Github notifier error: #{error}. Request: #{req.body}"

    res.end ""

announceRepoEvent = (data, eventType, cb) ->
  if eventActions[eventType]?
    eventActions[eventType](data, cb)
  else
    cb("Received a new #{eventType} event, just so you know.")
