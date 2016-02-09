class ProjectsController < ApplicationController
  def index
    @projects = TxghWeb::Projects.all
  end
end
