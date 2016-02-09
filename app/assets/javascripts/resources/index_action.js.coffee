$ ->
  doPush = (btn, projectSlug, resourceSlug, branch) ->
    url = Routes.resource_push_path(
      project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
    )

    get(url, btn).fail ->
      alert('Push failed. Try again?')

  doPull = (btn, projectSlug, resourceSlug, branch) ->
    url = Routes.resource_pull_path(
      project_slug: projectSlug, resource_slug: resourceSlug, branch: branch
    )

    get(url, btn).fail ->
      alert('Pull failed. Try again?')

  get = (url, btn) ->
    $(btn).attr('disabled', 'disabled')

    $.get(url).always ->
      $(btn).removeAttr('disabled')

  new ResourceTable(
    $('.resource-table'), {
      onPushClicked: doPush
      onPullClicked: doPull
    }
  )
