(use joy)
(use ./routes/retweet)
(use ./routes/reply)
(use ./routes/like)
(use ./routes/account)
(use ./routes/post)
(use ./routes/mention)

(import ./icons :as icons)


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

      [:div {:class "max-w-4xl mx-auto px-xl"}
       [:hstack {:spacing "m"}
        [:vstack {:spacing "m"}
         [:a {:href (url-for :home)}
           "Home"]
         [:a {:href (url-for :accounts/show {:* [(get-in req [:account :name])]})}
           "Profile"]]

        body]]

      [:button {:hx-get (url-for :posts/new)
                :hx-target "#modal"
                :hx-indicator "#loader"
                :x-on:click "modal = true"
                :class "fixed bottom-m right-m br-100 h-l w-l pa-0"}
        icons/pen]]]))


(route :get "/" :home)
(defn home [request]
  (def {:account current-account} request)

  (def posts (db/from :post
                      :join/one :account
                      :order "post.created_at desc"
                      :limit 15))

  [:div {:class "pb-m"}
   [:vstack {:class "bb b--background-alt"}
    (foreach [p posts]
      (post (merge request {:post p})))]])


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
