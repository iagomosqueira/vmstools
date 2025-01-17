###########################################################################
#   DETERMINE M�TIERS LEVEL 7 AND 5 WITH TWO ORDINATION METHODS           #
#   (FIRST SPECIES IN CATCH AND FIRST GROUP OF SPECIES IN CATCH)          #
#                                                                         #
#   DETERMINE M�TIERS LEVEL5 FROM M�TIERS LEVEL7 FOUND WITH THE           #
#   MULTIVARIATE CLASSIFICATION (DETERMINING THE TARGET SPECIES           #
#   FOR EACH CLUSTER)                                                     #
#                                                                         #
#   COMPARE THE M�TIERS FOUND WITH THE ORDINATION METHODS AND             #
#   WITH THE MULTIVARIATE CLASSIFICATION                                  #
###########################################################################  
  


#' Compare the metiers found with the classification from clustering e.g. CLARA
#' against the metiers found by two simple alternative ordination methods:
#' 'first species' & 'first group'.
#' 
#' This function allows to compare the metiers found using the classification
#' from clustering against the metiers found by two alternative ordination
#' methods, 'first species' and 'first group'.
#' 
#' The 'first species' method consists of characterizing the level 7 of each
#' logevent by the species with the highest catch.  Then, the level 5 is
#' deduced from the target assemblage of species for which this species belongs
#' to.
#' 
#' The 'first group' method alternatively assigns a level 5 to each logevent
#' correponding to the target assemblage having the highest catch volume.
#' 
#' The classification from clustering defines level 7 metiers for which each
#' metier is characterized by one or several species, called target species,
#' unlike the metiers from the simpler ordination methods. Hence, mixed metiers
#' can be obtained in case that these species belong to different target
#' assemblages.
#' 
#' This function enlights the differences when defining the metiers between the
#' classification from clustering and the simpler ordination methods, and
#' potentially demonstrates the higher power of the data clustering method in
#' obtaining exhaustive and accurately defined metiers.
#' 
#' 
#' @param dat a reduced data.frame from an eflalo format. It should contain
#' only the LE_ID (Logevent ID) variable as well as all species names in
#' columns, with raw catch data. It may be needed to sort out potential
#' error-prone rows (such as rows with only 0) prior to the analysis, and to
#' also replace NA values by 0.
#' @param Step2 numerical matrix with logevents as rows, and values to be used
#' for calculating distances between individuals as columns. This matrix is
#' produced at the step 2 of the metier analysis, output of the function
#' getTableAfterPCA().  In case a PCA is run, the selected axes will appear as
#' columns. If no PCA is run, the matrix will be the same as datSpecies
#' (produced at the step 1 of the metier analysis, using the function
#' extractTableMainSpecies()), with percentage values by species.
#' @param clusters the vector storing the cluster label of each logbook event.
#' This vector will be produced at the step 3 of the metier analysis, using the
#' function getMetierClusters().
#' @param targetSpecies a list giving the target species by cluster. This list
#' will be produced at the step 3 of the metier analysis, using the function
#' getMetierClusters().
#' @return The function returns a list with a number of tables on the
#' comparison of the three methods: \item{nbLogFirstSp}{An integer vector
#' giving the number of logevents allocated to each metier (level 7) defined by
#' the ordination method 'first species'. }
#' \item{compClustersL7vsFirstSpeciesL7}{A table giving the distribution of the
#' logevents of each metier (level 7) defined by the multivariate
#' classification in the metiers (level 7) defined by the ordination method
#' 'first species'. } \item{compClustersL5vsFirstSpeciesL5}{A table giving the
#' distribution of the logevents of each metier (level 5) defined by the
#' multivariate classification in the metiers (level 5) defined by the
#' ordination method 'first species'. } \item{compClustersL5vsFirstGroupL5}{A
#' table giving the distribution of the logevents of each metier (level 5)
#' defined by the multivariate classification in the metiers (level 5) defined
#' by the ordination method 'first group'. }
#' \item{compFirstSpeciesL5vsFirstGroupL5}{A table giving the distribution of
#' the logevents of each metier (level 5) defined by the ordination method
#' 'first species' in the metiers (level 5) defined by the ordination method
#' 'first group'. } \item{compClustersL5vsClustersL7}{A table giving the
#' distribution of the logevents of each metier (level 5) defined by the
#' multivariate classification in the metiers (level 7) defined by the
#' multivariate classification. }
#' @note A number of libraries are initially called for the whole metier
#' analyses and must be installed :
#' (FactoMineR),(cluster),(SOAR),(amap),(MASS),(mda)
#' @author Nicolas Deporte, Sebastien Demaneche, Stephanie Mahevas (IFREMER,
#' France), Clara Ulrich, Francois Bastardie (DTU Aqua, Denmark)
#' @seealso \code{\link{getEflaloMetierLevel7}},
#' \code{\link{selectMainSpecies}}, \code{\link{extractTableMainSpecies}},
#' \code{\link{getMetierClusters}}, \code{\link{getTableAfterPCA}},
#' \code{\link{getMetierClusters}}
#' @references Development of tools for logbook and VMS data analysis. Studies
#' for carrying out the common fisheries policy No MARE/2008/10 Lot 2
#' @examples
#' 
#' 
#'   
#'   
#'   \dontrun{
#'   
#'   data(eflalo)
#'   
#'   eflalo <- formatEflalo(eflalo)
#' 
#'   eflalo <- eflalo[eflalo$LE_GEAR=="OTB",]
#' 
#'   # note that output plots will be sent to getwd()
#'   analysisName <- "metier_analysis_OTB"
#'   
#'   dat <- eflalo[,c("LE_ID",grep("EURO",colnames(eflalo),value=TRUE))]
#'   names(dat)[-1] <- unlist(lapply(strsplit(names(dat[,-1]),"_"),function(x) x[[3]]))
#' 
#'   explo <- selectMainSpecies(dat, analysisName, RunHAC=TRUE, DiagFlag=FALSE)
#'     #=> send the LE_ID and LE_KG_SP columns only
#'            
#'   Step1 <- extractTableMainSpecies(dat, explo$NamesMainSpeciesHAC,
#'               paramTotal=95, paramLogevent=100)
#'     #=> send the LE_ID and LE_KG_SP columns only             
#' 
#'   rowNamesSave <- row.names(Step1)
#'   row.names(Step1) <- 1:nrow(Step1)
#'   
#'   # Run a PCA
#'   Step2 <- getTableAfterPCA(Step1, analysisName,
#'               pcaYesNo="pca", criterion="70percents")
#' 
#'   row.names(Step1) <- rowNamesSave
#'   row.names(Step2) <- rowNamesSave
#' 
#'   # Define a metier for each logevent running the CLARA algorithm 
#'   Step3 <- getMetierClusters(Step1, Step2, analysisName,
#'               methMetier="clara", param1="euclidean", param2=NULL)
#'   
#'   # Compare the differences between the metiers defined by CLARA
#'   # and the metiers defined by two simple ordination methods
#'   compMetiers <- compareToOrdination(dat, Step2,
#'                     clusters=Step3$clusters$clustering,
#'                     targetSpecies=Step3$targetSpecies)
#'     #=> send the LE_ID and LE_KG_SP columns only             
#' 
#'   }
#'   
#' 
#' @export compareToOrdination
compareToOrdination=function(dat, Step2, clusters, targetSpecies){

  # Load the table linking 3A-CODE (FAO CODE of species) to the species assemblage (level 5).
  data(correspLevel7to5)
  
  # Load the table linking mixed metiers (composed by 2 simple metiers) to their official code of mixed metiers level 5 (FAO - 3 characters).
  data(correspMixedMetier)
  
  
  ##########################
  # FIRST SPECIES IN CATCH #
  ##########################
  
  dat=as.matrix(dat[,2:ncol(dat)])
  p=ncol(dat)
  firstSp=list()
  nbLogFirstSp=list()

  # Determine the first species for each logevent (the catchest species of the logevent)
  firstSp=apply(dat,1,function(x) names(which.max(x)))
  metiersFirstSpeciesL7=firstSp
  
  # Calculate the number of logevent by first species (number of logevents by cluster)
  nbLogFirstSp=sapply(unique(unlist(firstSp)),function(x) table(firstSp==x)[2])

  names(nbLogFirstSp)=substr(names(nbLogFirstSp),1,3)
  
  # Number of logevents linked to each species from the method "first species in catch"
  png("Number of logevents by ordination metier level7.png", width = 1200, height = 800)
  barplot(nbLogFirstSp[order(nbLogFirstSp,decreasing=TRUE)], main="Number of logevents by ordination metier level7", xlab="Main species", ylab="Number of Logevents", las=3)
  dev.off()
  # idem without the species with the biggest number of logevents
  png(paste("Number of logevents by ordination metier level7 without ",names(nbLogFirstSp[order(nbLogFirstSp,decreasing=TRUE)])[1],".png",sep=""), width = 1200, height = 800)
  barplot(nbLogFirstSp[order(nbLogFirstSp,decreasing=TRUE)][-1], main=paste("Number of logevents by ordination metier level7 without",names(nbLogFirstSp[order(nbLogFirstSp,decreasing=TRUE)])[1],sep=" "), xlab="Main species", ylab="Number of Logevents", las=3)
  dev.off()
                                  
  
  # Names of species from the ordination method
  nomEspOrdi=names(nbLogFirstSp)
  nbEspOrdi=length(nomEspOrdi)
  nomEspOrdi=nomEspOrdi[order(nomEspOrdi,decreasing=FALSE)]
  # Initialization
  numEspOrdiClarai=numeric()
  nomEspOrdiPlot=character()
  nbLogEspOrdiPlot=numeric()
  nbClust=length(unique(clusters))
  
  # For each cluster Clara
  for(i in 1:nbClust){
    # Names of species from ordination method linked to the logevents of cluster Clara i
    nomEspOrdiClarai=unique(unlist(firstSp[which(clusters==i)]))
    # their number
    numEspOrdiClarai=sapply(nomEspOrdiClarai, function(x) which(nomEspOrdi==x))
    
    # Names of species to plot in the barplot of cluster i
    nomEspOrdiPloti=rep("",nbEspOrdi)
    nomEspOrdiPloti[numEspOrdiClarai]=nomEspOrdiClarai
    nomEspOrdiPlot=rbind(nomEspOrdiPlot,nomEspOrdiPloti)
    
    # for the cluster i, number of logevents of cluster i linked to each species from ordination method
    nbLogEspOrdiPloti=rep(0,nbEspOrdi)
    nbLogEspOrdiPloti[numEspOrdiClarai]=sapply(nomEspOrdiClarai,function(x) rev(table(firstSp[which(clusters==i)]==x))[1])
    nbLogEspOrdiPlot=rbind(nbLogEspOrdiPlot,nbLogEspOrdiPloti)
  }
  colnames(nbLogEspOrdiPlot)=names(nbLogFirstSp)[order(names(nbLogFirstSp))]
  rownames(nbLogEspOrdiPlot)=paste("nbLogFirstSpCluster",seq=1:nbClust,sep="")
  
  # Graphics
  png("Ordination_metiersL7_by_cluster.png", width = 1200, height = 800)
  op <- par(mfrow=c(ceiling(sqrt(nbClust)),round(sqrt(nbClust))))
  for(i in 1:nbClust){
    op2 <- par(las=2)
    barplot(nbLogEspOrdiPlot[i,],names.arg=nomEspOrdiPlot[i,], las=3)
    par(op2)
    mtext(paste("Cluster",i), side=3, outer=FALSE, adj=0.5, line=0.5, col="darkblue")
  }
  par(op)
  title(main=paste("Number of logevents linked to each metier from the ordination method 'first species' by cluster","\n","\n",sep=""))
  dev.off()
  
  # Projections on the first factorial plans
  nomEspOrdi=substr(names(nbLogFirstSp),1,3)
  espOrdi=matrix()
  espOrdi=rbind(names(nbLogFirstSp),seq(1:length(nbLogFirstSp)))
  numFirstSp=firstSp
  for(i in 1:length(nbLogFirstSp)){
    numFirstSp[which(firstSp==nomEspOrdi[i])]=espOrdi[2,which(espOrdi[1,]==nomEspOrdi[i])]
  }

  # Projections on the first factorial plans
  png("Ordination_Projections.png", width = 1200, height = 800)
  op <- par(mfrow=c(2,3))
  plot(Step2[,1], Step2[,2], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 1-2", xlab="axis 1", ylab="axis 2")
  plot(Step2[,2], Step2[,3], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 2-3", xlab="axis 2", ylab="axis 3")
  plot(Step2[,1], Step2[,3], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 1-3", xlab="axis 1", ylab="axis 3")
  plot(Step2[,1], Step2[,4], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 1-4", xlab="axis 1", ylab="axis 4")
  plot(Step2[,2], Step2[,4], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 2-4", xlab="axis 2", ylab="axis 4")
  plot(Step2[,3], Step2[,4], pch=21, bg=rainbow(length(nbLogFirstSp))[as.numeric(numFirstSp)], main="Projection of the classification by ordination on the factorial plan 3-4", xlab="axis 3", ylab="axis 4")
  par(op)
  dev.off()
  
  
  # Determine the metier level 5 from the metier level 7 based on the first species in catch (logevent by logevent)
  print("Please, be patient...") 
  metiersFirstSpeciesL5=lapply(as.list(firstSp), function(x) if(length(which(correspLevel7to5[,"X3A_CODE"]==x))==0){print(paste(x," : unknown species, classed in \'FIF\' group",sep=""));"FIF"} 
                                                    else correspLevel7to5[which(correspLevel7to5[,"X3A_CODE"]==x),"DCF_species_level5_COD"])
  metiersFirstSpeciesL5=unlist(lapply(metiersFirstSpeciesL5, function(x) as.character(x)))
   
   
   
                                      
  ###################################
  # FIRST GROUP OF SPECIES IN CATCH #
  ###################################
  
  # Determine the metier of each logevent thanks to the first group of species in catch (level 5) of the logevent
  datL5=dat
  groupColSpecies=lapply(as.list(colnames(datL5)), function(x) if(length(which(correspLevel7to5[,"X3A_CODE"]==x))==0){print(paste(x," : unknown species, classed in \'FIF\' group",sep=""));"FIF"} 
                                                               else correspLevel7to5[which(correspLevel7to5[,"X3A_CODE"]==x),"DCF_species_level5_COD"])  
  groupColSpecies=unlist(lapply(groupColSpecies, function(x) as.character(x)))
  colnames(datL5)=groupColSpecies
  nbC5=length(unique(colnames(datL5)))
  tab=matrix(NA,nrow=nrow(datL5),ncol=nbC5)
  colnames(tab)=unique(colnames(datL5))
  for(i in 1:nbC5){
    # Sub-data containing only one metier level 5.
    subdati=datL5[,which(colnames(datL5)==(unique(colnames(datL5))[i]))]
    if(length(which(colnames(datL5)==(unique(colnames(datL5))[i])))==1) tab[,i]=subdati
    else
      tab[,i]=apply(subdati,1,sum)
  }
  # Metiers (level 5) of each logevent found thanks to the first group of species in catch (level 5)
  metiersFirstGroupL5=unique(colnames(datL5))[apply(tab,1,which.max)]
  
  


  
  
  ###############################################################
  # LEVELS 7 AND 5 FOR METIERS FROM MULTIVARIATE CLASSIFICATION #
  ###############################################################

  # List of metiers (level 5.7)
  listMetiersLevel57=list()
  for (i in 1:nbClust){
    metiersClusteri=lapply(targetSpecies[[i]], function(x) if(length(which(correspLevel7to5[,"X3A_CODE"]==x))==0){print(paste(x," : unknown species, classed in \'FIF\' group",sep=""));"FIF"}
                                                        else correspLevel7to5[which(correspLevel7to5[,"X3A_CODE"]==x),"DCF_species_level5_COD"])
    metiersClusteri=as.character(unique(unlist(metiersClusteri)))
    metiersClusteri=paste(unlist(strsplit(metiersClusteri," ")),collapse=" ")
    listMetiersLevel57[[i]]=metiersClusteri
  }
  
  # Metiers (level 5.7) of each logevent found thanks to the getMetierClusters method 
  #(where mixed metiers labels are the aggregation of several simple metiers labels).
  metiersClustersL5=unlist(sapply(clusters,function(x) listMetiersLevel57[x]))


  # Correspondence of mixed metiers (composed by 2 simple metiers) to their official code of mixed metiers level 5 (FAO - 3 characters). 
  listMixedMetiersLevel57=lapply(listMetiersLevel57, function(x) if(nchar(x)!=3 & is.element(x,correspMixedMetier[,1])){correspMixedMetier[which(correspMixedMetier[,"combMetiersL5"]==x),"mixedMetierL5"]}
                                            else x )
                                            
  # Metiers (level 5.7) of each logevent found thanks to the getMetierClusters method (with official labels for mixed metiers).                                         
  mixedMetiersClustersL5=unlist(sapply(clusters,function(x) listMixedMetiersLevel57[x]))

  


  
  #################
  #  COMPARISONS  # 
  #################
  
  # Compare the metiers 'Clusters' (from getMetierClusters) (level 7) vs the metier 'First Species' in catch (level 7)
  compClustersL7vsFirstSpeciesL7=table(clusters,metiersFirstSpeciesL7)
  rownames(compClustersL7vsFirstSpeciesL7)=paste("Clust",seq=1:nbClust,sep="")
  
  # Compare the metiers 'Clusters' (level 5.7) vs the metiers 'First Species' (level 5)
  clustStep3L5=clusters
  compClustersL5vsFirstSpeciesL5=table(clustStep3L5,metiersFirstSpeciesL5)    
  rownames(compClustersL5vsFirstSpeciesL5)=unlist(listMixedMetiersLevel57) 
  
  # Compare the metiers 'Clusters' (level 5.7) vs the metiers 'First Group' (level 5)
  #compL5ClustStep3VsGroup=table(clustersStep3L5,metiersFirstGroupL5)  !! pb regroupement des clusters qui correspondent au m�me groupe d'esp�ce niveau 5.
  clustStep3L5=clusters
  compClustersL5vsFirstGroupL5=table(clustStep3L5,metiersFirstGroupL5)
  rownames(compClustersL5vsFirstGroupL5)=unlist(listMixedMetiersLevel57)
  
  # Compare the metiers 'First Species' (level 5) vs the metiers 'First Group' (level 5)
  compFirstSpeciesL5vsFirstGroupL5=table(metiersFirstSpeciesL5,metiersFirstGroupL5)
  
  
  # Less attractive
  # Compare the metiers 'Clusters' (level 5.7) vs the metiers 'Clusters' (level 7)
  clustStep3L7=clusters
  compClustersL5vsClustersL7=table(mixedMetiersClustersL5,clustStep3L7)    
  colnames(compClustersL5vsClustersL7)=paste("Clust",seq=1:nbClust)
  
  
           
  # Create csv tables
  dfTables=data.frame()
  dfTables=c("compClustersL7vsFirstSpeciesL7","compClustersL5vsFirstSpeciesL5",
  "compClustersL5vsFirstGroupL5","compFirstSpeciesL5vsFirstGroupL5","compClustersL5vsClustersL7")
  write.table(dfTables[1],file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(compClustersL7vsFirstSpeciesL7,file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(dfTables[2],file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(compClustersL5vsFirstSpeciesL5,file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(dfTables[3],file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(compClustersL5vsFirstGroupL5,file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(dfTables[4],file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(compFirstSpeciesL5vsFirstGroupL5,file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(dfTables[5],file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
  write.table(compClustersL5vsClustersL7,file="tablesCompToOrdination.csv",append=TRUE,col.names=NA)
      
  print("Done.")
  
  return(list(nbLogFirstSp=nbLogFirstSp, 
    compClustersL7vsFirstSpeciesL7=compClustersL7vsFirstSpeciesL7, 
    compClustersL5vsFirstSpeciesL5=compClustersL5vsFirstSpeciesL5,
    compClustersL5vsFirstGroupL5=compClustersL5vsFirstGroupL5,
    compFirstSpeciesL5vsFirstGroupL5=compFirstSpeciesL5vsFirstGroupL5,
    compClustersL5vsClustersL7=compClustersL5vsClustersL7))
}
