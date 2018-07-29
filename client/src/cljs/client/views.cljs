(ns client.views
  (:require
    [re-frame.core :as rf]
    [client.subs :as subs]
    [client.events :as events]))

;;;;;;;;;;;;;; Helpers ;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;; Scenes ;;;;;;;;;;;;;;;;


(defn set-board []
  (let [{:keys [ cols rows]} @(rf/subscribe [::subs/size])
        change-size #(rf/dispatch [::events/change-grid-size %1 (-> %2 .-target .-value)])]
    [:div.scene.scene--size
     [:h3 "Choose the size of your board"]
     [:div "Columns: " 
      [:input {:type "number"
               :size 2
               :value cols
               :on-change (partial change-size :cols)}]]
     [:div "Rows: " 
      [:input {:type "number"
               :size 2
               :value rows
               :on-change (partial change-size :rows)}]]
     [:button {:on-click #(rf/dispatch [::events/next-scene])} "Next"]]))

(defn set-ships []
  [:div.scene.scene--ships
   [:h3 "Layout your ships"]
   [:p "Click on a square to start a ship, then click on another square to finish it.  You can make as many as you like."]
   (when (seq @(rf/subscribe [::subs/ships]))
     [:button {:on-click #(rf/dispatch [::events/next-scene])} "Play!"])])

(defn play []
  [:div.scene.scene--ships
   [:h3 "It's time to play!"]
   [:p "Sit back and watch the AI try to sink your ships."]])

;;;;;;;;;;;;;; Layout ;;;;;;;;;;;;;;;;

(defn layer
  [class-name {:keys [cols rows]} children]
  (into [:div.layer 
         {:class (str "layer--" class-name)
          :style {:grid-template-columns (str  "repeat(" cols " , 1fr)")
                  :grid-template-rows (str  "repeat(" rows " , 1fr)")}}]
   children))

(defn water-tile
  [coords active] 
  ^{:key coords}
  [:div.tile.tile--water
   (when active {:class "tile--water-active"
                 :on-click #(rf/dispatch [::events/click-water-tile coords])
                 :on-mouse-over #(rf/dispatch [::events/hover-water-tile coords])})
   (-> coords  seq .toString)])

(defn ship-tile
  [can-remove-ship [[col1 row1] [col2 row2] :as ship]]
  ^{:key ship} 
  [:div.tile.tile--ship
   (into {:style {:grid-row (str (min row1 row2) "/ span " (second (dimensions ship)))
                  :grid-column (str (min col1 col2) "/ span " (first (dimensions ship)))}}
         (when can-remove-ship
           {:class "tile--ship-active"
            :on-click #(rf/dispatch [::events/remove-ship ship])}))
   (.toString ship)])

(defn play-tile
  [{:keys [col row status] :as play}]
  ^{:key play}
  [:div.tile.tile--play
   {:class (str "tile--" status)
    :style {:grid-row (str row "/ span 1")
            :grid-column (str col "/ span 1")}}
   (.toString status)])

(defn instructions [scene]
  [:div.instructions
   (cond
     (= scene :board) [set-board]
     (= scene :ships) [set-ships]
     (= scene :play) [play])])

(defn main-panel []
  (let [{:keys [ cols rows] :as size} @(rf/subscribe [::subs/size])
        ships @(rf/subscribe [::subs/ships])
        ship-in-progress @(rf/subscribe [::subs/ship-in-progress])
        plays @(rf/subscribe [::subs/plays])
        scene @(rf/subscribe [::subs/scene])
        can-remove-ship @(rf/subscribe [::subs/can-remove-ship])
        can-add-ships @(rf/subscribe [::subs/can-add-ships])]
    [:div.game
     [:h1 "Battleship!"]
     [instructions scene] 
     [:div.board
      [layer "water" size (for [ i (range (* cols rows))] (-> i (to-point size) (water-tile can-add-ships)))]
      [layer "ships" size (map (partial ship-tile can-remove-ship) (keep identity (conj ships ship-in-progress)))]]]))
      ; [layer "plays" size (map play-tile plays)]]]))

