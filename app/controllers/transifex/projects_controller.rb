require 'transifex'

class Transifex::ProjectsController < ApplicationController
  class Error < StandardError; end

  include ActionController::Streaming
  include Zipline

  def download
    project = TxghWeb::Projects.find_by_slug(params[:project_slug])
    unless project
      raise Error, "Couldn't find project '#{params[:project_slug]}'"
    end

    config = config_for(project, params[:branch])
    unless config
      raise Error, "Couldn't get config for branch '#{params[:branch]}'"
    end

    languages = client.languages(params[:project_slug])
    unless languages
      raise Error, "Couldn't get languages for project #{params[:project_slug]}"
    end

    files = config['resources'].lazy.flat_map do |resource_config|
      resource_slug = "#{resource_config['resource_slug']}-#{config['branch_slug']}"
      resource = client.resource(project['slug'], resource_slug)

      languages.lazy.map do |language|
        [
          StringIO.new(resource.translation(language.language_code)['content']),
          path_for(resource_config, language.language_code)
        ]
      end
    end

    cookies[:fileDownload] = { value: 'true', path: '/' }
    zipline(files, "#{params[:project_slug]}.zip")
  rescue Error => e
    respond_to do |format|
      format.json do
        render json: [{ error: e.message }], status: 404
      end
    end
  end

  private

  def client
    @client ||= Transifex::Client.new(
      username: ENV['TX_USERNAME'], password: ENV['TX_PASSWORD']
    )
  end

  def config_for(project_config, branch)
    config = HTTParty.get(
      config_url_for(project_config, branch), {
        headers: { 'Accept' => 'application/json' }
      }
    )

    if config.is_a?(Hash) && config.include?('data')
      config['data']
    end
  end

  def config_url_for(project_config, branch)
    build_url(project_config['url'], 'config', {
      branch: branch, project_slug: project_config['slug']
    })
  end

  def build_url(base, path, query)
    querystring = query.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')
    "#{base}/#{path}?#{querystring}"
  end

  def path_for(config, language_code)
    File.join(
      config['project_slug'],
      config['translation_file'].gsub('<lang>', language_code)
    )
  end
end
