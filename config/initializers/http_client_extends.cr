require "http/client"

class HTTP::Client::Response::Exception < Exception
  property response : HTTP::Client::Response

  def initialize(@response : HTTP::Client::Response)
    super(to_s)
  end

  def response
    @response
  end

  def to_s
    "#<#{self.class}>"
  end
end

def api_client(method : String, url : String, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType? = nil) : HTTP::Client::Response
  response = HTTP::Client.exec(method: method.upcase, url: url, headers: headers, body: body)
  raise HTTP::Client::Response::Exception.new(response) unless response.status.ok? || response.status.created? || response.status.accepted?

  response
end
