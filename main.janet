(use joy)


(defn layout [{:body body :request req}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "patter"]

      # meta
      # TODO: social
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (authenticity-token req)}]

      # css
      [:link {:rel "stylesheet" :media "(prefers-color-scheme: light), (prefers-color-scheme: none)" :href "/ridge-light.css"}]
      [:link {:rel "stylesheet" :media "(prefers-color-scheme: dark)" :href "/ridge-dark.css"}]
      [:link {:rel "stylesheet" :href "/ridge.css"}]
      [:link {:rel "stylesheet" :href "/app.css"}]

      # js
      [:script {:src "/app.js" :defer ""}]]

     [:body body]]))


(route :get "/" :home)
(defn home [request]
  (def posts (db/from :post :join/one :account :order "post.created_at desc" :limit 15))

  [:vstack {:class "sm:w-100 lg:w-3xl mx-auto"}
   (foreach [post posts]
     (let [account (post :account)]
       [:hstack {:spacing "xs" :align-y "top" :class "bg-background pa-xs bn bl bt br b--solid b--background-alt"}
        [:img {:src (account :photo-url) :class "br-100 ba b--background-alt sm:w-m md:w-m"}]

        [:vstack {:spacing "s"}
         [:hstack {:shrink ""}
          [:div {:class "ellipsis"}
           (account :display-name)]

          [:div {:class "muted ellipsis"}
           (string "@" (account :name))]

          [:time {:data-seconds (post :created-at) :class "muted tr"}
           (post :created-at)]]

         [:div {:class "pre-wrap"}
          (raw (post :body))]

         [:hstack
          [:svg {:xmlns "http://www.w3.org/2000/svg" :fill "currentColor" :height "1em" :width "1em" :class "bi bi-reply" :viewBox "0 0 16 16"}
           [:path {:fill-rule "evenodd" :d "M9.502 5.013a.144.144 0 0 0-.202.134V6.3a.5.5 0 0 1-.5.5c-.667 0-2.013.005-3.3.822-.984.624-1.99 1.76-2.595 3.876C3.925 10.515 5.09 9.982 6.11 9.7a8.741 8.741 0 0 1 1.921-.306 7.403 7.403 0 0 1 .798.008h.013l.005.001h.001L8.8 9.9l.05-.498a.5.5 0 0 1 .45.498v1.153c0 .108.11.176.202.134l3.984-2.933a.494.494 0 0 1 .042-.028.147.147 0 0 0 0-.252.494.494 0 0 1-.042-.028L9.502 5.013zM8.3 10.386a7.745 7.745 0 0 0-1.923.277c-1.326.368-2.896 1.201-3.94 3.08a.5.5 0 0 1-.933-.305c.464-3.71 1.886-5.662 3.46-6.66 1.245-.79 2.527-.942 3.336-.971v-.66a1.144 1.144 0 0 1 1.767-.96l3.994 2.94a1.147 1.147 0 0 1 0 1.946l-3.994 2.94a1.144 1.144 0 0 1-1.767-.96v-.667z"}]]

          [:spacer]

          [:svg {:xmlns "http://www.w3.org/2000/svg" :fill "currentColor" :height "1em" :width "1em" :class "bi bi-arrow-repeat" :viewBox "0 0 16 16"}
            [:path {:fill-rule "evenodd" :d "M2.854 7.146a.5.5 0 0 0-.708 0l-2 2a.5.5 0 1 0 .708.708L2.5 8.207l1.646 1.647a.5.5 0 0 0 .708-.708l-2-2zm13-1a.5.5 0 0 0-.708 0L13.5 7.793l-1.646-1.647a.5.5 0 0 0-.708.708l2 2a.5.5 0 0 0 .708 0l2-2a.5.5 0 0 0 0-.708z"}]
            [:path {:fill-rule "evenodd" :d "M8 3a4.995 4.995 0 0 0-4.192 2.273.5.5 0 0 1-.837-.546A6 6 0 0 1 14 8a.5.5 0 0 1-1.001 0 5 5 0 0 0-5-5zM2.5 7.5A.5.5 0 0 1 3 8a5 5 0 0 0 9.192 2.727.5.5 0 1 1 .837.546A6 6 0 0 1 2 8a.5.5 0 0 1 .501-.5z"}]]
          [:spacer]

          [:svg {:xmlns "http://www.w3.org/2000/svg" :fill "currentColor" :height "1em" :width "1em" :class "bi bi-heart" :viewBox "0 0 16 16"}
            [:path {:fill-rule "evenodd" :d "M8 2.748l-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"}]]]]]))])


(def app (app {:layout layout}))


(defn main [& args]
  (db/connect (env :database-url))
  (server app (env :port)))
