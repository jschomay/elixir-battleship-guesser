(ns client.views
  (:require
    [re-frame.core :as re-frame]
    [client.subs :as subs]))

(defn index-to-point
  [i {:keys [cols]}]
  (let [col (rem (inc i) cols)
        row (inc (quot i cols))]
    [(if (zero? col) cols col) row]))

(defn main-panel []
  (let [{:keys [ cols rows] :as size}
        @(re-frame/subscribe [::subs/size])]
    [:div
     [:h1 "Battleship!"]
     [:div "cols:" cols]
     [:div "rows:" rows]
     [:div.board
      {:style
       {:grid-template-columns (str  "repeat(" cols " , 1fr)")
        :grid-template-rows (str  "repeat(" rows " , 1fr)")}}
      (for [ i  (range 0 (* cols rows))]
        ^{:key i} [:div.water-tile (-> i (index-to-point size) seq .toString)])]]))

