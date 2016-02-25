class BranchList
  template: (branch) ->
    $("""
      <div class='col-sm-5 branch-list-item'>
        <button class='btn btn-default btn-xs download'>Download</button>&nbsp;#{branch}
      </div>
    """)

  constructor: (@parent, @branches, @options = {}) ->
    @slug = $(@parent).data('slug')

    @items = for branch in @branches
      # wrap in closure so branch is correct when @download is called
      ((branch) =>
        item = @template(branch)
        button = $('.download', item)
        button.click => @download(button, branch)
        item
      )(branch)

    @parent.append(@items)

  download: (btn, branch) ->
    Utils.trigger(@options, 'onDownloadClicked', btn, branch, @slug)

window.BranchList = BranchList
