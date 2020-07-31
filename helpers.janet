(defn modal [& body]
  [:div {:x-show "modal"}
   [:div {:class "fixed left-m right-m top-m bg-background br-2xs z-3 max-w-3xl mx-auto"}
    body]
   [:div {:class "fixed fill bg-inverse o-75"
          :x-on:click.prevent "modal = false"}]])
