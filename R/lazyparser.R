parser_def <- function(...){
  args <- eval(substitute(alist(...)))
  if(is.null(arg_name <- names(args))) {
    arg_name <- character(length(args))
  }
  which_empty <- which(arg_name == "")
  names(args)[which_empty] <- args[which_empty]
  wrong_name <- names(args) != make.names(names(args))
  if(any(wrong_name))
    stop("Invalid argument name: ",
         paste0(shQuote(names(args)[wrong_name]), collapse = ","))
  for(i in which_empty){
    args[[i]] <- bquote()
  }
  body <- bquote({
    lapply(names(environment()), function(.x) {eval(str2lang(.x))})
    as.list(environment(), all.names = TRUE)
  })
  eval(call("function", as.pairlist(eval(args)), body), parent.frame())
}

#' @export
lazyparser <- function(...) {
  .parser_internal <- parser_def(...)
  function(...) {
    args <- list(...)
    if(length(args) > 0)
      return(.parser_internal(...))
    e <- new.env(parent = parent.frame())
    e$.parser_internal <- .parser_internal
    eval(str2lang(paste0(".parser_internal(", paste0(commandArgs(TRUE), collapse = ","), ")")),
         envir = e)
  }
}
