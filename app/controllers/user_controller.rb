class UserController < ApplicationController


def index
  @users = User.all
end

def show
  @user = User.find(params[:id])
end

def new

end

def create

end


private

end
