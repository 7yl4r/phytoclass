#' Performs the steepest descent algorithm for a set number of iterations
#' 
#' @keywords internal
#' 
#' @param Fmat xx
#' @param place xx
#' @param S   xx
#' @param cm   xx
#' @param num.loops   xx
#'
#' @return
#'
#' @examples
Steepest_Descent <- function(Fmat, place, S, cm, num.loops) {
  loop <- 1
  F.new <- NNLS_MF(Fmat, S, cm)
  F.initial <- F.new
  for (i in 1:num.loops) { # should always be small. It would be nice to allow the
    F.new <- Minimise_elements_comb(F.initial[[1]], place, S, cm, c1_num = 3)
    
    loop   <- loop + 1
    loop_2 <- 1
    while (F.new[[2]] > F.initial[[2]]) {
      loop_2 <- loop_2 + 1

      if (loop_2 <= 5) {
        F.new <- Minimise_elements_comb(F.initial[[1]], place, S, cm, c1_num = 3)
      } else if (loop_2 < 10) {
        F.new <- Minimise_elements_comb(F.initial[[1]], place, S, cm, c1_num = 1)
      } else if (loop_2 <= 100) {
        # If it doesn't work the first time, it randomises at a lower rate
        F.new <- Minimise_elements_comb(F.initial[[1]], place, S, cm, c1_num = 2)
      } else if (loop_2 > 100) {
        # it will continue for 100 iterations, and then stop
        break
      }
    }
    F.initial <- F.new
  }
  return(F.new)
}
