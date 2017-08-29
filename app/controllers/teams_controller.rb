class TeamsController < ApplicationController


  def index
    @teams = Team.all
  end

  def new
    @users = User.all
    @team = Team.new
    @planning_id = params[:planning_id]
  end

  def create
    @planning = Planning.find(params[:planning_id])
    @users = User.all
    @team = Team.new(planning_id: params[:planning_id], user_id: params[:user_id])
    @team.save!
    redirect_to edit_planning_team_path(@planning, @team)
  end

  def edit
    @users = User.all
    @planning_id = Planning.find(params[:planning_id])
    @team_id = params[:team_id]
  end

  def update
    @team = Team.find(params[:id])
    @team = Team.update(planning_id: params[:planning_id], user_id: params[:user_id])
    @team.save!
    redirect_to edit_planning_team_path(@team)
  end
end
