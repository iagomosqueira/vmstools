#' Format Eflalo data to ensure that all columns are in right format
#' 
#' Reformat all the columns of the Eflalo data to ensure that all data is in
#' the right format
#' 
#' 
#' @param x eflalo file
#' @return Returns original Eflalo file but now with reformatted data
#' @author Niels T. Hintzen
#' @seealso \code{\link{formatTacsat}}
#' @references EU lot 2 project
#' @examples
#' 
#' data(eflalo)
#' eflalo <- formatEflalo(eflalo)
#' 
#' @export formatEflalo
formatEflalo <- function(x){
  x$VE_REF        <- ac(x$VE_REF)
  x$VE_FLT        <- ac(x$VE_FLT)
  x$VE_COU        <- ac(x$VE_COU)
  x$VE_LEN        <- an(ac(x$VE_LEN))
  x$VE_KW         <- an(ac(x$VE_KW))
  if("VE_TON" %in% colnames(x))       x$VE_TON        <- an(ac(x$VE_TON))
  x$FT_REF        <- ac(x$FT_REF)
  x$FT_DCOU       <- ac(x$FT_DCOU)
  x$FT_DHAR       <- ac(x$FT_DHAR)
  x$FT_DDAT       <- ac(x$FT_DDAT)
  x$FT_DTIME      <- ac(x$FT_DTIME)
  x$FT_LCOU       <- ac(x$FT_LCOU)
  x$FT_LHAR       <- ac(x$FT_LHAR)
  x$FT_LDAT       <- ac(x$FT_LDAT)
  x$FT_LTIME      <- ac(x$FT_LTIME)
  x$LE_ID         <- ac(x$LE_ID)
  x$LE_CDAT       <- ac(x$LE_CDAT)
  if("LE_UNIT"  %in% colnames(x)) x$LE_UNIT       <- ac(x$LE_UNIT)
  if("LE_STIME" %in% colnames(x)) x$LE_STIME      <- ac(x$LE_STIME)
  if("LE_ETIME" %in% colnames(x)) x$LE_ETIME      <- ac(x$LE_ETIME)
  if("LE_SLAT"  %in% colnames(x)) x$LE_SLAT       <- an(ac(x$LE_SLAT))
  if("LE_SLON"  %in% colnames(x)) x$LE_SLON       <- an(ac(x$LE_SLON))
  if("LE_ELAT"  %in% colnames(x)) x$LE_ELAT       <- an(ac(x$LE_ELAT))
  if("LE_ELON"  %in% colnames(x)) x$LE_ELON       <- an(ac(x$LE_ELON))
  x$LE_GEAR       <- ac(x$LE_GEAR)
  x$LE_MSZ        <- an(ac(x$LE_MSZ))
  x$LE_RECT       <- ac(x$LE_RECT)
  x$LE_DIV        <- ac(x$LE_DIV)
  if("LE_MET" %in% colnames(x)) x$LE_MET          <- ac(x$LE_MET)
  for(i in c(grep("_KG_",colnames(x)),grep("_EURO_",colnames(x)))) x[,i] <- an(ac(x[,i]))
  return(x)
}




