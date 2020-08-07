(use joy)
(use ./post)


(route :get "/posts/:id/replies/new" :replies/new)
(route :post "/posts/:id/replies" :replies/create)
(route :delete "/replies/:id" :replies/delete)


(def reply-params
  (params :reply
    (validates [:body] :required true)
    (permit [:body])))


(defn replies/new [req]
  (def {:errors errors :body body :params params} req)
  (def post (db/find-by :post :where {:post.id (get params :id)}
                              :join/one :account))
  (def account (post :account))

  (text/html
    [:div
     (post (merge req {:post post}))
     (form-with req (action-for :replies/create post)
       (posts/form {:body body :placeholder (string "Reply to @" (account :name))}))]))


(defn replies/create [req]
  (def {:params params :body body :account account} req)

  (def post (db/find :post (get params :id)))

  (def result (-> (reply-params req)
                  (put :post-id (post :id))
                  (put :account-id (account :id))
                  (db/insert)
                  (rescue)))

  (def [errors reply] result)

  (if errors
    (replies/new (put req :errors errors))
    (redirect-to :home)))


(defn replies/delete [req]
  (def {:params params} req)
  (def reply (db/find :reply params))

  (db/delete reply)

  (redirect-to :replies/index))
