(use joy)
(use ./like)


(route :get "/posts/new" :posts/new)
(route :get "/posts/:id" :posts/show)
(route :post "/posts" :posts/create)
(route :delete "/posts/:id" :posts/delete)


(def post-params
  (params :post
    (validates [:body] :required true)
    (permit [:body])))


(defn post [req]
  (def {:account account :post post :params params} req)
  (def post (if post
              post
              (db/find-by :post :where {:post.id (get params :id)}
                                :join/one :account)))
  (def account (or account (post :account)))

  (def like (db/find-by :like :where {:post-id (post :id) :account-id (account :id)}))
  (def replies (db/val "select count(id) from reply where post_id = ?" (post :id)))
  (def retweet (db/find-by :retweet :where {:post-id (post :id) :account-id (account :id)}))

  [:div {:class "w-100"}
   [:hstack {:stretch "" :spacing "xs" :align-y "top" :class "bg-background pa-xs br-2xs ba b--solid b--background-alt"}
    [:a {:href (url-for :accounts/show {:* [(account :name)]})}
     [:img {:src (account :photo-url) :class "br-100 ba b--background-alt sm:w-m md:w-m"}]]

    [:vstack {:spacing "m"}
     [:hstack {:stretch ""}
      [:a {:class "ellipsis" :href (url-for :accounts/show {:* [(account :name)]})}
       (account :display-name)]

      [:spacer]

      [:a {:class "muted ellipsis" :href (url-for :accounts/show {:* [(account :name)]})}
       (string "@" (account :name))]

      [:spacer]

      [:a {:href (url-for :posts/show post)}
       [:time {:data-seconds (post :created-at) :class "muted tr"}
        (post :created-at)]]]

     [:div {:class "pre-wrap"}
      (raw (post :body))]

     [:hstack
      [:a {:hx-get (url-for :replies/new post)
           :hx-target "#modal"
           :hx-indicator "#loader"
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

      (like-button post like)]]]])


(defn posts/show [req]
  (def {:params params} req)

  (when-let [post* (db/find :post (get params :id))]

    (def replies (db/fetch-all [:post post* :reply] :order "reply.created_at desc"))
    (def reply-posts (db/from :reply :where {:post-id (map |($ :post-id) replies)}))

    [:vstack {:spacing "m" :class "w-100"}
     (post (merge req {:post post*}))

     [:vstack {:spacing "s"}
      [:h2 "Replies"]
      (foreach [p reply-posts]
        (post (merge req {:post p})))]]))


(defn posts/form [options]
  (def {:body body :placeholder placeholder} options)

  [:vstack {:spacing "xs" :class "pa-s" :x-data "{ body: '' }"}
   [:textarea {:rows 7
               :name "body"
               :autofocus ""
               :value body
               :x-ref "textarea"
               :x-model "body"
               :hx-post (url-for :mentions/searches)
               :hx-trigger "keyup changed delay:10ms"
               :hx-target "#search-results"
               :class "b--none w-100 bs--none bg-background focus:bs--none pa-xs"
               :placeholder placeholder}]

   [:hstack {:spacing "m"}
    [:button {:type "submit"
              :x-bind:disabled "body.length === 0"
              :stretch ""}
     "Post"]

    [:div {:class "w-m" :x-text "body.length"}]]

   [:div {:id "search-results"}]])


(defn posts/new [req]
  (def {:body body} req)
  (def body (get body :body ""))

  (text/html
    (form-with req (action-for :posts/create)
      (posts/form {:body body :placeholder "What's up?"}))))


(defn finder [str]
 (peg/compile ~(any (+ (* ,str) 1))))


(def mention-finder (finder '(<- (* "@" (+ :w+ :d+)))))

(defn mentions [req]
  (peg/match mention-finder (get-in req [:body :body])))


(defn mention-link [s]
  (string/format `<a href="/%s">%s</a>` s s))


(defn mention-linker [mentions s]
  (var output s)

  (loop [m :in mentions]
    (set output (string/replace m (mention-link m) output)))

  output)


(defn mentionize [s]
  (def mentions (mentions s))) # => ["@hello" "@world"]


(defn posts/create [req]
  # before we save the post
  # take care of linking @ mentions
  # and # hashtags
  (def mentions (mentions req))

  (def req (-> (update-in req [:body :body] escape)
               (update-in [:body :body] |(mention-linker mentions $))))

  (def post* (-> (post-params req)
                 (put :account-id (get-in req [:account :id]))
                 (db/insert)
                 (rescue)))

  (def [errors post] post*)

  (def account-names (map |(string/replace "@" "" $) mentions))

  # map mentions to accounts
  (def accounts (->> (db/from :account :where {:name account-names})
                     (map |(table/slice $ [:id :name]))
                     (group-by |($ :name))
                     (map-vals first)
                     (map-vals |($ :id))))

  # save mentions too
  (unless (or errors (empty? mentions))
    (->> (map |(table :name $) account-names)
         (map |(put $ :post-id (post :id)))
         (map |(put $ :account-id (get accounts (get $ :name))))
         (db/insert-all :mention)))

  (if errors
    (posts/new (put req :errors errors))
    (redirect-to :home)))


(defn posts/delete [req]
  (def {:params params} req)
  (def post (db/find :post params))

  (db/delete post)

  (redirect-to :posts/index))
