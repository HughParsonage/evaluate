#' Generate a traceback from a list of calls.
#'
#' @param callstack stack of calls, as generated by (e.g.)
#'   \code{\link[base]{sys.calls}}
#' @keywords internal
#' @export
create_traceback <- function(callstack) {
  if (length(callstack) == 0) return()

  # Convert to text
  calls <- lapply(callstack, deparse, width = 500)
  calls <- sapply(calls, paste0, collapse = "\n")

  # Number and indent
  calls <- paste0(seq_along(calls), ": ", calls)
  calls <- sub(x = calls, "\n", "\n   ")
  calls
}

#' Try, capturing stack on error.
#'
#' This is a variant of \code{\link{tryCatch}} that also captures the call
#' stack if an error occurs.
#'
#' @param quoted_code code to evaluate, in quoted form
#' @param env environment in which to execute code
#' @keywords internal
#' @export
try_capture_stack <- function(quoted_code, env) {
  capture_calls <- function(e) {
    # Make sure a "call" component exists to avoid warnings with partial
    # matching in conditionCall.condition()
    e["call"] <- e["call"]

    # Capture call stack, removing last two calls from end (added by
    # withCallingHandlers), and first frame + 7 calls from start (added by
    # tryCatch etc)
    e$calls <- head(sys.calls()[-seq_len(frame + 7)], -2)
    signalCondition(e)
  }
  frame <- sys.nframe()

  tryCatch(
    withCallingHandlers(eval(quoted_code, env), error = capture_calls),
    error = identity
  )
}
