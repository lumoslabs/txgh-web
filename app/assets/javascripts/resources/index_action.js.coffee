$ ->
  doPush = (btn, projectSlug, resourceSlug, branch) ->
    msg = "Are you sure you want to push strings up to " +
      "#{projectSlug}.#{resourceSlug} from #{branch}?"

    if confirm(msg)
      url = Routes.project_resource_push_path(
        project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
      )

      _get(url, btn).fail ->
        alert('Push failed. Try again.')

  doPull = (btn, projectSlug, resourceSlug, branch) ->
    msg = "Are you sure you want to pull translations from " +
      "#{projectSlug}.#{resourceSlug} into #{branch}?"

    if confirm(msg)
      url = Routes.project_resource_pull_path(
        project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
      )

      _get(url, btn).fail ->
        alert('Pull failed. Try again.')

  doDownload = (btn, branch, projectSlug) ->
    baseUrl = $('.branch-list').data('url')
    url = "#{baseUrl}/download.zip?project_slug=#{projectSlug}&branch=#{branch}"
    $(btn).attr('disabled', 'disabled')

    $.fileDownload(url).fail (response) ->
      responseJson = JSON.parse($(response).text())
      alert(responseJson[0].error)
    .always ->
      $(btn).removeAttr('disabled')

  onLoad = (table) ->
    branches = []

    for resource in (row.resource for row in table.rows)
      if branches.indexOf(resource.branch) == -1
        branches.push(resource.branch)

    new BranchList(
      $('.branch-list'), branches, {
        onDownloadClicked: doDownload
      }
    )

  _get = (url, btn) ->
    $(btn).attr('disabled', 'disabled')

    $.get(url).always ->
      $(btn).removeAttr('disabled')

  new ResourceTable(
    $('.resource-table'), {
      onPushClicked: doPush
      onPullClicked: doPull
      onLoad: onLoad
    }
  )
