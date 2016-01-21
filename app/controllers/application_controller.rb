class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def add_sign(data)
    data.delete 'sign'
    keys = data.keys().sort()
    item = []
    keys.each do |k|
      item << "#{k}=#{data.fetch(k)}"
    end
    str_data = item.join('&')
    str_data += $redis.get('server_key')
    data['sign'] =  Digest::MD5.hexdigest str_data
    return data
  end

end
