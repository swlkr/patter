(import dotenv)
(dotenv/load)
(use joy)


(def port (os/getenv "PORT"))


(defn layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "patter"]

      # meta
      # TODO: social
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (authenticity-token request)}]

      # css
      [:link {:rel "stylesheet" :media "(prefers-color-scheme: light), (prefers-color-scheme: none)" :href "ridge-light.css"}]
      [:link {:rel "stylesheet" :media "(prefers-color-scheme: dark)" :href "ridge-dark.css"}]
      [:link {:rel "stylesheet" :href "/ridge.css"}]
      [:link {:rel "stylesheet" :href "/app.css"}]

      # js
      [:script {:src "/app.js" :defer ""}]]

     [:body body]]))


(route :get "/" :home)
(defn home [request]
  [:h1 "Welcome to patter"])


(def app (app {:layout layout}))


(defn main [& args]
  (db/connect)
  (server app port))
