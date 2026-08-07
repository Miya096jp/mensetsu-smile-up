class DiagnosesController < ApplicationController
  def new
  end

  def create
    dianosis_request = DiagnosisRequest.new(photos: photo_params[:photos])

    if dianosis_request.invalid?
      Rails.logger.warn("[ValidationError] #{dianosis_request.errors.full_messages.join(', ')}")
      render json: { message: "不正なリクエストです" }, status: :unprocessable_entity
      return
    end

    diagnosis = Llm::DiagnoseImpression.call(photos: photo_params[:photos])
    render json: { content: diagnosis.content }, status: :ok
  rescue RubyLLM::RateLimitError, RubyLLM::ServerError, RubyLLM::ServiceUnavailableError, RubyLLM::OverloadedError => e
    Rails.logger.error("[UpstreamError] #{e.class}: #{e.message}")
    render json: { message: "AI回答の取得に失敗しました" }, status: :service_unavailable
  rescue => e
    Rails.logger.error("[UnexpectedError] #{e.class}: #{e.message} | #{e.backtrace&.first(3)&.join(' <- ')}")
    render json: { message: "エラーが発生しました" }, status: :internal_server_error
  end

  def photo_params
    params.permit(photos: [])
  end
end
