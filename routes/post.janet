(use joy)


(route :get "/posts/new" :posts/new)
(route :get "/posts/:id" :posts/show)
(route :post "/posts" :posts/create)
(route :delete "/posts/:id" :posts/delete)


(def post-params
  (params :post
    (validates [:body] :required true)
    (permit [:body])))


(defn posts/show [req]
  (def {:account account :post post :params params} req)
  (def post (if post
              post
              (db/find-by :post :where {:id (get params :id)}
                                :join/one :account)))
  (def account (or account (post :account)))


  [:hstack {:spacing "xs" :align-y "top" :class "bg-background pa-xs bn bl bt br-2xs b--solid b--background-alt"}
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
     (raw (post :body))]]])


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
