(ns client.events
  (:require
   [re-frame.core :as rf]
   [ajax.core :as ajax]
   [day8.re-frame.http-fx]
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

(def server-url "http://localhost:4000/")
; TODO switch to based on prod flag


(defn make-request [endpoint & [game-id overrides]]
  (merge
    (into {:method :put
           :uri (str  server-url endpoint)
           :format (ajax/json-request-format)
           :response-format (ajax/json-response-format {:keywords? true}) 
           :on-success [::receive-guess]
           :on-failure [::bad-response]}
      (when game-id
        {:headers {:game-token game-id}}))
    overrides))


(rf/reg-event-fx
  ::next-scene
  (fn [{db :db} _]
    (case (:scene db)
      :board {:db (assoc db :scene :ships)}
      :ships {:db (assoc db :scene :play)
              :http-xhrio ( make-request
                            "new"
                            nil
                            {:method :post
                             :params (:size db)
                             :on-success [::game-created]
                             :on-failure [::bad-response]})}
      :play {:db db/default-db}
      {:db db})))


(rf/reg-event-fx
  ::game-created
  (fn [{db :db} [_ {game-id :id}]]
    {:db (assoc db :game-id game-id)
     :http-xhrio (make-request "start" game-id)}))

(rf/reg-event-fx
  ::request-guess
  (fn [_ [_ & args]]
    {:http-xhrio (apply make-request args)}))

(defn guess-result [ships plays guess]
  (let [hit-ship (some #(when (db/hit? % guess) %) ships)
        sunk (and hit-ship (db/sunk? (conj plays guess) hit-ship))]
    (cond
      sunk ["sunk" {:params {:size (count (db/ship-to-vec hit-ship))}}]
      hit-ship ["hit"]
      :always ["miss"])))


(rf/reg-event-fx
  ::receive-guess
  (fn [{{:keys [:game-id :ships :plays] :as db} :db} [_ {guess :guess}]]

    (let [[status overrides] (guess-result ships plays guess)
          new-plays (conj plays (assoc guess :status status))
          game-over (and (= status "sunk") (db/game-over? new-plays ships))]

      (into
        {:db (assoc db :plays new-plays :game-over game-over)}
        (if (not game-over)
          {:dispatch-later [{:ms 500
                             :dispatch [::request-guess status game-id overrides]}]}
          {:dispatch [::request-guess "leave" game-id
                      {:method :delete
                       :on-success [::game-deleted]}]})))))

(rf/reg-event-db
  ::game-deleted
  (fn [db _]
    db))

(rf/reg-event-db
  ::bad-response
  (fn [db [_ result]]
    (js/console.error (clj->js (str "Error: " (get-in result [:response :error]))))
    db))

(rf/reg-event-db
  ::click-water-tile
  (fn [{:keys [:scene :ships :ship-in-progress] :as db} [_ coord]] 
    (if (not= scene :ships)
      db
      (if (empty? ship-in-progress)
        (assoc db :ship-in-progress [coord coord])

        (assoc db
               :ship-in-progress nil
               :ships (conj ships ship-in-progress))))))

(rf/reg-event-db
  ::hover-water-tile
  (fn [{:keys [:scene :ship-in-progress :ships] :as db} [_ coord]] 
    (let [active? (and
                    (= scene :ships)
                    (seq ship-in-progress))
          valid? (and
                   (db/on-axis? (first ship-in-progress) coord)
                   (not-any? (partial db/collision? (assoc ship-in-progress 1 coord)) ships))]

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
    

      
