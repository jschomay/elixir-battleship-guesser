(ns client.views
  (:require
    [re-frame.core :as rf]
    [client.subs :as subs]))

(defn to-point
  [i {:keys [cols]}]
  (let [col (rem (inc i) cols)
        row (inc (quot i cols))]
    [(if (zero? col) cols col) row]))

(defn dimensions
  "returns [cols rows] as dimensions"
  [[[col1 row1] [col2 row2]]]
  [(inc (js/Math.abs (- col1 col2)))
   (inc (js/Math.abs (- row1 row2)))])

(defn layer
  [class-name {:keys [cols rows]} children]
  [:div 
   {:class class-name
    :style
    {:grid-template-columns (str  "repeat(" cols " , 1fr)")
     :grid-template-rows (str  "repeat(" rows " , 1fr)")}}
   children])

(defn ship
  [[[col1 row1] [col2 row2] :as ship]]
  ^{:key ship} [:div.tile.tile--ship
                {:style
                 {:grid-row (str (min row1 row2) "/ span " (second (dimensions ship)))
                  :grid-column (str (min col1 col2) "/ span " (first (dimensions ship)))}}
                (.toString ship)])

(defn water
  [coords] 
  ^{:key coords} [:div.tile.tile--water (-> coords  seq .toString)])

(defn main-panel []
  (let [{:keys [ cols rows] :as size} @(rf/subscribe [::subs/size])
        ships @(rf/subscribe [::subs/ships])]
    [:div.game
     [:h1 "Battleship!"]
     [:div "cols:" cols]
     [:div "rows:" rows]
     [:div.board
      (layer "water" size (for [ i (range (* cols rows))] (-> i (to-point size) water)))
      (layer "ships" size (map ship ships))]]))

