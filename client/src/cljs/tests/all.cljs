(ns tests.all
  (:require
    [cljs.test :refer-macros [deftest is testing run-tests]]
    [client.events :as events]))

(deftest ship-to-vec
  (testing "vertical"
    (let [ship [[1 2] [1 5]]
          actual (events/ship-to-vec ship)
          expected [[1 2] [1 3] [1 4] [1 5]]]
      (is (= actual expected))))

  (testing "horizontal"
    (let [ship [[1 2] [3 2]]
          actual (events/ship-to-vec ship)
          expected [[1 2] [2 2] [3 2]]]
      (is (= actual expected))))

  (testing "backwards"
    (let [ship [[1 5] [1 2]]
          actual (events/ship-to-vec ship)
          expected [[1 2] [1 3] [1 4] [1 5]]]
      (is (= actual expected))))

  (testing "1x2"
    (let [ship [[1 2] [1 3]]
          actual (events/ship-to-vec ship)
          expected [[1 2] [1 3]]]
      (is (= actual expected))))

  (testing "1x1"
    (let [ship [[1 2] [1 2]]
          actual (events/ship-to-vec ship)
          expected [[1 2]]]
      (is (= actual expected)))))

(defn run []
    (run-tests))

