(use joy)

(db/connect (env :database-url))

(repl nil
      (fn [_ y] (printf "%M" y))
      (fiber/getenv (fiber/current)))

(db/disconnect)
