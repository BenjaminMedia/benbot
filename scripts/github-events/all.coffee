#! /usr/bin/env coffee

#commit_comment,create,delete,deployment,deployment_status,fork,gollum,issue_comment,issues,member,membership,page_build,pull_request_review_comment,pull_request,push,repository,release,status,ping,team_add,watch

unique = (array) ->
  output = {}
  output[array[key]] = array[key] for key in [0...array.length]
  value for key, value of output

extractMentionsFromBody = (body) ->
  mentioned = body.match(/(^|\s)(@[\w\-\/]+)/g)

  if mentioned?
    mentioned = mentioned.filter (nick) ->
      slashes = nick.match(/\//g)
      slashes is null or slashes.length < 2

    mentioned = mentioned.map (nick) -> nick.trim()
    mentioned = unique mentioned

    "\nMentioned: #{mentioned.join(", ")}"
  else
    ""

module.exports =
  pull_request_review_comment: (data, callback) ->
    comment = data.comment
    pull_req = data.pull_request
    base = data.base
    repo = data.repository

    callback "New Comment on Pull Request \"#{comment.body}\" by #{comment.user.login}: #{comment.html_url}"

  pull_request: (data, callback) ->
    pull_num = data.number
    pull_req = data.pull_request
    base = data.base
    repo = data.repository
    sender = data.sender

    action = data.action

    msg = "Pull Request \##{data.number} \"#{pull_req.title}\" "

    switch action
      # when "assigned"
      #   msg += " assigned to: #{data.assignee.login} by #{sender.login} "
      # when "unassigned"
      #   msg += " unassigned #{data.assignee.login} by #{sender.login} "
      # when "opened"
      #   msg += " opened by #{sender.login} "
      # when "closed"
      #   if pull_req.merged
      #     msg += " merged by #{sender.login} "
      #   else
      #     msg += " closed by #{sender.login} "
      # when "reopened"
      #   msg += " reopened by #{sender.login} "
      when "labeled" and data.label.name == "ready for review"
        msg += " #{sender.login} added label: \"#{data.label.name}\" "
      when "labeled"
        msg += " #{sender.login} added label: \"#{data.label.name}\" "
      # when "unlabeled"
      #   msg += " #{sender.login} removed label: \"#{data.label.name}\" "
      # when "synchronize"
      #   msg +=" synchronized by #{sender.login} "

    callback msg + "- #{pull_req.html_url}"

  status: (data, callback) ->
    commit = data.commit
    state = data.state
    branches = data.branches
    repo = data.repository
    context = data.context
    
    msg = ""
    if context == "ci/circleci"
      msg += "CircleCI "
      switch state
        when "failure"
          msg += "Failed :x: :broken_heart: :x: - "
        when "success"
          msg += "Succeeded! :tada: :champagne: :beers: - "
          
      msg += " Branch: #{branches[0].name}"
  
      callback msg
  
  # push: (data, callback) ->
  #   commit = data.after
  #   commits = data.commits
  #   head_commit = data.head_commit
  #   repo = data.repository
  #   pusher = data.pusher
  # 
  #   if !data.deleted
  #     callback "New Commit \"#{head_commit.message}\" to #{repo.full_name} by #{pusher.name}: #{head_commit.url}"
  # 
  # # Org level event
  # repository: (data, callback) ->
  #   repo = data.repository
  #   org = data.organization
  #   action = data.action
  # 
  #   callback "#{repo.full_name} #{action}"
  # 
  # release: (data, callback) ->
  #   release = data.release
  #   repo = data.repository
  #   action = data.action
  # 
  #   callback "Release #{release.tag_name} #{action} on #{repo.full_name}"
  # watch: (data, callback) ->
  #   repo = data.repository
  #   sender = data.sender
  # 
  #   callback "#{repo.full_name} is now being watched by #{sender.login}"
  
  # commit_comment: (data, callback) ->
  #   comment = data.comment
  #   repo = data.repository
  # 
  #   callback "New comment by #{comment.user.login}
  #   on Commit #{comment.commit_id}: #{comment.body} - #{comment.html_url}"
  # 
  # create: (data, callback) ->
  #   repo = data.repository
  #   ref_type = data.ref_type
  #   ref = data.ref
  # 
  #   callback "New #{ref_type} #{ref} created on #{repo.full_name}"
  # 
  # delete: (data, callback) ->
  #   repo = data.repository
  #   ref_type = data.ref_type
  # 
  #   ref = data.ref.split('refs/heads/').join('')
  # 
  #   callback "#{ref_type} #{ref} deleted on #{repo.full_name}"
  # 
  # deployment: (data, callback) ->
  #   deploy = data.deployment
  #   repo = data.repository
  # 
  #   callback "New deployment #{deploy.id} from: #{repo.full_name} to: #{deploy.environment} started by: #{deploy.creator.login}"
  # 
  # deployment_status: (data, callback) ->
  #   deploy = data.deployment
  #   deploy_status = data.deployment_status
  #   repo = data.repository
  # 
  #   callback "Deployment #{deploy.id} from: #{repo.full_name} to: #{deploy.environment} - #{deploy_status.state} by #{deploy.status.creator.login}"
  # 
  # fork: (data, callback) ->
  #   forkee = data.forkee
  #   repo = data.repository
  # 
  #   callback "#{repo.full_name} forked by #{forkee.owner.login}"
  # 
  # # Needs to handle more then just one page
  # gollum: (data, callback) ->
  #   pages = data.pages
  #   repo = data.repository
  #   sender = data.sender
  # 
  #   page = pages[0]
  # 
  #   callback "Wiki page: #{page.page_name} #{page.action} on #{repo.full_name} by #{sender.login}"
  # 
  # issues: (data, callback) ->
  #   issue = data.issue
  #   repo = data.repository
  #   action = data.action
  #   sender = data.sender
  # 
  #   msg = "Issue \##{issue.number} \"#{issue.title}\""
  # 
  #   switch action
  #     when "assigned"
  #       msg += " assigned to: #{issue.assignee.login} by #{sender.login} "
  #     when "unassigned"
  #       msg += " unassigned #{data.assignee.login} by #{sender.login} "
  #     when "opened"
  #       msg += " opened by #{sender.login} "
  #     when "closed"
  #       msg += " closed by #{sender.login} "
  #     when "reopened"
  #       msg += " reopened by #{sender.login} "
  #     when "labeled"
  #       msg += " #{sender.login} added label: \"#{data.label.name}\" "
  #     when "unlabeled"
  #       msg += " #{sender.login} removed label: \"#{data.label.name}\" "
  # 
  #   callback msg + "- #{issue.html_url}"
  # 
  # issue_comment: (data, callback) ->
  #   issue = data.issue
  #   comment = data.comment
  #   repo = data.repository
  # 
  #   issue_pull = "Issue"
  # 
  #   if comment.html_url.indexOf("/pull/") > -1
  #     issue_pull = "Pull Request"
  # 
  #   callback "New Comment on #{issue_pull} \##{issue.number} by #{comment.user.login}: \"#{comment.body}\" - #{comment.html_url}"
  # 
  # member: (data, callback) ->
  #   member = data.member
  #   repo = data.repository
  # 
  #   callback "Member #{member.login} #{data.action} from #{repo.full_name}"
  # 
  # # Org level event
  # membership: (data, callback) ->
  #   scope = data.scope
  #   member = data.member
  #   team = data.team
  #   org = data.organization
  # 
  #   callback "#{org.login} #{data.action} #{member.login} to #{scope} #{team.name}"
  # 
  # page_build: (data, callback) ->
  #   build = data.build
  #   repo = data.repository
  #   if build?
  #     if build.status is "built"
  #       callback "#{build.pusher.login} built #{data.repository.full_name} pages at #{build.commit} in #{build.duration}ms."
  #     if build.error.message?
  #       callback "Page build for #{data.repository.full_name} errored: #{build.error.message}."
