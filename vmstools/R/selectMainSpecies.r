################################################################################
# EXPLORE THE SELECTED SPECIES DEPENDING ON THE METHOD (HAC, TOTALE, LOGEVENT) #
# AND THE THRESHOLD CHOSEN                                                     #
################################################################################



#' Identyfing in an EFLALO dataset which species can be considered as important
#' for the analysis of target species, by crossing three different approaches.
#' 
#' A typical logbook dataset will contain a large number of species recorded,
#' but only a limited number of these could potentially be considered as target
#' species. This function aims thus at identifying these by using three
#' different approaches : - HAC (Hierarchical Ascending Classification) based
#' on Euclidian distances between species with Ward aggregating criteria; -
#' Total, where species are ranked based on their proportion in the total
#' catch, and those cumulating to a given percentage are retained - Logevent,
#' where species are selected if they represent at least a given percentage of
#' the logevent's catch for at least one logevent (one line)
#' 
#' The HAC and the Logevent methods work on catch data transformed in
#' percentage of species by logevent (line), in order to remove the effect of
#' large hauls compared to small hauls. The Total method works on raw data.  In
#' the HAC method, a first group of species, the residual ones, is identified
#' by clustering and using a first-order scree test for cutting the tree.
#' Other species are pooled in the group of principals. New similar HACs are
#' run through a loop on this group of residuals species, to identify if any
#' new species might have been left aside in the first run. It is important to
#' note though that HAC method might quickly reach memory limits on standard
#' PCs, and may thus not be run on very large datasets. In the Total method,
#' the percentage threshold is being increased with 5\% steps from 5 to 100,
#' and the ranked species summing up to this value is recorded.  In the
#' Logevent method, the percentage threshold is also being increased with 5\%
#' steps from 5 to 100, and all species representing at least this value in at
#' least one line are recorded.
#' 
#' This function allows thus to explore the variability and the sensitivity of
#' the definition of key species to differences in concepts and subjective
#' thresholds. A plot showing the number of species retained according to these
#' two criteria is produced, allowing the user to make a qualitative choice
#' when this will be used for identyfing metiers. Empirical experience led us
#' to suggest that the combination of species entering either the HAC, or 95\%
#' of the total cumulated catch, or 100\% of at least one logevent would be
#' sufficient to cover the main target species of a standard logbook dataset,
#' but other choices could be made.
#' 
#' 
#' @param dat a data.frame reduced from an eflalo format. It should contain
#' only the LE_ID (Logevent ID) variable as well as all species names in
#' columns, with raw catch data. It is necessary to sort out potential
#' error-prone lines (such as lines with only 0) prior to the analysis, and to
#' replace NA values by 0.
#' @param analysisName character, the name of the run. Used for the file name
#' of the plots.
#' @param RunHAC Boolean. In case of very large datasets, memory limits might
#' be reached with HAC method. This option allows thus to skip the method and
#' consider species selection using the two other methods only.
#' @param DiagFlag Boolean. If DiagFlag=TRUE, additional plots and diagnostics
#' are produced. Not very used.
#' @return The function produces a plot (saved in the "analysisName" working
#' directory showing the number of species selected according to the method and
#' the percentage threshold selected for both 'Total' and 'Logevent' methods.
#' The function returns also a list of diagnostics of the three methods :
#' \item{nbAllSpecies}{Number of species initially in the dataset }
#' \item{propNbMainSpeciesHAC}{Proportion of the number of species retained by
#' the HAC method to the total number of species }
#' \item{propNbMainSpeciesTotal}{Proportion of the number of species retained
#' by the Total method to the total number of species }
#' \item{propNbMainSpeciesLogevent}{Proportion of the number of species
#' retained by the Logevent method to the total number of species }
#' \item{nbMainSpeciesHAC}{Number of species retained by the HAC method }
#' \item{nbMainSpeciesTotal}{Number of species retained by the Total method
#' with a percentage threshold increasing at 5\% step from 5\% to 100\% }
#' \item{nbMainSpeciesLogevent}{Number of species retained by the Logevent
#' method with a percentage threshold increasing at 5\% step from 5\% to 100\%
#' } \item{namesMainSpeciesHAC}{Names of species retained by the HAC method }
#' \item{namesMainSpeciesTotalAlphabetical}{Names of species retained by the
#' Total method with 95\% threshold in alphabetical order, for easier
#' comparison with the two other methods }
#' \item{namesMainSpeciesTotalByImportance}{Names of species retained by the
#' Total method with 95\% threshold in ranked order of importance }
#' \item{namesMainSpeciesLogevent}{Names of species retained by the Logevent
#' method with 100\% threshold } \item{namesMainSpeciesAll}{Unique combination
#' of the species retained in either HAC method, Total method with 95\%
#' threshold, and Logevent method with 100\% threshold }
#' \item{propCatchMainSpeciesAll}{Proportion of the total catch represented by
#' the selected species (species in namesMainSpeciesAll) }
#' @note A number of libraries are initially called for the whole metier
#' analyses and must be installed :
#' (FactoMineR),(cluster),(SOAR),(amap),(MASS),(mda)
#' @author Nicolas Deporte, Sebastien Demaneche, Stephanie Mahevas (IFREMER,
#' France), Clara Ulrich, Francois Bastardie (DTU Aqua, Denmark)
#' @seealso \code{\link{extractTableMainSpecies}}
#' @references Development of tools for logbook and VMS data analysis. Studies
#' for carrying out the common fisheries policy No MARE/2008/10 Lot 2
#' @examples
#' 
#' 
#' 
#' data(eflalo)
#' 
#' eflalo <- formatEflalo(eflalo)
#' 
#' eflalo <- eflalo[eflalo$LE_GEAR=="OTB",]
#' 
#' # note that output plots will be sent to getwd()
#' analysisName <- "metier_analysis_OTB"
#' 
#' dat <- eflalo[,c("LE_ID",grep("EURO",colnames(eflalo),value=TRUE))]
#' names(dat)[-1] <- unlist(lapply(strsplit(names(dat[,-1]),"_"),function(x) x[[3]]))
#' 
#' explo <- selectMainSpecies(dat, analysisName, RunHAC=TRUE, DiagFlag=FALSE)
#'   #=> send the LE_ID and LE_EURO_SP columns only
#' 
#' @export selectMainSpecies
selectMainSpecies=function(dat,analysisName="",RunHAC=TRUE,DiagFlag=FALSE){

    require(FactoMineR)   # function PCA
    require(cluster)      # functions pam & clara
    require(SOAR)         # function Store
    require(amap)         # function hcluster
    require(MASS)         # function lda
    require(mda)          # function fda

    p=ncol(dat)   # Number of species
    n=nrow(dat)
      
    # Transform quantities to proportions of total quantity caught by logevent
    print("calculating proportions...") 

    propdat=transformation_proportion(dat[,2:p])
    nameSpecies=colnames(propdat)
    nbAllSpecies=ncol(propdat)
    
    t1=Sys.time()           

    if (RunHAC == TRUE) {

      # METHOD : 'HAC'
      
      print("######## SPECIES EXPLORATION METHOD 1: HAC ########")
      # Transposing data
      table_var=table_variables(propdat)
  
      # HAC
      print("cluster...")
      cah_var=hcluster(table_var, method="euclidean", link="ward")
  
      Store(objects())
      gc(reset=TRUE)

      # Select the number of clusters by scree-test
      inerties.vector=cah_var$height[order(cah_var$height,decreasing=TRUE)]
      nb.finalclusters=which(scree(inerties.vector)[,"epsilon"]<0)[1]
  
      if(!is.na(nb.finalclusters)){
        # Dendogram cutting at the selected level
        cah_cluster_var=cutree(cah_var,k=nb.finalclusters)

        png(paste(analysisName,"HAC_Dendogram_Step1.png",sep="_"), width = 1200, height = 800)
        plot(cah_var,labels=FALSE,hang=-1,ann=FALSE)
        title(main="HAC dendogram",xlab="Species",ylab="Height")
        rect.hclust(cah_var, k=nb.finalclusters)
        dev.off()

        temp=select_species(dat[,2:p],cah_cluster_var)
        namesResidualSpecies=nameSpecies[which(cah_cluster_var==temp[[2]])] #list of residual species

        fait=FALSE
        nb_cut=1
        while ((fait == FALSE) && (nb_cut < (p-nb.finalclusters-2))) {
          # cutting below
          print(paste("----------- nb_cut =",nb_cut))
          cah_cluster_var_step=cutree(cah_var,k=(nb.finalclusters+nb_cut))
          # testing residual species
          print(paste("------------- Residual species cluster(s) ",unique(cah_cluster_var_step[namesResidualSpecies])))
          if (length(unique(cah_cluster_var_step[namesResidualSpecies]))==1) {
            print(paste("-------------  No residual cut -----"))
            nb_cut = nb_cut+1 # cutting below
          }else{
            print("-------------  Residual cut -----")
            nbSpeciesClusters=table(cah_cluster_var_step[namesResidualSpecies])
            # testing if a species is alone in a group
            if (sort(nbSpeciesClusters)[1]>1) { # if not alone
              print("------- I stop and have a beer ------")
              fait = TRUE # then I stop
            }else{
              print("------ Updating residual species -----")
              nb_cut = nb_cut+1;  # if alone then cutting below and updating nameResidualSpecies to start again
              numGroupSpeciesAlone = as.numeric(names(sort(nbSpeciesClusters)[1]))
              namesSpeciesAlone = names(cah_cluster_var_step)[which(cah_cluster_var_step==numGroupSpeciesAlone)]
              namesResidualSpecies = namesResidualSpecies[ - which(namesResidualSpecies==namesSpeciesAlone)]
              print(paste("---- Adding new species ---",namesSpeciesAlone))
            }
          }
        } # end of while


        # If all species are selected step by step, the final k is the initial cut (nb.finalclusters)
        if((nb.finalclusters+nb_cut)>=(p-2)){
          kFinal=nb.finalclusters
          cah_cluster_var=cutree(cah_var,k=kFinal)
          temp=select_species(dat[,2:p],cah_cluster_var)
          namesResidualSpecies=nameSpecies[which(cah_cluster_var==temp[[2]])] #list of residual species
        }


        # Dendogram of the first cut in the residual species cluster
        png(paste(analysisName,"HAC_Dendogram_Step1_ResidualSpecies.png",sep="_"), width = 1200, height = 800)
        plot(cah_var,labels=FALSE,hang=-1,ann=FALSE)
        title(main="HAC dendogram - Step",xlab="Species",ylab="Height")
        if((nb.finalclusters+nb_cut)>=(p-2)){
          rect.hclust(cah_var, k=kFinal)
        }else{
          rect.hclust(cah_var, k=(nb.finalclusters+nb_cut))
        }
        dev.off()

        # Selection of main species
        nomespsel=setdiff(nameSpecies,namesResidualSpecies)
        cat("main species : ",nomespsel,"\n")

        # Return the dataset retaining only the main species
        nbMainSpeciesHAC=length(nomespsel)
        namesMainSpeciesHAC=nomespsel
        propNbMainSpeciesHAC=nbMainSpeciesHAC/nbAllSpecies*100

        if(DiagFlag==TRUE) {
          datSpeciesWithoutProp=building_tab_pca(dat[,2:p],nomespsel)
          pourcentCatchMainSpeciesHAC=apply(datSpeciesWithoutProp,1,sum)/apply(dat[,2:p],1,sum)*100
          medianPourcentCatchMainSpeciesHAC=median(pourcentCatchMainSpeciesHAC)
        }

        Store(objects())
        gc(reset=TRUE)

      } else {
         namesMainSpeciesHAC=NA; nbMainSpeciesHAC=as.numeric(NA); medianPourcentCatchMainSpeciesHAC=as.numeric(NA); propNbMainSpeciesHAC=NA
      }
      
  print(Sys.time()-t1)

  }else{ namesMainSpeciesHAC=NA; nbMainSpeciesHAC=as.numeric(NA); medianPourcentCatchMainSpeciesHAC=as.numeric(NA); propNbMainSpeciesHAC=NA }
 
 
    # METHOD : 'TOTALE'
    
    print("######## SPECIES EXPLORATION METHOD 2: 'TOTAL' ########")
    
    # Total quantity caught by species
    sumcol=numeric(length=p-1)
    for(i in 2:p){
      sumcol[i-1]=sum(dat[,i], na.rm=TRUE)
    }
    names(sumcol)=names(dat)[-1]

    # Percent of each species in the total catch
    propesp=sumcol/sum(sumcol,na.rm=TRUE)*100
    # Columns number of each species by decreasing order of capture
    numesp=order(propesp,decreasing=TRUE)
    # Percent of each species in the total catch by cumulated decreasing order
    propesp=cumsum(propesp[order(propesp,decreasing=TRUE)])

    # We are taking all species until having at least seuil% of total catch
    nbMainSpeciesTotal=numeric()
    medianPourcentCatchMainSpeciesTotal=numeric()

    for(seuil in seq(5,100,5)){
      cat("seuil:",seuil,"\n")
      pourcent=which(propesp<=seuil)
      # We are taking the name of selected species
      espsel=numesp[1:(length(pourcent)+1)]
      nomespsel=nameSpecies[espsel]
      nbMainSpeciesTotal[seuil/5]=length(nomespsel)

      if(DiagFlag==TRUE) {
        # We are building the table with main species and aggregated other species
        datSpeciesWithoutProp=building_tab_pca(dat[,2:p],nomespsel)
        if(length(nomespsel)==1){
          vectorNul=rep(0,n)
          datSpeciesWithoutProp=cbind(datSpeciesWithoutProp,vectorNul)
        }
        pourcentCatchMainSpeciesTotal=apply(datSpeciesWithoutProp,1,sum, na.rm=TRUE)/apply(dat[,2:p],1,sum, na.rm=TRUE)*100
        medianPourcentCatchMainSpeciesTotal[seuil/5]=median(pourcentCatchMainSpeciesTotal)
      }
    }
    nbMainSpeciesTotal=c(0,nbMainSpeciesTotal)
    nbMainSpeciesTotal[length(nbMainSpeciesTotal)]=p-1
    namesMainSpeciesTotal=nomespsel[1:nbMainSpeciesTotal[length(nbMainSpeciesTotal)-1]]
    propNbMainSpeciesTotal=nbMainSpeciesTotal[length(nbMainSpeciesTotal)-1]/nbAllSpecies*100
    
    if (DiagFlag) medianPourcentCatchMainSpeciesTotal=c(0,medianPourcentCatchMainSpeciesTotal)

    Store(objects())
    gc(reset=TRUE)
      
    print(Sys.time()-t1)



    # METHOD : 'LOGEVENT'
    
    print("######## SPECIES EXPLORATION METHOD 3: 'LOGEVENT' ########")
    
    nbMainSpeciesLogevent=numeric()
    medianPourcentCatchMainSpeciesLogevent=numeric()

    for(seuil in seq(5,100,5)){
      cat("seuil:",seuil,"\n")
      nomespsel=character()
      # We are taking all species with a % of catch >= seuil% for at least one logevent
      for (i in nameSpecies) if (!is.na(any(propdat[,i]>=seuil)) && any(propdat[,i]>=seuil)) nomespsel <- c(nomespsel,i)
      nbMainSpeciesLogevent[seuil/5]=length(nomespsel)
   
      # We are building the table with main species and aggregated other species
      if(DiagFlag==TRUE) {
        datSpeciesWithoutProp=building_tab_pca(dat[,2:p],nomespsel)
        if(length(nomespsel)==1){
          vectorNul=rep(0,n)
          datSpeciesWithoutProp=cbind(datSpeciesWithoutProp,vectorNul)
        }
        pourcentCatchMainSpeciesLogevent=apply(datSpeciesWithoutProp,1,sum)/apply(dat[,2:p],1,sum)*100
        medianPourcentCatchMainSpeciesLogevent[seuil/5]=median(pourcentCatchMainSpeciesLogevent)
      }
    }
    nbMainSpeciesLogevent=c(p-1,nbMainSpeciesLogevent)
    namesMainSpeciesLogevent=nomespsel
    propNbMainSpeciesLogevent=nbMainSpeciesLogevent[length(nbMainSpeciesLogevent)]/nbAllSpecies*100
    
    
    if(DiagFlag) medianPourcentCatchMainSpeciesLogevent=c(100,medianPourcentCatchMainSpeciesLogevent)

    print(Sys.time()-t1)

    # GRAPHICS

    # Number of main species
    X11(5,5)
    plot(seq(0,100,5),nbMainSpeciesTotal,type='l',col="blue",lwd=3, axes=FALSE, xlab="Threshold (%)",ylab="Number of species")
    lines(seq(0,100,5),nbMainSpeciesLogevent,col="green",lwd=3)
    if(!is.na(nbMainSpeciesHAC)) segments(0,nbMainSpeciesHAC,100,nbMainSpeciesHAC,col="red",lwd=3)
    axis(1)
    axis(2, las=2)
    box()
    legend(20, p*0.9, c( "HAC", "PerTotal", "PerLogevent"),lwd=3,col=c("red", "blue", "green"),bty="n")
    savePlot(filename = paste(analysisName,'Number of main species',sep="_"),type ="png")
    dev.off()

    X11(5,5)
    plot(seq(0,100,5),nbMainSpeciesTotal,type='l',col="blue",lwd=3, axes=FALSE, xlab="Threshold (%)",ylab="Number of species")
    lines(seq(0,100,5),nbMainSpeciesLogevent,col="green",lwd=3)
    if(!is.na(nbMainSpeciesHAC)) segments(0,nbMainSpeciesHAC,100,nbMainSpeciesHAC,col="red",lwd=3)
    axis(1)
    axis(2, las=2)
    box()
    legend(20, p*0.9, c( "HAC", "PerTotal", "PerLogevent"),lwd=3,col=c("red", "blue", "green"),bty="n")
    savePlot(filename = paste(analysisName,'Number of main species',sep="_"),type ="png")
    dev.off()

    # Black and white version
    X11(5,5)
    plot(seq(0,100,5),nbMainSpeciesTotal, type='l' ,lty='dashed', col="black",lwd=3, axes=FALSE, xlab="Threshold (%)",ylab="Number of species")
    lines(seq(0,100,5),nbMainSpeciesLogevent, type='l', lty='dotted', col="black",lwd=3)
    if(!is.na(nbMainSpeciesHAC)) segments(0,nbMainSpeciesHAC,100,nbMainSpeciesHAC,col="black",lwd=3)
    axis(1)
    axis(2, las=2)
    box()
    legend(20, p*0.9, c( "HAC", "PerTotal", "PerLogevent"),lwd=3,col=c("black", "black", "black"),bty="n",lty=c('solid','dashed','dotted'),box.lty = par("lty"))
    savePlot(filename = paste(analysisName,'Number of main species_new_2',sep="_"),type ="png")
    dev.off()

    # Median percentage of catch represented by main species by logevent
    if(DiagFlag){
      png(paste(analysisName,"Median percentage of catch represented by main species by logevent.png",sep="_"), width = 1200, height = 800)
      plot(seq(0,100,5),medianPourcentCatchMainSpeciesTotal,type='l',col="blue",lwd=2, main="Median percentage of catch represented by main species by logevent depending of the threshold", xlab="Threshold (%)",ylab="Median percentage of catch represented by main species by logevent")
      lines(seq(0,100,5),medianPourcentCatchMainSpeciesLogevent,col="green",lwd=2)
      if (RunHAC==TRUE) abline(medianPourcentCatchMainSpeciesHAC,0, col="red",lwd=2)
      mtext(paste(p-1," Species"),col='darkblue')
      if (RunHAC==TRUE) legend(70, 40, c("HAC", "Total", "Logevent"),lwd=2,col=c("red", "blue", "green"))
      if (RunHAC==FALSE) legend(70, 40, c("Total", "Logevent"),lwd=2,col=c("blue", "green"))
      dev.off()
    }
    
    listSpecies=sort(unique(c(namesMainSpeciesHAC,namesMainSpeciesTotal,namesMainSpeciesLogevent)))

    # Proportion of the total catch represented by the species in listSpecies (= namesMainSpeciesAll)
    catchListSpecies=sumcol[listSpecies]
    propCatchListSpecies=sum(catchListSpecies)/sum(sumcol)*100
    

    if(DiagFlag==FALSE) { 
      explo_species = list(nbAllSpecies=nbAllSpecies,
                            propNbMainSpeciesHAC=propNbMainSpeciesHAC,
                            propNbMainSpeciesTotal=propNbMainSpeciesTotal,
                            propNbMainSpeciesLogevent=propNbMainSpeciesLogevent,
                            nbMainSpeciesHAC=nbMainSpeciesHAC, 
                            nbMainSpeciesTotal=nbMainSpeciesTotal, 
                            nbMainSpeciesLogevent=nbMainSpeciesLogevent,
                            namesMainSpeciesHAC=sort(namesMainSpeciesHAC), 
                            namesMainSpeciesTotalAlphabetical=sort(namesMainSpeciesTotal),                                             
                            namesMainSpeciesTotalByImportance=namesMainSpeciesTotal,
                            namesMainSpeciesLogevent=sort(namesMainSpeciesLogevent),
                            namesMainSpeciesAll=listSpecies,
                            propCatchMainSpeciesAll=propCatchListSpecies) 
    }else{         
      explo_species = list(nbAllSpecies=nbAllSpecies,
                            propNbMainSpeciesHAC=propNbMainSpeciesHAC,
                            propNbMainSpeciesTotal=propNbMainSpeciesTotal,
                            propNbMainSpeciesLogevent=propNbMainSpeciesLogevent,
                            nbMainSpeciesHAC=nbMainSpeciesHAC, 
                            nbMainSpeciesTotal=nbMainSpeciesTotal, 
                            nbMainSpeciesLogevent=nbMainSpeciesLogevent,
                            namesMainSpeciesHAC=sort(namesMainSpeciesHAC), 
                            namesMainSpeciesTotalAlphabetical=sort(namesMainSpeciesTotal),                                             
                            namesMainSpeciesTotalByImportance=namesMainSpeciesTotal,
                            namesMainSpeciesLogevent=sort(namesMainSpeciesLogevent),
                            namesMainSpeciesAll=listSpecies,
                            medianPourcentCatchMainSpeciesHAC=median(pourcentCatchMainSpeciesHAC),
                            medianPourcentCatchMainSpeciesTotal=medianPourcentCatchMainSpeciesTotal,
                            medianPourcentCatchMainSpeciesLogevent=medianPourcentCatchMainSpeciesLogevent,
                            propCatchMainSpeciesAll=propCatchListSpecies)
    }    

    return(explo_species)
    
}
