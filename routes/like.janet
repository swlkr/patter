(use joy)


(route :post "/likes" :likes/create)
(route :delete "/likes/:id" :likes/delete)


(defn like-button [post &opt like]
  [:form
    [:input {:type "hidden" :name "post-id" :value (get post :id)}]
    [:a (merge {:href "#" :hx-swap "outerHTML"}
               (if like
                 {:hx-delete (url-for :likes/delete like)
                  :class "danger"}
                 {:hx-post (url-for :likes/create)
                  :class "bright"}))
      (if like
        (raw `<svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-heart-fill" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
               <path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>
             </svg>`)
        (raw `<svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-heart" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
               <path fill-rule="evenodd" d="M8 2.748l-.717-.737C5.6.281 2.514.878 1.4 3.053c-.523 1.023-.641 2.5.314 4.385.92 1.815 2.834 3.989 6.286 6.357 3.452-2.368 5.365-4.542 6.286-6.357.955-1.886.838-3.362.314-4.385C13.486.878 10.4.28 8.717 2.01L8 2.748zM8 15C-7.333 4.868 3.279-3.04 7.824 1.143c.06.055.119.112.176.171a3.12 3.12 0 0 1 .176-.17C12.72-3.042 23.333 4.867 8 15z"/>
              </svg>`))]])


(defn like [req]
  (let [id (get-in req [:params :id])]
    (db/find :like id)))


(def like-params
  (params :like
    (validates [:post-id] :required true)
    (permit [:post-id])))


(defn likes/create [req]
  (def {:account account} req)

  (def params (like-params req))

  (def result (-> (like-params req)
                  (put :account-id (account :id))
                  (db/insert)
                  (rescue)))

  (def [errors like] result)

  (text/html
    (like-button {:id (params :post-id)} like)))


(defn likes/delete [req]
  (def like (like req))

  (db/delete like)

  (text/html
    (like-button {:id (like :post-id)})))
