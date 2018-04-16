namespace :stride do
  task :notify_deploy_failed do
    message = "#{fetch(:local_user, local_user).strip} cancelled deployment of #{fetch(:application)} to #{fetch(:stage)}."

    request = fetch(:request)
    body = {
        body: {
            version: 1,
            type: "doc",
            content: [
                {
                    type: "paragraph",
                    content: [
                        {
                            type: "text",
                            text: message
                        }
                    ]
                }
            ]
        }
    }
    request.body = body.to_json

    fetch(:http).request(request)
  end

  task :notify_deploy_started do
    commits = `git log --no-color --max-count=5 --pretty=format:' - %an: %s' --abbrev-commit --no-merges #{fetch(:previous_revision, "HEAD")}..#{fetch(:current_revision, "HEAD")}`
    commits.gsub!("\n", "<br />")
    message = "#{fetch(:local_user, local_user).strip} is deploying #{fetch(:application)} to #{fetch(:stage)} <br />"
    message << commits

    request = fetch(:request)
    body = {
        body: {
            version: 1,
            type: "doc",
            content: [
                {
                    type: "paragraph",
                    content: [
                        {
                            type: "text",
                            text: message
                        }
                    ]
                }
            ]
        }
    }
    request.body = body.to_json

    fetch(:http).request(request)
  end

  task :notify_deploy_finished do
    message = "#{fetch(:local_user, local_user).strip} finished deploying #{fetch(:application)} to #{fetch(:stage)}."

    request = fetch(:request)
    body = {
        body: {
            version: 1,
            type: "doc",
            content: [
                {
                    type: "paragraph",
                    content: [
                        {
                            type: "text",
                            text: message
                        }
                    ]
                }
            ]
        }
    }
    request.body = body.to_json

    fetch(:http).request(request)
  end

  before "deploy:updated", "stride:notify_deploy_started"
  after "deploy:finished", "stride:notify_deploy_finished"
  before "deploy:reverted", "stride:notify_deploy_failed"
end

namespace :load do
  task :defaults do
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse(fetch(:stride_url))

    header = {
        'Content-Type': 'text/json',
        'Authorization': "Bearer #{fetch(:stride_token)}"
    }

    set(:http, -> { Net::HTTP.new(uri.host, uri.port) })
    set(:request, -> { Net::HTTP::Post.new(uri.request_uri, header) })
  end
end