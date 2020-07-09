(declare-project
  :name "patter"
  :description ""
  :dependencies ["https://github.com/joy-framework/joy"]
  :author ""
  :license ""
  :url ""
  :repo "")

(phony "server" []
  (os/shell "janet main.janet"))

(phony "watch" []
  (os/shell "ls | entr -r -d janet main.janet"))
