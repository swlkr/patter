(use joy)
(use ./routes/reply)
(use ./routes/like)
(use ./routes/account)
(use ./routes/post)
(use ./routes/mention)


(defn loader [&opt opts]
  (default opts {:color "#fff"})
  (raw
    (string/format
      `<svg class="htmx-indicator mx-auto" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 44 44" stroke="%s">
        <g fill="none" fill-rule="evenodd" stroke-width="2">
        <circle cx="22" cy="22" r="1">
          <animate attributeName="r" begin="0s" dur="1.8s" values="1; 20" calcMode="spline" keyTimes="0; 1" keySplines="0.165, 0.84, 0.44, 1" repeatCount="indefinite"/>
          <animate attributeName="stroke-opacity" begin="0s" dur="1.8s" values="1; 0" calcMode="spline" keyTimes="0; 1" keySplines="0.3, 0.61, 0.355, 1" repeatCount="indefinite"/>
        </circle>
        <circle cx="22" cy="22" r="1">
          <animate attributeName="r" begin="-0.9s" dur="1.8s" values="1; 20" calcMode="spline" keyTimes="0; 1" keySplines="0.165, 0.84, 0.44, 1" repeatCount="indefinite"/>
          <animate attributeName="stroke-opacity" begin="-0.9s" dur="1.8s" values="1; 0" calcMode="spline" keyTimes="0; 1" keySplines="0.3, 0.61, 0.355, 1" repeatCount="indefinite"/>
        </circle>
        </g>
      </svg>` (opts :color))))


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
      [:script {:src "/alpine.min.js" :defer ""}]
      [:script {:src "/app.js" :defer ""}]
      [:script {:src "/htmx.min.js"}]]

     [:body {:x-data "{ modal: true }"
             :x-on:keyup.escape.window "modal = false"}
      [:div {:id "modal"}]

      body

      [:div {:class "fixed bottom-m right-m"}
       [:button {:hx-get (url-for :posts/new)
                 :hx-target "#modal"
                 :x-on:click "modal = true"
                 :class "br-100 h-l w-l pa-0"}
        (loader)
        (raw `<svg width="1.5em" height="1.5em" viewBox="0 0 16 16" class="bi bi-pen" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M5.707 13.707a1 1 0 0 1-.39.242l-3 1a1 1 0 0 1-1.266-1.265l1-3a1 1 0 0 1 .242-.391L10.086 2.5a2 2 0 0 1 2.828 0l.586.586a2 2 0 0 1 0 2.828l-7.793 7.793zM3 11l7.793-7.793a1 1 0 0 1 1.414 0l.586.586a1 1 0 0 1 0 1.414L5 13l-3 1 1-3z"/>
                <path fill-rule="evenodd" d="M9.854 2.56a.5.5 0 0 0-.708 0L5.854 5.855a.5.5 0 0 1-.708-.708L8.44 1.854a1.5 1.5 0 0 1 2.122 0l.293.292a.5.5 0 0 1-.707.708l-.293-.293z"/>
                <path d="M13.293 1.207a1 1 0 0 1 1.414 0l.03.03a1 1 0 0 1 .03 1.383L13.5 4 12 2.5l1.293-1.293z"/>
              </svg>`)]]]]))


(route :get "/" :home)
(defn home [request]
  (def {:account current-account} request)

  (def posts (db/from :post
                      :join/one :account
                      :order "post.created_at desc"
                      :limit 15))

  [:div {:class "pb-m"}
   [:vstack {:class "sm:w-100 lg:w-3xl mx-auto mb-m bb b--background-alt"}
    (foreach [post posts]
      (let [account (post :account)
            like (db/find-by :like :where {:post-id (post :id) :account-id (current-account :id)})
            replies (db/val "select count(id) from reply where post_id = ?" (post :id))]
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
           [:a {:hx-get (url-for :replies/new post)
                :hx-target "#modal"
                :x-on:click "modal = true"
                :href "#"}
            [:span {:class "mr-2xs"} replies]
            [:svg {:xmlns "http://www.w3.org/2000/svg" :fill "currentColor" :height "1.2em" :width "1.2em" :class "bi bi-reply" :viewBox "0 0 16 16"}
             [:path {:fill-rule "evenodd" :d "M9.502 5.013a.144.144 0 0 0-.202.134V6.3a.5.5 0 0 1-.5.5c-.667 0-2.013.005-3.3.822-.984.624-1.99 1.76-2.595 3.876C3.925 10.515 5.09 9.982 6.11 9.7a8.741 8.741 0 0 1 1.921-.306 7.403 7.403 0 0 1 .798.008h.013l.005.001h.001L8.8 9.9l.05-.498a.5.5 0 0 1 .45.498v1.153c0 .108.11.176.202.134l3.984-2.933a.494.494 0 0 1 .042-.028.147.147 0 0 0 0-.252.494.494 0 0 1-.042-.028L9.502 5.013zM8.3 10.386a7.745 7.745 0 0 0-1.923.277c-1.326.368-2.896 1.201-3.94 3.08a.5.5 0 0 1-.933-.305c.464-3.71 1.886-5.662 3.46-6.66 1.245-.79 2.527-.942 3.336-.971v-.66a1.144 1.144 0 0 1 1.767-.96l3.994 2.94a1.147 1.147 0 0 1 0 1.946l-3.994 2.94a1.144 1.144 0 0 1-1.767-.96v-.667z"}]]]

           [:spacer]

           [:svg {:xmlns "http://www.w3.org/2000/svg" :fill "currentColor" :height "1.2em" :width "1.2em" :class "bi bi-arrow-repeat" :viewBox "0 0 16 16"}
             [:path {:fill-rule "evenodd" :d "M2.854 7.146a.5.5 0 0 0-.708 0l-2 2a.5.5 0 1 0 .708.708L2.5 8.207l1.646 1.647a.5.5 0 0 0 .708-.708l-2-2zm13-1a.5.5 0 0 0-.708 0L13.5 7.793l-1.646-1.647a.5.5 0 0 0-.708.708l2 2a.5.5 0 0 0 .708 0l2-2a.5.5 0 0 0 0-.708z"}]
             [:path {:fill-rule "evenodd" :d "M8 3a4.995 4.995 0 0 0-4.192 2.273.5.5 0 0 1-.837-.546A6 6 0 0 1 14 8a.5.5 0 0 1-1.001 0 5 5 0 0 0-5-5zM2.5 7.5A.5.5 0 0 1 3 8a5 5 0 0 0 9.192 2.727.5.5 0 1 1 .837.546A6 6 0 0 1 2 8a.5.5 0 0 1 .501-.5z"}]]
           [:spacer]

           (form-with request {}
             [:input {:type "hidden" :name "post-id" :value (post :id)}]
             (let [attrs @{:href "#"}
                   attrs (if like
                           (put attrs :hx-delete (url-for :likes/delete like))
                           (put attrs :hx-post (url-for :likes/create)))]
               [:a attrs
                [:svg {:xmlns "http://www.w3.org/2000/svg" :fill (if like "red" "currentColor") :height "1.2em" :width "1.2em" :class "bi bi-heart" :viewBox "0 0 16 16"}
                  [:path {:fill-rule "evenodd" :d "M8 2.748l-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"}]]]))]]]))]])


(before "/*" :set-current-account)
(defn set-current-account [req]
  (let [account (get-in req [:session :account :id])]
    (if (nil? account)
      (put req :account (db/find :account 1))
      (put req :account account))))


(def app (app {:layout layout}))


(defn main [& args]
  (db/connect (env :database-url))
  (server app (env :port)))
