(ns client.subs
  (:require
   [re-frame.core :as rf]))

(rf/reg-sub
 ::size
 (fn [db]
   (:size db)))

(rf/reg-sub
 ::ships
 (fn [db]
   (:ships db)))

(rf/reg-sub
 ::plays
 (fn [db]
   (conj (:plays db) (assoc (:guess db) :status "guess"))))
