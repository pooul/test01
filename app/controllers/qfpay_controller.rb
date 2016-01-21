class QfpayController < ApplicationController

  def web_pay
    # params[:amt], params[:id]
    out_sn = Digest::MD5.hexdigest("web" + params.to_s)

    order_token = order_token(params[:amt], out_sn)
    puts order_token

    guitar = Guitar.find(params[:id])
    data = {'app_code': $redis.get('app_code'), 'token': $redis.get('token'),
            'order_token': order_token, 'out_sn': out_sn,
            'total_amt': params[:amt], 'goods_name': guitar.name,
            'mchnt_name': '漫游指南', 'mobile': '',
            'goods_info': 'yoyo'}
    #
    uri = URI( $redis.get('web_order_host'))
    uri.query = URI.encode_www_form(data)
    redirect_to uri.to_s

  end

  def wechat_front_pay
    out_sn = Digest::MD5.hexdigest('wechat_front' + params.to_s)
    the_caller = 'h5'
    total_amt = 1
    pay_amt = 1
    pay_type = 2 # 支付类型 1: 支付宝 2:微信
    pay_source = 4

    order_token = order_token(params[:amt], out_sn)
    guitar = Guitar.find(params[:id])

    data = {
          'caller': the_caller, 'app_code': $redis.get('app_code'), 'order_token': order_token,
          'token': $redis.get('token'), 'total_amt': total_amt, 'pay_amt': pay_amt,
          'pay_type': pay_type, 'pay_source': pay_source, 'goods_name': guitar.name
    }
    data = add_sign(data)
    puts '_-' * 42
    puts data

    uri = URI( $redis.get('pre_create_host') )
    res = Net::HTTP.post_form(uri, data )

    res_json = nil
    if res.is_a?(Net::HTTPSuccess)
      puts '_-' * 42
      puts res.body

      res_json = JSON.parse res.body
      puts '_-' * 42
      puts res_json

    end



    redirect_to res_json['data']['channel']['code_url']

  end
  def wechat_reverse_pay

  end

  def order_token(total_amt, out_sn)
    the_caller     = 'server'
    data ={'caller': the_caller, 'app_code': $redis.get('app_code'), 'total_amt': total_amt, 'out_sn': out_sn}
    data = add_sign(data)

    uri = URI( $redis.get('pre_create_host') )
    res = Net::HTTP.post_form(uri, data )

    order_token = ''
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse res.body
      order_token =  data['data']['order_token']
      $redis.set out_sn, order_token
    end
    return order_token
  end


  def token
    # form data
    the_caller     = 'server'
    out_user   = '555555'
    mobile     = '15100285081'
    mchnt_id   = '5999121801714645681'
    expires   = '6600'

    data = {'caller': the_caller, 'app_code': $redis.get('app_code'), 'out_user': out_user, 'mobile': mobile, 'expires': expires}
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
