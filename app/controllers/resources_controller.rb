require 'txgh_web/projects'
require 'cgi'

class ResourcesController < ApplicationController
  before_action :set_project

  def index
  end

  def push
    response = HTTParty.patch(url_for('push'))

    respond_to do |format|
      format.json do
        render status: response.code, json: { response: response.body }
      end
    end
  end

  def pull
    response = HTTParty.patch(url_for('pull'))

    respond_to do |format|
      format.json do
        render status: response.code, json: { response: response.body }
      end
    end
  end

  private

  def url_for(action)
    base = @project['url']

    query = {
      'project_slug' => @project['slug'],
      'resource_slug' => params[:resource_slug],
      'branch' => params[:branch],
    }

    querystring = query.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')
    "#{base}/#{action}?#{querystring}"
  end

  def set_project
    @project = TxghWeb::Projects.find_by_slug(params[:project_slug])
  end
end
