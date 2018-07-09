(ns client.views
  (:require
    [re-frame.core :as rf]
    [client.subs :as subs]
    [client.events :as events]))

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
  (into [:div.layer 
         {:class (str "layer--" class-name)
          :style {:grid-template-columns (str  "repeat(" cols " , 1fr)")
                  :grid-template-rows (str  "repeat(" rows " , 1fr)")}}]
   children))

(defn water-tile
  [coords] 
  ^{:key coords}
  [:div.tile.tile--water (-> coords  seq .toString)])

(defn ship-tile
  [[[col1 row1] [col2 row2] :as ship]]
  ^{:key ship} 
  [:div.tile.tile--ship
   {:style {:grid-row (str (min row1 row2) "/ span " (second (dimensions ship)))
            :grid-column (str (min col1 col2) "/ span " (first (dimensions ship)))}}
   (.toString ship)])

(defn play-tile
  [{:keys [col row status] :as play}]
  ^{:key play}
  [:div.tile.tile--play
   {:class (str "tile--" status)
    :style {:grid-row (str row "/ span 1")
            :grid-column (str col "/ span 1")}}
   (.toString status)])

(defn main-panel []
  (let [{:keys [ cols rows] :as size} @(rf/subscribe [::subs/size])
        ships @(rf/subscribe [::subs/ships])
        plays @(rf/subscribe [::subs/plays])
        change-size #(rf/dispatch [::events/change-grid-size %1 (-> %2 .-target .-value)])]
    [:div.game
     [:h1 "Battleship!"]
     [:div.size
       [:div "Columns: " 
        [:input {:type "number"
                 :size 2
                 :value cols
                 :on-change (partial change-size :cols)}]]
       [:div "Rows: " 
        [:input {:type "number"
                 :size 2
                 :value rows
                 :on-change (partial change-size :rows)}]]]
     [:div.board
      [layer "water" size (for [ i (range (* cols rows))] (-> i (to-point size) water-tile))]]]))
      ; [layer "ships" size (map ship-tile ships)]
      ; [layer "ships" size (map ship-tile ships)]
      ; [layer "plays" size (map play-tile plays)]]]))

