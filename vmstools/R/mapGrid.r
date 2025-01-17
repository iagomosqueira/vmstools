#mapGrid.r
#andy south 12/2/09

#to map grids input as SGDF
#** OR  maybe just provide a wrapper to mapGriddedData instead ?
#would need to add a better worldmap into that



#' function to map grids
#' 
#' Accepts an input of a \code{SpatialGridDataFrame} Plots a map of the grid
#' and optionally outputs to a gridAscii file and/or an image.
#' 
#' 
#' @param sGDF a \code{SpatialGridDataFrame}
#' @param sPDF an optional \code{SpatialPointsDataFrame} plotted if
#' \code{plotPoints=TRUE}
#' @param we western bounds of the area to plot, if not specified taken from
#' the \code{sGDF}
#' @param ea eastern bounds of the area to plot, if not specified taken from
#' the \code{sGDF}
#' @param so southern bounds of the area to plot, if not specified taken from
#' the \code{sGDF}
#' @param no northern bounds of the area to plot, if not specified taken from
#' the \code{sGDF}
#' @param gridValName the name of the attribute column to plot from the
#' \code{SpatialGridDataFrame}
#' @param plotTitle optional title to add to the plot
#' @param numCats how many categories to classify grid values into for map plot
#' (uses\code{pretty()}) classification)
#' @param paletteCats color pallete to use
#' @param addLegend whether to add a legend to the plot
#' @param legendx position of legend should be one of 'bottomright', 'bottom',
#' 'bottomleft', 'left', 'topleft', 'top', 'topright', 'right', 'center'
#' @param legendncol number of columns in the legend
#' @param legendtitle legend title
#' @param plotPoints whether to add the original points to the plot
#' @param colPoints color of points to plot
#' @param legPoints Logical. Points in legend
#' @param colland color of land
#' @param addICESgrid Logical. Adding ICES grid on top
#' @param addScale Logical. Adding axes
#' @param outGridFile optional name for a gridAscii file to be created from the
#' grid
#' @param outPlot optional name for a png file to be created from the plot
#' @param \dots NOT used yet
#' @author Andy South
#' @seealso \code{vmsGridCreate()}
#' @references EU Lot 2 project
#' @examples
#' 
#' #mapGrid(dF, nameLon = "POS_LONGITUDE", nameLat = "POS_LATITUDE",
#' #        cellsizeX = 0.5, cellsizeY = 0.5,legendx='bottomright',
#' #        plotPoints=TRUE )
#' 
#' @export mapGrid
mapGrid <- function( sGDF
                         , sPDF
                         , we=""
                         , ea=""
                         , so=""
                         , no=""
                         , gridValName="fishing"
                         , plotTitle = ""
                         , numCats = 5
                         , paletteCats = "heat.colors"
                         , addLegend = TRUE
                         , legendx='bottomleft'
                         , legendncol = 1
                         , legendtitle = "fishing activity"
                         , plotPoints = FALSE
                         , colPoints =1
                         , legPoints = FALSE
                         , colLand = 'sienna'
                         , addICESgrid = FALSE
                         , addScale = TRUE
                         , outGridFile = ""  #name for output gridAscii
                         , outPlot = ""  #name for output png
                         , ... )
{

require(sp)
require(maptools)

par(mar=c(4,6,1,1))
 
xlim0=c(we,ea)
ylim0=c(so,no)

lstargs <- list(...)

#dev.new()
if(length(lstargs$breaks0)==0) {
      breaks0 <- pretty(sGDF[[gridValName]],n=numCats)
      } else{
      breaks0 <- lstargs$breaks0
      }

# rainbow, heat.colors, etc.
cols <- rev(do.call(paletteCats, list(length(breaks0)-1)))

require(mapdata)
#windows(8,7)         # what is this for ? 
map("worldHires", add=FALSE,col=colLand,fill=TRUE, bg="white",  xlim=xlim0 + c(+0.1,-0.1), ylim=ylim0 + c(+0.1,-0.1), 
regions=c('uk','ireland','france','germany','netherlands', 'norway','belgium',
'spain','luxembourg','denmark', 'sweden','iceland', 'portugal','italy','sicily','ussr','sardinia','albania','monaco','turkey','austria',
'switzerland','czechoslovakia','finland','libya', 'hungary','yugoslavia','poland','greece','romania','bulgaria', 'slovakia','morocco',
'tunisia','algeria','egypt' ),  mar=c(2,6,2,2))

  im <-  as.image.SpatialGridDataFrame(sGDF, attr=2)
   image(im$x,im$y,im$z,  axes=FALSE, col=cols,  breaks = breaks0, 
   xlim=xlim0 , ylim=ylim0, add=TRUE   )
   
#add ICES rectangles 
if(addICESgrid){
  for(i in seq(-15,50, by=1)) abline(v=i)
  for(i in seq(0, 75, by=0.5)) abline(h=i)
  }

map("worldHires", add=TRUE, col=colLand, fill=TRUE, bg="white",  xlim=xlim0 , ylim=ylim0 , 
regions=c('uk','ireland','france','germany','netherlands', 'norway','belgium',
'spain','luxembourg','denmark', 'sweden','iceland', 'portugal','italy','sicily','ussr','sardinia','albania','monaco','turkey','austria',
'switzerland','czechoslovakia','finland','libya', 'hungary','yugoslavia','poland','greece','romania','bulgaria', 'slovakia','morocco',
'tunisia','algeria','egypt' ))


box() # to put a box around the plot
#mtext(paste(gear,year),font=4,line=-1.5)
axis(1)
axis(2, las=2)
 if(we>0){
   mtext("Degree East", side=1, line=2)
   } else{
   mtext("Degree West", side=1, line=2)
   }
 if(no>0){
   mtext("Degree North", side=2, line=3)
 } else{
   mtext("Degree South", side=2, line=3)
   }

 

# add a scale
if(addScale) map.scale(x=xlim0[2]-(xlim0[2]-xlim0[1])/2, y=ylim0[1], ratio=FALSE)

#to add points (can obscure grid)
if (plotPoints) {
 if(length(colPoints)!=1) {
   colPoints <- factor(colPoints)
   a.legPoints <- levels(colPoints)
   levels(colPoints) <- colors()[(1:length(levels(colPoints))) *10] 
   points(sPDF, pch=16, col=as.character(colPoints),cex=0.5)

     if(length(legPoints)!=0){
     legend(x='bottomright', legend=a.legPoints, pch = 16, col=levels(colPoints), title="", ncol=2, bg="white", pt.cex=1)
     }
   }else{
   points(sPDF, pch='.', col=colPoints,cex=0.1)   
   }
 }
   
#legend(x='bottomleft', legend=breaks[1:(length(breaks)-1)], pch = 22, pt.bg=cols, title="fishing activity",bg="white",pt.cex=2 )
legend(x=legendx, legend=breaks0[1:(length(breaks0)-1)], pch = 22, pt.bg=cols, title=legendtitle, ncol=legendncol, bg="white",pt.cex=2 )


#to add plotTitle
if (plotTitle != "") mtext(plotTitle)



} #end of mapGrid
