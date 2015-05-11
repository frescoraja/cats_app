class ToysController < ApplicationController
  def index
    cat = Cat.find(params[:cat_id])
    render json: cat.toys
  end

  def show
    render json: Toy.find(self.params[:id])
  end

  def create
    toy = Toy.new(self.toy_params)

    if toy.save
      render json: toy
    else
      render json: toy.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    toy = Toy.find(params[:id])
    toy.destroy
    render json: toy
  end

  def update
    toy = Toy.find(params[:id])

    success = toy.update(self.toy_params)
    if success
      render json: toy
    else
      render json: toy.errors.full_messages, status: :unprocessable_entity
    end
  end

  protected
  def toy_params
    self.params[:toy].permit(:name, :ttype, :cat_id)
  end
end
