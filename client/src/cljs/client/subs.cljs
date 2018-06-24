(ns client.subs
  (:require
   [re-frame.core :as re-frame]))

(re-frame/reg-sub
 ::size
 (fn [db]
   (:size db)))
