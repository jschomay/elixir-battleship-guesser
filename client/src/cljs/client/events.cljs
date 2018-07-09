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
