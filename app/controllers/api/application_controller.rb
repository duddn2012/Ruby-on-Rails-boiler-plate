class Api::ApplicationController < ActionController::API
  # 에러 핸들링
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: :not_found
  end
  
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end 