require "./config/environment"
require "./app/models/user"
require "pry"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    username = params[:username]
    password = params[:password]
    if username.empty? || password.empty?
      #User.create(username: params[:username], password: params[:password])
      redirect '/failure'
    else
      User.create(params)
      redirect '/login'
    end
  end

  get '/account' do
    @user = current_user
    erb :account
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/account'
    elsif params[:username].empty? || params[:password].empty?
      redirect '/failure'
    else
      redirect '/failure'
    end
  end

  patch "/account" do
    @user = current_user
    if params[:depost]
      @user.balance = @user.balance.to_f + params[:deposit].to_f
      @user.save
    elsif params[:withdraw]
      @user.balance = @user.balance.to_f - params[:withdraw].to_f
      @user.save
    else
      @user.balance = @user.balance
      @user.save
    end
    redirect '/account'
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
