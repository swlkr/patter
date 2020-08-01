(use joy)

(route :post "/mentions/searches" :mentions/searches)


(defn add-mention [account]
  (string/format "body = body.slice(0, body.lastIndexOf('@')) + '@%s'; $refs.textarea.focus()" (account :name)))


(defn search-result [account]
  [:hstack {:align-y "center" :spacing "xs"}

   [:a {:href (url-for :accounts/show {:* [(account :name)]})
        :x-on:click.prevent (add-mention account)}
    [:img {:src (account :photo-url)
           :class "br-100 ba b--background-alt sm:w-m md:w-m"
           :alt (string (account :name) "'s profile photo")}]]

   [:vstack {:align-y "center"}
    [:a {:href (url-for :accounts/show {:* [(account :name)]})
         :x-on:click.prevent (add-mention account)}
      (string "@" (account :name))]

    [:div {:class "muted"}
      (let [rows (db/query "select count(*) as follow_count from follow where followed_id = ?" [(account :id)])
            follow-count (get-in rows [0 :follow-count])]
        (string follow-count
                (if (one? follow-count)
                  " follower"
                  " followers")))]]])


(defn mentions/searches [req]
  (def body (get-in req [:body :body] ""))
  (def name (last (string/split "@" body)))

  (text/html
    (when (and (nil? (string/find " " name))
               (string/find "@" body))
      (def accounts (db/from :account :where ["name like ?" (string name "%")] :order "name"))

      [:div {:class "bg-background br-xs mh-2xl overflow-y"}
       [:div {:x-cloak "" :x-show "false" :x-ref "firstResult"}
        (-> accounts first (get :name))]

       [:vstack {:spacing "xs" :class "pa-s br-xs"}
        (map search-result accounts)]])))
