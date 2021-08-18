;;;; protocol.lisp --- Protocol functions provided by the syntax system.
;;;;
;;;; Copyright (C) 2018-2022 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:s-expression-syntax)

;;; Name protocol

;;; in conditions.lisp
#+(or)(defgeneric name (thing))
(setf (documentation 'name 'function)
      "Return the name of THING.

If THING is syntax description that describes a standard special
operator, macro, class or type, the returned name is the symbol in the
COMMON-LISP package which names the special operator, macro, class or
type.

If THING is a component, the name is a symbol which uniquely identifies the
component within the containing syntax description.")

;;; Component protocol

(defgeneric cardinality (component)
  (:documentation
   "Return cardinality of sub-expression(s) described by COMPONENT.

The following values may be returned

? The described sub-expression occurs zero or one times in the
  containing expression.

1 The described sub-expression occurs exactly once in the containing
  expression.

* The described sub-expression occurs zero or more times in the
  containing expression."))

(defgeneric evaluation (component)
  (:documentation
   "Return evaluation semantics of sub-expressions described by COMPONENT."))

;;; Syntax description protocol

(defgeneric components (container)
  (:documentation
   "Return a sequence of components belonging to CONTAINER.

"))

(defgeneric find-component (name container &key if-does-not-exist)
  (:documentation
   "Return the component of CONTAINER named NAME.

IF-DOES-NOT-EXIST controls the behavior in case a component named NAME
does not exist in CONTAINER.

If the value of IF-DOES-NOT-EXIST is a function, that function is
called with a single argument, a condition of type
`component-not-found-error'.

If the value of IF-DOES-NOT-EXIST is not a function, that value is
returned in place of the missing component."))

;;; Default behavior

(defmethod find-component ((name t) (container symbol) &key if-does-not-exist)
  (declare (ignore if-does-not-exist))
  (find-component name (find-syntax container)))

(defmethod find-component :around ((name t) (container t) &key if-does-not-exist) ; TODO should be outermost call only
  (or (call-next-method)
      (typecase if-does-not-exist
        (function
         (funcall if-does-not-exist (make-condition 'component-not-found-error
                                                    :syntax container
                                                    :name   name)))
        (t
         if-does-not-exist))))

;;; Syntax description repository protocol

(defgeneric find-syntax (name &key if-does-not-exist)
  (:documentation
   "Return the syntax description named NAME, if any.

IF-DOES-NOT-EXIST controls the behavior in case a syntax description
named NAME does not exist. The following values are allowed:

#'ERROR

  Signal an error if a syntax description named NAME does not exist.

OBJECT

  Return OBJECT if a syntax description named NAME does not exist."))

(defgeneric (setf find-syntax) (new-value name &key if-does-not-exist))

(defgeneric ensure-syntax (name class &rest initargs))

;;; Default behavior

(defmethod find-syntax :around ((name t) &key (if-does-not-exist #'error))
  (or (call-next-method)
      (typecase if-does-not-exist
        (function
         (funcall if-does-not-exist (make-condition 'syntax-not-found-error
                                                    :name name)))
        (t
         if-does-not-exist))))

;;; Parse protocol

(defgeneric classify (client expression)
  (:documentation
   "Classify EXPRESSION, possibly according to specialized behavior of CLIENT.

Return a syntax description object that roughly reflects the kind of
EXPRESSION. Note that a precise classification would have to take into
account aspects beyond the syntax, such as the environment, to, for
example, distinguish function and macro application or variable
references and symbol macro applications. It should always be possible
to find an appropriate syntax description:

+ If EXPRESSION is a special form, this function returns the syntax
  description for the corresponding special operator.

+ If EXPRESSION is an application of a standard macro, this function
  returns the syntax description for that macro.

+ If EXPRESSION a list not covered by the above cases, this function
  returns the syntax description for a generic (that is, function or
  macro) application. Note that this case also covers invalid
  applications such as (1 2 3).

+ If EXPRESSION is a symbol but not a keyword, this function returns a
  syntax description for a variable reference.

+ If EXPRESSION is any object that is not covered by the above cases,
  this function returns a syntax description for a self-evaluating
  object."))

(defgeneric parse (client syntax expression)
  (:documentation
   "Parse EXPRESSION according to SYNTAX, possibly specialized behavior of CLIENT.

TODO"))

;;; Default behavior

(defmethod parse ((client t) (syntax symbol) (expression t))
  (parse client (find-syntax syntax) expression))
