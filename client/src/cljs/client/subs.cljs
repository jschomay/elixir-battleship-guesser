(ns client.subs
  (:require
   [re-frame.core :as rf]
   [client.db :as db]))

(rf/reg-sub
 ::size
 (fn [db]
   (:size db)))

(rf/reg-sub
 ::scene
 (fn [db]
   (:scene db)))

(rf/reg-sub
 ::ship-in-progress
 (fn [db]
   (:ship-in-progress db)))

(rf/reg-sub
 ::ships
 (fn [db]
   (:ships db)))

(rf/reg-sub
  ::plays
  (fn [db]
    (:plays db)))

(rf/reg-sub
 ::game-over
 (fn [db]
   (:game-over db)))

(rf/reg-sub
  ::accuracy
  :<- [::plays]
  :<- [::ships]
  (fn [[plays ships] _]
    (js/Math.round
      (* 100 (/ (count (mapcat db/ship-to-vec ships))
                (count plays))))))


(rf/reg-sub
  ::can-add-ships
  :<- [::scene]
  (fn [scene _]
    (and (= scene :ships))))

(rf/reg-sub
  ::can-remove-ship
  :<- [::scene]
  :<- [::ship-in-progress]
  (fn [[scene ship-in-progress] _]
    (and (= scene :ships)
         (empty? ship-in-progress))))
