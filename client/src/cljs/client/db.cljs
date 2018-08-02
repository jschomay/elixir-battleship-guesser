(ns client.db)

(def default-db
  {:size {:cols 7 :rows 5}
   :scene :board
   :ship-in-progress nil
   :ships []
   :game-id nil
   :plays []
   :game-over false})

(def example-ships
  [[[3 3] [3 4]]
   [[1 1] [4 1]]
   [[2 3] [2 5]]
   [[6 3] [7 3]]
   [[7 4] [6 4]]])


(def example-plays
  [{:col 3 :row 4 :status "hit"}
   {:col 5 :row 2 :status "miss"}])

; domain helpers

(defn ship-to-vec [[[x1 y1] [x2 y2]]]
  (vec (for [x (range (min x1 x2) (inc (max x1 x2)))
             y (range (min y1 y2) (inc (max y1 y2)))]
         [x y])))

(defn on-axis? [[x y] [x1 y1]]
  (or (= x x1) (= y y1)))

(defn collision? [ship1 ship2]
  (not (apply distinct? (concat (ship-to-vec ship1) (ship-to-vec ship2)))))

(defn hit? [ship {:keys [:col :row]}]
  (->>
    ship
    (ship-to-vec)
    (some #{[col row]})))

(defn sunk? [plays ship]
  (=
   (count (filter #(hit? ship %) plays))
   (count (ship-to-vec ship))))

(defn game-over? [plays ships]
  (every? (partial sunk? plays) ships))

