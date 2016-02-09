require 'txgh_web/projects'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with(
    name: ENV['HTTP_BASIC_USERNAME'],
    password: ENV['HTTP_BASIC_PASSWORD']
  )

  before_action :set_projects

  def set_projects
    @projects = TxghWeb::Projects.all
  end
end
