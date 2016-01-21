class HomeController < ApplicationController
  def index
    out_user   = '555555'
    mobile     = '15100285081'
    mchnt_id   = '5999121801714645681'
    expires   = '6600'

    data = {'caller': 'server', 'app_code': $redis.get('app_code'), 'out_user': out_user, 'mobile': mobile, 'expires': expires}
    data = add_sign(data)

    uri = URI( $redis.get("qtsandbox_token_host") )

    uri.query = URI.encode_www_form(data)

    puts '*' * 42
    puts uri
    res = Net::HTTP.get_response(uri)
    puts '_-' * 42
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse res.body
      token =  data['data']['token']
      $redis.set 'token', token
    end
    puts $redis.get 'token'
    puts '_-' * 42

    @token_url = uri
  end
end
