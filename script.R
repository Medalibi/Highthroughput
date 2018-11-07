if (!requireNamespace("BiocManager"))
    install.packages("BiocManager")
BiocManager::install(ask=FALSE)
BiocManager::install(c('ggplot2', 'boot', 'matrixStats', 'qqman', 'ggplot', 'moments', 'ggpubr'), ask=FALSE)
