(use joy)


(route :post "/posts/:id/retweets" :retweets/create)
(route :delete "/retweets/:id" :retweets/delete)


(def retweet-icon
  (raw `<svg width="1.2em" height="1.2em" viewBox="0 0 16 16" class="bi bi-arrow-counterclockwise" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
        <path fill-rule="evenodd" d="M12.83 6.706a5 5 0 0 0-7.103-3.16.5.5 0 1 1-.454-.892A6 6 0 1 1 2.545 5.5a.5.5 0 1 1 .91.417 5 5 0 1 0 9.375.789z"/>
        <path fill-rule="evenodd" d="M7.854.146a.5.5 0 0 0-.708 0l-2.5 2.5a.5.5 0 0 0 0 .708l2.5 2.5a.5.5 0 1 0 .708-.708L5.707 3 7.854.854a.5.5 0 0 0 0-.708z"/>
       </svg>`))


(defn retweets/create [req]
  (def {:params params :account account} req)

  (def post (db/find :post (params :id)))

  (def result (->> {:account-id (account :id)
                    :post-id (post :id)}
                   (db/insert :retweet)
                   (rescue)))

  (def [errors retweet] result)

  (if errors
    (text/html
      [:a {:href "#"
           :class "bright"
           :hx-swap "outerHTML"
           :hx-post (url-for :retweets/create post)}
        retweet-icon])

    (text/html
     [:a {:href "#"
          :class "link"
          :hx-swap "outerHTML"
          :hx-delete (url-for :retweets/delete retweet)}
       retweet-icon])))


(defn retweets/delete [req]
  (def {:params params} req)

  (def retweet (db/find :retweet (params :id)))

  (def post (db/find :post (retweet :post-id)))

  (db/delete retweet)

  (text/html
    [:a {:href "#"
         :class "bright"
         :hx-swap "outerHTML"
         :hx-post (url-for :retweets/create post)}
      retweet-icon]))
