class TeamsController < ApplicationController


  def index
    @teams = Team.all
  end

  def new
    @users = User.all
    @team = Team.new
  end

  def create

    @users = User.all
    @team = Team.new(planning_id: params[:planning_id], user_id: params[:user_id])
    # @team.save
    # redirect_to edit_planning_team_path(@team)
  end

  def edit

  end

  def update

  end
end
