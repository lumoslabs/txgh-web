$ ->
  doPush = (btn, projectSlug, resourceSlug, branch) ->
    url = Routes.resource_push_path(
      project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
    )

    _get(url, btn).fail ->
      alert('Push failed. Try again.')

  doPull = (btn, projectSlug, resourceSlug, branch) ->
    url = Routes.resource_pull_path(
      project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
    )

    _get(url, btn).fail ->
      alert('Pull failed. Try again.')

  doDownload = (btn, branch, projectSlug) ->
    url = Routes.transifex_download_path(
      project_slug: projectSlug, branch: branch, format: 'json'
    )

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
