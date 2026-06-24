class DiagnosesController < ApplicationController
  def new
  end

  def create
  end

  def photo_params
    params.permit(photos: [])
  end
end
