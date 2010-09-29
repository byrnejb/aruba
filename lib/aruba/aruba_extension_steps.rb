When /clean up the working directory/ do
  clean_up
end


When /run "(.*)" with errors?$/ do |cmd|
  run(unescape(cmd), false)
end


When /run "(.*)" without errors?$/ do |cmd|
  run(unescape(cmd), true)
end
