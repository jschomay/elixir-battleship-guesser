(ns client.db)

(def default-db
  {:size {:cols 7 :rows 5}
   :scene :board
   :ship-in-progress nil
   :ships []
   :plays []
   :guess {:col 3 :row 5}})

(def example-ships
  [[[3 3] [3 4]
    [[1 1] [4 1]]
    [[2 3] [2 5]]
    [[6 3] [7 3]]
    [[7 4] [6 4]]]])


(def example-plays
  [{:col 3 :row 4 :status "hit"}
   {:col 5 :row 2 :status "miss"}])
