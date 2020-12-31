;;;; lambda-lists.lisp --- Tests for lambda list related rules.
;;;;
;;;; Copyright (C) 2018, 2019, 2020 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:syntax.test)

(def-suite* :syntax.lambda-lists
  :in :syntax)

;;; Ordinary lambda list

(test keyword-parameter
  "Smoke test for the `keyword-parameter' rule."

  (rule-test-cases ((syntax::keyword-parameter syntax::lambda-lists)
                    (make-hash-table :test #'eq))
    '((x (declare)) :fatal (declare) "declare is not allowed here")
    '(5             :fatal 5         "must be a lambda list variable name")
    '(x             t      t         ((keyword x) x nil nil))))

(test ordinary-lambda-list
  "Smoke test for the `ordinary-lambda-list' rule."

  (rule-test-cases ((syntax::ordinary-lambda-list syntax::lambda-lists)
                    (make-hash-table :test #'eq))
    '((&optional (foo (declare)))
      :fatal (declare) "declare is not allowed here")
    '((&key (foo (declare)))
      :fatal (declare) "declare is not allowed here")
    '((&aux (foo (declare)))
      :fatal (declare) "declare is not allowed here")

    '((foo bar &optional (hash-table-rehash-size default)
       &rest x
       &key ((:x-kw y) 1 supplied?) b &allow-other-keys &aux (a 1))
      t nil ((foo bar) ((hash-table-rehash-size default nil)) x
             ((:x-kw y 1 supplied?) ((keyword b) b nil nil)) &allow-other-keys
             ((a 1))))

    '((foo foo2 &rest pie &key ((:foo bar) :default bar-p)
       &aux (a 1) b)
      t nil ((foo foo2) () pie ((:foo bar :default bar-p)) nil ((a 1) (b nil))))))

;;; Specialized lambda list

(test specialized-lambda-list
  "Smoke test for the `specialized-lambda-list' rule."

  (rule-test-cases ((syntax::specialized-lambda-list syntax::lambda-lists)
                    (make-hash-table :test #'eq))
    '(((foo 1))
      :fatal 1 "must be a class name")
    '(((foo (eql 1 2)))
      :fatal (1 2) "must be a single object")

    '(((baz fez) (foo bar) &rest whoop)
      t nil (((baz fez) (foo bar)) () whoop () nil))

    '(((baz fez) (foo bar) &rest foo)
      :fatal foo "must be a lambda list variable name")))

;;; Destructuring lambda list

(test destructuring-lambda-list
  "Smoke test for the `destructuring-lambda-list' rule."

  (rule-test-cases ((syntax::destructuring-lambda-list syntax::destructuring-lambda-list)
                    (make-hash-table :test #'eq))
    '(((foo bar))
      t nil (:destructuring-lambda-list
             nil nil
             ((:destructuring-lambda-list nil nil (foo bar) () nil () nil ()))
             ()
             nil
             ()
             nil
             ()))

    '((&whole whole (foo &key a) . (&rest fez))
      t nil (:destructuring-lambda-list
             whole nil
             ((:destructuring-lambda-list
               nil nil (foo) () nil (((keyword a) a nil nil)) nil ()))
             ()
             fez
             ()
             nil
             ()))

    '((&optional ((bar baz) (5 6) bar-baz-p))
      t nil (:destructuring-lambda-list
             nil nil ()
             (((:destructuring-lambda-list nil nil (bar baz) () nil () nil ())
               (5 6) bar-baz-p))
             nil () nil ()))

    '((&aux a (b 1))
      t nil (:destructuring-lambda-list
             nil nil
             ()
             ()
             nil
             ()
             nil
             ((a nil) (b 1))))))

;;; Deftype lambda list

(test deftype-lambda-list
  "Smoke test for the `deftype-lambda-list' rule."

  (rule-test-cases ((syntax::deftype-lambda-list syntax::deftype-lambda-list)
                    (make-hash-table :test #'eq))
    '((foo bar)
      t nil (nil (foo bar) () nil () nil ()))))
