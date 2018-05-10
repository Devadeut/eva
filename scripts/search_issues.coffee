# # Description:
# #  Search a keyword or phrase in all issues of metakgp organisation
# #
# # Dependencies:
# #   githubot
# #
# # Configuration:
# #   None
# #
# # Commands:
# #   search/query - searches a keyword in all issues and returns link of matching issues 
# #
# # Author:
# #  thealphadollar


git_search = (msg, robot, keywords) ->
  """
  fetches list of issues matching keyword(s)
  Argument:: 
    keywords:
      lists of keyword to match in the repositories name and description.
  """

  github = require('githubot')(robot)

  github.get "orgs/metakgp/issues", {filter: "all", per_page: 100}, (issue_list) ->

    matching_issue_index = []

    # iterating over all issues to match keyword(s)
    for issue, index in issue_list
      for keyword in keywords

        if keyword in issue.title.split " "
          matching_issue_index.push index
        else if keyword in issue.body.split " "
          matching_issue_index.push index
      
    if matching_issue_index.length > 0 
      if matching_issue_index.length == 1
        msg_to_send = [
          "The following issue matches your query [" + keywords.join(' ,') + "]:\n"
          ]
      else
        msg_to_send = [
          "The following issues match your query [" + keywords.join(' ,') + "]:\n"
          ]

      for index in matching_issue_index
        specific_issue_msg = "*" + issue_list[index].title + "* -> " + issue_list[index].html_url
        msg_to_send.push specific_issue_msg

      msg.send msg_to_send.join('\n')
        
    else
      msg.send "Oops! No issue found matching your query [" + keywords.join(' ,') + "]" 

    
search_issue_plugin = (robot) ->
    """
    Searches all github issues of the metakgp organisation for a keyword.
  
    Keyword can be a sentence preceded by search/query keyword.
    -- @eva search javascript email
    Keywords here will be ["javascript", "email"]
  
    Returns matching issues in the following format:
    -- Matching issues for your query [query] are:
    -- *[issue_Title_1]* [issue_Link]
    -- *[issue_Title_2]* [issue_Link]
    -- ...
    """
    robot.respond /(search|query) (.*)/i, (msg) ->
        keyword = msg.match[2]
        keywords = keyword.split " "   
        git_search(msg, robot, keywords)


module.exports = search_issue_plugin

