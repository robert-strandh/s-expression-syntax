;;;; types.lisp --- Rules for parsing type specifiers.
;;;;
;;;; Copyright (C) 2018, 2019, 2020, 2021 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:s-expression-syntax)

(parser:defgrammar type-specifiers
  (:class eg::expression-grammar))

(parser:in-grammar type-specifiers)

;;; General type specifier syntax

#+TODO-maybe (parser:defrule compound-type-specifier ()
                 (list (guard symbolp) (* :any))
               (bp:node* (:compound-type-specifier :head )
                 (* :argument )))

(defrule type-specifier ()
    (and (must (not (list* 'values :any)) "VALUES type is invalid in this context")
         (must (not 'values) "the symbol VALUES is not a valid type specifier")
         (or (guard symbolp) ; TODO control whether * is allowed
             (list (guard symbolp) (* :any)))))

(defrule type-specifier! ()
    (must (type-specifier) "must be a type specifier"))

;;; `values' type specifier

;; TODO The symbol * may not be among the value-types.
(defrule values-type-specifier ()
    (list 'values
          (* (<<- required (and :any
                                (not (or '&optional '&rest '&allow-other-keys))
                                (type-specifier!))))
          (? (seq '&optional (<<- optional (and :any
                                                (not (or '&rest '&allow-other-keys))
                                                (type-specifier!)))))
          (? (seq '&rest (<- rest (type-specifier!))))
          (? (<- allow-other-keys? '&allow-other-keys)))
  (list required optional rest allow-other-keys?))
