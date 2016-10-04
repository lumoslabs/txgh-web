require 'txgh'

class TranslationDelta
  DEFAULT_WINDOW = 30.days
  DEFAULT_BRANCH = 'heads/master'
  DEFAULT_LANGUAGE = 'en'

  attr_reader :repo_name, :branch, :language, :start_date, :end_date

  def initialize(repo_name, options = {})
    @repo_name = repo_name
    @branch = options.fetch(:branch, DEFAULT_BRANCH)
    @language = options.fetch(:language, DEFAULT_LANGUAGE)
    @end_date = options.fetch(:start_date) { DateTime.now.utc }
    @start_date = options.fetch(:end_date) { end_date - DEFAULT_WINDOW }
  end

  def gain
    diffs.inject(0) do |ret, (path, diff)|
      ret + diff[:added].size + diff[:modified].size
    end
  end

  def loss
    diffs.inject(0) do |ret, (path, diff)|
      ret - diff[:removed].size
    end
  end

  def delta
    gain + loss  # loss is always negative
  end

  private

  def diffs
    @diffs ||= newer_contents.each_with_object({}) do |(path, contents), ret|
      ret[path] = contents.diff_hash(older_contents[path])
    end
  end

  def older_contents
    @resource_older_contents ||= resource_contents(older_sha)
  end

  def newer_contents
    @resource_newer_contents ||= resource_contents(newer_sha)
  end

  def resource_contents(sha)
    resources.each_with_object({}) do |resource, ret|
      path = path_for(resource)
      ret[path] = contents_of(resource, path, sha)
    end
  end

  def contents_of(resource, path, sha)
    Txgh::ResourceContents.new(
      resource, raw: repo.api.download(path, sha)[:content]
    )
  rescue Octokit::NotFound
    Txgh::EmptyResourceContents.new(resource)
  end

  def older_sha
    old_commits.first[:sha]
  end

  def newer_sha
    @newer_sha ||= repo.api.get_ref(branch)[:object][:sha]
  end

  def repo
    config.github_repo
  end

  def config
    @config ||= Txgh::Config::KeyManager.config_from_repo(repo_name)
  end

  def old_commits
    @old_commits ||= repo.api.client.commits_before(
      repo_name, start_date.iso8601, sha: branch
    )
  end

  def path_for(resource)
    if language == resource.source_lang
      resource.source_file
    else
      resource.translation_path(language)
    end
  end

  def resources
    @resources ||= tx_config.resources.map do |rsrc|
      Txgh::TxBranchResource.new(rsrc, branch)
    end
  end

  def tx_config
    @tx_config ||= Txgh::Config::TxManager.tx_config(
      config.transifex_project, config.github_repo, branch
    )
  end
end
