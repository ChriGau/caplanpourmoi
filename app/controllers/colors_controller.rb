class ColorsController < ApplicationController
  def new
    @color = Color.new
  end

  def create
    @color = Color.new(params_color)
    if @color.save
      redirect_to plannings_path
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def params_color
    params.require(:color).permit(:hexadecimal_code)
  end
end
