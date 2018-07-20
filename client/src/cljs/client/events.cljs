(ns client.events
  (:require
   [re-frame.core :as rf]
   [client.db :as db]))


(rf/reg-event-db
  ::initialize-db
  (fn [_ _]
    db/default-db))

(rf/reg-event-db
  ::change-grid-size
  (fn [db [_ axis value]]
    (if (-> value js/Number.parseInt ((some-fn js/Number.isNaN zero? #(< % 1))))
      db
      (assoc-in db [:size axis] (js/Math.round value)))))

(rf/reg-event-db
  ::next-scene
  (fn [db _]
    (cond
      (= (:scene db) :board) (assoc db :scene :ships)
      (= (:scene db) :ships) (assoc db :scene :play)
      :else db)))
      

(rf/reg-event-db
  ::click-water-tile
  (fn [{:keys [:scene :ships :ship-in-progress] :as db} [_ coord]] 
    (if (not= scene :ships)
      db
      (if (empty? ship-in-progress)
        (assoc db :ship-in-progress [coord coord])

        (assoc db
               :ship-in-progress []
               :ships (conj ships ship-in-progress))))))

(defn ship-to-vec [[[x1 y1] [x2 y2]]]
  (vec (for [x (range (min x1 x2) (inc (max x1 x2)))
             y (range (min y1 y2) (inc (max y1 y2)))]
         [x y])))

(defn on-axis? [[x y] [x1 y1]]
  (or (= x x1) (= y y1)))

(defn collision? [ship1 ship2]
  (not (apply distinct? (concat (ship-to-vec ship1) (ship-to-vec ship2)))))

(rf/reg-event-db
  ::hover-water-tile
  (fn [{:keys [:scene :ship-in-progress :ships] :as db} [_ coord]] 
    (let [active? (and
                    (= scene :ships)
                    (seq ship-in-progress))
          valid? (and
                   (on-axis? (first ship-in-progress) coord)
                   (not-any? (partial collision? (assoc ship-in-progress 1 coord)) ships))]

      (if (and active? valid?)
        (assoc-in db [:ship-in-progress 1] coord)
        db))))

(rf/reg-event-db
  ::remove-ship
  (fn [{:keys [:scene :ships] :as db} [_ ship]]
    (if (not= scene :ships)
        db
        (->>
          ships
          (remove #(= ship %))
          (assoc db :ships)))))
    

      
