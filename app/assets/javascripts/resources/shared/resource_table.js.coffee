class ResourceRow
  template: (data) ->
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

  constructor: (@parent, @resource, @options = {}) ->
    @row = @template(@resource)
    resource_slug = @deBranchResourceSlug(@resource.slug, @resource.branch)
    that = @

    $('.action-push', @row).click ->
      that.trigger('onPushClicked', @, that.parent.slug, resource_slug, that.resource.branch)

    $('.action-pull', @row).click ->
      that.trigger('onPullClicked', @, that.parent.slug, resource_slug, that.resource.branch)

    @parent.element.append(@row)
    @completion = $('.completion', @row)

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

  trigger: (method, args...) ->
    @options[method].apply(@, args) if @options[method]?


class ResourceTable
  template: ->
    template = $("""
      <table class="table table-striped table-hover">
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
