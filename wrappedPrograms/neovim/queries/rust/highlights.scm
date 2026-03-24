; extends

; Distinguish tuple parentheses from regular parentheses
(tuple_expression ["(" ")"] @constructor)

; Distinguish unary operators from binary operators
(reference_type "&" @keyword)
(unary_expression ["*" "&"] @keyword)
