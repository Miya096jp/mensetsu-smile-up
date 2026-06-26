class DiagnosesController < ApplicationController
  def new
  end

  def create
    diagnosis = Llm::DiagnoseImpression.call(photos: photo_params[:photos])
    render json: diagnosis
  end

  def photo_params
    params.permit(photos: [])
  end
end
