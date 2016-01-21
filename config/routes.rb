Rails.application.routes.draw do

  get 'qfpay/token' # fetch token
  get 'qfpay/web_pay' #
  get 'qfpay/wechat_front_pay' #
  get 'qfpay/wechat_reverse_pay'

  get 'home/index'
  resources :guitars do
    member do
      get :buy
    end
  end
  root 'home#index'
end
