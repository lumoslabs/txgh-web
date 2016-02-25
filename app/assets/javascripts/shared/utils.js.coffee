class Utils
  @trigger: (obj, method, args...) ->
    obj[method].apply(obj, args) if obj[method]?

window.Utils = Utils
