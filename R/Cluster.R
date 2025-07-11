#' Cluster things
#'
#' @param Data S (sample) matrix
#' @param minSamplesPerCluster the minimum number of samples required for a cluster
#'
#' @return A named list of length two. The first element "cluster.list"
#'  is a list of clusters, and the second element "cluster.plot" the 
#'  cluster analysis object (dendogram) that can be plotted.
#' @export
#'
#' @examples
#' Cluster.result <- Cluster(Sm, 14)
#' Cluster.result$cluster.list
#' plot(Cluster.result$cluster.plot)
Cluster <- function(Data, minSamplesPerCluster) {
  
  number_of_Samples <- nrow(Data)
  number_of_Features <- ncol(Data) - 1 
  
  # Warn if minSamplesPerCluster is less than the number of features
  if (minSamplesPerCluster < number_of_Features) {
    warning(sprintf("minSamplesPerCluster (%d) is less than the number of features/pigments (%d). This may lead to poor clustering or errors.", 
                    minSamplesPerCluster, number_of_Features))
  }
  
  # Warn if minSamplesPerCluster exceeds half the total number of samples
  maxAllowed <- floor(number_of_Samples / 2)
  if (minSamplesPerCluster > maxAllowed) {
    stop(sprintf("minSamplesPerCluster (%d) exceeds half of total samples (%d). Clustering may not be meaningful.", 
                    minSamplesPerCluster, maxAllowed))
  }
  
  standardise <- function(Data) {
    b <- Data
    b <- b[, 1:ncol(b) - 1]
    Chl <- Data[, ncol(Data)]
    b[b == 0] <- 1e-6
    b <- b / Chl
    v <- lapply(b, bestNormalize::boxcox)
    return(v)
  }

  v <- standardise(Data)

  L <- length(v)

  ndf <- list()
  for (i in 1:L) {
    ndf[[length(ndf) + 1]] <- data.frame(v[[i]][1])
  }

  S <- Data
  ndf <- do.call("cbind", ndf)
  colnames(ndf) <- colnames(S[, ncol(S) - 1])


  mscluster <- stats::dist(ndf, method = "euclidean")
  mv.hclust <- stats::hclust(mscluster, method = "ward.D2")

  ev.clust <- Data
  # Change the minSamplesPerCluster argument below to adjust how many samples 
  # You might want to play around with it if you want ~ 6 clusters.
  # You could try setting it at 1/6th of the total sample number :)
  dynamicCut <- dynamicTreeCut::cutreeDynamic(mv.hclust,
    cutHeight = 70,
    minClusterSize = minSamplesPerCluster,
    method = "hybrid",
    distM = as.matrix(stats::dist(ndf, method = "euclidean")), 
    deepSplit = 4,
    pamStage = TRUE, 
    pamRespectsDendro = TRUE,
    useMedoids = FALSE, 
    maxDistToLabel = NULL,
    maxPamDist = 50,
    respectSmallClusters = TRUE
  )

  # NULL assignment to stop NOTE during the package "Check"
  #  -  no visible binding for global variable
  Clust <- NULL

  ev.clust$Clust <- dynamicCut

  L2 <- length(unique(ev.clust$Clust))
  L <- list()
  for (i in 1:L2) {
    L[[length(L) + 1]] <- dplyr::filter(ev.clust, Clust == i)
  }

  L

  e <- numeric()
  for (i in 1:length(L)) {
    e[[length(e) + 1]] <- length(L[[i]][[1]])
  }

  return(list(cluster.list = L, cluster.plot = mv.hclust))
}
