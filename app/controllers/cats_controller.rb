class CatsController < ApplicationController
  def index
    #GET /cats
    self.render json: Cat.all
  end

  def show
    #GET /cats/1
    self.render json: Cat.find(params[:id])
  end

  def create
    #POST /cats
    cat = Cat.new(name: params[:id][:name])
    if cat.save
      render json: cat
    else
      render json: cat.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    cat = Cat.find(params[:cat])
    cat.update(params[:cat].permit(:name))
  end
end
