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
    query = {
      'project_slug' => @project['slug'],
      'resource_slug' => params[:resource_slug],
      'branch' => params[:branch],
    }

    build_url(@project['internal_url'], action, query)
  end

  def build_url(base, path, query)
    querystring = query.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')
    "#{base}/#{path}?#{querystring}"
  end

  def set_project
    @project = TxghWeb::Projects.find_by_slug(params[:project_slug])
  end
end
