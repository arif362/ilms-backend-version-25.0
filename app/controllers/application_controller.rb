class ApplicationController < ActionController::API
  def route_not_found
    render json: { error: 'Route not found' }, status: 404
  end
end
