json.set! :list do
  json.partial! 'list', list: @list
  json.isInitiallyChecked false
end