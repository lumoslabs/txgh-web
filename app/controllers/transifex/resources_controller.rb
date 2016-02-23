require 'transifex'

class Transifex::ResourcesController < ApplicationController
  def index
    resources = client.resources(params[:project_slug])

    respond_to do |format|
      format.json do
        fields = resources.map do |resource|
          resource_fields(resource)
        end

        render json: fields
      end
    end
  end

  def show
    stats = client.stats(params[:project_slug], params[:slug])

    respond_to do |format|
      format.json do
        fields = {
          slug: params[:slug],
          stats: stat_fields(stats)
        }

        render json: fields
      end
    end
  end

  private

  def client
    @client ||= Transifex::Client.new(
      username: ENV['TX_USERNAME'], password: ENV['TX_PASSWORD']
    )
  end

  def resource_fields(resource)
    categories = Array(resource.categories).each_with_object({}) do |category, ret|
      category.split(' ').each do |part|
        key, val = part.split(':')
        ret[key] = val
      end
    end

    {
      name: resource.name,
      slug: resource.slug,
      branch: categories['branch'],
      author: categories['author']
    }
  end

  def stat_fields(stats)
    stats.each_with_object({}) do |(lang, stats), ret|
      ret[lang] = {
        completed: stats.completed.to_i
      }
    end
  end
end
