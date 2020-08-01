(use joy)
(use ./routes/retweet)
(use ./routes/reply)
(use ./routes/like)
(use ./routes/account)
(use ./routes/post)
(use ./routes/mention)


(defn loader [&opt opts]
  (default opts {:color "#fff"})
  [:vstack {:stretch "" :align-y "center"}
   [:div {:id "loader"}
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
         </svg>` (opts :color)))]])


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

     [:body {:x-data "{ modal: false }"
             :x-on:keyup.escape.window "modal = false"}
      [:div {:x-show "modal"}
        [:div {:id "modal" :class "fixed left-m right-m top-m bg-background br-2xs z-3 max-w-3xl min-h-2xl mx-auto"}
         (loader {:color "#333"})]
        [:div {:class "fixed fill bg-inverse o-75"
               :x-on:click.prevent "modal = false"}]]

      body

      [:div {:class "fixed bottom-m right-m"}
       [:button {:hx-get (url-for :posts/new)
                 :hx-target "#modal"
                 :hx-indicator "#loader"
                 :x-on:click "modal = true"
                 :class "br-100 h-l w-l pa-0"}
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
            replies (db/val "select count(id) from reply where post_id = ?" (post :id))
            retweet (db/find-by :retweet :where {:post-id (post :id) :account-id (current-account :id)})]
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
            (raw `<svg width="1.1em" height="1.1em" viewBox="0 0 16 16" class="bi bi-chat" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                   <path fill-rule="evenodd" d="M2.678 11.894a1 1 0 0 1 .287.801 10.97 10.97 0 0 1-.398 2c1.395-.323 2.247-.697 2.634-.893a1 1 0 0 1 .71-.074A8.06 8.06 0 0 0 8 14c3.996 0 7-2.807 7-6 0-3.192-3.004-6-7-6S1 4.808 1 8c0 1.468.617 2.83 1.678 3.894zm-.493 3.905a21.682 21.682 0 0 1-.713.129c-.2.032-.352-.176-.273-.362a9.68 9.68 0 0 0 .244-.637l.003-.01c.248-.72.45-1.548.524-2.319C.743 11.37 0 9.76 0 8c0-3.866 3.582-7 8-7s8 3.134 8 7-3.582 7-8 7a9.06 9.06 0 0 1-2.347-.306c-.52.263-1.639.742-3.468 1.105z"/>
                 </svg>`)]

           [:spacer]

           [:a (merge {:href "#"
                       :hx-swap "outerHTML"}
                      (if retweet
                        {:hx-delete (url-for :retweets/delete retweet)}
                        {:hx-post (url-for :retweets/create post)
                         :class "bright"}))
            (raw `<svg width="1.2em" height="1.2em" viewBox="0 0 16 16" class="bi bi-arrow-counterclockwise" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                   <path fill-rule="evenodd" d="M12.83 6.706a5 5 0 0 0-7.103-3.16.5.5 0 1 1-.454-.892A6 6 0 1 1 2.545 5.5a.5.5 0 1 1 .91.417 5 5 0 1 0 9.375.789z"/>
                   <path fill-rule="evenodd" d="M7.854.146a.5.5 0 0 0-.708 0l-2.5 2.5a.5.5 0 0 0 0 .708l2.5 2.5a.5.5 0 1 0 .708-.708L5.707 3 7.854.854a.5.5 0 0 0 0-.708z"/>
                 </svg>`)]

           [:spacer]

           (like-button post like)]]]))]])


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
