(use joy)
(import uri)


(route :get "/posts" :posts/index)
(route :get "/posts/new" :posts/new)
(route :get "/posts/:id" :posts/show)
(route :post "/posts" :posts/create)
(route :get "/posts/:id/edit" :posts/edit)
(route :patch "/posts/:id" :posts/patch)
(route :delete "/posts/:id" :posts/delete)


(defn post [req]
  (let [id (get-in req [:params :id])]
    (db/find :post id)))


(def params
  (params :post
    (validates [:body] :required true)
    (permit [:body])))


(defn posts/index [req]
  (let [posts (db/from :post)]
   [:div
    [:a {:href (url-for :posts/new)} "New post"]

    [:table
     [:thead
      [:tr
       [:th "id"]
       [:th "account-id"]
       [:th "body"]
       [:th "created-at"]
       [:th "updated-at"]
       [:th]
       [:th]
       [:th]]]
     [:tbody
      (foreach [post posts]
        [:tr
          [:td (post :id)]
          [:td (post :account-id)]
          [:td (post :body)]
          [:td (post :created-at)]
          [:td (post :updated-at)]
          [:td
           [:a {:href (url-for :posts/show post)} "Show"]]
          [:td
           [:a {:href (url-for :posts/edit post)} "Edit"]]
          [:td
           (form-for [req :posts/delete post]
            [:input {:type "submit" :value "Delete"}])]])]]]))


(defn posts/show [req]
  (def post (post req))

  [:div
   [:strong "id"]
   [:div (post :id)]

   [:strong "account-id"]
   [:div (post :account-id)]

   [:strong "body"]
   [:div (post :body)]

   [:strong "created-at"]
   [:div (post :created-at)]

   [:strong "updated-at"]
   [:div (post :updated-at)]


   [:a {:href (url-for :posts/index)} "All posts"]])


(defn posts/new [req]
  (def errors (get req :errors {}))
  (def body (get req :body {}))

  (form-for [req :posts/create]
    [:div
     [:label {:for "body"} "body"]
     [:input {:type "text" :name "body" :value (body :body)}]
     [:small (errors :body)]]

    [:input {:type "submit" :value "Save"}]))


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

  (def post* (-> (params req)
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


(defn posts/edit [req]
  (def post (post req))
  (def errors (get req :errors {}))
  (def body (get req :body {}))

  (form-for [req :posts/patch post]
    [:div
     [:label {:for "body"} "body"]
     [:input {:type "text" :name "body" :value (or (body :body)
                                                   (post :body))}]
     [:small (errors :body)]]

    [:input {:type "submit" :value "Save"}]))


(defn posts/patch [req]
  (let [post (post req)
        result (->> (params req)
                    (merge post)
                    (db/update)
                    (rescue))
        [errors post] result]
    (if errors
      (posts/edit (put req :errors errors))
      (redirect-to :posts/index))))


(defn posts/delete [req]
  (def post (post req))

  (db/delete post)

  (redirect-to :posts/index))


(defn posts/mention-suggestions [req])
