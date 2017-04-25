# Description
#   A hubot script to tell your team of today's New Relic warnings and violations
#
# Configuration:
#   HUBOT_NEW_RELIC_INCIDENTS_PAGE  - (Optional) This is the alerts page for incidents
#   HUBOT_NEW_RELIC_API_KEY - Your API key for New Relic
#   HUBOT_NEW_RELIC_POLICY_ID - (Optional) By default, it will count all the alerts, you can filter by policy id with this variable
#   HUBOT_NEW_RELIC_ALERT_HOUR - Hour of the day the alerts happen in miltary time. (O-23) Defaults to 12.
#   HUBOT_NEW_RELIC_ALERT_ROOM - The room that alerts are sent to
#
# Commands:
#
# Notes:
#
# Author:
#   Kimberly Munoz

gist = require 'quick-gist'
moment = require 'moment'
request = require 'request'


checkNewRelic = (robot) ->

  newRelicURL = process.env.HUBOT_NEW_RELIC_INCIDENTS_PAGE or 'https://alerts.newrelic.com/'

  options =
    url:'https://api.newrelic.com/v2/alerts_violations.json?only_open=true'
    headers:
      'X-Api-Key': process.env.HUBOT_NEW_RELIC_API_KEY

  processNewRelicAPI = (error, response, body) ->
    throw new Error('Error: Could not find the New Relic API') if error

    body = JSON.parse body

    numOfWarnings = 0
    numOfViolations = 0
    lines = []
    header = """
    | Entity | Policy name | Opened | Duration |
    | ---    | ---         | ---    | ---      |
    """

    countWarningsViolations = (el) ->
      numOfWarnings++ if el.priority is 'Warning'
      numOfViolations++ if el.priority is 'Critical'

    body.violations.forEach (el) ->
      countWarningsViolations(el) if not process.env.HUBOT_NEW_RELIC_POLICY_ID
      countWarningsViolations(el) if el.links.policy_id == Number(process.env.HUBOT_NEW_RELIC_POLICY_ID)

      line = []
      line.push "|" + el.entity.name
      line.push "#{el.policy_name} - #{el.condition_name}"
      line.push moment(el.opened_at).calendar()
      line.push moment.duration(el.duration, 's').humanize()
      lines.push line.join " | "

    msg = "Daily performance update! There are #{numOfWarnings} performance warnings and #{numOfViolations} performance policy violations today. Check them out at #{newRelicURL}"

    robot.messageRoom process.env.HUBOT_NEW_RELIC_ALERT_ROOM, msg

    msg = "#{header}\n" + lines.join(" |\n")
    if msg.length >= 4000
      gist {content: msg, enterpriseOnly: true, fileExtension: 'md'}, (err, resp, data) ->
        url = data.html_url
        robot.messageRoom process.env.HUBOT_NEW_RELIC_ALERT_ROOM, "View output at: " + url
    else
        robot.messageRoom process.env.HUBOT_NEW_RELIC_ALERT_ROOM, msg


  request(options, processNewRelicAPI)

module.exports = (robot) ->

  if !process.env.HUBOT_NEW_RELIC_ALERT_ROOM
    return robot.logger.debug "New Relic Alert Room environment variable has not been set"

  robot.respond /testchecknewrelic/i, (msg) ->
    console.log "Testing new relic alert output"
    checkNewRelic(robot)

  scheduleAtHour = (cb) ->
    hour = process.env.HUBOT_NEW_RELIC_ALERT_HOUR or 12
    now = new Date
    scheduleTime = new Date
    scheduleTime.setHours hour
    scheduleTime.setMinutes 0
    scheduleTime.setSeconds 0
    scheduleTime.setMilliseconds 0

    if now.getHours() >= hour - 1
      scheduleTime.setDate scheduleTime.getDate() + 1
    setTimeout cb, scheduleTime - now

  logAndSchedule = ->
    checkNewRelic robot
    # don't get ruined by timing weirdness
    setTimeout (->
      scheduleAtHour logAndSchedule
    ), 1000

  scheduleAtHour logAndSchedule

