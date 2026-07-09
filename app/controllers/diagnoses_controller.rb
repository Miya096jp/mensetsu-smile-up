class DiagnosesController < ApplicationController
  def new
  end

  def create
    begin
      diagnosis = Llm::DiagnoseImpression.call(photos: photo_params[:photos])
      render json: { content: diagnosis.content }, status: :ok
    rescue => e
      Rails.logger.error("[API failed] #{e.class}: #{e.message} | #{e.backtrace&.first(3)&.join(' <- ')}")
      render json: { message: "AI回答の取得に失敗しました" }, status: :internal_server_error
    end
  end

  def photo_params
    params.permit(photos: [])
  end
end
