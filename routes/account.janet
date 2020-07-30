(use joy)


(route :get "/accounts" :accounts/index)
(route :get "/accounts/new" :accounts/new)
(route :get "/@*" :accounts/show)
(route :post "/accounts" :accounts/create)
(route :get "/accounts/:id/edit" :accounts/edit)
(route :patch "/accounts/:id" :accounts/patch)
(route :delete "/accounts/:id" :accounts/delete)


(defn account [req]
  (let [id (get-in req [:params :id])]
    (db/find :account id)))


(def params
  (params :account
    (validates [ :name :display-name :photo-url] :required true)
    (permit [ :name :display-name :photo-url])))


(defn accounts/index [req]
  (let [accounts (db/from :account)]
   [:div
    [:a {:href (url-for :accounts/new)} "New account"]

    [:table
     [:thead
      [:tr
       [:th "id"]
       [:th "name"]
       [:th "display-name"]
       [:th "photo-url"]
       [:th "created-at"]
       [:th "updated-at"]
       [:th]
       [:th]
       [:th]]]
     [:tbody
      (foreach [account accounts]
        [:tr
          [:td (account :id)]
          [:td (account :name)]
          [:td (account :display-name)]
          [:td (account :photo-url)]
          [:td (account :created-at)]
          [:td (account :updated-at)]
          [:td
           [:a {:href (url-for :accounts/show account)} "Show"]]
          [:td
           [:a {:href (url-for :accounts/edit account)} "Edit"]]
          [:td
           (form-for [req :accounts/delete account]
            [:input {:type "submit" :value "Delete"}])]])]]]))


(defn accounts/show [req]
  (def account (db/find-by :account :where {:name (get-in req [:wildcard 0])}))

  [:div
   [:strong "id"]
   [:div (account :id)]

   [:strong "name"]
   [:div (account :name)]

   [:strong "display-name"]
   [:div (account :display-name)]

   [:strong "photo-url"]
   [:div (account :photo-url)]

   [:strong "created-at"]
   [:div (account :created-at)]

   [:strong "updated-at"]
   [:div (account :updated-at)]


   [:br]
   [:a {:href (url-for :home)} "Feed me"]])


(defn accounts/new [req]
  (def errors (get req :errors {}))
  (def body (get req :body {}))

  (form-for [req :accounts/create]
    [:div
     [:label {:for "name"} "name"]
     [:input {:type "text" :name "name" :value (body :name)}]
     [:small (errors :name)]]

    [:div
     [:label {:for "display-name"} "display-name"]
     [:input {:type "text" :name "display-name" :value (body :display-name)}]
     [:small (errors :display-name)]]

    [:div
     [:label {:for "photo-url"} "photo-url"]
     [:input {:type "text" :name "photo-url" :value (body :photo-url)}]
     [:small (errors :photo-url)]]

    [:input {:type "submit" :value "Save"}]))


(defn accounts/create [req]
  (let [result (->> (params req)
                    (db/insert)
                    (rescue))
        [errors account] result]
    (if errors
      (accounts/new (put req :errors errors))
      (redirect-to :accounts/index))))


(defn accounts/edit [req]
  (def account (account req))
  (def errors (get req :errors {}))
  (def body (get req :body {}))

  (form-for [req :accounts/patch account]
    [:div
     [:label {:for "name"} "name"]
     [:input {:type "text" :name "name" :value (or (body :name)
                                                   (account :name))}]
     [:small (errors :name)]]

    [:div
     [:label {:for "display-name"} "display-name"]
     [:input {:type "text" :name "display-name" :value (or (body :display-name)
                                                        (account :display-name))}]
     [:small (errors :display-name)]]

    [:div
     [:label {:for "photo-url"} "photo-url"]
     [:input {:type "text" :name "photo-url" :value (or (body :photo-url)
                                                       (account :photo-url))}]
     [:small (errors :photo-url)]]

    [:input {:type "submit" :value "Save"}]))


(defn accounts/patch [req]
  (let [account (account req)
        result (->> (params req)
                    (merge account)
                    (db/update)
                    (rescue))
        [errors account] result]
    (if errors
      (accounts/edit (put req :errors errors))
      (redirect-to :accounts/index))))


(defn accounts/delete [req]
  (def account (account req))

  (db/delete account)

  (redirect-to :accounts/index))
