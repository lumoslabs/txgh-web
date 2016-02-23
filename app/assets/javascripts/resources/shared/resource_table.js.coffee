class ResourceRow
  resource_template: (data) ->
    $("""
      <tr class='resource-row' data-slug='#{data.slug}'>
        <td>#{data.name}</td>
        <td>#{data.branch || '(Unknown)'}</td>
        <td>#{(data.author || '(Unknown)').replace('_', ' ')}</td>
        <td class='completion'></td>
        <td class='actions'>
          <button class='btn btn-default btn-xs action-push'>Push</button>
          <button class='btn btn-default btn-xs action-pull'>Pull</button>
        </td>
      </tr>
    """)

  stats_template: ->
    $("""
      <tr class='resource-stats'>
        <td colspan='5'>
          <div class='resource-stat-list'></div>
        </td>
      </tr>
    """)

  stat_template: (data) ->
    $("""
      <div class='col-sm-3'>
        <div class='pull-left resource-stat-progress'>
          <div class="progress">
            <div class='progress-bar' style='width: #{data.percentage}%'>#{data.percentage}%</div>
          </div>
        </div>
        <div class='pull-left resource-stat-language'>#{data.language}</div>
      </div>
    """)

  constructor: (@parent, @resource, @options = {}) ->
    @resource_row = @resource_template(@resource)
    @stats_row = @stats_template(@resource)
    @stat_list = $('.resource-stat-list', @stats_row)
    resource_slug = @deBranchResourceSlug(@resource.slug, @resource.branch)
    that = @

    $('.action-push', @resource_row).click ->
      that.trigger('onPushClicked', @, that.parent.slug, resource_slug, that.resource.branch)

    $('.action-pull', @resource_row).click ->
      that.trigger('onPullClicked', @, that.parent.slug, resource_slug, that.resource.branch)

    @resource_row.click => @stats_row.toggle()

    @parent.element.append(@resource_row)
    @parent.element.append(@stats_row)
    @completion = $('.completion', @resource_row)

    spinner = new Spinner(@completion)

    url = Routes.transifex_resource_path(
      project_slug: @parent.slug, slug: @resource.slug
    )

    spinner.get(url).success (data) =>
      @update(data)

  deBranchResourceSlug: (slug, branch) ->
    branch = branch.replace('/', '_')
    slug.replace("-#{branch}", '')

  averageCompletedPct: (stats) ->
    pcts = 0
    count = 0

    for lang, stat of stats
      pcts += parseInt(stat.completed)
      count += 1

    # round to one decimal place
    Math.round(pcts / count * 10) / 10

  update: (data) ->
    @completion.text("#{@averageCompletedPct(data.stats)}%")

    for lang, stat of data.stats
      @stat_list.append(
        @stat_template(
          percentage: stat.completed, language: lang
        )
      )

  trigger: (method, args...) ->
    @options[method].apply(@, args) if @options[method]?


class ResourceTable
  template: ->
    template = $("""
      <table class="table table-striped table-hover resource-table">
        <tr>
          <th>File</th>
          <th>Branch</th>
          <th>Author</th>
          <th>Complete</th>
          <th>Actions</th>
        </tr>
      </table>
    """)

    template

  constructor: (@parent, @options = {}) ->
    @element = @template()
    @parent.append(@element)
    @slug = $(@parent).data('slug')

    @spinner = new Spinner(@element)
    url = Routes.transifex_resources_path(project_slug: @slug)
    @spinner.get(url).success (data) =>
      @update(data)

  update: (data) ->
    for resource in data
      if resource.branch?
        new ResourceRow(@, resource, @options)

window.ResourceTable = ResourceTable
