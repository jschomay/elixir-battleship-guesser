(ns client.db)

(def default-db
  {:size {:cols 7 :rows 5}
   :ships [[[3 3] [3 4]]
           [[1 1] [4 1]]
           [[2 3] [2 5]]
           [[6 3] [7 3]]
           [[7 4] [6 4]]]})
           
; :plays [{:col 3 :row 4 :status :hit}]
; :guess {:col 3 :row 5}})
