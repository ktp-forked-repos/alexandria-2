(in-package :alexandria)

(defun extract-function-name (spec)
  "Useful for macros that want to mimic the functional interface for functions
like #'eq and 'eq."
  (if (and (consp spec)
           (member (first spec) '(quote function)))
      (second spec)
      spec))

(defun %reevaluate-constant (name value &key (test 'eql))
  (if (not (boundp name))
      value
      (let ((old (symbol-value name))
            (new value))
        (if (not (constantp name))
            (prog1 new
              (cerror "Try to redefine the variable as a constant."
                      "~@<~S is an already bound non-constant variable ~
                       whose value is ~S.~:@>" name old))
            (if (funcall test old new)
                old
                (prog1 new
                  (cerror "Try to redefine the constant."
                          "~@<~S is an already defined constant whose value ~
                           ~S is not equal to the provided initial value ~S ~
                           under ~S.~:@>" name old new test)))))))

(defmacro define-constant (name initial-value &key (test ''eql) documentation)
  "Ensures that the global variable named by NAME is a constant with a
value that is equal under TEST to the result of evaluating
INITIAL-VALUE. TEST is a /function designator/ that defaults to
EQL. If DOCUMENTATION is given, it becomes the documentation string of
the constant.

Signals an error if NAME is already a bound non-constant variable.

Signals an error if NAME is already a constant variable whose value is not
equal under TEST to result of evaluating INITIAL-VALUE."
  `(defconstant ,name (%reevaluate-constant ',name
                                            ,initial-value
                                            :test ,test)
     ,@(when documentation `(,documentation))))
