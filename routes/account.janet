(use joy)
(use ./post)


(route :get "/@*" :accounts/show)


(defn accounts/show [req]
  (def {:wildcard params*} req)

  (when-let [account (db/find-by :account :where {:name (get params* 0)})]

    (def following (db/val "select count(id) from follow where followed_id = ?" (account :id)))
    (def followers (db/val "select count(id) from follow where follower_id = ?" (account :id)))
    (def likes (db/val "select count(id) from like where account_id = ?" (account :id)))
    (def num-posts (db/val "select count(id) from post where account_id = ?" (account :id)))
    (def posts (db/fetch-all [:account account :post] :order "post.created_at desc"))

    [:vstack {:spacing "s" :class "w-100"}

     [:img {:src (account :photo-url) :class "br-100 ba b--background-alt w-xl"}]

     [:vstack {:spacing "s"}

      [:vstack {:spacing "xs"}
       [:strong (account :display-name)]
       [:div {:class "muted"} (string "@" (account :name))]]

      [:hstack {:spacing "s"}

       [:hstack {:spacing "xs"}
        [:b following]
        [:span {:class "muted"} "Following"]]

       [:hstack {:spacing "xs"}
        [:b followers]
        [:span {:class "muted"} "Followers"]]

       [:hstack {:spacing "xs"}
        [:b likes]
        [:span {:class "muted"} "Likes"]]]]

     [:vstack
      (foreach [p posts]
        (post (merge req {:post p})))]]))
